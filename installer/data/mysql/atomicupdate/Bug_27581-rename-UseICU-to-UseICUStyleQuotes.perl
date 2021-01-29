$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET variable = 'UseICUStyleQUotes' WHERE variable = 'UseICU'" );
    NewVersion( $DBversion, 27581, "Rename UseICU to UseICUStyleQuotes");
}
