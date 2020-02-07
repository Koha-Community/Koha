$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    if (!column_exists('account_credit_types', 'archived')) {
        $dbh->do('ALTER TABLE account_credit_types ADD COLUMN archived tinyint(1) NOT NULL DEFAULT 0 AFTER is_system');
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17702 - Add column account_credit_types.archived)\n";
}
