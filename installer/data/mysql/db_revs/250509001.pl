use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "34000",
    description => "Prevent re-issuance of auto-generated cardnumbers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $exists = $dbh->selectrow_array(q{SELECT 1 FROM systempreferences WHERE variable = 'autoMemberNumValue'});

        if ($exists) {
            say_warning( $out, "System preference 'autoMemberNumValue' already exists, skipping" );
            return;
        }

        # Seed from the highest numeric cardnumber ever issued, considering both live
        # and deleted patrons so pre-upgrade deletions don't free up their numbers.
        my ($seed) = $dbh->selectrow_array(
            q{
            SELECT COALESCE(
                GREATEST(
                    COALESCE(
                        (SELECT MAX(CAST(cardnumber AS SIGNED)) FROM borrowers
                          WHERE cardnumber REGEXP '^-?[0-9]+$'),
                        0
                    ),
                    COALESCE(
                        (SELECT MAX(CAST(cardnumber AS SIGNED)) FROM deletedborrowers
                          WHERE cardnumber REGEXP '^-?[0-9]+$'),
                        0
                    )
                ),
                0
            )
        }
        );
        $seed //= 0;

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable, value) VALUES ('autoMemberNumValue', ?)},
            undef, $seed
        );

        say_success( $out, "Added new system preference 'autoMemberNumValue' seeded to $seed" );
    },
};
