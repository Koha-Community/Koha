use Modern::Perl;

return {
    bug_number  => "29341",
    description => "Remove foreign keys on pseudonymized_transactions",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        for my $fk (
            qw( pseudonymized_transactions_borrowers_ibfk_2 pseudonymized_transactions_borrowers_ibfk_3 pseudonymized_transactions_ibfk_1 )
            )
        {
            if ( foreign_key_exists( 'pseudonymized_transactions', $fk ) ) {
                $dbh->do(
                    qq{
                    ALTER TABLE pseudonymized_transactions DROP FOREIGN KEY $fk
                }
                );
            }
        }
    },
    }
