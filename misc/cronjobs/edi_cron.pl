#!/usr/bin/perl
#
# Copyright 2013,2014,2015 PTFS Europe Ltd
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use warnings;
use strict;
use utf8;

# Handles all the edi processing for a site
# loops through the vendor_edifact records and uploads and downloads
# edifact files if the appropriate type is enabled
# downloaded quotes, invoices and responses are processed here
# if orders are enabled and present they are generated and sent
# can be run as frequently as required
# log messages are appended to logdir/editrace.log

use C4::Context;
use Log::Log4perl qw(:easy);
use Koha::Database;
use Koha::EDI qw( process_quote process_invoice process_ordrsp);
use Koha::Edifact::Transport;
use Fcntl qw( :DEFAULT :flock :seek );

my $logdir = C4::Context->config('logdir');

# logging set to trace as this may be what you
# want on implementation
Log::Log4perl->easy_init(
    {
        level => $TRACE,
        file  => ">>$logdir/editrace.log",
    }
);

# we dont have a lock dir in context so use the logdir
my $pidfile = "$logdir/edicron.pid";

my $pid_handle = check_pidfile();

my $schema = Koha::Database->new()->schema();

my @edi_accts = $schema->resultset('VendorEdiAccount')->all();

my $logger = Log::Log4perl->get_logger();

for my $acct (@edi_accts) {
    if ( $acct->quotes_enabled ) {
        my $downloader = Koha::Edifact::Transport->new( $acct->id );
        $downloader->download_messages('QUOTE');

    }

    if ( $acct->invoices_enabled ) {
        my $downloader;

        if ( $acct->plugin ) {
            $downloader = Koha::Plugins::Handler->run(
                {
                    class  => $acct->plugin,
                    method => 'edifact_transport',
                    params => {
                        vendor_edi_account_id => $acct->id,
                    }
                }
            );
        }

        $downloader ||= Koha::Edifact::Transport->new( $acct->id );

        $downloader->download_messages('INVOICE');

    }
    if ( $acct->orders_enabled ) {

        # select pending messages
        my @pending_orders = $schema->resultset('EdifactMessage')->search(
            {
                message_type => 'ORDERS',
                vendor_id    => $acct->vendor_id,
                status       => 'Pending',
            }
        );
        my $uploader = Koha::Edifact::Transport->new( $acct->id );
        $uploader->upload_messages(@pending_orders);
    }
    if ( $acct->responses_enabled ) {
        my $downloader = Koha::Edifact::Transport->new( $acct->id );
        $downloader->download_messages('ORDRSP');
    }
}

# process any downloaded quotes

my @downloaded_quotes = $schema->resultset('EdifactMessage')->search(
    {
        message_type => 'QUOTE',
        status       => 'new',
    }
)->all;

foreach my $quote_file (@downloaded_quotes) {
    my $filename = $quote_file->filename;
    $logger->trace("Processing quote $filename");
    process_quote($quote_file);
}

# process any downloaded invoices

my @downloaded_invoices = $schema->resultset('EdifactMessage')->search(
    {
        message_type => 'INVOICE',
        status       => 'new',
    }
)->all;

foreach my $invoice (@downloaded_invoices) {
    my $filename = $invoice->filename();
    $logger->trace("Processing invoice $filename");

    my $plugin_used = 0;
    if ( my $plugin_class = $invoice->edi_acct->plugin ) {
        my $plugin = $plugin_class->new();
        if ( $plugin->can('edifact_process_invoice') ) {
            $plugin_used = 1;
            Koha::Plugins::Handler->run(
                {
                    class  => $plugin_class,
                    method => 'edifact_process_invoice',
                    params => {
                        invoice => $invoice,
                    }
                }
            );
        }
    }

    process_invoice($invoice) unless $plugin_used;
}

my @downloaded_responses = $schema->resultset('EdifactMessage')->search(
    {
        message_type => 'ORDRSP',
        status       => 'new',
    }
)->all;

foreach my $response (@downloaded_responses) {
    my $filename = $response->filename();
    $logger->trace("Processing order response $filename");
    process_ordrsp($response);
}

if ( close $pid_handle ) {
    unlink $pidfile;
    exit 0;
}
else {
    $logger->error("Error on pidfile close: $!");
    exit 1;
}

sub check_pidfile {

    # sysopen my $fh, $pidfile, O_EXCL | O_RDWR or log_exit "$0 already running"
    sysopen my $fh, $pidfile, O_RDWR | O_CREAT
      or log_exit("$0: open $pidfile: $!");
    flock $fh => LOCK_EX or log_exit("$0: flock $pidfile: $!");

    sysseek $fh, 0, SEEK_SET or log_exit("$0: sysseek $pidfile: $!");
    truncate $fh, 0 or log_exit("$0: truncate $pidfile: $!");
    print $fh "$$\n" or log_exit("$0: print $pidfile: $!");

    return $fh;
}

sub log_exit {
    my $error = shift;
    $logger->error($error);

    exit 1;
}
