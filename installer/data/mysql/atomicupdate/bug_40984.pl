use Modern::Perl;

return {
    bug_number  => "40984",
    description => "Update authority plugin hooks for consistency",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say $out "WARNING: Plugin authors should consider changes introduced here";
        say $out "WARNING: after_authority_action now passes data inside a 'payload' hash, like after_biblio_action";
        say $out
            "WARNING: the 'authority' and 'authority_id' parameters outside of the 'payload' are deprecated and will be removed in a future release";
        say $out "WARNING: a new before_authority_action hook is called before an authority record is saved";
    },
};
