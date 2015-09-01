$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE items ADD COLUMN genre VARCHAR(10) DEFAULT NULL
    });
    $dbh->do(q{
        ALTER TABLE items ADD COLUMN sub_location VARCHAR(10) DEFAULT NULL
    });
    $dbh->do(q{
        ALTER TABLE deleteditems ADD COLUMN genre VARCHAR(10) DEFAULT NULL
    });
    $dbh->do(q{
        ALTER TABLE deleteditems ADD COLUMN sub_location VARCHAR(10) DEFAULT NULL
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-211 - Adding genre and sub_location to items)\n";
}
