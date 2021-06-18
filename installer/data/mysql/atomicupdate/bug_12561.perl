$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q{ DELETE FROM systempreferences WHERE variable IN ('HighlightOwnItemsOnOPAC', 'HighlightOwnItemsOnOPACWhich')} );

    NewVersion( $DBversion, 12561, "Remove system preferences HighlightOwnItemsOnOPAC and HighlightOwnItemsOnOPACWhich");
}
