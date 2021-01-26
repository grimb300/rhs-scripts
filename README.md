## Rockwood Historical Society scripts

A series of Perl scripts created to efficiently parse data contained in static HTML files.

- rhs_surname_parse.pl
  ```
  Usage: parse_rhs.pl [-f <file_or_directory>] [-r] [-d] [-h]
  Options: -i <file_or_directory> : Filename or directory of the input file(s)
                                    default: current working directory
           -o <file>              : Filename of the output file
                                    default: rhs_surname.out
           -r                     : Recursively parse all subdirectories if passed a directory
           -d                     : Print debug messages
           -h                     : Print this help message
