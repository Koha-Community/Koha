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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;

use Koha::Script -cron;
use C4::Letters qw( SendQueuedMessages );
use C4::Log     qw( cronlogaction );
use Try::Tiny   qw( catch try );

my $opt = Koha::Script->describe_options(
    'This script processes the message queue in the message_queue database
table. It sends out the messages in that queue and marks them
appropriately to indicate success or failure. It is recommended that
you run this regularly from cron, especially if you are using the
advance_notices.pl script.

%c %o',
    [ 'username|u:s', 'username of mail account' ],
    [ 'password|p:s', 'password of mail account' ],
    [ 'type|t:s@',    'if supplied, only processes this type of message (email, sms), repeatable' ],
    [ 'code|c:s@',    'if supplied, only processes messages with this letter code, repeatable' ],
    [
        'exclude-code|x:s@',
        'if supplied, processes all messages except those with this letter code, repeatable'
    ],
    [ 'limit|l:s', 'the maximum number of messages to process for this run' ],
    [
        'method|m:s',
        'authentication method required by SMTP server (see perldoc Sendmail.pm for supported authentication types)',
        { default => 'LOGIN' }
    ],
    [ 'verbose|v', 'provides verbose output to STDOUT' ],
    [ 'where|w:s', 'filter messages to send with additional conditions in the where clause' ],
    [
        'exit-on-plugin-failure|e',
        'if enabled, script will exit prematurely if any plugin before_send_messages hook fails'
    ],
    { exclusive => [ [qw(code exclude-code)] ] },
);

# Remove empty elements, see bug 37075. -c/-x take an optional value ('code|c:s@'), so a bare
# flag with no value still leaves an empty string in the array.
my @letter_code         = grep { $_ ne q{} } @{ $opt->code         // [] };
my @exclude_letter_code = grep { $_ ne q{} } @{ $opt->exclude_code // [] };

my $script_handler = Koha::Script->new( { script => $0 } );

try {
    $script_handler->lock_exec;
} catch {
    my $message = "Skipping execution of $0 ($_)";
    print STDERR "$message\n"
        if $opt->verbose;
    cronlogaction( { info => $message } );
    exit;
};

C4::Letters::SendQueuedMessages(
    {
        verbose                => $opt->verbose,
        username               => $opt->username,
        password               => $opt->password,
        method                 => $opt->method,
        limit                  => $opt->limit,
        type                   => $opt->type // [],
        letter_code            => \@letter_code,
        exclude_letter_code    => \@exclude_letter_code,
        where                  => $opt->where,
        exit_on_plugin_failure => $opt->exit_on_plugin_failure,
    }
);

