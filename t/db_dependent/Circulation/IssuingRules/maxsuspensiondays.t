use Modern::Perl;
use Test::More tests => 2;

use MARC::Record;
use MARC::Field;
use Test::MockModule;
use C4::Context;

use C4::Biblio qw( AddBiblio );
use C4::Circulation qw( AddIssue AddReturn );
use C4::Items qw( AddItem );
use C4::Members qw( AddMember GetMember );
use Koha::DateUtils;
use Koha::Borrower::Debarments qw( GetDebarments DelDebarment );
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

my $branchcode = 'CPL';
local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /redefined/ };
my $userenv->{branch} = $branchcode;
*C4::Context::userenv = \&Mock_userenv;

my $circulation_module = Test::MockModule->new('C4::Circulation');

# Test without maxsuspensiondays set
$circulation_module->mock('GetIssuingRule', sub {
        return {
            firstremind => 0,
            finedays => 2,
            lengthunit => 'days',
        }
});

my $borrowernumber = AddMember(
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => 'S',
    branchcode => $branchcode,
);
my $borrower = GetMember( borrowernumber => $borrowernumber );

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
    } , $biblionumber);


my $daysago20 = dt_from_string->add_duration(DateTime::Duration->new(days => -20));
my $daysafter40 = dt_from_string->add_duration(DateTime::Duration->new(days => 40));

AddIssue( $borrower, $barcode, $daysago20 );
AddReturn( $barcode, $branchcode );
my $debarments = GetDebarments({borrowernumber => $borrower->{borrowernumber}});
is( $debarments->[0]->{expiration}, output_pref({ dt => $daysafter40, dateformat => 'iso', dateonly => 1 }));
DelDebarment( $debarments->[0]->{borrower_debarment_id} );

# Test with maxsuspensiondays = 10 days
$circulation_module->mock('GetIssuingRule', sub {
        return {
            firstremind => 0,
            finedays => 2,
            maxsuspensiondays => 10,
            lengthunit => 'days',
        }
});
my $daysafter10 = dt_from_string->add_duration(DateTime::Duration->new(days => 10));
AddIssue( $borrower, $barcode, $daysago20 );
AddReturn( $barcode, $branchcode );
$debarments = GetDebarments({borrowernumber => $borrower->{borrowernumber}});
is( $debarments->[0]->{expiration}, output_pref({ dt => $daysafter10, dateformat => 'iso', dateonly => 1 }));
DelDebarment( $debarments->[0]->{borrower_debarment_id} );


# C4::Context->userenv
sub Mock_userenv {
    return $userenv;
}
