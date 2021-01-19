$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
   $dbh->do(q{
    INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('PatronSelfModificationMandatoryField','', NULL,'Define the required fields when a patron is editing their information via the OPAC.','multiple');
    });
    NewVersion($DBversion, 13188, "Allow configuration of required fields when a patron is editing their information via the OPAC");
}
