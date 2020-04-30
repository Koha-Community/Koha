$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE message_transport_types SET message_transport_type = "itiva" WHERE message_transport_type = "phone"
    });

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 25333, q{Change message transport type for Talking Tech from "phone" to "itiva"});
}
