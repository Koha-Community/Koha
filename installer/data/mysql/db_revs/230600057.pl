use Modern::Perl;

return {
    bug_number  => "26170",
    description => "Add protected status for patrons",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'borrowers', 'protected' ) ) {
            $dbh->do(
                q{
                ALTER TABLE borrowers ADD COLUMN protected tinyint(1) NOT NULL DEFAULT 0
                COMMENT 'boolean flag to mark selected patrons as protected from deletion'
                AFTER `primary_contact_method`;
            }
            );
            say $out "Added column 'borrowers.protected'";
        }

        if ( !column_exists( 'deletedborrowers', 'protected' ) ) {
            $dbh->do(
                q{
                ALTER TABLE deletedborrowers ADD COLUMN protected tinyint(1) NOT NULL DEFAULT 0
                COMMENT 'boolean flag to mark selected patrons as protected from deletion'
                AFTER `primary_contact_method`;
            }
            );
            say $out "Added column 'deletedborrowers.protected'";
        }
    },
};
