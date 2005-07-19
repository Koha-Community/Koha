package C4::Log; #assumes C4/Log

#package to deal with Logging Actions in DB


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
use C4::Context;

require Exporter;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Log - Koha Log Facility functions

=head1 SYNOPSIS

  use C4::Log;

=head1 DESCRIPTION

The functions in this module perform various functions in order to log all the operations done on the Database, including deleting and undeleting books, adding/editing members, etc.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&logaction &logstatus);

=item logaction

  &logaction($usernumber, $modulename, $actionname, $infos);

Adds a record into action_logs table to report the different changes upon the database

=cut
#'
sub logaction{
  my ($usernumber,$modulename, $actionname, $objectnumber, $infos)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Insert into action_logs (timestamp,user,module,action,object,info) values (now(),?,?,?,?,?)");
	$sth->execute($usernumber,$modulename,$actionname,$objectnumber,$infos);
	$sth->finish;
}

=item logstatus

  &logstatus;

returns True If Activate_Log variable is equal to On
Activate_Log is a system preference Variable
=cut
#'
sub logstatus{
	return C4::Context->preference("Activate_Log");
}

=item displaylog

  &displaylog($modulename, @filters);
  $modulename is the name of the module on which the user wants to display logs
  @filters is an optional table of hash containing :
  	- name : the name of the variable to filter
	- value : the value of the filter.... May be with * joker

returns a table of hash containing who did what on which object at what time

=cut
#'
sub displaylog{
  my ($modulename, @filters)=@_;
	my $dbh = C4::Context->dbh;
	my $strsth;
	if ($modulename eq "acqui.simple"){
		$strsth="select action_logs.timestamp, action_logs.action, borrowers.cardnumber, borrowers.surname, borrowers.firstname, borrowers.userid,";
		$strsth .= "biblio.biblionumber, biblio.title, biblio.author" ;#if ($modulename eq "acqui.simple");
		$strsth .= "FROM borrowers,action_logs ";
		$strsth .= ",biblio" ;#if ($modulename eq "acqui.simple");
	
		$strsth .="WHERE borrowers.borrowernumber=action_logs.user";
		$strsth .= "AND action_logs.module = 'acqui.simple' AND action_logs.object=biblio.biblionumber ";# if ($modulename eq "acqui.simple");
		if (@filters){
			foreach my $filter (@filters){
				if ($filter->{name} =~ /user/){
					$filter->{value}=~s/\*/%/g;
					$strsth .= " AND borrowers.surname like ".$filter->{value};
				}elsif ($filter->{name} =~ /title/){
					$filter->{value}=~s/\*/%/g;
					$strsth .= " AND biblio.title like ".$filter->{value};
				}elsif ($filter->{name} =~ /author/){
					$filter->{value}=~s/\*/%/g;
					$strsth .= " AND biblio.author like ".$filter->{value};
				}
			}
		}
	} elsif ($modulename eq "acqui")  {
	} elsif ($modulename eq "circ")   {
	} elsif ($modulename eq "members"){
	}
	warn "displaylog :".$strsth;
	my $sth=$dbh->prepare($strsth);
	$sth->execute;
	my @results;
	my $count;
	while (my $data = $sth->fetchrow_hashref){
		push @results, $data;
		$count++;
	}
	return ($count, \@results);
}
END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
