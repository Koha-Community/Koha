$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type)
    VALUES ('AddbiblioHostFrameworkToComponentFramework', '', NULL,
            'When creating a new component biblio via detail view -> New -> New child record, use this to convert the host framework code to a child framework code. Eg. \"NUO=>ONU,KIR=>OSA,SR=>MUO\"', 'free')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-3315: Addbiblio does not populate default marc field values. Add preference AddbiblioHostFrameworkToComponentFramework)\n";
}
