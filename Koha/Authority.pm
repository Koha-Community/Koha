package Koha::Authority;

# Copyright 2015 Koha Development Team
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

use Modern::Perl;

use base qw(Koha::Object);

use Koha::Authority::ControlledIndicators;
use Koha::SearchEngine::Search;

=head1 NAME

Koha::Authority - Koha Authority Object class

=head1 API

=head2 Instance Methods

=head3 get_usage_count

    $count = $self->get_usage_count;

    Returns the number of linked biblio records.

=cut

sub get_usage_count {
    my ( $self ) = @_;
    return Koha::Authorities->get_usage_count({ authid => $self->authid });
}

=head3 linked_biblionumbers

    my @biblios = $self->linked_biblionumbers({
        [ max_results => $max ], [ offset => $offset ],
    });

    Returns an array of biblionumbers.

=cut

sub linked_biblionumbers {
    my ( $self, $params ) = @_;
    $params->{authid} = $self->authid;
    return Koha::Authorities->linked_biblionumbers( $params );
}

=head3 controlled_indicators

    Some authority types control the indicators of some corresponding
    biblio fields (especially in MARC21).
    For example, if you have a PERSO_NAME authority (report tag 100), the
    first indicator of biblio field 600 directly comes from the authority,
    and the second indicator depends on thesaurus settings in the authority
    record. Use this method to obtain such controlled values. In this example
    you should pass 600 in the biblio_tag parameter.

    my $result = $self->controlled_indicators({
        record => $auth_marc, biblio_tag => $bib_tag
    });
    my $ind1 = $result->{ind1};
    my $ind2 = $result->{ind2};
    my $subfield_2 = $result->{sub2}; # Optional subfield 2 when ind==7

    If an indicator is not controlled, the result hash does not contain a key
    for its value. (Same for the sub2 key for an optional subfield $2.)

    Note: The record parameter is a temporary bypass in order to prevent
    needless conversion of $self->marcxml.

=cut

sub controlled_indicators {
    my ( $self, $params ) = @_;
    my $tag = $params->{biblio_tag} // q{};
    my $record = $params->{record};

    my $flavour = C4::Context->preference('marcflavour') eq 'UNIMARC'
        ? 'UNIMARCAUTH'
        : 'MARC21';
    if( !$record ) {
        $record = $self->record;
    }

    if( !$self->{_report_tag} ) {
        my $authtype = Koha::Authority::Types->find( $self->authtypecode );
        return {} if !$authtype; # very exceptional
        $self->{_report_tag} = $authtype->auth_tag_to_report;
    }

    $self->{_ControlledInds} //= Koha::Authority::ControlledIndicators->new;
    return $self->{_ControlledInds}->get({
        auth_record => $record,
        report_tag  => $self->{_report_tag},
        biblio_tag  => $tag,
        flavour     => $flavour,
    });
}

=head3 get_identifiers

    my $identifiers = $author->get_identifiers;

Return a list of identifiers of the authors which are in 024$2$a

=cut

sub get_identifiers {
    my ( $self, $params ) = @_;

    my $record = $self->record;

    my @identifiers;
    for my $field ( $record->field('024') ) {
        my $sf_2 = $field->subfield('2');
        my $sf_a = $field->subfield('a');
        next unless $sf_2 && $sf_a;
        push @identifiers, {source => $sf_2, number => $sf_a, };
    }

    return \@identifiers;
}

=head3 record

    my $record = $authority->record()

Return the MARC::Record for this authority

=cut

sub record {
    my ( $self ) = @_;

    my $flavour =
      C4::Context->preference('marcflavour') eq 'UNIMARC'
      ? 'UNIMARCAUTH'
      : 'MARC21';
    return MARC::Record->new_from_xml( $self->marcxml, 'UTF-8', $flavour );
}

=head2 Class Methods

=head3 type

=cut

sub _type {
    return 'AuthHeader';
}

1;
