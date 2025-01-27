use Modern::Perl;

return {
    bug_number  => 30498,
    description => "Correct enum search_field.type",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q|ALTER TABLE search_field MODIFY COLUMN `type` enum('','string','date','number','boolean','sum','isbn','stdno','year') NOT NULL COMMENT 'what type of data this holds, relevant when storing it in the search engine'|
        );
    },
};
