$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    # Add 'credit_applied' offset type
    $dbh->do(q{
        INSERT IGNORE INTO `account_offset_types` (`type`) VALUES ('Credit Applied');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20997 - Add Koha::Account::Line::apply)\n";
}
