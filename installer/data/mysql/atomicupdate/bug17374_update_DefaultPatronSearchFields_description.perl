$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET  explanation = 'Comma separated list defining the default fields to be used during a patron search using the \"standard\" option. If empty Koha will default to \"surname,firstname,othernames,cardnumber,userid\". Additional fields added to this preference will be added as search options in the dropdown menu on the patron search page.' WHERE variable='DefaultPatronSearchFields' " );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17374 - update description of DefaultPatronSearchFields)\n";
}
