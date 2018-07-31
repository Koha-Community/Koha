use Modern::Perl;
use Test::More tests => 2;

use MARC::Record;
use MARC::Field;
use C4::Context;

use C4::Circulation qw( AddIssue AddReturn );
use C4::Items qw( AddItem );
use C4::Biblio qw( AddBiblio );
use Koha::Database;
use Koha::DateUtils;
use Koha::Patron::Debarments qw( GetDebarments DelDebarment );
use Koha::Patrons;

use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
my $itemtype   = $builder->build({ source => 'Itemtype' })->{itemtype};
my $patron_category = $builder->build({ source => 'Category' });

local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /redefined/ };
my $userenv->{branch} = $branchcode;
*C4::Context::userenv = \&Mock_userenv;

# Test without maxsuspensiondays set
Koha::IssuingRules->search->delete;
$builder->build(
    {
        source => 'Issuingrule',
        value  => {
            categorycode => '*',
            itemtype     => '*',
            branchcode   => '*',
            firstremind  => 0,
            finedays     => 2,
            lengthunit   => 'days',
            suspension_chargeperiod => 1,
        }
    }
);

my $borrowernumber = Koha::Patron->new({
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => $patron_category->{categorycode},
    branchcode => $branchcode,
})->store->borrowernumber;
my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;

my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'My author'),
    MARC::Field->new('245', ' ', ' ', a => 'My title'),
);

my $barcode = 'bc_maxsuspensiondays';
my ($biblionumber, $biblioitemnumber) = AddBiblio($record, '');
my (undef, undef, $itemnumber) = AddItem({
        homebranch => $branchcode,
        holdingbranch => $branchcode,
        barcode => $barcode,
        itype => $itemtype
    } , $biblionumber);

# clear any holidays to avoid throwing off the suspension day
# calculations
$dbh->do('DELETE FROM special_holidays');
$dbh->do('DELETE FROM repeatable_holidays');

my $daysago20 = dt_from_string->add_duration(DateTime::Duration->new(days => -20));
my $daysafter40 = dt_from_string->add_duration(DateTime::Duration->new(days => 40));

AddIssue( $borrower, $barcode, $daysago20 );
AddReturn( $barcode, $branchcode );
my $debarments = GetDebarments({borrowernumber => $borrower->{borrowernumber}});
is(
    $debarments->[0]->{expiration},
    output_pref({ dt => $daysafter40, dateformat => 'iso', dateonly => 1 }),
    'calculate suspension with no maximum set'
);
DelDebarment( $debarments->[0]->{borrower_debarment_id} );

# Test with maxsuspensiondays = 10 days
my $issuing_rule = Koha::IssuingRules->search->next;
$issuing_rule->maxsuspensiondays( 10 )->store;

my $daysafter10 = dt_from_string->add_duration(DateTime::Duration->new(days => 10));
AddIssue( $borrower, $barcode, $daysago20 );
AddReturn( $barcode, $branchcode );
$debarments = GetDebarments({borrowernumber => $borrower->{borrowernumber}});
is(
    $debarments->[0]->{expiration},
    output_pref({ dt => $daysafter10, dateformat => 'iso', dateonly => 1 }),
    'calculate suspension with a maximum set'
);
DelDebarment( $debarments->[0]->{borrower_debarment_id} );

$schema->storage->txn_rollback;

# C4::Context->userenv
sub Mock_userenv {
    return $userenv;
}
