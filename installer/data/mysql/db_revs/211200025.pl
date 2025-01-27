use Modern::Perl;

return {
    bug_number  => "29990",
    description => "Add new system preference ShowHeadingUse",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('ShowHeadingUse', '0', NULL, 'Show whether authority record contains an established heading that conforms to descriptive cataloguing rules, and can therefore be used as a main/added entry, or subject, or series title', 'YesNo') }
        );
    },
};
