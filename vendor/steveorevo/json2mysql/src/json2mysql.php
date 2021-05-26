<?php
/**
 * JSON2MySQL Class and command line tool.
 */

// Resolve autoloader
foreach ([__DIR__ . '/../../../autoload.php', __DIR__ . '/../vendor/autoload.php'] as $file) {
  if (file_exists($file)) {
      require $file;
      break;
  }
}

class JSON2MySQL {
  public $version = "2.1.0"; // TODO: obtain via composer
  public $climate = NULL;
  public $jsonDB = NULL;
  public $dbNames = [];
  public $dbName = "";
  public $db;

  const SEPARATOR = "\f~\v";

  /**
   * Create our JSON2MySQL object
   */
  function __construct() {
 
  }

  /**
   * Process the command line interface arguments
   */
  function cli() {
    $composer = json_decode(file_get_contents(__DIR__ . "/../composer.json"));
    $this->climate = new League\CLImate\CLImate;
    $this->climate->description( $composer->description . "\nVersion " . $this->version);
    $this->climate->arguments->add([
      'help' => [
        'prefix'       => '?',
        'longPrefix'   => 'help',
        'description'  => 'print this help',
        'noValue'      => true,
      ],
      'host' => [
        'prefix'       => 'h',
        'longPrefix'   => 'host',
        'description'  => 'host name or IP address (default: localhost)',
        'defaultValue' => 'localhost',
      ],
      'list' => [
        'prefix'      => 'l',
        'longPrefix'  => 'list',
        'description' => 'list tables available for import',
        'noValue'     => true,
      ],
      'password' => [
        'prefix'       => 'p',
        'longPrefix'   => 'password',
        'description'  => 'password to connect with (default is none)',
        'defaultValue' => '',
      ],
      'port' => [
        'prefix'      => 'P',
        'longPrefix'  => 'port',
        'description' => 'the TCP/IP port number to connect to',
        'castTo'      => 'int',
      ],
      'skip_create' => [
        'prefix'      => 's',
        'longPrefix'  => 'skip',
        'description' => 'skip dropping/creating of existing database',
        'noValue'     => true,
      ],
      'tables' => [
        'prefix'       => 't',
        'longPrefix'   => 'tables',
        'description'  => 'a comma delimited list of tables (default empty for all)',
        'defaultValue' => '',
      ],
      'user' => [
        'prefix'       => 'u',
        'longPrefix'   => 'user',
        'description'  => 'username to connect as (default: root)',
        'defaultValue' => 'root',
      ],
      'quiet' => [
        'prefix'       => 'q',
        'longPrefix'   => 'quiet',
        'description'  => 'quiet (no output and default question to yes)',
        'noValue'      => true,
      ],
      'version' => [
        'prefix'       => 'v',
        'longPrefix'   => 'version',
        'description'  => 'output version number',
        'noValue'      => true,
      ],
      'dbname' => [
        'prefix'       => 'd',
        'longPrefix'   => 'dbname',
        'description'  => 'override, create/import using specified database name',
        'defaultValue' => '',
      ],
      'json_file' => [
        'description'  => 'the json file to import'
      ]
    ]);
    $this->climate->arguments->parse();
    if (! $this->climate->arguments->defined("help")) {
      $this->showVersion();
      $this->doListing();
      $this->importJSON();  
    }
    $this->climate->usage();
  }

