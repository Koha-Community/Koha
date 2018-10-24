$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q(
        INSERT IGNORE INTO message_transports
        (message_attribute_id,message_transport_type,is_digest,letter_module,letter_code)
        VALUES
        (2, 'phone', 0, 'circulation', 'PREDUE'),
        (2, 'phone', 1, 'circulation', 'PREDUEDGST'),
        (4, 'phone', 0, 'reserves',    'HOLD')
        ));
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21639 - Add phone transports by default)\n";
}
