package C4::Stats;

# $Id$

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
use C4::Context;
use vars qw($VERSION @ISA @EXPORT);

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

C<$env-E<gt>{usercode}> specifies the value of the C<usercode> field.

=cut
#'
sub UpdateStats {
  #module to insert stats data into stats table
  my ($env,$branch,$type,$amount,$other,$itemnum,$itemtype,$borrowernumber)=@_;
  my $dbh = C4::Context->dbh;
  if ($branch eq ''){
    $branch=$env->{'branchcode'};
  }
  my $user = $env->{'usercode'};
  print $borrowernumber;
  # FIXME - Use $dbh->do() instead
  my $sth=$dbh->prepare("Insert into statistics
  (datetime,branch,type,usercode,value,
  other,itemnumber,itemtype,borrowernumber)
  values (now(),'$branch','$type','$user','$amount',
  '$other','$itemnum','$itemtype','$borrowernumber')");
  $sth->execute;
  $sth->finish;
}

# FIXME - Why does this function exist? Why not just rename &circrep
# to &statsreport?
# Then again, it only appears to be used in reports.pl which, in turn,
# doesn't appear to be used. So presumably this function is obsolete.
# If not, it needs a POD.
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

# Only used internally. Probably useless: see comment for
# &statsreport.
sub circrep {
  my ($time,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from statistics";
  if ($time eq 'today'){
    # FIXME - What is this supposed to do? MySQL 3.23.42 barfs on it.
    $query=$query." where type='$type' and datetime
    >=datetime('yesterday'::date)";
			# FIXME - .= <<EOT;
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
  	my %tempvalue;
    $tempvalue{'value'}="$data->{'datetime'}\t$data->{'branch'}";
    push(@results, \%tempvalue);
  }
  $sth->finish;
#  print $query;
  return(@results);
}

# FIXME - This is only used in stats.pl, which in turn is never used.
# Otherwise, this needs a POD.
sub Count {
  my ($type,$branch,$time,$time2)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from statistics where type='$type'";
  $query.=" and datetime >= '$time' and datetime< '$time2' and branch='$branch'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
#  print $query;
  return($data->{'count(*)'});
}

# FIXME - This function doesn't appear to be used.
# If it is, it needs a POD.
sub Overdues{
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from issues where date_due >= now()";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $count=$sth->fetchrow_hashref;
  $sth->finish;
  return($count->{'count(*)'});
}

# FIXME - Never used.
# Otherwise, it'd need a POD.
sub TotalOwing{
  my ($type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select sum(amountoutstanding) from accountlines";
  if ($type eq 'fine'){
    $query .= " where accounttype='F' or accounttype='FN'";
  }
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
   my $total=$sth->fetchrow_hashref;
   $sth->finish;
  return($total->{'sum(amountoutstanding)'});
}

# FIXME - Never used.
# Otherwise, it'd need a POD.
sub TotalPaid {
  my ($time)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from accountlines,borrowers where (accounttype = 'Pay'
or accounttype ='W')
  and accountlines.borrowernumber = borrowers.borrowernumber";
  if ($time eq 'today'){
    $query .= " and date = now()";
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
#  print $query;
  return(@results);
}

# FIXME - Only used in stats.pl, which in turn is never used.
# Otherwise, it needs a POD.
sub getcharges{
  my($borrowerno,$timestamp)=@_;
  my $dbh = C4::Context->dbh;
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
  return(@results);
}

# This is only used in stats.pl and stats2.pl, neither of which is
# used.
# Otherwise, this needs a POD.
sub Getpaidbranch{
  my($date,$borrno)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select * from statistics where type='payment' and datetime
  >'$date' and  borrowernumber='$borrno'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
#  print $query;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data->{'branch'});
}

# FIXME - This is only used in reservereport.pl and reservereport.xls,
# neither of which is used.
# Otherwise, it needs a POD.
sub unfilledreserves {
  my $dbh = C4::Context->dbh;
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
  return($i,\@results);
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
