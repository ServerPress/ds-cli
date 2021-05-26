json2mysql
==========

JSON to database import tool with support for PHP serialization.

### About

This command line tool will import the specified JSON file created from the companion tool [mysql2json](https://github.com/steveorevo/mysql2json). Auto-detection of objects will be stored as PHP serialized strings.  

#### Help
Type json2mysql --help

```
JSON2MySQL is a JSON import tool with support for PHP serialization.
Version 2.1.0

Usage: json2mysql [-d dbname, --dbname dbname] [-?, --help] [-h host, --host host (default: localhost)] [-l, --list] [-p password, --password password] [-P port, --port port] [-q, --quiet] [-s, --skip] [-t tables, --tables tables] [-u user, --user user (default: root)] [-v, --version] [json_file]

Optional Arguments:
        -?, --help
                print this help
        -h host, --host host (default: localhost)
                host name or IP address (default: localhost)
        -l, --list
                list tables available for import
        -p password, --password password
                password to connect with (default is none)
        -P port, --port port
                the TCP/IP port number to connect to
        -s, --skip
                skip dropping/creating of existing database
        -t tables, --tables tables
                a comma delimited list of tables (default empty for all)
        -u user, --user user (default: root)
                username to connect as (default: root)
        -q, --quiet
                quiet (no output and default question to yes)
        -v, --version
                output version number
        -d dbname, --dbname dbname
                override, create/import using specified database name
        json_file
                the json file to import
```
