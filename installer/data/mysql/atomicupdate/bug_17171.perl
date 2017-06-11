$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`) VALUES
        ('AutoReturnCheckedOutItems', '0', '', 'If disabled, librarian must confirm return of checked out item when checking out to another.', 'YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17171 - Add a syspref to allow currently issued items to be issued to a new patron without staff confirmation)\n";
}
