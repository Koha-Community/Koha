#!/usr/bin/perl
#
# Copyright 2023 BibLibre
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use warnings;
use strict;
use utf8;

use Getopt::Long qw( GetOptions );
use Koha::Script -cron;
use Koha::OAI::Client::Harvester;
use Koha::OAIServers;
use C4::Log   qw( cronlogaction );
use Try::Tiny qw( catch try );

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

my ( $help, $verbose, $id, $days, $list, $force );

GetOptions(
    'h|help'         => \$help,
    'v|verbose'      => \$verbose,
    'r|repository:i' => \$id,
    'd|days:i'       => \$days,
    'l|list'         => \$list,
    'f|force'        => \$force,
);
my $usage = <<'ENDUSAGE';

This script starts an OAI Harvest

This script has the following parameters:
    -h --help: this message
    -v --verbose
    -r --repository: id of the OAI repository
    -d --days: number of days to harvest from (optional)
    -l --list: list the OAI repositories
    -f --force: force harvesting (ignore records datestamps)
ENDUSAGE

if ($help) {
    print $usage;
    exit;
}

if ($list) {
    my $servers = Koha::OAIServers->search( {}, { order_by => { -asc => 'oai_server_id' } } )->unblessed;
    print "The following repositories are available: \n\n";
    foreach my $server (@$servers) {
        print $server->{'oai_server_id'} . ": "
            . $server->{'servername'}
            . ", endpoint: "
            . $server->{'endpoint'}
            . ", set: "
            . $server->{'oai_set'}
            . ", recordtype: "
            . $server->{'recordtype'} . "\n";
    }
    print "\n";
    exit;
}

if ( !$id ) {
    print "The repository parameter is mandatory.\n";
    print $usage . "\n";
    exit;
}

my $server = Koha::OAIServers->find($id);

unless ($server) {
    print "OAI Server $id unknown\n";
    exit;
}

my $script_handler = Koha::Script->new( { script => $0 } );

try {
    $script_handler->lock_exec;
} catch {
    my $message = "Skipping execution of $0";
    print "$message\n" if $verbose;
    cronlogaction( { info => $message } );
    exit;
};

my $harvester =
    Koha::OAI::Client::Harvester->new( { server => $server, days => $days, force => $force, logger => \&logFunction } );
$harvester->init();

cronlogaction( { action => 'End', info => "COMPLETED" } );

sub logFunction {
    my $message = shift;
    print $message . "\n" if ($verbose);
    cronlogaction( { info => $message } );
}

exit(0);
