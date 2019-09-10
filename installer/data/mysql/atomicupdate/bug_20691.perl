$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    unless ( column_exists( 'borrowers', 'privacy_guarantor_fines' ) ) {
        $dbh->do(q{
            ALTER TABLE borrowers
                ADD privacy_guarantor_fines TINYINT(1) NOT NULL DEFAULT '0' AFTER privacy;
        });
    }

    unless ( column_exists( 'deletedborrowers', 'privacy_guarantor_fines' ) ) {
        $dbh->do(q{
            ALTER TABLE deletedborrowers
                ADD privacy_guarantor_fines TINYINT(1) NOT NULL DEFAULT '0' AFTER privacy;
        });
    }

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type )
        VALUES (
            'AllowStaffToSetFinesVisibilityForGuarantor',  '0', NULL,
            'If enabled, library staff can set a patron''s fines to be visible to linked patrons from the opac.',  'YesNo'
        ), (
            'AllowPatronToSetFinesVisibilityForGuarantor',  '0', NULL,
            'If enabled, the patron can set fines to be visible to  his or her guarantor',  'YesNo'
        )
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20691 - Add ability for guarantors to view guarantee's fines in OPAC)\n";
}
