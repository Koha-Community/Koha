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

            my $index_name = $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX;
            my $indexer    = Koha::SearchEngine::Elasticsearch::Indexer->new( { index => $index_name } );
            $indexer->update_mappings();
            say $out "Updated ES mappings to make local-number sortable";
        } elsif ( !defined $local_number_map_id ) {
            say_warning( $out, "No mapping defined for local-number" );
        } else {
            say_info( $out, "local-number already sortable" );
        }
    },
};
