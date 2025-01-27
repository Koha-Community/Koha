package Koha::Filter::MARC::ExpandCodedFields;

# Copyright 2022 PTFS Europe
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

Koha::Filter::MARC::ExpandCodedFields - Replaces AV codes with descriptions in MARC::Record objects.

=head1 SYNOPSIS

  my $biblio = Koha::Biblios->find(
      $biblio_id,
      { prefetch => [ metadata ] }
  );

  my $record = $biblio->metadata->record;

  my $record_processor = Koha::RecordProcessor->new(
    {
        filters => ['ExpandCodedFields'],
        options => {
            interface => 'opac',
        }
    }
  );

  $record_processor->process($record);

=head1 DESCRIPTION

Filter to replace Koha AV codes in MARC::Records with their Koha AV descriptions.

=cut

use Modern::Perl;

use C4::Biblio qw( GetAuthorisedValueDesc );

use Koha::Caches;

use base qw(Koha::RecordProcessor::Base);
our $NAME = 'ExpandCodedFields';

=head2 filter

Embed items into the MARC::Record object.

=cut

sub filter {
    my $self   = shift;
    my $record = shift;

    return unless defined $record and ref($record) eq 'MARC::Record';

    my $params        = $self->params;
    my $interface     = $params->{options}->{interface} // 'opac';
    my $opac          = $interface eq 'opac' ? 1 : 0;
    my $frameworkcode = $params->{options}->{frameworkcode} // q{};

    my $marcflavour  = C4::Context->preference('marcflavour');
    my $coded_fields = _getCodedFields($frameworkcode);
    for my $tag ( keys %$coded_fields ) {
        for my $field ( $record->field($tag) ) {
            my @new_subfields = ();
            for my $subfield ( $field->subfields() ) {
                my ( $letter, $value ) = @$subfield;

                # Replace the field value with the authorised value
                # *except* for MARC21 field 942$n (suppression in opac)
                if ( !( $tag eq '942' && $subfield->[0] eq 'n' )
                    || $marcflavour eq 'UNIMARC' )
                {
                    $value = GetAuthorisedValueDesc(
                        $tag,          $letter, $value, '',
                        $coded_fields, undef,   $opac
                    ) if $coded_fields->{$tag}->{$letter};
                }
                push( @new_subfields, $letter, $value );
            }
            $field->replace_with(
                MARC::Field->new(
                    $tag,                 $field->indicator(1),
                    $field->indicator(2), @new_subfields
                )
            );
        }
    }

    return $record;
}

sub _getCodedFields {
    my ($frameworkcode) = @_;
    $frameworkcode //= "";

    my $cache     = Koha::Caches->get_instance();
    my $cache_key = "MarcCodedFields-$frameworkcode";
    my $cached    = $cache->get_from_cache( $cache_key, { unsafe => 1 } );
    return $cached if $cached;

    my $coded_fields = {};
    my @fields       = Koha::MarcSubfieldStructures->search(
        {
            frameworkcode    => $frameworkcode,
            authorised_value => { '>' => '' }
        },
        {
            columns  => [ 'tagfield', 'tagsubfield', 'authorised_value' ],
            order_by => [ 'tagfield', 'tagsubfield' ]
        }
    )->as_list;
    for my $field (@fields) {
        $coded_fields->{ $field->tagfield }->{ $field->tagsubfield }->{'authorised_value'} = $field->authorised_value;
    }

    $cache->set_in_cache( $cache_key, $coded_fields );
    return $coded_fields;
}

1;
