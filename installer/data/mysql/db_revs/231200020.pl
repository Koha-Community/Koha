use Modern::Perl;

return {
    bug_number  => "36343",
    description => "Update plugin hooks for consistency",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say $out "WARNING: Plugin authors should consider changes introduced here";
        say $out
            "WARNING: after_biblio_action, after_item_action and patron_generate_userid hooks now pass data inside a 'payload' hash";
    },
};
