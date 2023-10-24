use Modern::Perl;

return {
    bug_number  => "27153",
    description => "Add option to filter search fields",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'search_marc_to_field', 'filter' ) ) {
            $dbh->do(
                q{
                ALTER TABLE search_marc_to_field
                ADD filter varchar(100) NOT NULL DEFAULT '' COMMENT 'specify a filter to be applied to field'
                AFTER search
            }
            );
            say $out "Added column 'search_marc_to_field.filter'";
        }
        unless ( primary_key_exists( 'search_marc_to_field', 'filter' ) ) {
            $dbh->do(
                q{
                ALTER TABLE search_marc_to_field
                DROP PRIMARY KEY,
                ADD PRIMARY KEY (search_marc_map_id,search_field_id,filter)
            }
            );
            say $out "Updated primary key to include filter";
        }
    },
};
