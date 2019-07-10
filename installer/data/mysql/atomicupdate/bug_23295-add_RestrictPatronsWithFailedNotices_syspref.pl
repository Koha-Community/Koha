use Modern::Perl;

return {
    bug_number  => "23295",
    description => "Automatically debar patrons if SMS or email notice fail",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('RestrictPatronsWithFailedNotices', '0', NULL, 'If enabled then when SMS and email notices fail sending at the Koha level then a debarment will be applied to a patrons account', 'YesNo') }
        );

        say $out "Added system preference 'RestrictPatronsWithFailedNotices'";
    },
};
