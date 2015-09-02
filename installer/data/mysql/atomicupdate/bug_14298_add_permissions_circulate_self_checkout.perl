use Modern::Perl;

use C4::Context;
my $dbh = C4::Context->dbh;

$dbh->do(q|
    INSERT INTO permissions (module_bit, code, description)
    VALUES (1, 'self_checkout', 'Perform self checkout at the OPAC. It should be used for the patron matching the AutoSelfCheckID')
|);

my $AutoSelfCheckID = C4::Context->preference('AutoSelfCheckID');

$dbh->do(q|
    UPDATE borrowers
    SET flags=0
    WHERE userid=?
|, undef, $AutoSelfCheckID);

$dbh->do(q|
    DELETE FROM user_permissions
    WHERE borrowernumber=(SELECT borrowernumber FROM borrowers WHERE userid=?)
|, undef, $AutoSelfCheckID);

$dbh->do(q|
    INSERT INTO user_permissions(borrowernumber, module_bit, code)
    SELECT borrowernumber, 1, 'self_checkout' FROM borrowers WHERE userid=?
|, undef, $AutoSelfCheckID);
