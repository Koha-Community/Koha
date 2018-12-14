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

use JSON qw( to_json );

use C4::Context;
use Koha::DateUtils;
use Koha::Logger;

use vars qw(@ISA @EXPORT);

BEGIN {
        require Exporter;
        @ISA = qw(Exporter);
        @EXPORT = qw(&logaction &cronlogaction &GetLogs);
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
    my ($modulename, $actionname, $objectnumber, $infos, $interface)=@_;

    # Get ID of logged in user.  if called from a batch job,
    # no user session exists and C4::Context->userenv() returns
    # the scalar '0'.
    my $userenv = C4::Context->userenv();
    my $usernumber = (ref($userenv) eq 'HASH') ? $userenv->{'number'} : 0;
    $usernumber ||= 0;
    $interface //= C4::Context->interface;

    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Insert into action_logs (timestamp,user,module,action,object,info,interface) values (now(),?,?,?,?,?,?)");
    $sth->execute($usernumber,$modulename,$actionname,$objectnumber,$infos,$interface);
    $sth->finish;

    my $logger = Koha::Logger->get(
        {
            interface => 'intranet',
            category  => "ActionLogs.$modulename.$actionname"
        }
    );
    $logger->debug(
        sub {
            "ACTION LOG: " . to_json(
                {
                    user   => $usernumber,
                    module => $modulename,
                    action => $actionname,
                    object => $objectnumber,
                    info   => $infos
                }
            );
        }
    );
}

=item cronlogaction

  &cronlogaction($infos);

Convenience routine to add a record into action_logs table from a cron job.
Logs the path and name of the calling script plus the information privided by param $infos.

=cut

#'
sub cronlogaction {
    my ($infos)=@_;
    my $loginfo = (caller(0))[1];
    $loginfo .= ' ' . $infos if $infos;
    logaction( 'CRONJOBS', 'Run', undef, $loginfo ) if C4::Context->preference('CronjobLog');
}

=item GetLogs

$logs = GetLogs($datefrom,$dateto,$user,\@modules,$action,$object,$info);

Return:
C<$logs> is a ref to a hash which contains all columns from action_logs

=cut

sub GetLogs {
    my $datefrom = shift;
    my $dateto   = shift;
    my $user     = shift;
    my $modules  = shift;
    my $action   = shift;
    my $object   = shift;
    my $info     = shift;
    my $interfaces = shift;

    my $iso_datefrom = $datefrom ? output_pref({ dt => dt_from_string( $datefrom ), dateformat => 'iso', dateonly => 1 }) : undef;
    my $iso_dateto = $dateto ? output_pref({ dt => dt_from_string( $dateto ), dateformat => 'iso', dateonly => 1 }) : undef;

    $user ||= q{};

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT *
        FROM   action_logs
        WHERE 1
    ";

    my @parameters;
    $query .=
      " AND DATE_FORMAT(timestamp, '%Y-%m-%d') >= \"" . $iso_datefrom . "\" "
      if $iso_datefrom;    #fix me - mysql specific
    $query .=
      " AND DATE_FORMAT(timestamp, '%Y-%m-%d') <= \"" . $iso_dateto . "\" "
      if $iso_dateto;
    if ( $user ne q{} ) {
        $query .= " AND user = ? ";
        push( @parameters, $user );
    }
    if ( $modules && scalar(@$modules) ) {
        $query .=
          " AND module IN (" . join( ",", map { "?" } @$modules ) . ") ";
        push( @parameters, @$modules );
    }
    if ( $action && scalar(@$action) ) {
        $query .= " AND action IN (" . join( ",", map { "?" } @$action ) . ") ";
        push( @parameters, @$action );
    }
    if ($object) {
        $query .= " AND object = ? ";
        push( @parameters, $object );
    }
    if ($info) {
        $query .= " AND info LIKE ? ";
        push( @parameters, "%" . $info . "%" );
    }
    if ( $interfaces && scalar(@$interfaces) ) {
        $query .=
          " AND interface IN (" . join( ",", map { "?" } @$interfaces ) . ") ";
        push( @parameters, @$interfaces );
    }

    my $sth = $dbh->prepare($query);
    $sth->execute(@parameters);

    my @logs;
    while ( my $row = $sth->fetchrow_hashref ) {
        push @logs, $row;
    }
    return \@logs;
}

1;
__END__

=back

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
