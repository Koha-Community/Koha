use Modern::Perl;

return {
    bug_number => "32745",
    description => "Update context={} for invalid background jobs",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            UPDATE background_jobs
            SET context="{}"
            WHERE context IS NULL
        });
    },
};
