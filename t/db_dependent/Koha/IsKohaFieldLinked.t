use Modern::Perl;
use Test::More;

use C4::Context;
use C4::Koha;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

my $frameworkcode = 'FCUT';
$dbh->do( qq|
    INSERT INTO marc_subfield_structure(
        tagfield, tagsubfield, liblibrarian, kohafield, frameworkcode
    ) VALUES
        ('952', 'p', 'Barcode', 'items.barcode', '$frameworkcode'),
        ('952', '8', 'Collection code', 'items.ccode', '$frameworkcode'),
        ('952', '7', 'Not for loan', 'items.notforloan', '$frameworkcode'),
        ('952', 'y', 'Koha item type', 'items.itype', '$frameworkcode'),
        ('952', 'c', 'Permanent location', '', '$frameworkcode')
|);

is ( C4::Koha::IsKohaFieldLinked( {
    kohafield => 'items.barcode',
    frameworkcode => $frameworkcode,
}), 1, 'items.barcode is linked' );

is ( C4::Koha::IsKohaFieldLinked( {
    kohafield => 'items.notforloan',
    frameworkcode => $frameworkcode,
}), 1, 'items.notforloan is linked' );

is ( C4::Koha::IsKohaFieldLinked( {
    kohafield => 'notforloan',
    frameworkcode => $frameworkcode,
}), 0, 'notforloan is not linked' );

is ( C4::Koha::IsKohaFieldLinked( {
    kohafield => 'items.permanent_location',
    frameworkcode => $frameworkcode,
}), 0, 'items.permanent_location is not linked' );


done_testing;
