package Koha::Authority::MergeRequests;

# Copyright Rijksmuseum 2017
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use MARC::File::XML;
use MARC::Record;

use C4::Context;
use Koha::Authority::MergeRequest;

use parent qw(Koha::Objects);

=head1 NAME

Koha::Authority::MergeRequests - Koha::Objects class for need_merge_authorities

=head1 SYNOPSIS

use Koha::Authority::MergeRequests;

=head1 DESCRIPTION

Description

=head1 METHODS

=head2 INSTANCE METHODS

=head2 CLASS METHODS

=head3 reporting_tag_xml

    my $xml = Koha::Authority::MergeRequests->reporting_tag_xml({
        record => $record, tag => $tag,
    });

=cut

sub reporting_tag_xml {
    my ( $class, $params ) = @_;
    return if !$params->{record} || !$params->{tag};

    my $newrecord = MARC::Record->new;
    $newrecord->encoding( 'UTF-8' );
    my $reportfield = $params->{record}->field( $params->{tag} );
    return if !$reportfield;

    $newrecord->append_fields( $reportfield );
    return $newrecord->as_xml(
        C4::Context->preference('marcflavour') eq 'UNIMARC' ?
        'UNIMARCAUTH' :
        'MARC21'
    );
}

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'NeedMergeAuthority';
}

=head3 object_class

Returns name of corresponding Koha object class

=cut

sub object_class {
    return 'Koha::Authority::MergeRequest';
}

=head1 AUTHOR

Marcel de Rooy (Rijksmuseum)

Koha Development Team

=cut

1;
