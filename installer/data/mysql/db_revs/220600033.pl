use Modern::Perl;

return {
    bug_number  => "27779",
    description => "Simplify credit descriptions",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE account_credit_types
            SET description = 'Refund' WHERE code = 'REFUND' AND description = 'A refund applied to a patrons fine';
        }
        );
    },
    }
