#!/usr/bin/perl

# Copyright 2017 Koha Development team
#
# This file is part of Koha
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

use Test::NoWarnings;
use Test::More tests => 10;

use Koha::Notice::Templates;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder         = t::lib::TestBuilder->new;
my $library         = $builder->build( { source => 'Branch' } );
my $nb_of_templates = Koha::Notice::Templates->search->count;
my ( $module, $mtt ) = ( 'circulation', 'email' );
my $new_template = Koha::Notice::Template->new(
    {
        module                 => $module,
        code                   => 'tmpl_code_for_t',
        branchcode             => $library->{branchcode},
        name                   => 'my template name for test 1',
        title                  => 'my template title for test 1',
        content                => 'This one is almost empty',
        message_transport_type => $mtt,
    }
)->store;

is(
    Koha::Notice::Templates->search->count,
    $nb_of_templates + 1,
    'The template should have been added'
);

my $retrieved_template = Koha::Notice::Templates->find(
    {
        module                 => $module,
        code                   => $new_template->code,
        branchcode             => $library->{branchcode},
        message_transport_type => $mtt,
    }
);
is(
    $retrieved_template->name, $new_template->name,
    'Find a notice template by pk should return the correct template'
);

$retrieved_template->delete;
is(
    Koha::Notice::Templates->search->count,
    $nb_of_templates, 'Delete should have deleted the template'
);

## Tests for Koha::Notice::Messages->get_failed_notices

# Remove all existing messages in the message_queue
Koha::Notice::Messages->delete;

# Make a patron
my $patron_category = $builder->build( { source => 'Category' } )->{categorycode};
my $patron          = Koha::Patron->new(
    {
        firstname      => 'Jane',
        surname        => 'Smith',
        categorycode   => $patron_category,
        branchcode     => $library->{branchcode},
        smsalertnumber => '123',
    }
)->store;
my $borrowernumber = $patron->borrowernumber;

# With all notices removed from the message_queue table confirm get_failed_notices() returns 0
my @failed_notices = Koha::Notice::Messages->get_failed_notices->as_list;
is( @failed_notices, 0, 'No failed notices currently exist' );

# Add a failed notice to the message_queue table
my $message = Koha::Notice::Message->new(
    {
        borrowernumber         => $borrowernumber,
        subject                => 'subject',
        content                => 'content',
        message_transport_type => 'sms',
        status                 => 'failed',
        letter_code            => 'just_a_code',
        time_queued            => \"NOW()",
    }
)->store;

# With one failed notice in the message_queue table confirm get_failed_notices() returns 1
my @failed_notices2 = Koha::Notice::Messages->get_failed_notices->as_list;
is( @failed_notices2, 1, 'One failed notice currently exists' );

# Change failed notice status to 'pending'
$message->update( { status => 'pending' } );

# With the 1 failed notice in the message_queue table marked 'pending' confirm get_failed_notices() returns 0
my @failed_notices3 = Koha::Notice::Messages->get_failed_notices->as_list;
is( @failed_notices3, 0, 'No failed notices currently existing, now the notice has been marked pending' );

## Tests for Koha::Notice::Message::restrict_patron_when_notice_fails

# Empty the borrower_debarments table
my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM borrower_debarments|);

# Change the status of the notice back to 'failed'
$message->update( { status => 'failed' } );

my @failed_notices4 = Koha::Notice::Messages->get_failed_notices->as_list;

# There should be one failed notice
if (@failed_notices4) {

    # Restrict the borrower who has the failed notice
    foreach my $failed_notice (@failed_notices4) {
        if ( $failed_notice->message_transport_type eq 'sms' || $failed_notice->message_transport_type eq 'email' ) {
            $failed_notice->restrict_patron_when_notice_fails;
        }
    }
}

# Confirm that the restrict_patron_when_notice_fails() has added a restriction to the patron
is(
    $patron->restrictions->search( { comment => 'SMS number invalid' } )->count, 1,
    "Patron has a restriction placed on them"
);

# Restrict the borrower who has the failed notice
foreach my $failed_notice (@failed_notices4) {
    if ( $failed_notice->message_transport_type eq 'sms' || $failed_notice->message_transport_type eq 'email' ) {

        # If the borrower already has a debarment for failed SMS or email notice then don't apply
        # a new debarment to their account
        if ( $patron->restrictions->search( { comment => 'SMS number invalid' } )->count > 0 ) {
            next;
        } elsif ( $patron->restrictions->search( { comment => 'Email address invalid' } )->count > 0 ) {
            next;
        }

        # Place the debarment if the borrower doesn't already have one for failed SMS or email
        # notice
        $failed_notice->restrict_patron_when_notice_fails;
    }
}

# Confirm that no new debarment is added to the borrower
is(
    $patron->restrictions->search( { comment => 'SMS number invalid' } )->count, 1,
    "No new restriction has been placed on the patron"
);

subtest 'find_effective_template' => sub {
    plan tests => 7;

    my $default_template = $builder->build_object(
        { class => 'Koha::Notice::Templates', value => { branchcode => '', lang => 'default' } } );
    my $key = {
        module                 => $default_template->module,
        code                   => $default_template->code,
        message_transport_type => $default_template->message_transport_type,
    };

    my $library_specific_template =
        $builder->build_object( { class => 'Koha::Notice::Templates', value => { %$key, lang => 'default' } } );

    my $es_template = $builder->build_object(
        {
            class => 'Koha::Notice::Templates',
            value => { %$key, lang => 'es-ES' },
        }
    );

    $key->{branchcode} = $es_template->branchcode;

    t::lib::Mocks::mock_preference( 'TranslateNotices', 0 );

    my $template = Koha::Notice::Templates->find_effective_template($key);
    is( $template->lang, 'default', 'no lang passed, default is returned' );
    $template = Koha::Notice::Templates->find_effective_template( { %$key, lang => 'es-ES' } );
    is(
        $template->lang, 'default',
        'TranslateNotices is off, default is returned'
    );

    t::lib::Mocks::mock_preference( 'TranslateNotices', 1 );
    $template = Koha::Notice::Templates->find_effective_template($key);
    is( $template->lang, 'default', 'no lang passed, default is returned' );
    $template = Koha::Notice::Templates->find_effective_template( { %$key, lang => 'es-ES' } );
    is(
        $template->lang, 'es-ES',
        'TranslateNotices is on and es-ES is requested, es-ES is returned'
    );

    {    # IndependentBranches => 1
        t::lib::Mocks::mock_userenv( { branchcode => $library_specific_template->branchcode, flag => 0 } );
        t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );
        $template = Koha::Notice::Templates->find_effective_template(
            { %$key, branchcode => $library_specific_template->branchcode } );
        is(
            $template->content, $library_specific_template->content,
            'IndependentBranches is on, logged in patron is not superlibrarian but asks for their specific template, it is returned'
        );

        my $another_library = $builder->build_object( { class => 'Koha::Libraries' } );
        t::lib::Mocks::mock_userenv( { branchcode => $another_library->branchcode, flag => 0 } );
        $template = Koha::Notice::Templates->find_effective_template($key);
        is(
            $template->content, $default_template->content,
            'IndependentBranches is on, logged in patron is not superlibrarian, default is returned'
        );
    }

    t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );
    $es_template->delete;

    $template = Koha::Notice::Templates->find_effective_template( { %$key, lang => 'es-ES' } );
    is(
        $template->lang, 'default',
        'TranslateNotices is on and es-ES is requested but does not exist, default is returned'
    );

};

$schema->storage->txn_rollback;
