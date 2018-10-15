$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type)
    VALUES ('MarcToFrameworkcodeAutoconvert', '', '70|10',
            'Rules to automatically set the framework code based on values in the record. This is YAML.', 'Textarea')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD 3354: Automatic frameworkcode from MARC record)\n";
}
