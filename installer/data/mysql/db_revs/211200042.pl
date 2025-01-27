use Modern::Perl;

return {
    bug_number  => 30572,
    description => "Adjust search_marc_to_field.sort",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q|
ALTER TABLE search_marc_to_field MODIFY COLUMN sort tinyint(1) DEFAULT 1 NOT NULL COMMENT 'Sort defaults to 1 (Yes) and creates sort fields in the index, 0 (no) will prevent this';
        |
        );
    },
};
