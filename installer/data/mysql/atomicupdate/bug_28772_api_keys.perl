$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    use Koha::AuthUtils qw(hash_password);

    my $sth = $dbh->prepare(q{
        SELECT client_id, secret
        FROM api_keys
    });
    $sth->execute;
    my $results = $sth->fetchall_arrayref({});

    $sth = $dbh->prepare(q{
        UPDATE api_keys
        SET
            secret = ?
        WHERE
            client_id = ?
    });

    foreach my $api_key (@$results) {
        unless ( $api_key->{secret} =~ m/^\$2a\$08\$/ ) {
            my $digest = Koha::AuthUtils::hash_password( $api_key->{secret} );
            $sth->execute( $digest, $api_key->{client_id} );
        }
    }

    NewVersion( $DBversion, 28772, "Store hashed API key secrets" );
}
