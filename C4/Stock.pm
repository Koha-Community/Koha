package C4::Stock; #assumes C4/Stock.pm

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use C4::Database;

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&stockreport);

sub stockreport {
  my $dbh=C4Connect;
  my @results;
  my $query="Select count(*) from items where homebranch='C'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $count=$sth->fetchrow_hashref;
  $results[0]="$count->{'count'}\t Levin";
  $sth->finish;
  $query="Select count(*) from items where homebranch='F'";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $count=$sth->fetchrow_hashref;
  $results[1]="$count->{'count'}\t Foxton";
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}

END { }       # module clean-up code here (global destructor)
  
    

