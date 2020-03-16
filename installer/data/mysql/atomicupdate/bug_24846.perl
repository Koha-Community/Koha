$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(qq{
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (13, 'batch_extend_due_dates', 'Perform batch extend due dates')
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 24846 - Add a new permission for new tool batch extend due dates)\n";
}
