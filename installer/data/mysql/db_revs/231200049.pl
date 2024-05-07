use Modern::Perl;

return {
    bug_number  => "36396",
    description => "Link Elasticsearch facets with authorized value categories",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'search_field', 'authorised_value_category' ) ) {
            $dbh->do(
                q{
            ALTER TABLE search_field
            ADD COLUMN `authorised_value_category` varchar(32) DEFAULT NULL
            AFTER mandatory
        }
            );
        }
        say $out "Added Elasticsearch facets with authorized value categories";
    },
};
