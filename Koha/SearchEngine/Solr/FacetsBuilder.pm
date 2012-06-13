package Koha::SearchEngine::Solr::FacetsBuilder;

use Modern::Perl;
use Moose::Role;

with 'Koha::SearchEngine::FacetsBuilderRole';

sub build_facets {
    my ( $self, $results, $facetable_indexes, $filters ) = @_;
    my @facets_loop;
    for my $index ( @$facetable_indexes ) {
        my $index_name = $index->{type} . '_' . $index->{code};
        my $facets = $results->facets->{'str_' . $index->{code}};
        if ( @$facets > 1 ) {
            my @values;
            $index =~ m/^([^_]*)_(.*)$/;
            for ( my $i = 0 ; $i < scalar(@$facets) ; $i++ ) {
                my $value = $facets->[$i++];
                my $count = $facets->[$i];
                utf8::encode($value);
                my $lib =$value;
                push @values, {
                    'lib'     => $lib,
                    'value'   => $value,
                    'count'   => $count,
                    'active'  => ( $filters->{$index_name} and scalar( grep /"?\Q$value\E"?/, @{ $filters->{$index_name} } ) ) ? 1 : 0,
                };
            }

            push @facets_loop, {
                'indexname' => $index_name,
                'label'     => $index->{label},
                'values'    => \@values,
                'size'      => scalar(@values),
            };
        }
    }
    return @facets_loop;
}

1;
