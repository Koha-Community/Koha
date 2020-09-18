$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
   $dbh->do(q{
    INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('OPACSuggestionUnwantedFields','', NULL,'Define the hidden fields for a patron purchase suggestions made via OPAC.','multiple');
    });
    NewVersion($DBversion, 23420, "Allow configuration of hidden fields on the suggestion form in OPAC");
}
