use Modern::Perl;

return {
    bug_number  => "29386",
    description => "Extend background_jobs.data to LONGTEXT",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q|
            ALTER TABLE background_jobs
            CHANGE COLUMN `data` `data` LONGTEXT DEFAULT NULL
        |
        );
    },
    }
