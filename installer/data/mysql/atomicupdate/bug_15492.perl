$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInMainUserBlock', '', '70|10', 'Add a block of HTML that will display on the self check-in screen.', 'Textarea');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInModule', 0, NULL, 'Enable the standalone self-checkin module.', 'YesNo');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInModuleUserID', NULL, NULL, 'Patron ID (borrowernumber) to be allowed on the self-checkin module.', 'Integer');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInTimeout', 120, NULL, 'Define the number of seconds before the self check-in module times out.', 'Integer');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInUserCSS', '', NULL, 'Add CSS to be included in the self check-in module in an embedded <style> tag.', 'free');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInUserJS', '', NULL, 'Define custom javascript for inclusion in the self check-in module.', 'free');
    });

    # Add new userflag for self check
    $dbh->do(q{
        INSERT IGNORE INTO userflags (bit,flag,flagdesc,defaulton) VALUES
            (23,'self_check','Self check modules',0);
    });

    # Add self check-in module subpermission
    $dbh->do(q{
        INSERT IGNORE INTO permissions (module_bit,code,description)
        VALUES (23, 'self_checkin_module', 'Log into the self check-in module');
    });

    # Add self check-in module subpermission
    $dbh->do(q{
        INSERT IGNORE INTO permissions (module_bit,code,description)
        VALUES (23, 'self_checkout_module', 'Perform self checkout at the OPAC. It should be used for the patron matching the AutoSelfCheckID');
    });

    # Update patrons with self_checkout permission
    # IMPORTANT: Needs to happen before removing the old subpermission
    $dbh->do(q{
        UPDATE user_permissions
        SET module_bit = 23,
                  code = 'self_checkout_module'
        WHERE module_bit = 1 AND code = 'self_checkout';
    });

    # Remove old self_checkout permission
    $dbh->do(q{
        DELETE IGNORE FROM permissions
        WHERE  code='self_checkout';
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15492: Add a standalone self-checkin module)\n";
}