  /**
   * Import a JSON representation of the given database and tables
   */
  function importJSON() {
    $this->parseJSONFile();
    $this->getDBNames();

    // Prompt for database overwrite
    if (! $this->climate->arguments->defined('quiet')) {
      if (FALSE !== in_array($this->dbName, $this->dbNames)) {
        if (! $this->climate->arguments->defined('skip_create')) {
          $input = $this->climate->confirm("Database " . $this->dbName . " exists. Use --skip_create option to preserve database. Overwrite (destroy) existing?");
          if (!$input->confirmed()) {
              exit();
          }
        }
      }
    }

    $this->connectToDB();

    // Create (drop any existing) database definition
    if (! $this->climate->arguments->defined('skip_create')) {
      $sql = "DROP DATABASE IF EXISTS `" . $this->dbName . "`;\n";
      if ($this->db->query($sql) !== TRUE) {
          echo "Error, dropping database: " . $this->db->error;
          exit();
      }
      $create = $this->jsonDB['create'];
      
      if ($this->jsonDB['name'] != $this->dbName) {
        $create = str_replace($this->jsonDB['name'], $this->dbName, $create);
      }
      $sql =  $create . ";\n";
      if ($this->db->query($sql) !== TRUE) {
        echo "Error, creating database: " . $this->db->error;
        exit();
      } 
    }

    // Always use specified database
    $sql = "USE `" . $this->dbName . "`;\n";
    if ($this->db->query($sql) !== TRUE) {
      echo "Error, using database: " . $this->db->error;
      exit();
    } 

    // Create tables and import data
    foreach($this->jsonDB['tables'] as $table) {

      // Check for implicit tables or default to all
      $bSkip = false;
      if ($this->climate->arguments->defined('tables')) {
        $t = ',' . $this->climate->arguments->get('tables') . ',';
        if (FALSE === strpos($t, "," . $table['name'] . ",")) {
          $bSkip = true;
        }
      }
      if (FALSE === $bSkip) {
        $sql = $table['create'];
        if ($this->db->query($sql) !== TRUE) {
          echo "Error, creating table: " . $this->db->error;
          exit();
        }
  
        // Import data
        $last = round(microtime(true) * 1000);
        $spin = 0;
        foreach($table['data'] as $row) {
          $sql = "INSERT INTO " . $table['name'] . " (";
          $vals = "(";
          foreach($table['columns'] as $col) {
            $sql = $sql . $col['name'] . ',';
            $v = $row[$col['name']];
            if (NULL !== $v) {
              if ($col['json_type'] === 'string' || $col['json_type'] === 'object') {
                if ($col['json_type'] === 'string' || gettype($v) == 'string') {
                  $vals = $vals . '"' . mysqli_real_escape_string($this->db, $v) . '",';
                }else{
                  $vals = $vals . '"' . mysqli_real_escape_string($this->db, serialize($v)) . '",';
                }
              }else{
                if ($col['json_type'] === 'number') {
                  $vals = $vals . strval($v) . ',';
                }else{
                  if ($v) { // Boolean
                    $vals = $vals . 'true' . ',';
                  }else{
                    $vals = $vals . 'false' . ',';
                  }
                }
              }
            }else{
              $vals = $vals . 'NULL' . ',';
            }
          }
          $sql = new Steveorevo\GString($sql);
          $sql = $sql->delRightMost(",")->concat(") VALUES " . $vals);
          $sql = $sql->delRightMost(",")->concat(");\n");
          if ($this->db->query($sql) !== TRUE) {
            echo "Error, insert into table: " . $table['name'] . "\n";
            echo $sql . "\n";
            var_dump($this->db);
            exit();
          }
          if (! $this->climate->arguments->defined('quiet')) {
  
            // Spin the cursor
            if ((round(microtime(true) * 1000) - 100) > $last) {
              $last = round(microtime(true) * 1000);
              echo chr(8);
              if ($spin == 0 || $spin == 4) {
                echo "|";
              } elseif ($spin == 1 || $spin == 5) {
                echo "/";
              } elseif ($spin == 2 || $spin == 6) {
                echo "-";
              } elseif ($spin == 3 || $spin == 7) {
                echo "\\";
              }
              if ($spin > 6) {
                $spin = 0;
              }else{
                $spin++;
              }
            }
          }
        }
        if (! $this->climate->arguments->defined('quiet')) {
          echo chr(8) . "Imported table: " . $table['name'] . "\n";
        }       
      }
    }
    if (! $this->climate->arguments->defined('quiet')) {
      echo chr(8) . "Database import complete: " . $this->dbName . "\n";
    }
    $this->db->close();
    exit();
  }

  /**
   * List available databases or tables for a given database
   */
  function doListing() {
    if (! $this->climate->arguments->defined('list')) return;
    $this->parseJSONFile();
    echo "JSON file contains database " . $this->jsonDB['name'] . " with tables:\n";
    foreach($this->jsonDB['tables'] as $table) {
      echo "   " . $table['name'] . "\n";
    }
    exit();
  }

  /**
   * Read and parse the given JSON database file
   */
  function parseJSONFile() {
    $json_file = $this->climate->arguments->get('json_file');
    if (NULL == $json_file) {
      echo "Error, missing JSON file: $json_file\n";
      exit();
    }else{
      if (FALSE === file_exists($json_file)) {
        $json_file = getcwd() . "/$json_file";
        if (FALSE === file_exists($json_file)) {
          echo "Error, missing JSON file: $json_file\n";
          exit();
        }
      }
    }
    try {
      $this->jsonDB = json_decode(file_get_contents($json_file), true);
    } catch (Exception $e) {
      echo 'Error, parsing JSON file: ',  $e->getMessage(), "\n";
      exit();
    }

    // Override database name if specified
    $this->dbName = $this->climate->arguments->get('dbname');
    if ($this->dbName == '') {
      $this->dbName = $this->jsonDB['name'];
    }

    // Generate mirror classes and object instances for each __PHP_Incomplete_Class_Name
    $paths = $this->get_paths($this->jsonDB, '__PHP_Incomplete_Class_Name');
    foreach($paths as $p) {
      $data = $this->get_leaf($this->jsonDB, $p);
      $mirror = $this->generate_ic_mirror($data);
      $this->replace_leaf($this->jsonDB, $p, $mirror);
    }

    // Ensure each object with __PHP_stdClass property is stored as an stdClass
    $paths = $this->get_paths($this->jsonDB, '__PHP_stdClass');
    foreach($paths as $p) {
      $data = $this->get_leaf($this->jsonDB, $p);
      unset($data['__PHP_stdClass']);
      $this->replace_leaf($this->jsonDB, $p, $data, true);
    }
  } 

