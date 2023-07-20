#!/usr/bin/perl

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

use Modern::Perl;

use Test::More tests => 6;

use t::lib::TestBuilder;

use C4::Acquisition qw( NewBasket );
use C4::Biblio qw( AddBiblio );
use C4::Budgets qw( AddBudgetPeriod AddBudget );
use C4::Serials qw( NewSubscription SearchSubscriptions );

use Koha::Acquisition::Booksellers;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );

my $schema  = Koha::Database->schema();
my $builder = t::lib::TestBuilder->new;

subtest '->baskets() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin();

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });

    my $vendor = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );

    is( $vendor->baskets->count, 0, 'Vendor has no baskets' );

    # Add two baskets
    my $basket_1_id = C4::Acquisition::NewBasket( $vendor->id, $patron->borrowernumber, 'basketname1' );
    my $basket_2_id = C4::Acquisition::NewBasket( $vendor->id, $patron->borrowernumber, 'basketname2' );

    # Re-fetch vendor
    $vendor = Koha::Acquisition::Booksellers->find( $vendor->id );
    is( $vendor->baskets->count, 2, 'Vendor has two baskets' );

    $schema->storage->txn_rollback();
};

subtest '->subscriptions() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin();

    my $vendor = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );
    is( $vendor->subscriptions->count, 0, 'Vendor has no subscriptions' );

    my $dt_today = dt_from_string;
    my $today    = output_pref(
        { dt => $dt_today, dateformat => 'iso', timeformat => '24hr', dateonly => 1 } );

    my $dt_today1 = dt_from_string;
    my $dur5 = DateTime::Duration->new( days => -5 );
    $dt_today1->add_duration($dur5);
    my $daysago5 = output_pref(
        { dt => $dt_today1, dateformat => 'iso', timeformat => '24hr', dateonly => 1 } );

    my $budgetperiod = C4::Budgets::AddBudgetPeriod(
        {   budget_period_startdate   => $daysago5,
            budget_period_enddate     => $today,
            budget_period_description => "budget desc"
        }
    );
    my $id_budget = AddBudget(
        {   budget_code      => "CODE",
            budget_amount    => "123.132",
            budget_name      => "Budgetname",
            budget_notes     => "This is a note",
            budget_period_id => $budgetperiod
        }
    );
    my $bib = MARC::Record->new();
    $bib->append_fields(
        MARC::Field->new( '245', ' ', ' ', a => 'Journal of ethnology', b => 'A subtitle' ),
        MARC::Field->new( '500', ' ', ' ', a => 'bib notes' ),
    );
    my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $bib, '' );

    # Add two subscriptions
    my $subscription_1_id = NewSubscription(
        undef,        'BRANCH2',     $vendor->id,          undef,
        $id_budget,   $biblionumber, '2013-01-01',         undef,
        undef,        undef,         undef,                undef,
        undef,        undef,         undef,                undef,
        undef,        1,             "subscription notes", undef,
        '2013-01-01', undef,         undef,                undef,
        'CALL ABC',   0,             "intnotes",           0,
        undef,        undef,         0,                    undef,
        '2013-11-30', 0
    );

    my @subscriptions = SearchSubscriptions( { biblionumber => $biblionumber } );
    is( $subscriptions[0]->{publicnotes},
        'subscription notes',
        'subscription search results include public notes (bug 10689)'
    );
    is( $subscriptions[0]->{subtitle},
        'A subtitle',
        'subscription search results include subtitle (bug 30204)'
    );

    my $id_subscription2 = NewSubscription(
        undef,        'BRANCH2',     $vendor->id,          undef,
        $id_budget,   $biblionumber, '2013-01-01',         undef,
        undef,        undef,         undef,                undef,
        undef,        undef,         undef,                undef,
        undef,        1,             "subscription notes", undef,
        '2013-01-01', undef,         undef,                undef,
        'CALL DEF',   0,             "intnotes",           0,
        undef,        undef,         0,                    undef,
        '2013-07-31', 0
    );

    # Re-fetch vendor
    $vendor = Koha::Acquisition::Booksellers->find( $vendor->id );
    my $subscriptions = $vendor->subscriptions;
    is( $subscriptions->count, 2, 'Vendor has two subscriptions' );
    while (my $subscription = $subscriptions->next ) {
        is( ref($subscription), 'Koha::Subscription', 'Type is correct' );
    }

    $schema->storage->txn_rollback();
};

