$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{UPDATE systempreferences SET variable="OPACComments" WHERE variable="reviewson" });
    NewVersion( $DBversion, 27847, "Rename 'reviewson' to 'OPACComments");
}
