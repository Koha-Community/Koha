use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "33641",
    description => "Added issues.checkin_library and old_issues.checkin_library",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'issues', 'checkin_library' ) ) {
            $dbh->do(
                q{
                ALTER TABLE issues
                ADD COLUMN checkin_library varchar(10) DEFAULT NULL
                COMMENT 'library the item was checked in at'
                AFTER returndate
             }
            );
            say_success( $out, "Added column 'issues.checkin_library'" );
        }
        if ( !column_exists( 'old_issues', 'checkin_library' ) ) {
            $dbh->do(
                q{
                ALTER TABLE old_issues
                ADD COLUMN checkin_library varchar(10) DEFAULT NULL
                COMMENT 'library the item was checked in at'
                AFTER returndate
             }
            );
            say_success( $out, "Added column 'old_issues.checkin_library'" );
        }

    },
};
