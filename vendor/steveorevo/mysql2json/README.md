mysql2json
==========

Database to JSON object conversion tool with support for PHP serialization.

### About

This command line tool will export the specified database to a "pretty print" JSON object. Auto-detection of PHP serialized strings will also be converted to a JSON object. This tool allows for simple line-by-line representation of a MySQL database and is perfect for viewing content in text based comparison tools. Re-import can be performed using the companion tool, [json2mysql](https://github.com/steveorevo/json2mysql).

#### Help
Type mysql2json --help

```
MySQL2JSON is a database to JSON export tool with support for serialized PHP.
Version 2.1.0

Usage: mysql2json [-x, --exclude] [-?, --help] [-h host, --hose host (default: localhost)] [-l, --list] [-o output, --output output] [-p password, --password password] [-P port, --port port] [-q, --quiet] [-t tables, --tables tables] [-u user, --user user (default: root)] [-v, --version] [database]

Optional Arguments:
        -?, --help
                print this help
        -h host, --hose host (default: localhost)
                host name or IP address (default: localhost)
        -l, --list
                list databases & tables available for export
        -x, --exclude
                excludes rows with _transient_ in option_name column (WordPress)
        -o output, --output output
                path & file (default is db name in current folder)
        -p password, --password password
                password to connect with (default is none)
        -P port, --port port
                the TCP/IP port number to connect to
        -t tables, --tables tables
                a comma delimited list of tables (default empty for all)
        -u user, --user user (default: root)
                username to connect as (default: root)
        -q, --quiet
                quiet (no output)
        -v, --version
                output version number
        database
                the database to export
```
  
