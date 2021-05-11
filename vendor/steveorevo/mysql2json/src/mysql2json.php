<?php
/**
 * MySQL2JSON Class and command line tool.
 */

// Resolve autoloader
foreach ([__DIR__ . '/../../../autoload.php', __DIR__ . '/../vendor/autoload.php'] as $file) {
  if (file_exists($file)) {
      require $file;
      break;
  }
}

class MySQL2JSON {
  public $version = "1.1.2"; // TODO: obtain via composer
  public $climate = NULL;
  public $dbNames = [];
  public $tables = [];
  public $db;

  /**
   * Create our MySQL2JSON object
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
        'longPrefix'   => 'hose',
        'description'  => 'host name or IP address (default: localhost)',
        'defaultValue' => 'localhost',
      ],
      'list' => [
        'prefix'      => 'l',
        'longPrefix'  => 'list',
        'description' => 'list databases & tables available for export',
        'noValue'     => true,
      ],
      'output' => [
        'prefix'       => 'o',
        'longPrefix'   => 'output',
        'description'  => 'path & file (default is db name in current folder)',
        'defaultValue' => '',
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
        'description'  => 'quiet (no output)',
        'noValue'      => true
      ],
      'version' => [
        'prefix'       => 'v',
        'longPrefix'   => 'version',
        'description'  => 'output version number',
        'noValue'      => true,
      ],
      'database' => [
        'description'  => 'the database to export'
      ]
    ]);
    $this->climate->arguments->parse();
    if (! $this->climate->arguments->defined("help")) {
      $this->showVersion();
      $this->getDBNames();
      $this->doListing();
      $this->buildJSON();  
    }
    $this->climate->usage();
  }

  /**
   * Create a JSON representation of the given database and tables
   */
  function buildJSON() {
    $database = $this->climate->arguments->get('database');
    if (FALSE == in_array($database, $this->dbNames)) {
      if ($database == NULL) {
        echo "Missing database name.\nType 'mysql2json --help' for more options.\n";
      }else{
        echo "Unknown database: $database\n";
      }
      exit();
    }

    // Define the creation for databases and tables
    $this->getTables();
    $this->connectToDB($database);
    $objDB = new stdClass();
    $objDB->name = $database;
    $r = $this->db->query("SHOW CREATE DATABASE $database;");
    if ($r->num_rows > 0) {
      $row = $r->fetch_assoc();
      $objDB->create = $row["Create Database"];
    }
    $objDB->tables = [];
    foreach($this->tables as $name) {
      $r = $this->db->query("SHOW CREATE TABLE $name;");
      if ($r->num_rows > 0) {
        $row = $r->fetch_assoc();
        $table = new stdClass();
        $table->name = $name;
        $table->create = $row["Create Table"];
        $table->columns = [];
        $table->data = [];
        array_push($objDB->tables, $table);
      }
    }

    // Get column details for the given tables
    $mapString = ["char","varchar","tinytext","text","mediumtext","longtext","binary",
                  "varbinary","date","datetime","timestamp","time","year"];
    $mapNumber = ["bit","tinyint","smallint","mediumint","int","integer","bigint",
                  "decimal","dec","fixed","float","double","real"];
    $mapBoolean = ["bool", "boolean"];
    for ($i = 0; $i < count($objDB->tables); $i++) {
      $name = $objDB->tables[$i]->name;
      $r = $this->db->query("SHOW COLUMNS FROM $name;");
      if ($r->num_rows > 0) {
        while($row = $r->fetch_assoc()) {
          $column = new stdClass();
          $column->name = $row["Field"];
          $type = new steveorevo\GString($row["Type"]);
          $type = $type->getLeftMost("(")->__toString();
          $column->mysql_type = $type;
          if (FALSE !== in_array($type, $mapString)) {
            $type = "string";
          }else{
            if (FALSE !== in_array($type, $mapNumber)) {
              $type = "number";
            }else{
              if (FALSE !== in_array($type, $mapBoolean)) {
                $type = "boolean";
              }else{
                $type = NULL;
              }
            }
          }
          $column->json_type = $type;
          array_push($objDB->tables[$i]->columns, $column);
        }
      }
    }

    // Dump data for the given tables
    for ($i = 0; $i < count($objDB->tables); $i++) {
      $name = $objDB->tables[$i]->name;
      $r = $this->db->query("SELECT * FROM $name;");
      if ($r->num_rows > 0) {
        $data = [];
        while($row = $r->fetch_assoc()) {

          // Check row for serialized data in string
          foreach ((object)$row as $k => $v) {
            for ($c = 0; $c < count($objDB->tables[$i]->columns); $c++) {
              if ($k == $objDB->tables[$i]->columns[$c]->name) {
                break;
              }
            }

            // Update data-type to object and unserialize data
            if (true === $this->is_serialized($v)) {
              $objDB->tables[$i]->columns[$c]->json_type = 'object';
              (object)$row[$k] = unserialize($v);
            }
          }

          array_push($objDB->tables[$i]->data, (object)$row);
        }
      }
      if (! $this->climate->arguments->defined('quiet')) {
        echo "Exported table: " . $name . "\n";
      }
    }
    $this->db->close();
    $output = $this->climate->arguments->get('output');
    if (NULL === $output) {
      $output = getcwd() . "/" . $database . ".json";
    }
    file_put_contents($output, json_encode($objDB, JSON_PRETTY_PRINT));
    if (! $this->climate->arguments->defined('quiet')) {
      echo "File export complete: $output\n";
    }
    exit();
  }

