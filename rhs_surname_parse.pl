#!/usr/bin/perl

# Use necessary packages
use Cwd;

# Parse command line opts
use Getopt::Std;
use vars qw($opt_h $opt_d $opt_r $opt_i $opt_o);
getopts('hdri:o:');

&help if ($opt_h);

# Get the input filename/directory defaults
my $INPUT_DIR = ($opt_i && -d $opt_i) ? $opt_i : cwd; # Defaults to current working directory
my $INPUT_FILE = ($opt_i && -f $opt_i) ? $opt_i : ""; # Defaults to empty string/no file
# Make sure a filename/directory given on the command line actually exists
&help("Bad filename or directory: $opt_i") if ($opt_i && ! -e $opt_i);
# &dbg("Calculated INPUT_DIR: $INPUT_DIR and INPUT_FILE: $INPUT_FILE");

# Get the output filename
my $OUTPUT_FILE = ( $opt_o ) ? $opt_o : "rhs_surname.out";
open( OUTPUT_FH, '>', $OUTPUT_FILE ) or die "Can't open $OUTPUT_FILE for writing: $!";

# If we're parsing a single file
if ( $INPUT_FILE ) {
  &parse_file($INPUT_FILE);
} else {
  # Get the directory listing
  opendir( my $dh, $INPUT_DIR ) || die "Can't open $INPUT_DIR: $!";
  while ( readdir $dh ) {
    my $filename = "$INPUT_DIR/$_";
    &dbg( "$filename" );
    if ( -f $filename && $filename =~ /.html$/ ) {
      &parse_file( $filename );
    }
  }
  closedir $dh;
}

# Close the output file
close OUTPUT_FH;

printf( "Successfully parsed %s\n", $INPUT_FILE ? $INPUT_FILE : $INPUT_DIR );

exit();

# End main program flow

sub parse_file {
  # Regular expressions
  &err("No filename passed to parse_file()") if ! scalar(@_);
  my $filename = $_[0];
  open(INPUT_FH, '<', $filename) or die "Can't open $filename for reading: $!";
  # Flag indicating we're parsing a table element
  my $parsing_table = 0;
  # Variable to dump the raw table string
  my $table_string = "";
  while(<INPUT_FH>) {
    # Get the current line minus any pesky newlines
    # NOTE: chomp doesn't necessarily work because there's no guarantee that the file was created on unix
    # chomp;
    $line = $_;
    # Strip off any possible type of line ending
    $line =~ s/\015\012//g; # DOS
    $line =~ s/\012//g;     # Unix
    $line =~ s/\015//g;     # Mac
    # Strip off leading and trailing whitespace
    $line =~ s/^\s*(<.*>)\s*$/$1/;
    # print $line . "\n";

    # If there is an opening table tag, set the flag
    # TODO: Do I want to capture any class name or id here?
    # NOTE: By using substitution here, don't have to strip out the table tags later
    if ($line =~ s/^(.*)<table[\s\w\-=]*>(.*)$/$1$2/) {
      # If we're already in the middle of parsing a table, something went wrong
      &err("Already parsing a table") if ($parsing_table);
      &dbg("Saw opening table tag:\n$line\n");
      $parsing_table = 1;
    }

    # Do something if we're parsing a table or this line has the opening table tag
    if ($parsing_table) {
      # If the current line has the closing table tag, clear the flag and process the table string
      # NOTE: By using substitution here, don't have to strip out the table tags later
      if ($line =~ s/^(.*)<\/table>(.*)$/$1$2/) {
        &dbg("Saw closing table tag:\n$line\n");
        $parsing_table = 0;
      }

      # Add the current line to the table lines
      $table_string .= $line;

      # If this was the last table line, process the string
      if ( ! $parsing_table ) {
        &dbg( "Table string:\n" . $table_string );

        # Split the string by table row
        $table_string =~ s/^<tr>(.*)<\/tr>$/$1/;
        @table_rows = split( "</tr><tr>", $table_string );
        foreach $table_row ( @table_rows ) {
          # print $table_row . "\n";

          # If this is a header row
          if ( $table_row =~ s/^<th>(.*)<\/th>/$1/ ) {
            # Split into headers by <th> tag
            @table_headers = split( "</th><th>", $table_row );
            # Add cemetery and headstone ID headers
            push @table_headers, ( "CemeteryID", "StoneID" );
            # Join the headers with commas
            $table_row = join( ",", @table_headers );
          }
          # Else if this is a data row
          elsif ( $table_row =~ s/^<t[dh]>(.*)<\/t[dh]>/$1/ ) {
            # Split into data fields by the <td> tag
            @table_fields = split( /<\/td><td>/, $table_row );
            # Add cemetery and headstone ID data fields
            # Found in the anchor tag in the "Given Name" field
            if ( $table_fields[1] =~ /^<a.*href=.*(cem\d+).html#(sid\d+)>(.*)</a>$/ ) {
              # Replace the field with the text inside the anchor tag
              $table_fields[1] = $3;
              # Add the cemetery and headston IDs
              push @table_fields, ( $1, $2 );
            } else {
              # This field is an unknown format
              &err( "Unknown Given Name field format: " . $table_fields[1] );
            }
            # Join the data fields with commas
            $table_row = join( ",", @table_fields );
          }
        }

        # Print the full CSV file
        foreach $table_row ( @table_rows ) {
          print OUTPUT_FH $table_row . "\n";
        }
      }
    }
  }

  # Close the filehandle
  close INPUT_FH;
}

sub err {
  print "Error: $_[0]\n" if scalar(@_);
  exit();
}

sub dbg {
  print $_[0] . "\n" if ($opt_d && scalar(@_));
}

sub help {
  my $err_msg = scalar(@_) ? "\nERROR: " . pop(@_) . "\n--------------\n" : "";
  print $err_msg . "Rocktown Historical Society surname file parser\n" .
        "  Usage: parse_rhs.pl [-f <file_or_directory>] [-r] [-d] [-h]\n" .
        "  Options: -i <file_or_directory> : Filename or directory of the input file(s)\n" .
        "                                    default: current working directory\n" .
        "           -o <file>              : Filename of the output file\n" .
        "                                    default: rhs_surname_index.out\n" .
        "           -r                     : Recursively parse all subdirectories if passed a directory\n" .
        "           -d                     : Print debug messages\n" .
        "           -h                     : Print this help message\n\n";
  exit();
}