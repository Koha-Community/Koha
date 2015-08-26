$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{ INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`,`type`) VALUES ('OPACSuggestionAutoFill', '0', NULL, 'Automatically fill OPAC suggestion form with data from Google Books API','YesNo') });

    NewVersion( $DBversion, 14242, "Add OPACSuggestionAutoFill system preference");
}
