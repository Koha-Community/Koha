package C4::Log;

#package to deal with Logging Actions in DB


# Copyright 2000-2002 Katipo Communications
# Copyright 2011 MJ Ray and software.coop
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

use C4::Context;
use C4::Dates qw(format_date);

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw(&logaction &GetLogStatus &displaylog &GetLogs);
}

=head1 NAME

C4::Log - Koha Log Facility functions

=head1 SYNOPSIS

  use C4::Log;

=head1 DESCRIPTION

The functions in this module perform various functions in order to log all the operations done on the Database, including deleting and undeleting books, adding/editing members, etc.

=head1 FUNCTIONS

=over 2

=item logaction

  &logaction($modulename, $actionname, $objectnumber, $infos);

Adds a record into action_logs table to report the different changes upon the database.
Each log entry includes the number of the user currently logged in.  For batch
jobs, which operate without authenticating a user and setting up a session, the user
number is set to 0, which is the same as the superlibrarian's number.

=cut

#'
sub logaction {
    my ($modulename, $actionname, $objectnumber, $infos)=@_;

    # Get ID of logged in user.  if called from a batch job,
    # no user session exists and C4::Context->userenv() returns
    # the scalar '0'.
    my $userenv = C4::Context->userenv();
    my $usernumber = (ref($userenv) eq 'HASH') ? $userenv->{'number'} : 0;
    $usernumber ||= 0;

    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Insert into action_logs (timestamp,user,module,action,object,info) values (now(),?,?,?,?,?)");
    $sth->execute($usernumber,$modulename,$actionname,$objectnumber,$infos);
    $sth->finish;
}

=item GetLogStatus

  $status = GetLogStatus;

C<$status> is a hasref like this example:
    $hash = {
        BorrowersLog   => 1,
        CataloguingLog => 0,
        IssueLog       => 0,
        ...
    }

=cut

#'
sub GetLogStatus {
    my %hash;
    $hash{BorrowersLog}    = C4::Context->preference("BorrowersLog");
    $hash{CataloguingLog}  = C4::Context->preference("CataloguingLog");
    $hash{IssueLog}        = C4::Context->preference("IssueLog");
    $hash{ReturnLog}       = C4::Context->preference("ReturnLog");
    $hash{SubscriptionLog} = C4::Context->preference("SubscriptionLog");
    $hash{LetterLog}       = C4::Context->preference("LetterLog");
    $hash{FinesLog}        = C4::Context->preference("FinesLog");
    return \%hash;
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
sub displaylog {
  my ($modulename, @filters) = @_;
    my $dbh = C4::Context->dbh;
    my $strsth=qq|
		SELECT action_logs.timestamp, action_logs.action, action_logs.info,
				borrowers.cardnumber, borrowers.surname, borrowers.firstname, borrowers.userid,
        		biblio.biblionumber, biblio.title, biblio.author
        FROM action_logs 
		LEFT JOIN borrowers ON borrowers.borrowernumber=action_logs.user 
        LEFT JOIN  biblio   ON action_logs.object=biblio.biblionumber
        WHERE action_logs.module = 'cataloguing' 
	|;
	my %filtermap = ();
    if ($modulename eq "catalogue" or $modulename eq "acqui") {
		%filtermap = (
			  user => 'borrowers.surname',
			 title => 'biblio.title',
			author => 'biblio.author',
		);
    } elsif ($modulename eq "members") {
        $strsth=qq|
		SELECT action_logs.timestamp, action_logs.action, action_logs.info, 
        		borrowers.cardnumber, borrowers.surname, borrowers.firstname, borrowers.userid,
        		bor2.cardnumber, bor2.surname, bor2.firstname, bor2.userid
        FROM action_logs 
		LEFT JOIN borrowers ON borrowers.borrowernumber=action_logs.user 
		LEFT JOIN borrowers as bor2 ON action_logs.object=bor2.borrowernumber
        WHERE action_logs.module = 'members' 
		|;
		%filtermap = (
		       user => 'borrowers.surname',
		    surname => 'bor2.surname',
		  firstname => 'bor2.firstname',
		 cardnumber => 'bor2.cardnumber',
		);
    } else {
		return 0;
	}

    if (@filters) {
		foreach my $filter (@filters) {
			my $tempname = $filter->{name}         or next;
			(grep {/^$tempname$/} keys %filtermap) or next;
			$filter->{value} =~ s/\*/%/g;
			$strsth .= " AND " . $filtermap{$tempname} . " LIKE " . $filter->{value};
		}
	}
    my $sth=$dbh->prepare($strsth);
    $sth->execute;
    my @results;
    my $count;
    my $hilighted=1;
    while (my $data = $sth->fetchrow_hashref){
    	$data->{hilighted} = ($hilighted>0);
        $data->{info} =~ s/\n/<br\/>/g;
        $data->{day} = format_date($data->{timestamp});
        push @results, $data;
        $count++;
        $hilighted = -$hilighted;
    }
    return ($count, \@results);
}

=item GetLogs

$logs = GetLogs($datefrom,$dateto,$user,\@modules,$action,$object,$info);

Return: 
C<$logs> is a ref to a hash which containts all columns from action_logs

=cut

sub GetLogs {
    my $datefrom = shift;
    my $dateto   = shift;
    my $user     = shift;
    my $modules   = shift;
    my $action   = shift;
    my $object   = shift;
    my $info     = shift;
   
    my $iso_datefrom = C4::Dates->new($datefrom,C4::Context->preference("dateformat"))->output('iso');
    my $iso_dateto = C4::Dates->new($dateto,C4::Context->preference("dateformat"))->output('iso');

    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT *
        FROM   action_logs
        WHERE 1
    ";

    my @parameters;
    $query .= " AND DATE_FORMAT(timestamp, '%Y-%m-%d') >= \"".$iso_datefrom."\" " if $iso_datefrom;   #fix me - mysql specific
    $query .= " AND DATE_FORMAT(timestamp, '%Y-%m-%d') <= \"".$iso_dateto."\" " if $iso_dateto;
    if($user ne "") {
    	$query .= " AND user = ? ";
    	push(@parameters,$user);
    }
    if($modules && scalar(@$modules)) {
    	$query .= " AND module IN (".join(",",map {"?"} @$modules).") ";
	push(@parameters,@$modules);
    }
    if($action && scalar(@$action)) {
    	$query .= " AND action IN (".join(",",map {"?"} @$action).") ";
	push(@parameters,@$action);
    }
    if($object) {
    	$query .= " AND object = ? ";
	push(@parameters,$object);
    }
    if($info) {
    	$query .= " AND info LIKE ? ";
	push(@parameters,"%".$info."%");
    }
   
    my $sth = $dbh->prepare($query);
    $sth->execute(@parameters);
    
    my @logs;
    while( my $row = $sth->fetchrow_hashref ) {
        push @logs , $row;
    }
    return \@logs;
}

1;
__END__

=back

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
