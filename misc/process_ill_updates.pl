#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2022 PTFS Europe
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

use Modern::Perl;
use Getopt::Long qw( GetOptions );
use POSIX;

use Koha::Script;
use Koha::ILL::Requests;

# Command line option values
my $get_help        = 0;
my $statuses        = "";
my $status_alias    = "";
my $status_to       = "";
my $status_alias_to = "";
my $backend         = "";
my $dry_run         = 0;
my $delay           = 0;
my $debug           = 0;

my $options = GetOptions(
    'h|help'            => \$get_help,
    'statuses:s'        => \$statuses,
    'status-alias:s'    => \$status_alias,
    'status-to:s'       => \$status_to,
    'status-alias-to:s' => \$status_alias_to,
    'backend=s'         => \$backend,
    'dry-run'           => \$dry_run,
    'api-delay:i'       => \$delay,
    'debug'             => \$debug
);

if ($get_help) {
    get_help();
    exit 1;
}

if ( !$backend ) {
    print "No backend specified\n";
    exit 0;
}

# First check we can proceed
my $cfg                = Koha::ILL::Request::Config->new;
my $backends           = $cfg->available_backends;
my $has_branch         = $cfg->has_branch;
my $backends_available = ( scalar @{$backends} > 0 );
if ( !$has_branch || $backends_available == 0 ) {
    print "Unable to proceed:\n";
    print "Branch configured: $has_branch\n";
    print "Backends available: $backends_available\n";
    exit 0;
}

# Get all required requests
my @statuses_arr     = split( /:/, $statuses );
my @status_alias_arr = split( /:/, $status_alias );

my $where = { backend => $backend };

if ( scalar @statuses_arr > 0 ) {
    my @or = grep( !/null/, @statuses_arr );
    if ( scalar @or < scalar @statuses_arr ) {
        push @or, undef;
    }
    $where->{status} = \@or;
}

if ( scalar @status_alias_arr > 0 ) {
    my @or = grep( !/null/, @status_alias_arr );
    if ( scalar @or < scalar @status_alias_arr ) {
        push @or, undef;
    }
    $where->{status_alias} = \@or;
}

debug_msg("DBIC WHERE:");
debug_msg($where);

my $requests = Koha::ILL::Requests->search($where);

debug_msg( "Processing " . $requests->count . " requests" );

# Create an options hashref to pass to processors
my $options_to_pass = {
    dry_run         => $dry_run,
    status_to       => $status_to,
    status_alias_to => $status_alias_to,
    delay           => $delay,
    debug           => \&debug_msg
};

# The progress log
my $output = [];

while ( my $request = $requests->next ) {
    debug_msg( "- Request ID " . $request->illrequest_id );
    my $update = $request->backend_get_update($options_to_pass);

    # The log for this request
    my $update_log = {
        request_id     => $request->illrequest_id,
        processed_by   => $request->_backend->name,
        processors_run => []
    };
    if ($update) {

        # Currently we make an assumption, this may need revisiting
        # if we need to extend the functionality:
        #
        # Only the backend that originated the update will want to
        # process it
        #
        # Since each backend's update format is different, it may
        # be necessary for a backend to subclass Koha::ILL::Request::SupplierUpdate
        # so it can provide methods (corresponding to a generic interface) that
        # return pertinent info to core ILL when it is processing updates
        #
        # Attach any request processors
        $request->attach_processors($update);

        # Attach any processors from this request's backend
        $request->_backend->attach_processors($update);
        my $processor_results = $update->run_processors($options_to_pass);

        # Update our progress log
        $update_log->{processors_run} = $processor_results;
    }
    push @{$output}, $update_log;
}

print_summary($output);

sub print_summary {
    my ($log) = @_;

    my $timestamp = POSIX::strftime( "%d/%m/%Y %H:%M:%S\n", localtime );
    print "Run details:\n";
    foreach my $entry ( @{$log} ) {
        my @processors_run = @{ $entry->{processors_run} };
        print "Request ID: " . $entry->{request_id} . "\n";
        print "  Processing by: " . $entry->{processed_by} . "\n";
        print "  Number of processors run: " . scalar @processors_run . "\n";
        if ( scalar @processors_run > 0 ) {
            print "  Processor details:\n";
            foreach my $processor (@processors_run) {
                print "    Processor name: " . $processor->{name} . "\n";
                print "    Success messages: " . join( ", ", @{ $processor->{result}->{success} } ) . "\n";
                print "    Error messages: " . join( ", ", @{ $processor->{result}->{error} } ) . "\n";
            }
        }
    }
    print "Job completed at $timestamp\n====================================\n\n";
}

sub debug_msg {
    my ($msg) = @_;

    if ( !$debug ) {
        return;
    }

    if ( ref $msg eq 'HASH' ) {
        use Data::Dumper;
        $msg = Dumper $msg;
    }
    print STDERR "$msg\n";
}

sub get_help {
    print <<"HELP";
$0: Fetch and process outstanding ILL updates

This script will fetch all requests that have the specified
statuses and run any applicable processor scripts on them.
For example, the RapidILL backend provides a processor script
that emails users when their requested electronic resource
request has been fulfilled

Parameters:
    --statuses <statuses>                specify the statuses a request must have in order to be processed,
                                         statuses should be separated by a : e.g. REQ:COMP:NEW. A null value
                                         can be specified by passing null, e.g. --statuses null

    --status-aliases <status-aliases>    specify the statuses aliases a request must have in order to be processed,
                                         statuses should be separated by a : e.g. STA:OLD:PRE. A null value
                                         can be specified by passing null, e.g. --status-aliases null
    --status-to <status-to>              specify the status a successfully processed request must be set to
                                         after processing
    --status-alias-to <status-alias-to>  specify the status alias a successfully processed request must be set to
                                         after processing
    --dry-run                            only produce a run report, without actually doing anything permanent
    --api-delay <seconds>                if a processing script needs to make an API call, how long a pause
                                         should be inserted between each API call
    --debug                              print additional debugging info during run

    --help or -h                         get help
HELP
}
