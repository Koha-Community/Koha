use Modern::Perl;

return {
    bug_number  => "28772",
    description => "Store hashed API key secrets",
    up          => sub {
        my ($args) = @_;
        my ($dbh)  = @$args{qw(dbh)};

        use Koha::AuthUtils qw(hash_password);

        my $sth = $dbh->prepare(
            q{
            SELECT client_id, secret
            FROM api_keys
        }
        );
        $sth->execute;
        my $results = $sth->fetchall_arrayref( {} );

        $sth = $dbh->prepare(
            q{
            UPDATE api_keys
            SET
                secret = ?
            WHERE
                client_id = ?
        }
        );

        foreach my $api_key (@$results) {
            unless ( $api_key->{secret} =~ m/^\$2a\$08\$/ ) {
                my $digest = Koha::AuthUtils::hash_password( $api_key->{secret} );
                $sth->execute( $digest, $api_key->{client_id} );
            }
        }
    },
    }
