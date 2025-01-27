use Modern::Perl;
return {
    bug_number  => "10950",
    description => "Add preferred pronoun field to patron record",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'borrowers', 'pronouns' ) ) {
            $dbh->do(
                q{
                ALTER TABLE borrowers
                ADD COLUMN pronouns longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's pronouns"
                AFTER initials
            }
            );
            say $out "Added column 'borrowers.pronouns'";
        }
        if ( !column_exists( 'deletedborrowers', 'pronouns' ) ) {
            $dbh->do(
                q{
                ALTER TABLE deletedborrowers
                ADD COLUMN pronouns longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's pronouns"
                AFTER initials
            }
            );
            say $out "Added column 'deletedborrowers.pronouns'";
        }
        if ( !column_exists( 'borrower_modifications', 'pronouns' ) ) {
            $dbh->do(
                q{
                ALTER TABLE borrower_modifications
                ADD COLUMN pronouns longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's pronouns"
                AFTER initials
            }
            );
            say $out "Added column 'borrower_modifications.pronouns'";
        }
    },
    }
