use Modern::Perl;

return {
    bug_number => "30889",
    description => "Add context to background_jobs",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        unless( column_exists( 'background_jobs', 'context') ) {
            $dbh->do(q{ ALTER TABLE background_jobs ADD `context` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `data` });
            say $out "field added";
        }
    },
};