  /**
   * Replace the leaf within a multi-dimensional array at the given path
   * with a PHP object.
   *
   * @param string $data The given array
   * @param string $path The path (keys divided by separators) to the element
   * @param object $obj The object to set the given leaf key to
   * @param boolean $as_object Cast the new leaf as a stdClass or associative array (default);
   */
  function replace_leaf(&$data, $path, $obj, $as_object = false) {
    $path = substr($path, strlen(JSON2MySQL::SEPARATOR));
    $leafs = explode(JSON2MySQL::SEPARATOR, $path);

    $i = 0;
    $result[$i] = &$data;
    foreach($leafs as $p) {
        $i++;
        $result[$i] = &$result[$i-1][$p];
    }
    if ($as_object) {
      $result[$i] = (object) $obj;
    }else{
      $result[$i] = $obj;
    }
  }

  /**
   * Get the leaf within a multi-dimensional array given a path.
   * 
   * @param string $data The given array
   * @param string $path The path (keys divided by separators) to the element
   */
  function get_leaf($data, $path) {
    $path = substr($path, strlen(JSON2MySQL::SEPARATOR));
    $leafs = explode(JSON2MySQL::SEPARATOR, $path);
    $i = 0;
    $result[$i] = $data;
    foreach($leafs as $p) {
        $i++;
        $result[$i] = $result[$i-1][$p];
    }
    return $result[$i];
  }

  /**
   * Generate a mirror class given an array with the __PHP_Incomplete_Class_Name key
   * definition. The class will have the missing class name and all of it's public
   * protected, and private property values in addition to a setter within the 
   * constructor. 
   */
  function generate_ic_mirror($data) {

    // Define the mirror class
    $code = "if (! class_exists('${data['__PHP_Incomplete_Class_Name']}')) {\n";
    $code .= "  class ${data['__PHP_Incomplete_Class_Name']} {\n";
    $con = "";
    $i = 0;

    // Define the mirror class' properties
    $values = [];
    foreach($data as $k=>$v) {
        if ($k != '__PHP_Incomplete_Class_Name') {
            $prefix = substr($k, 0, 2);
            $name = substr($k, 2);
            if ($prefix == "*|") {
                $code .= "    protected $" . $name . " = null;\n";
            }elseif ($prefix == "A|") {
                $code .= "    private $" . $name . " = null;\n";
            }else{
                $name = $k;
                $code .= "    public $" . $name . " = null;\n";
            }
            $con .= "      \$this->" . $name . " = \$fn_args[$i];\n";
            $values[$i] = $v;
            $i++;
        }
    }
    $code .="\n";
    $code .= "    function __construct(\$fn_args) {\n";
    $code .=        $con;
    $code .= "    }\n";
    $code .= "  }\n";
    $code .= "}\n";
    eval($code);
    $mirror = new $data['__PHP_Incomplete_Class_Name']($values);
    return $mirror;
  }

  /**
   * Get an array of paths to the given key 
   */
  function get_paths($data, $key) {
    $all = [];
    $all = $this->find_path_recursive($data, null, $all, $key);

    // Sort list with longest paths we need to resolve first
    usort($all, function($a, $b) {
        return strlen($b) - strlen($a);
    });
    return $all;
  }

  /**
   * Find path recursively 
   */
  function find_path_recursive(array $array, $path = null, &$all = [], $key) {
    foreach ($array as $k => $v) {
        if (!is_array($v)) {
            if ($k === $key) {
              array_push($all, $path);
            }
        }
        else {
            // directory node -- recurse
            $all = $this->find_path_recursive($v, $path . JSON2MySQL::SEPARATOR . $k, $all, $key);
        }
    }
    return $all;
  }

  /**
   * Show the version number
   */
  function showVersion() {
    if (! $this->climate->arguments->defined('version')) return;
    echo "JSON2MySQL version " . $this->version . "\n";
    echo "Copyright ©2018 Stephen J. Carnam\n";
    exit();
  }

  /**
   * Gather a list of available databases
   */
  function getDBNames() {
    $this->connectToDB();
    $r = $this->db->query('SHOW DATABASES;');
    if ($r->num_rows > 0) {
      while($row = $r->fetch_assoc()) {
          array_push($this->dbNames, $row["Database"]);
      }
    }
    $this->db->close();
  }

  /**
   * Connect to the mysql database with the given credentials
   * string - the name of the database to connect to, default is mysql
   */
  function connectToDB($database = "mysql") {
    $host = $this->climate->arguments->get('host');
    if ($host == 'localhost') {
      $host = '127.0.0.1';
    }
    $user = $this->climate->arguments->get('user');
    $password = $this->climate->arguments->get('password');
    $this->db = new mysqli($host, $user, $password, $database);
    if ($this->db->connect_error) {
      die('Connection failed: ' . $this->db->connect_error);
    }
  }
}

// From command line, create instance & do cli arguments
if ( PHP_SAPI === 'cli' ) {
  $myCmd = new JSON2MySQL();
  $name = new Steveorevo\GString(__FILE__);
  $argv[0] = $name->getRightMost("/")->delRightMost(".");
  $myCmd->cli();
}
