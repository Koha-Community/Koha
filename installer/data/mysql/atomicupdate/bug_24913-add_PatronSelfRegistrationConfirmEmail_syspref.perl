$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('PatronSelfRegistrationConfirmEmail', '0', NULL, 'Require users to confirm their email address by entering it twice.', 'YesNo') });

    NewVersion( $DBversion, 24913, "Add PatronSelfRegistrationConfirmEmail syspref");
}
