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

use Data::Dumper   qw( Dumper );
use File::Basename qw( basename );
use JSON           qw( to_json encode_json );
use Scalar::Util   qw( blessed );
use Struct::Diff   qw( diff );

use C4::Context;
use Koha::Logger;
use Koha::ActionLogs;

use vars qw(@ISA @EXPORT);

BEGIN {
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(logaction cronlogaction);
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

  &logaction($modulename, $actionname, $objectnumber, $infos, $interface, $original_as_hashref_or_object);

Adds a record into action_logs table to report the different changes upon the database.
Each log entry includes the number of the user currently logged in.  For batch
jobs, which operate without authenticating a user and setting up a session, the user
number is set to 0, which is the same as the superlibrarian's number.

=cut

#'
sub logaction {
    my ( $modulename, $actionname, $objectnumber, $infos, $interface, $original ) = @_;

    my $updated;

    # Get ID of logged in user.  if called from a batch job,
    # no user session exists and C4::Context->userenv() returns
    # the scalar '0'.
    my $userenv    = C4::Context->userenv();
    my $usernumber = ( ref($userenv) eq 'HASH' ) ? $userenv->{'number'} : 0;
    $usernumber ||= 0;
    $interface //= C4::Context->interface;

    if ( blessed($infos) && $infos->isa('Koha::Object') ) {
        $infos   = $infos->get_from_storage if $infos->in_storage;
        $updated = $infos->unblessed;
        local $Data::Dumper::Sortkeys = 1;

        if ( $infos->isa('Koha::Item') && $modulename eq 'CATALOGUING' && $actionname eq 'MODIFY' ) {
            $infos = "item " . Dumper( $original->unblessed );
        } else {
            $infos = Dumper($updated);
        }
    } else {
        $updated = $infos;
    }

    my $script =
        ( $interface eq 'cron' or $interface eq 'commandline' )
        ? basename($0)
        : undef;

    my @trace;
    my $depth = C4::Context->preference('ActionLogsTraceDepth') || 0;
    for ( my $i = 0 ; $i < $depth ; $i++ ) {
        my ( $package, $filename, $line, $subroutine ) = caller($i);
        last unless defined $line;
        push(
            @trace,
            {
                package    => $package,
                filename   => $filename,
                line       => $line,
                subroutine => $subroutine,
            }
        );
    }
    my $trace = @trace ? to_json( \@trace, { utf8 => 1, pretty => 0 } ) : undef;

    my $is_object = blessed($original) && $original->isa('Koha::Object');

    if ( $actionname =~ /^(ADD|CREATE)$/ ) {

        # Log diff against empty hashref for newly created objects
        $updated  = $is_object ? $original->unblessed : $original;
        $original = {};
    } elsif ( $actionname eq 'DELETE' ) {

        # Log diff for deleted objects against empty hashref
        $original = $is_object ? $original->unblessed : $original;
        $updated  = {};
    } else {

        # Log diff against hashref of pre-modified object if passed in
        $original = $is_object ? $original->unblessed : $original;
    }

    my $diff = undef;
    $diff //= encode_json( diff( $original, $updated, noU => 1 ) )
        if $original && ref $updated eq 'HASH';

    Koha::ActionLog->new(
        {
            timestamp => \'NOW()',
            user      => $usernumber,
            module    => $modulename,
            action    => $actionname,
            object    => $objectnumber,
            info      => $infos,
            interface => $interface,
            script    => $script,
            trace     => $trace,
            diff      => $diff,
        }
    )->store();

    my $logger = Koha::Logger->get(
        {
            interface => $interface,
            category  => "ActionLogs.$modulename.$actionname"
        }
    );
    $logger->debug(
        sub {
            "ACTION LOG: " . encode_json(
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
Logs the path and name of the calling script plus the information provided by param $infos.

=cut

#'
sub cronlogaction {
    my $params = shift;
    my $info   = $params->{info};
    my $action = $params->{action};
    $action ||= "Run";
    my $loginfo = ( caller(0) )[1];
    $loginfo .= ' ' . $info                        if $info;
    logaction( 'CRONJOBS', $action, $$, $loginfo ) if C4::Context->preference('CronjobLog');
}

1;
__END__

=back

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
