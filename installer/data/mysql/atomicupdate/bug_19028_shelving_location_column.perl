$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences
        SET
            variable='OpacLocationOnDetail',
            options='holding|home|both|column',
            explanation='In the OPAC detail, display the shelving location on its own column or under a library columns.'
        WHERE
            variable='OpacLocationBranchToDisplayShelving'
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19028: Add 'shelving location' to holdings table in detail page)\n";
}