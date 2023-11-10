use Modern::Perl;

return {
    bug_number => "33317",
    description => "Add new system preference OpacMetaRobots",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('OpacMetaRobots','','','Improve search engine crawling.', 'Multiple') });

        say $out "Added system preference 'OpacMetaRobots'";
    },
};