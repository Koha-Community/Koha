use Modern::Perl;
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
                $indexer->update_mappings();
            } else {
                say $out "ES disabled, mappings not updated";
            }
            say $out "Updated ES mappings to make local-number sortable";
        } elsif ( !defined $local_number_map_id ) {
            say_warning( $out, "No mapping defined for local-number" );
        } else {
            say_info( $out, "local-number already sortable" );
        }
    },
};
