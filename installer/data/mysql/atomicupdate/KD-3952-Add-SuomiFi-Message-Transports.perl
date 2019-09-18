$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("insert into message_transport_types (message_transport_type) values ('suomifi');");
    $dbh->do("insert into message_transports (message_attribute_id, message_transport_type,is_digest, letter_module, letter_code) values (1, 'suomifi', 1, 'circulation', 'DUEDGST');");
    $dbh->do("insert into message_transports (message_attribute_id, message_transport_type,is_digest, letter_module, letter_code) values (2, 'suomifi', 1, 'circulation', 'PREDUEDGST');");
    $dbh->do("insert into message_transports (message_attribute_id, message_transport_type,is_digest, letter_module, letter_code) values (4, 'suomifi', 0, 'reserves', 'HOLD');");
    $dbh->do("insert into message_transports (message_attribute_id, message_transport_type,is_digest, letter_module, letter_code) values (5, 'suomifi', 0, 'circulation', 'CHECKIN');");
    $dbh->do("insert into message_transports (message_attribute_id, message_transport_type,is_digest, letter_module, letter_code) values (6, 'suomifi', 0, 'circulation', 'CHECKOUT');");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 3952 - Add Suomi.fi message transports)\n";
}
