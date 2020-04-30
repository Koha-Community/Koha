$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('PhoneNotification','0',NULL,'If ON, enables generation of phone notifications to be sent by plugins','YesNo')
    });

    $dbh->do(q{
        INSERT INTO message_transport_types (message_transport_type) VALUES ('phone')
    });

    $dbh->do(q{
        INSERT IGNORE INTO `message_transports`
        (`message_attribute_id`, `message_transport_type`, `is_digest`, `letter_module`, `letter_code`)
        VALUES
        (1, 'phone',       0, 'circulation', 'DUE'),
        (1, 'phone',       1, 'circulation', 'DUEDGST'),
        (2, 'phone',       0, 'circulation', 'PREDUE'),
        (2, 'phone',       1, 'circulation', 'PREDUEDGST'),
        (4, 'phone',       0, 'reserves',    'HOLD'),
        (5, 'phone',       0, 'circulation', 'CHECKIN'),
        (6, 'phone',       0, 'circulation', 'CHECKOUT');
    });

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 25334, "Add generic 'phone' message transport type");
}
