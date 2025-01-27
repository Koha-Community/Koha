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

use Test::More tests => 2;
use t::lib::TestBuilder;
use t::lib::Mocks;
use File::Spec;
use File::Basename;

use Koha::DateUtils qw( dt_from_string );

my $scriptDir = dirname( File::Spec->rel2abs(__FILE__) );

my $schema = Koha::Database->new->schema;
my $dbh    = C4::Context->dbh;

my $library1;
my $library2;
my $library3;
my $borrower;

sub build_test_objects {

    # Set only to avoid exception.
    t::lib::Mocks::mock_preference( 'dateformat', 'metric' );

    my $builder = t::lib::TestBuilder->new;

    $library1 = $builder->build(
        {
            source => 'Branch',
        }
    );
    $library2 = $builder->build(
        {
            source => 'Branch',
        }
    );
    $library3 = $builder->build(
        {
            source => 'Branch',
        }
    );
    $borrower = $builder->build(
        {
            source => 'Borrower',
            value  => {
                branchcode => $library1->{branchcode},
            }
        }
    );
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

    my $message_attribute = $builder->build(
        {
            source => 'MessageAttribute',
            value  => { message_name => 'Advance_Notice' }
        }
    );

    my $letter = $builder->build(
        {
            source => 'Letter',
            value  => {
                module                 => 'circulation',
                code                   => 'PREDUEDGST',
                branchcode             => '',
                message_transport_type => 'email',
                lang                   => 'default',
                is_html                => 0,
                content                => '<<count>> <<branches.branchname>>'
            }
        }
    );
    my $borrower_message_preference = $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $borrower->{borrowernumber},
                wants_digest         => 1,
                days_in_advance      => 1,
                message_attribute_id => $message_attribute->{message_attribute_id}
            }
        }
    );

    my $borrower_message_transport_preference = $builder->build(
        {
            source => 'BorrowerMessageTransportPreference',
            value  => {
                borrower_message_preference_id => $borrower_message_preference->{borrower_message_preference_id},
                message_transport_type         => 'email'
            }
        }
    );

    #Adding a second preference for a notice that isn't defined, should just be skipped
    my $borrower_message_transport_preference_1 = $builder->build(
        {
            source => 'BorrowerMessageTransportPreference',
            value  => {
                borrower_message_preference_id => $borrower_message_preference->{borrower_message_preference_id},
                message_transport_type         => 'phone'
            }
        }
    );

    my $item1    = $builder->build_sample_item;
    my $item2    = $builder->build_sample_item;
    my $item3    = $builder->build_sample_item;
    my $now      = dt_from_string();
    my $tomorrow = $now->add( days => 1 )->strftime('%F');

    my $issue1 = $builder->build(
        {
            source => 'Issue',
            value  => {
                date_due       => $tomorrow,
                itemnumber     => $item1->itemnumber,
                branchcode     => $library2->{branchcode},
                borrowernumber => $borrower->{borrowernumber},
                returndate     => undef
            }
        }
    );

    my $issue2 = $builder->build(
        {
            source => 'Issue',
            value  => {
                date_due       => $tomorrow,
                itemnumber     => $item2->itemnumber,
                branchcode     => $library3->{branchcode},
                borrowernumber => $borrower->{borrowernumber},
                returndate     => undef
            }
        }
    );
    my $issue3 = $builder->build(
        {
            source => 'Issue',
            value  => {
                date_due       => $tomorrow,
                itemnumber     => $item3->itemnumber,
                branchcode     => $library3->{branchcode},
                borrowernumber => $borrower->{borrowernumber},
                returndate     => undef
            }
        }
    );

    C4::Context->set_preference( 'EnhancedMessagingPreferences', 1 );
}

sub run_script {
    my $script = shift;
    local @ARGV = @_;

    # We simulate script execution by evaluating the script code in the context
    # of this unit test.

    eval $script;    ## no critic (StringyEval)

    die $@ if $@;
}

my $scriptContent = '';
my $scriptFile    = "$scriptDir/../../../misc/cronjobs/advance_notices.pl";
open my $scriptfh, "<", $scriptFile or die "Failed to open $scriptFile: $!";

while (<$scriptfh>) {
    $scriptContent .= $_;
}
close $scriptfh;

my $sthmq = $dbh->prepare('SELECT * FROM message_queue WHERE borrowernumber = ?');

subtest 'Default behaviour tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    build_test_objects();

    run_script( $scriptContent, 'advanced_notices.pl', '-c' );

    $sthmq->execute( $borrower->{borrowernumber} );

    my $messages = $sthmq->fetchall_hashref('message_id');

    is( scalar( keys %$messages ), 1, 'There is one message in the queue' );

    for my $message ( keys %$messages ) {
        $messages->{$message}->{content} =~ /(\d+) (.*)/;
        my $count      = $1;
        my $branchname = $2;

        is( $count,      '3',                     'Issue count is 3' );
        is( $branchname, $library1->{branchname}, 'Branchname is that of borrowers home branch.' );
    }

    $schema->storage->txn_rollback;
};

subtest '--digest-per-branch tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    build_test_objects();

    run_script( $scriptContent, 'advanced_notices.pl', '-c', '-digest-per-branch' );

    $sthmq->execute( $borrower->{borrowernumber} );

    my $messages = $sthmq->fetchall_hashref('message_id');

    is( scalar( keys %$messages ), 2, 'There are two messages in the queue' );

    my %expected = (
        $library2->{branchname} => {
            count => 1,
        },
        $library3->{branchname} => {
            count => 2,
        }
    );

    my %expected_branchnames = (
        $library2->{branchname} => 1,
        $library3->{branchname} => 1
    );

    my $i = 0;
    for my $message ( keys %$messages ) {
        $messages->{$message}->{content} =~ /(\d+) (.*)/;
        my $count      = $1;
        my $branchname = $2;

        ok( $expected_branchnames{$branchname}, 'Branchname is that of expected issuing branch.' );

        $expected_branchnames{$branchname} = 0;

        is( $count, $expected{$branchname}->{count}, 'Issue count is ' . $expected{$branchname}->{count} );

        $i++;
    }

    $schema->storage->txn_rollback;
};
