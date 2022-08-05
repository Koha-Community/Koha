#!/usr/bin/perl 
#-----------------------------------
# Script Name: build_holds_queue.pl
# Description: builds a holds queue in the tmp_holdsqueue table
#-----------------------------------
# FIXME: add command-line options for verbosity and summary
# FIXME: expand perldoc, explain intended logic

use strict;
use warnings;

use Koha::Script -cron;
use C4::HoldsQueue qw(CreateQueue);
use C4::Log qw( cronlogaction );

my $command_line_options = join(" ",@ARGV);
cronlogaction({ info => $command_line_options });

CreateQueue();

cronlogaction({ action => 'End', info => "COMPLETED" });
