## Rockwood Historical Society scripts

A series of Perl scripts created to efficiently parse data contained in static HTML files.

#### rhs_surname_parse.pl
Parse the surname files located in `public_html/cemeteries/<ABC...>/<surname>.html`
```
Usage: rhs_surname_parse.pl [-f <file_dir>] [-o <file>] [-r] [-d] [-h]
Options: -i <file_dir> : Filename or directory of the input file(s)
                        default: current working directory
        -o <file>     : Filename of the output file
                        default: rhs_surname.out
        -r            : Recursively parse all subdirectories if passed a directory
        -d            : Print debug messages
        -h            : Print this help message
```
#### rhs_cemetery_parse.pl
Parse the cemetery files located in `public_html/cemeteries/cem/cem<cemeteryID>.html`
```
Usage: rhs_cemetery_parse.pl [-f <file_dir>] [-o <file>] [-r] [-d] [-h]\n" .
Options: -i <file_dir> : Filename or directory of the input file(s)
                          default: current working directory
          -o <file>     : Filename of the output file
                          default: rhs_cemetery.out
          -r            : Recursively parse all subdirectories if passed a directory
          -d            : Print debug messages
          -h            : Print this help message
```