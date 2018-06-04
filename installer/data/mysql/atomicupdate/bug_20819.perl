$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Add table and add column
    $dbh->do(q|
CREATE TABLE patron_consent (id int AUTO_INCREMENT, borrowernumber int NOT NULL, type enum('GDPR_PROCESSING' ), given_on datetime, refused_on datetime, PRIMARY KEY (id), FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE )
    |);
    $dbh->do(q|
ALTER TABLE borrower_modifications ADD COLUMN gdpr_proc_consent datetime
    |);

    # Add two sysprefs too
    $dbh->do(q|
INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES ('PrivacyPolicyURL','',NULL,'This URL is used in messages about GDPR consents.', 'Free')
    |);
    $dbh->do(q|
INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES ('GDPR_Policy','','Enforced\|Permissive\|Disabled','General Data Protection Regulation - policy', 'Choice')
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20819: Add patron_consent)\n";
}