subtest '->contacts() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin();

    my $vendor = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );

    is( $vendor->contacts->count, 0, 'Vendor has no contacts' );

    # Add two contacts
    my $contact_1 = $builder->build_object(
        {   class => 'Koha::Acquisition::Bookseller::Contacts',
            value => { booksellerid => $vendor->id }
        }
    );
    my $contact_2 = $builder->build_object(
        {   class => 'Koha::Acquisition::Bookseller::Contacts',
            value => { booksellerid => $vendor->id }
        }
    );

    # Re-fetch vendor
    $vendor = Koha::Acquisition::Booksellers->find( $vendor->id );
    my $contacts = $vendor->contacts;
    is( $contacts->count, 2, 'Vendor has two contacts' );
    is( ref($contacts), 'Koha::Acquisition::Bookseller::Contacts', 'Type is correct' );

    $schema->storage->txn_rollback();
};

subtest 'aliases' => sub {

    plan tests => 3;

    $schema->storage->txn_begin();

    my $vendor = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );

    is( $vendor->aliases->count, 0, 'Vendor has no aliases' );

    $vendor->aliases( [ { alias => 'alias 1' }, { alias => 'alias 2' } ] );

    $vendor = $vendor->get_from_storage;
    my $aliases = $vendor->aliases;
    is( $aliases->count, 2 );
    is( ref($aliases), 'Koha::Acquisition::Bookseller::Aliases', 'Type is correct' );

    $schema->storage->txn_rollback();
};

subtest 'interfaces' => sub {

    plan tests => 11;

    $schema->storage->txn_begin();

    my $vendor = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );

    is( $vendor->interfaces->count, 0, 'Vendor has no interfaces' );

    $vendor->interfaces( [ { name => 'first interface' }, { name => 'second interface', login => 'one_login' } ] );

    $vendor = $vendor->get_from_storage;
    my $interfaces = $vendor->interfaces;
    is( $interfaces->count, 2, '2 interfaces stored' );
    is( ref($interfaces), 'Koha::Acquisition::Bookseller::Interfaces', 'Type is correct' );

    $vendor->interfaces( [ { name => 'first interface', login => 'one_login', password => 'oneP@sswOrd' } ] );
    $vendor     = $vendor->get_from_storage;
    $interfaces = $vendor->interfaces;
    is( $interfaces->count, 1, '1 interface stored' );
    my $interface = $interfaces->next;
    is( $interface->name,  'first interface', 'name correctly saved' );
    is( $interface->login, 'one_login',       'login correctly saved' );
    is( $interface->uri,   undef,             'no value is stored as NULL' );
    isnt( $interface->password, 'oneP@sswOrd', 'Password is not stored in plain text' );
    isnt( $interface->password, '',            'Password is not removed' );
    isnt( $interface->password, undef,         'Password is not set to NULL' );
    is( $interface->plain_text_password, 'oneP@sswOrd', 'Password can be retrieved using ->plain_text_password' );

    $schema->storage->txn_rollback();
};

subtest 'issues' => sub {

    plan tests => 4;

    $schema->storage->txn_begin();

    my $vendor = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );

    is( $vendor->issues->count, 0, 'Vendor has no issues' );

    Koha::Acquisition::Bookseller::Issue->new(
        {
            vendor_id => $vendor->id,
            type      => 'MAINTENANCE',
            notes     => 'a vendor issue'
        }
    )->store;

    $vendor = $vendor->get_from_storage;
    my $issues = $vendor->issues;
    is( $issues->count, 1,                                       '1 issue stored' );
    is( ref($issues),   'Koha::Acquisition::Bookseller::Issues', 'Type is correct' );

    is( $issues->next->strings_map->{type}->{str}, 'Maintenance' );

    $schema->storage->txn_rollback();
};
