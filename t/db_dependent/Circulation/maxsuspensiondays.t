use Modern::Perl;
use Test::More tests => 4;

use MARC::Record;
use MARC::Field;
use C4::Context;

use C4::Circulation qw( AddIssue AddReturn );
use C4::Biblio qw( AddBiblio );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Patron::Debarments qw( DelDebarment );
use Koha::Patrons;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
my $itemtype   = $builder->build({ source => 'Itemtype' })->{itemtype};
my $patron_category = $builder->build({ source => 'Category' });

t::lib::Mocks::mock_userenv({ branchcode => $branchcode });

# Test without maxsuspensiondays set
Koha::CirculationRules->search->delete;
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rules        => {
            firstremind => 0,
            finedays    => 2,
            lengthunit  => 'days',
            suspension_chargeperiod => 1,
        }
    }
);

my $patron = Koha::Patron->new({
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => $patron_category->{categorycode},
    branchcode => $branchcode,
})->store;

my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'My author'),
    MARC::Field->new('245', ' ', ' ', a => 'My title'),
);

my $barcode = 'bc_maxsuspensiondays';
my ($biblionumber, $biblioitemnumber) = AddBiblio($record, '');
my $itemnumber = Koha::Item->new({
        biblionumber => $biblionumber,
        homebranch => $branchcode,
        holdingbranch => $branchcode,
        barcode => $barcode,
        itype => $itemtype
    })->store->itemnumber;

# clear any holidays to avoid throwing off the suspension day
# calculations
$dbh->do('DELETE FROM special_holidays');
$dbh->do('DELETE FROM repeatable_holidays');

my $daysago20 = dt_from_string->add_duration(DateTime::Duration->new(days => -20));
my $daysafter40 = dt_from_string->add_duration(DateTime::Duration->new(days => 40));

AddIssue( $patron, $barcode, $daysago20 );
AddReturn( $barcode, $branchcode );
my $debarments = $patron->restrictions;
my $THE_debarment = $debarments->next;
is(
    $THE_debarment->expiration,
    output_pref({ dt => $daysafter40, dateformat => 'iso', dateonly => 1 }),
    'calculate suspension with no maximum set'
);
DelDebarment( $THE_debarment->borrower_debarment_id );

# Test with maxsuspensiondays = 10 days
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rules        => {
            maxsuspensiondays => 10,
        }
    }
);

my $daysafter10 = dt_from_string->add_duration(DateTime::Duration->new(days => 10));
AddIssue( $patron, $barcode, $daysago20 );
AddReturn( $barcode, $branchcode );
$debarments = $patron->restrictions;
$THE_debarment = $debarments->next;
is(
    $THE_debarment->expiration,
    output_pref({ dt => $daysafter10, dateformat => 'iso', dateonly => 1 }),
    'calculate suspension with a maximum set'
);
DelDebarment( $THE_debarment->borrower_debarment_id );

subtest "suspension_chargeperiod" => sub {
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                firstremind  => 0,
                finedays     => 7,
                lengthunit   => 'days',
                suspension_chargeperiod => 15,
                maxsuspensiondays => 333,
            }
        }
    );
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $item = $builder->build_sample_item;

    my $last_year = dt_from_string->clone->subtract( years => 1 );
    my $today = dt_from_string;
    my $new_debar_dt = C4::Circulation::_calculate_new_debar_dt( $patron, $item, $last_year, $today );
    is( $new_debar_dt->truncate( to => 'day' ),
        $today->clone->add( days => 365 / 15 * 7 )->truncate( to => 'day' ) );

};

subtest "maxsuspensiondays" => sub {
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                firstremind  => 0,
                finedays     => 15,
                lengthunit   => 'days',
                suspension_chargeperiod => 7,
                maxsuspensiondays => 333,
            }
        }
    );
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $item = $builder->build_sample_item;

    my $last_year = dt_from_string->clone->subtract( years => 1 );
    my $today = dt_from_string;
    my $new_debar_dt = C4::Circulation::_calculate_new_debar_dt( $patron, $item, $last_year, $today );
    is( $new_debar_dt->truncate( to => 'day' ),
        $today->clone->add( days => 333 )->truncate( to => 'day' ) );
};

$schema->storage->txn_rollback;
