package Koha::SearchEngine::Solr::Index;
use Moose::Role;
with 'Koha::SearchEngine::IndexRole';

use Data::SearchEngine::Solr;
use Data::Dump qw(dump);
use List::MoreUtils qw(uniq);

use Koha::SearchEngine::Solr;
use C4::AuthoritiesMarc;
use C4::Biblio;
use Koha::RecordProcessor;

has searchengine => (
    is => 'rw',
    isa => 'Koha::SearchEngine::Solr',
    default => sub { Koha::SearchEngine::Solr->new },
    lazy => 1
);

sub optimize {
    my ( $self ) = @_;
    return $self->searchengine->_solr->optimize;
}

sub index_record {
    my ($self, $recordtype, $recordids) = @_;

    my $indexes = $self->searchengine->config->indexes;
    my @records;

    my $recordids_str = ref($recordids) eq 'ARRAY'
                    ? join " ", @$recordids
                    : $recordids;
    warn "IndexRecord called with $recordtype $recordids_str";

    for my $id ( @$recordids ) {
        my $record;

        $record = GetAuthority( $id )  if $recordtype eq "authority";
        $record = GetMarcBiblio( $id ) if $recordtype eq "biblio";

        if ($recordtype eq 'biblio' && C4::Context->preference('IncludeSeeFromInSearches')) {
            my $normalizer = Koha::RecordProcessor->new( { filters => 'EmbedSeeFromHeadings' } );
            $record = $normalizer->process($record);
        }

        next unless ( $record );

        my $index_values = {
            recordid => $id,
            recordtype => $recordtype,
        };

        warn "Indexing $recordtype $id";

        for my $index ( @$indexes ) {
            next if $index->{ressource_type} ne $recordtype;
            my @values;
            eval {
                my $mappings = $index->{mappings};
                for my $tag_subf_code ( sort @$mappings ) {
                    my ( $f, $sf ) = split /\$/, $tag_subf_code;
                    for my $field ( $record->field( $f ) ) {
                        if ( $field->is_control_field ) {
                            push @values, $field->data;
                        } else {
                            my @sfvals = $sf eq '*'
                                       ? map { $_->[1] } $field->subfields
                                       : map { $_      } $field->subfield( $sf );

                            for ( @sfvals ) {
                                $_ = NormalizeDate( $_ ) if $index->{type} eq 'date';
                                push @values, $_ if $_;
                            }
                        }
                    }
                }
                @values = uniq (@values); #Removes duplicates

                $index_values->{$index->{type}."_".$index->{code}} = \@values;
                if ( $index->{sortable} ){
                    $index_values->{"srt_" . $index->{type} . "_".$index->{code}} = $values[0];
                }
                # Add index str for facets if it's not exist
                if ( $index->{facetable} and @values > 0 and $index->{type} ne 'str' ) {
                    $index_values->{"str_" . $index->{code}} = $values[0];
                }
            };
            if ( $@ ) {
                chomp $@;
                warn  "Error during indexation : recordid $id, index $index->{code} ( $@ )";
            }
        }

        my $solrrecord = Data::SearchEngine::Item->new(
            id    => "${recordtype}_$id",
            score => 1,
            values => $index_values,
        );
        push @records, $solrrecord;
    }
    $self->searchengine->add( \@records );
}

1;
