use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "33641",
    description => "Added issues.return_branch and old_issues.return_branch",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'issues', 'return_branch' ) ) {
            $dbh->do(
                q{
                ALTER TABLE issues
                ADD COLUMN return_branch varchar(10) DEFAULT NULL
                COMMENT 'foreign key, linking to the branches table for the location the item was returned'
                AFTER returndate
             }
            );
            say_success( $out, "Added column 'issues.return_branch'" );
        }
        if ( !column_exists( 'old_issues', 'return_branch' ) ) {
            $dbh->do(
                q{
                ALTER TABLE old_issues
                ADD COLUMN return_branch varchar(10) DEFAULT NULL
                COMMENT 'foreign key, linking to the branches table for the location the item was returned'
                AFTER returndate
             }
            );
            say_success( $out, "Added column 'old_issues.return_branch'" );
        }

    },
};
