use Modern::Perl;
return {
    bug_number => "10950",
    description => "Add pronouns to borrowers table",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        if( !column_exists( 'borrowers', 'pronouns' ) ) {
            $dbh->do(q{
                ALTER TABLE borrowers
                ADD COLUMN pronouns longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's pronouns"
                AFTER initials
            });
            say $out "Added pronouns column to borrowers table";
        }
        if( !column_exists( 'deletedborrowers', 'pronouns' ) ) {
            $dbh->do(q{
                ALTER TABLE deletedborrowers
                ADD COLUMN pronouns longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's pronouns"
                AFTER initials
            });
            say $out "Added pronouns column to deletedborrowers table";
        }
        if( !column_exists( 'borrower_modifications', 'pronouns' ) ) {
            $dbh->do(q{
                ALTER TABLE borrower_modifications
                ADD COLUMN pronouns longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's pronouns"
                AFTER initials
            });
            say $out "Added pronouns column to borrower_modifications table";
        }
    },
}
