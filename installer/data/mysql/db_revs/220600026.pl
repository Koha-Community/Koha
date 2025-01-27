use Modern::Perl;

return {
    bug_number  => "30984",
    description => "Log the cron script that generated an action log if there is one",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'action_logs', 'script' ) ) {
            $dbh->do(
                q{
                ALTER TABLE action_logs
                ADD COLUMN script varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'the name of the cron script that caused this change'
                AFTER interface
            }
            );
            say $out "Added column 'action_logs.script'";
        }
    },
};
