use Modern::Perl;

return {
    bug_number  => "36396",
    description => "Link elastic facets with authorized value categories",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            ALTER TABLE search_field
            ADD COLUMN `authorised_value_category` varchar(32) DEFAULT NULL
            AFTER mandatory
        }
        );
    },
};
