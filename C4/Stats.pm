package C4::Stats; #assumes C4/Stats


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
use DBI;
use C4::Database;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Stats - Update Koha statistics (log)

=head1 SYNOPSIS

  use C4::Stats;

=head1 DESCRIPTION

The C<&UpdateStats> function adds an entry to the statistics table in
the Koha database, which acts as an activity log.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&UpdateStats &statsreport &Count &Overdues &TotalOwing
&TotalPaid &getcharges &Getpaidbranch &unfilledreserves);

=item UpdateStats

  &UpdateStats($env, $branch, $type, $value, $other, $itemnumber,
               $itemtype, $borrowernumber);

Adds a line to the statistics table of the Koha database. In effect,
it logs an event.

C<$branch>, C<$type>, C<$value>, C<$other>, C<$itemnumber>,
C<$itemtype>, and C<$borrowernumber> correspond to the fields of the
statistics table in the Koha database.

If C<$branch> is the empty string, the branch code will be taken from
C<$env-E<gt>{branchcode}>.

C<$env-E<gt>{usercode} specifies the value of the C<usercode> field.

=cut
#'
sub UpdateStats {
  #module to insert stats data into stats table
  my ($env,$branch,$type,$amount,$other,$itemnum,$itemtype,$borrowernumber)=@_;
  my $dbh=C4Connect();
  if ($branch eq ''){
    $branch=$env->{'branchcode'};
  }
  my $user = $env->{'usercode'};
  print $borrowernumber;
  # FIXME - Use $dbh->do() instead?
  my $sth=$dbh->prepare("Insert into statistics
  (datetime,branch,type,usercode,value,
  other,itemnumber,itemtype,borrowernumber)
  values (now(),'$branch','$type','$user','$amount',
  '$other','$itemnum','$itemtype','$borrowernumber')");
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

# XXX - POD
# FIXME - Why does this function exist? Why not just rename &circrep
# to &statsreport?
# Then again, it only appears to be used in reports.pl which, in turn,
# doesn't appear to be used. So presumably this function is obsolete.
sub statsreport {
  #module to return a list of stats for a given day,time,branch type
  #or to return search stats
  my ($type,$time)=@_;
  my @data;
#  print "here";
#  if ($type eq 'issue'){
    @data=circrep($time,$type);
#  }
  return(@data);
}

# XXX - Doc. Only used internally. Probably useless: see comment for
# &statsreport.
sub circrep {
  my ($time,$type)=@_;
  my $dbh=C4Connect;
  my $query="Select * from statistics";
  if ($time eq 'today'){
    # FIXME - What is this supposed to do? MySQL 3.23.42 barfs on it.
    $query=$query." where type='$type' and datetime
    >=datetime('yesterday'::date)";
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'datetime'}\t$data->{'branch'}";
    $i++;
  }
  $sth->finish;
#  print $query;
  $dbh->disconnect;
  return(@results);

}

# XXX - POD
# FIXME - This is only used in stats.pl, which in turn is never used.
sub Count {
  my ($type,$branch,$time,$time2)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from statistics where type='$type'";
  $query.=" and datetime >= '$time' and datetime< '$time2' and branch='$branch'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
#  print $query;
  $dbh->disconnect;
  return($data->{'count(*)'});
}

# XXX - POD. Doesn't appear to be used
sub Overdues{
  my $dbh=C4Connect;
  my $query="Select count(*) from issues where date_due >= now()";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $count=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($count->{'count(*)'});
}

# XXX - POD. Never used
sub TotalOwing{
  my ($type)=@_;
  my $dbh=C4Connect;
  my $query="Select sum(amountoutstanding) from accountlines";
  if ($type eq 'fine'){
    $query=$query." where accounttype='F' or accounttype='FN'";
  }
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
   my $total=$sth->fetchrow_hashref;
   $sth->finish;
  $dbh->disconnect;
  return($total->{'sum(amountoutstanding)'});
}

# XXX - POD. Never used
sub TotalPaid {
  my ($time)=@_;
  my $dbh=C4Connect;
  my $query="Select * from accountlines,borrowers where (accounttype = 'Pay'
or accounttype ='W')
  and accountlines.borrowernumber = borrowers.borrowernumber";
  if ($time eq 'today'){
    $query=$query." and date = now()";
  } else {
    $query.=" and date='$time'";
  }
#  my $query="Select * from statistics,borrowers
#  where statistics.borrowernumber= borrowers.borrowernumber
#  and (statistics.type='payment' or statistics.type='writeoff') ";
#  if ($time eq 'today'){
#    $query=$query." and datetime = now()";
#  } else {
#    $query.=" and datetime > '$time'";
#  }
  $query.=" order by timestamp";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
   $sth->finish;
  $dbh->disconnect;
#  print $query;
  return(@results);
}

# XXX - POD. Only used in stats.pl, which in turn is never used.
sub getcharges{
  my($borrowerno,$timestamp)=@_;
  my $dbh=C4Connect;
  my $timestamp2=$timestamp-1;
  my $query="Select * from accountlines where borrowernumber=$borrowerno
  and timestamp = '$timestamp' and accounttype <> 'Pay' and
  accounttype <> 'W'";
  my $sth=$dbh->prepare($query);
#  print $query,"<br>";
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
#    if ($data->{'timestamp'} == $timestamp){
      $results[$i]=$data;
      $i++;
#    }
  }
  $dbh->disconnect;
  return(@results);
}

# XXX - POD. This is only used in stats.pl and stats2.pl, neither of
# which is used.
sub Getpaidbranch{
  my($date,$borrno)=@_;
  my $dbh=C4Connect;
  my $query="select * from statistics where type='payment' and datetime
  >'$date' and  borrowernumber='$borrno'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
#  print $query;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data->{'branch'});
}

# XXX - POD. This is only used in reservereport.pl and
# reservereport.xls, neither of which is used.
sub unfilledreserves {
  my $dbh=C4Connect;
  my $query="select *,biblio.title from reserves,reserveconstraints,biblio,borrowers,biblioitems where found <> 'F' and cancellationdate
is NULL and biblio.biblionumber=reserves.biblionumber and
reserves.constrainttype='o'
and (reserves.biblionumber=reserveconstraints.biblionumber
and reserves.borrowernumber=reserveconstraints.borrowernumber)
and
reserves.borrowernumber=borrowers.borrowernumber and
biblioitems.biblioitemnumber=reserveconstraints.biblioitemnumber order by
biblio.title,reserves.reservedate";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $query="select *,biblio.title from reserves,biblio,borrowers where found <> 'F' and cancellationdate
is NULL and biblio.biblionumber=reserves.biblionumber and reserves.constrainttype='a' and
reserves.borrowernumber=borrowers.borrowernumber
order by
biblio.title,reserves.reservedate";
  $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}

END { }       # module clean-up code here (global destructor)

1;
__END__
=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