  /**
   * List available databases or tables for a given database
   */
  function doListing() {
    if (! $this->climate->arguments->defined('list')) return;
    $database = $this->climate->arguments->get('database');
    if (FALSE == $database) {
      echo "Databases:\n";
      foreach($this->dbNames as $name) {
        echo "   $name\n";
      } 
    }else{
      if (in_array($database, $this->dbNames)) {
        $this->getTables();
        echo "Tables in database $database:\n";
        foreach($this->tables as $name) {
          echo "   $name\n";
        }
      }else{
        echo "Unknown database: $database\n";
      }
    }
    exit();
  }

  /**
   * Show the version number
   */
  function showVersion() {
    if (! $this->climate->arguments->defined('version')) return;
    echo "MySQL2JSON version " . $this->version . "\n";
    echo "Copyright ©2018 Stephen J. Carnam\n";
    exit();
  }

  /**
   * Gather the list of tables in the given database
   */
  function getTables() {
    $database = $this->climate->arguments->get('database');
    $this->connectToDB($database);
    $r = $this->db->query('SHOW TABLES;');
    if ($r->num_rows > 0) {
      while($row = $r->fetch_assoc()) {
        
        // Limit to implicit tables argument if present
        $name = $row["Tables_in_$database"];
        if ($this->climate->arguments->defined('tables')) {
          $t = ',' . $this->climate->arguments->get('tables') . ',';
          if (FALSE !== strpos($t, "," . $name . ",")) {
            array_push($this->tables, $name);
          }
        }else{
          array_push($this->tables, $name);
        }
      }
    }
    $this->db->close();
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
    if (!$this->db->set_charset("utf8")) {
      printf("Error loading character set utf8: %s\n", $this->db->error);
      exit();
    }
    if ($this->db->connect_error) {
      die('Connection failed: ' . $this->db->connect_error);
    }
  }

  /**
   * Checks to see if the given data is PHP serialized data in a string.
   * 
   * @param (string) - the data to analyze.
   * @return (boolean) true if serialized or false if not.
   */
  function is_serialized($str) {
    $data = @unserialize($str);
    if ($str === 'b:0;' || $data !== false) {
        return true;
    } else {
        return false;
    }
  }
}

// From command line, create instance & do cli arguments
if ( PHP_SAPI === 'cli' ) {
  $myCmd = new MySQL2JSON();
  $name = new Steveorevo\GString(__FILE__);
  $argv[0] = $name->getRightMost("/")->delRightMost(".");
  $myCmd->cli();
}
