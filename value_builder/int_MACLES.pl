#!/usr/bin/perl -w  -CS
use C4::Context;
use Encode;
use Getopt::Long;
use utf8;
my ( $input_marc_file) = ('',0);
my ($version, $delete, $test_parameter,$char_encoding, $verbose,$field,$test_dollar);
GetOptions(
    'h'    => \$version,
    'file:s'    => \$input_marc_file,
    't' => \$test_parameter,
    'd' => \$delete,
);

if ($version || ($input_marc_file eq '')) {
print <<EOF
small script to import languages from a file.
parameters :
\th : this version/help screen
\tfile /path/to/file/to/dump : the file to dump
\tv : verbose mode. 1 means "some infos", 2 means "MARC dumping"
\tt : test mode : parses the file, saying what he would do, but doing nothing.
IMPORTANT : don't use this script before you've entered and checked twice (or more) your  MARC parameters tables.
If you fail this, the import won't work correctly and you will get invalid datas.

SAMPLE : ./bulkmarcimport.pl -file /home/paul/koha.dev/local/npl -n 1
EOF
;#'
die;
}

my $dbh = C4::Context->dbh;
$|=1; # flushes output

if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
if ($delete){
	$dbh->do("DELETE from authorised_values WHERE category=\"MACLES\";");
}
open FILE, "<", $input_marc_file or die "unable to open $input_marc_file";
my $strsth="INSERT IGNORE into authorised_values (category,authorised_value,lib) VALUES ('MACLES',?,?);";
my $rq=$dbh->prepare($strsth);
while (<FILE>){
  my ($col,$lib)=($1,$3) if ($_=~/(([0-9X]{3}|,)+)\s+(.*)$/);
#  Encode::from_to( $data[0] ,"utf-8","latin1");
#  Encode::from_to( $data[1] ,"utf-8","latin1");
#  warn "col:$col lib:$lib ";  
  $rq->execute($col,$lib) unless($test_parameter);
  print "$col\t$lib\n" if ($test_parameter);
}
#$rq->finish;
