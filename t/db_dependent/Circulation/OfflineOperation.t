#!/usr/bin/perl

use Modern::Perl;
use C4::Circulation;

use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Library;

use Test::More tests => 7;

BEGIN {
    use_ok('C4::Circulation');
}
can_ok(
    'C4::Circulation',
    qw(
      AddOfflineOperation
      GetOfflineOperation
      GetOfflineOperations
      DeleteOfflineOperation
      )
);

#Start transaction
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM pending_offline_operations|);

#Add branch
my $samplebranch1 = {
    branchcode     => 'SAB1',
    branchname     => 'Sample Branch',
    branchaddress1 => 'sample adr1',
    branchaddress2 => 'sample adr2',
    branchaddress3 => 'sample adr3',
    branchzip      => 'sample zip',
    branchcity     => 'sample city',
    branchstate    => 'sample state',
    branchcountry  => 'sample country',
    branchphone    => 'sample phone',
    branchfax      => 'sample fax',
    branchemail    => 'sample email',
    branchurl      => 'sample url',
    branchip       => 'sample ip',
    branchprinter  => undef,
    opac_info      => 'sample opac',
};
Koha::Library->new($samplebranch1)->store;

my $now = dt_from_string->truncate( to => 'minute' );

#Begin Tests
#Test AddOfflineOperation
is(
    AddOfflineOperation(
        'User1', $samplebranch1->{branchcode},
        $now, 'Action1', 'CODE', 'Cardnumber1', 10
    ),
    'Added.',
    "OfflineOperation has been added"
);
my $offline_id =
  $dbh->last_insert_id( undef, undef, 'pending_offline_operations', undef );

#Test GetOfflineOperations
is_deeply(
    GetOfflineOperation($offline_id),
    {
        operationid => $offline_id,
        userid      => 'User1',
        branchcode  => $samplebranch1->{branchcode},
        # FIXME sounds like we need a 'timestamp' dateformat
        timestamp   => output_pref({ dt => $now, dateformat => 'iso', dateonly => 0 }) . ':00',
        action      => 'Action1',
        barcode     => 'CODE',
        cardnumber  => 'Cardnumber1',
        amount      => '10.000000'
    },
    "GetOffline returns offlineoperation's informations"
);
is( GetOfflineOperation(), undef,
    'GetOfflineOperation without parameters returns undef' );
is( GetOfflineOperation(-1), undef,
    'GetOfflineOperation with wrong parameters returns undef' );

#Test GetOfflineOperations
#TODO later: test GetOfflineOperations
# Actually we cannot mock C4::Context->userenv in unit tests

#Test DeleteOfflineOperation
is( DeleteOfflineOperation($offline_id),
    'Deleted.', 'Offlineoperation has been deleted' );

#is (DeleteOfflineOperation(), undef, 'DeleteOfflineOperation without id returns undef');
#is (DeleteOfflineOperation(-1),undef, 'DeleteOfflineOperation with a wrong id returns undef');#FIXME

#End transaction
$dbh->rollback;
