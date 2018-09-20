$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q|
INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
VALUES
('UnsubscribeReflectionDelay','',NULL,'Delay for locking unsubscribers', 'Integer'),
('PatronAnonymizeDelay','',NULL,'Delay for anonymizing patrons', 'Integer'),
('PatronRemovalDelay','',NULL,'Delay for removing anonymized patrons', 'Integer')
    |);
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21336 - Add preferences)\n";
}
