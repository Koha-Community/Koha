#!/usr/bin/perl
#
# This file is part of Koha.
#
# Copyright (C) 2018  Andreas Jonsson <andreas.jonsson@kreablo.se>
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

use Modern::Perl;

use Test::More tests => 3;
use t::lib::TestBuilder;
use DateTime;
use File::Spec;
use File::Basename;
use Data::Dumper;

my $scriptDir = dirname(File::Spec->rel2abs( __FILE__ ));

my $dbh = C4::Context->dbh;

# Set only to avoid exception.
$ENV{"OVERRIDE_SYSPREF_dateformat"} = 'metric';

$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;

my $library1 = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
    source => 'Branch',
});
my $library3 = $builder->build({
    source => 'Branch',
});
my $borrower = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library1->{branchcode},
    }
});
$dbh->do(<<DELETESQL);
DELETE FROM letter
 WHERE module='circulation'
   AND code = 'PREDUEDGST'
   AND message_transport_type='email'
   AND branchcode=''
DELETESQL
$dbh->do(<<DELETESQL);
DELETE FROM message_attributes WHERE message_name = 'Advance_Notice'
DELETESQL

my $message_attribute = $builder->build({
    source => 'MessageAttribute',
    value => {
        message_name => 'Advance_Notice'
    }
});

my $letter = $builder->build({
    source => 'Letter',
    value => {
        module => 'circulation',
        code => 'PREDUEDGST',
        branchcode => '',
        message_transport_type => 'email',
        lang => 'default',
        is_html => 0,
        content => '<<count>> <<branches.branchname>>'
    }
});
my $borrower_message_preference = $builder->build({
    source => 'BorrowerMessagePreference',
    value => {
        borrowernumber => $borrower->{borrowernumber},
        wants_digest => 1,
        days_in_advance => 1,
        message_attribute_id => $message_attribute->{message_attribute_id}
    }
});

my $borrower_message_transport_preference = $builder->build({
    source => 'BorrowerMessageTransportPreference',
    value => {
        borrower_message_preference_id => $borrower_message_preference->{borrower_message_preference_id},
        message_transport_type => 'email'
    }
});

my $biblio = $builder->build({
    source => 'Biblio',
});
my $biblioitem = $builder->build({
    source => 'Biblioitem',
    value => {
        biblionumber => $biblio->{biblionumber}
    }
});
my $item1 = $builder->build({
    source => 'Item'
});
my $item2 = $builder->build({
    source => 'Item'
});
my $now = DateTime->now();
my $tomorrow = $now->add(days => 1)->strftime('%F');

my $issue1 = $builder->build({
    source => 'Issue',
    value => {
        date_due => $tomorrow,
        itemnumber => $item1->{itemnumber},
        branchcode => $library1->{branchcode},
        borrowernumber => $borrower->{borrowernumber},
        returndate => undef
    }
});

my $issue2 = $builder->build({
    source => 'Issue',
    value => {
        date_due => $tomorrow,
        itemnumber => $item2->{itemnumber},
        branchcode => $library2->{branchcode},
        branchcode => $library3->{branchcode},
        borrowernumber => $borrower->{borrowernumber},
        returndate => undef
    }
});

C4::Context->set_preference('EnhancedMessagingPreferences', 1);

my $script = '';
my $scriptFile = "$scriptDir/../../../misc/cronjobs/advance_notices.pl";
open my $scriptfh, "<", $scriptFile or die "Failed to open $scriptFile: $!";

while (<$scriptfh>) {
    $script .= $_;
}
close $scriptfh;

@ARGV = ('advanced_notices.pl', '-c');

## no critic

# We simulate script execution by evaluating the script code in the context
# of this unit test.

eval $script; #Violates 'ProhibitStringyEval'

## use critic

die $@ if $@;

my $sthmq = $dbh->prepare('SELECT * FROM message_queue WHERE borrowernumber = ?');
$sthmq->execute($borrower->{borrowernumber});

my $messages = $sthmq->fetchall_hashref('message_id');

is(scalar(keys %$messages), 1, 'There is one message in the queue');
for my $message (keys %$messages) {
    $messages->{$message}->{content} =~ /(\d+) (.*)/;
    my $count = $1;
    my $branchname = $2;

    is ($count, '2', 'Issue count is 2');
    is ($branchname, $library1->{branchname}, 'Branchname is that of borrowers home branch.');
}

$dbh->rollback;
