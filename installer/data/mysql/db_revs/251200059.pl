use Modern::Perl;
use Try::Tiny               qw( catch try );
use Koha::Installer::Output qw(say_warning say_success say_info);
use Koha::SearchEngine::Elasticsearch::Indexer;

return {
    bug_number  => "40658",
    description => "Ensure local-number is sortable",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        my ( $local_number_map_id, $local_number_sortable ) = $dbh->selectrow_array(
            q|
            SELECT search_marc_map_id,sort FROM search_field
            JOIN search_marc_to_field ON search_field.id = search_marc_to_field.search_field_id
            JOIN search_marc_map ON search_marc_to_field.search_marc_map_id = search_marc_map.id
            WHERE search_field.name='local-number' AND index_name = 'biblios' AND marc_type='marc21';
        |
        );

        if ( defined $local_number_map_id && $local_number_sortable == 0 ) {
            $dbh->do(
                q{
                UPDATE search_marc_to_field
                SET sort = 1
                WHERE search_marc_map_id = ?
            }, undef, $local_number_map_id
            );

            # We do want to update the mappings in the DB in case ES gets switched on
            # but just skip the ES engine update if ES not enabled
            my $searchengine =
                $dbh->selectrow_array(q|SELECT value FROM systempreferences WHERE variable = 'SearchEngine'|);
            if ( $searchengine eq 'Elasticsearch' ) {
                my $index_name = $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX;
                my $indexer    = Koha::SearchEngine::Elasticsearch::Indexer->new( { index => $index_name } );

                # The existing mapping for local-number may not be compatible with the
                # sortable mapping we need (e.g. it is currently typed as an integer).
                # In that case Elasticsearch refuses the mapping change and update_mappings
                # throws. Catch that so the whole DB upgrade doesn't die - update_mappings
                # already flags the index as needing a full reindex, which the mappings
                # admin page and rebuild_elasticsearch.pl will pick up.
                try {
                    $indexer->update_mappings();
                    say $out "Updated ES mappings to make local-number sortable";
                } catch {
                    say_warning(
                        $out,
                        "Unable to update Elasticsearch mappings for local-number ("
                            . $_->message
                            . "). A full reindex is required, run misc/search_tools/rebuild_elasticsearch.pl -r -b"
                    );
                };
            } else {
                say $out "ES disabled, mappings not updated";
            }
        } elsif ( !defined $local_number_map_id ) {
            say_warning( $out, "No mapping defined for local-number" );
        } else {
            say_info( $out, "local-number already sortable" );
        }
    },
};
