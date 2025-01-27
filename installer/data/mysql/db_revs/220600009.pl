use Modern::Perl;

return {
    bug_number  => "30889",
    description => "Add calling context information to background_jobs",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'background_jobs', 'context' ) ) {
            $dbh->do(
                q{
                ALTER TABLE background_jobs
                    ADD `context` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL
                    COMMENT 'JSON-serialized context information for the job'
                    AFTER `data`
            }
            );

            say $out "Added column 'background_jobs.context'";
        }
    },
};
