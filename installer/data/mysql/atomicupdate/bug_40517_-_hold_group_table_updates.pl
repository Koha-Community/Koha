use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40517",
    description => "Add 'borrower' column to hold_groups",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'hold_groups', 'borrowernumber' ) ) {
            $dbh->do(
                q{ALTER TABLE hold_groups ADD COLUMN borrowernumber int(11) DEFAULT NULL COMMENT 'foreign key, linking this to the borrowers table' AFTER hold_group_id}
            );
            $dbh->do(
                q{
                    ALTER TABLE hold_groups ADD KEY `hold_groups_borrowernumber` (`borrowernumber`)
                }
            );
            $dbh->do(
                q{
                    ALTER TABLE hold_groups ADD CONSTRAINT hold_groups_ibfk_1
                    FOREIGN KEY(`borrowernumber`)
                    REFERENCES `borrowers` (`borrowernumber`)
                    ON DELETE CASCADE;
                }
            );
            say_success( $out, "Added column 'borrowernumber' to hold_groups" );
        }
    },
};
