package C4::Database; #asummes C4/Database

#requires DBI.pm to be installed

use strict;
require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT);
  
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(
	&C4Connect &requireDBI
);


sub C4Connect  {
  my $dbname="c4";
   my ($database,$hostname,$user,$pass,%configfile);
   open (KC, "/etc/koha.conf");
   while (<KC>) {
     chomp;
     (next) if (/^\s*#/);
     if (/(.*)\s*=\s*(.*)/) {
       my $variable=$1;
       my $value=$2;
       # Clean up white space at beginning and end
       $variable=~s/^\s*//g;
       $variable=~s/\s*$//g;
       $value=~s/^\s*//g;
       $value=~s/\s*$//g;
       $configfile{$variable}=$value;
     }
   }
   $database=$configfile{'database'};
   $hostname=$configfile{'hostname'};
   $user=$configfile{'user'};
   $pass=$configfile{'pass'};
    
   my $dbh=DBI->connect("DBI:mysql:$database:$hostname",$user,$pass);
  return $dbh;
} # sub C4Connect

#------------------
# Helper subroutine to make sure database handle was passed properly
sub requireDBI {
    my (
	$dbh,
	$subrname,	# name of calling subroutine
    )=@_;

    unless ( ref($dbh) =~ /DBI::db/ ) {
	print "<pre>\nERROR: Subroutine $subrname called without proper DBI handle.\n" .
		"Please contact system administrator.\n</pre>\n";
	die "ERROR: Subroutine $subrname called without proper DBI handle.\n";
    }
} # sub requireDBI


END { }
