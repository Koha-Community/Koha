use Modern::Perl;

return {
    bug_number  => 28869,
    description => "Add authorised_value_categories.is_integer_only",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'authorised_value_categories', 'is_integer_only' ) ) {
            $dbh->do(
                q{
ALTER TABLE authorised_value_categories ADD COLUMN is_integer_only tinyint(1) DEFAULT 0 NOT NULL AFTER `is_system`
            }
            );
        }
    },
};
