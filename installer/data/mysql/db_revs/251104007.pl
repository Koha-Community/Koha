use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42156",
    description => "Add 'authid' Elasticsearch search field for authorities",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my ($field_exists) = $dbh->selectrow_array(q{SELECT id FROM search_field WHERE name = 'authid'});

        if ($field_exists) {
            say_warning( $out, "Search field 'authid' already exists, skipping" );
            return;
        }

        $dbh->do(
            q{
                INSERT INTO search_field (name, label, type, staff_client, opac)
                VALUES ('authid', 'authid', 'stdno', 1, 1)
            }
        );
        my $search_field_id = $dbh->last_insert_id( undef, undef, 'search_field', 'id' );
        say_success( $out, "Added Elasticsearch search field 'authid'" );

        for my $marc_type (qw( marc21 unimarc )) {
            $dbh->do(
                q{
                    INSERT IGNORE INTO search_marc_map (index_name, marc_type, marc_field)
                    VALUES ('authorities', ?, '001')
                },
                undef,
                $marc_type,
            );

            my ($marc_map_id) = $dbh->selectrow_array(
                q{
                    SELECT id FROM search_marc_map
                    WHERE index_name = 'authorities' AND marc_type = ? AND marc_field = '001'
                },
                undef,
                $marc_type,
            );

            $dbh->do(
                q{
                    INSERT IGNORE INTO search_marc_to_field
                        (search_marc_map_id, search_field_id, facet, suggestible, sort, search)
                    VALUES (?, ?, 0, 0, 1, 1)
                },
                undef,
                $marc_map_id, $search_field_id,
            );
            say_success(
                $out,
                "Mapped authorities $marc_type 001 to search field 'authid'"
            );
        }

        say_info(
            $out,
            "Rebuild the Elasticsearch index (misc/search_tools/rebuild_elasticsearch.pl -r -v -a) for the new field to take effect"
        );
    },
};
