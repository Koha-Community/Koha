$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
   $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        SELECT 'PatronSelfModificationMandatoryField', value, NULL, 'Define the required fields when a patron is editing their information via the OPAC','multiple'
        FROM (SELECT value FROM systempreferences WHERE variable="PatronSelfRegistrationBorrowerMandatoryField") tmp
    });
    NewVersion($DBversion, 13188, "Allow configuration of required fields when a patron is editing their information via the OPAC");
}
