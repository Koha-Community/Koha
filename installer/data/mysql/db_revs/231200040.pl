use Modern::Perl;

return {
    bug_number  => "32610",
    description => "Add option for additional patron attributes of type date",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( column_exists( 'borrower_attribute_types', 'is_date' ) ) {
            $dbh->do(
                q{ALTER TABLE borrower_attribute_types
                    ADD COLUMN `is_date` tinyint(1) NOT NULL default 0 AFTER `unique_id`}
            );
            say $out "Added column 'borrower_attribute_types.is_date'";
        }
    },
};
