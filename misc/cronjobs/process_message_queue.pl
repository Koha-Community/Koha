#!/usr/bin/perl

# Copyright 2008 LibLime
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

use Koha::Script -cron;
use C4::Letters qw( SendQueuedMessages );
use C4::Log qw( cronlogaction );
use Getopt::Long qw( GetOptions );
use Try::Tiny qw( catch try );

my $username = undef;
my $password = undef;
my $limit    = undef;
my $method = 'LOGIN';
my $help = 0;
my $verbose = 0;
my @type;
my @letter_code;

my $command_line_options = join(" ",@ARGV);

GetOptions(
    'u|username:s'      => \$username,
    'p|password:s'      => \$password,
    'l|limit:s'         => \$limit,
    'm|method:s'        => \$method,
    'h|help|?'          => \$help,
    'v|verbose'         => \$verbose,
    't|type:s'          => \@type,
    'c|code:s'          => \@letter_code,
);
my $usage = << 'ENDUSAGE';

This script processes the message queue in the message_queue database
table. It sends out the messages in that queue and marks them
appropriately to indicate success or failure. It is recommended that
you run this regularly from cron, especially if you are using the
advance_notices.pl script.

This script has the following parameters :
    -u --username: username of mail account
    -p --password: password of mail account
    -t --type: If supplied, only processes this type of message ( email, sms ), repeatable
    -c --code: If supplied, only processes messages with this letter code, repeatable
    -l --limit: The maximum number of messages to process for this run
    -m --method: authentication method required by SMTP server (See perldoc Sendmail.pm for supported authentication types.)
    -h --help: this message
    -v --verbose: provides verbose output to STDOUT
ENDUSAGE

die $usage if $help;

my $script_handler = Koha::Script->new({ script => $0 });

try {
    $script_handler->lock_exec;
}
catch {
    my $message = "Skipping execution of $0 ($_)";
    print STDERR "$message\n"
        if $verbose;
    cronlogaction({ info => $message });
    exit;
};

cronlogaction({ info => $command_line_options });

if ( C4::Context->config("enable_plugins") ) {
    my @plugins = Koha::Plugins->new->GetPlugins({
        method => 'before_send_messages',
    });

    if (@plugins) {
        foreach my $plugin ( @plugins ) {
            try {
                $plugin->before_send_messages(
                    {
                        verbose     => $verbose,
                        limit       => $limit,
                        type        => \@type,
                        letter_code => \@letter_code,
                    }
                );
            }
            catch {
                warn "$_";
            };
        }
    }
}

C4::Letters::SendQueuedMessages(
    {
        verbose     => $verbose,
        username    => $username,
        password    => $password,
        method      => $method,
        limit       => $limit,
        type        => \@type,
        letter_code => \@letter_code,
    }
);

cronlogaction({ action => 'End', info => "COMPLETED" });
