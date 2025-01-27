package Koha::Authority::MergeRequest;

# Copyright Rijksmuseum 2017
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

use parent qw(Koha::Object);

use Koha::Authorities;
use Koha::Authority::Types;

=head1 NAME

Koha::Authority::MergeRequest - Koha::Object class for single need_merge_authorities record

=head1 SYNOPSIS

use Koha::Authority::MergeRequest;

=head1 DESCRIPTION

Description

=head1 METHODS

=head2 INSTANCE METHODS

=head3 new

    $self->new({
        authid => $id,
        [ authid_new => $new, ]
        [ oldrecord => $marc, ]
    });

    authid refers to the old authority id,
    authid_new optionally refers to a new different authority id

    oldrecord is the MARC record belonging to the original authority record

    This method returns an object and initializes the reportxml property.

=cut

sub new {
    my ( $class, $params ) = @_;
    my $oldrecord = delete $params->{oldrecord};
    delete $params->{reportxml};    # just making sure it is empty
    my $self = $class->SUPER::new($params);

    if ( $self->authid && $oldrecord ) {
        my $auth = Koha::Authorities->find( $self->authid );
        my $type = $auth ? Koha::Authority::Types->find( $auth->authtypecode ) : undef;
        $self->reportxml( $self->reporting_tag_xml( { record => $oldrecord, tag => $type->auth_tag_to_report } ) )
            if $type;
    }
    return $self;
}

=head3 oldmarc

    my $record = $self->oldmarc;

    Convert reportxml back to MARC::Record.

=cut

sub oldmarc {
    my ($self) = @_;
    return if !$self->reportxml;
    return MARC::Record->new_from_xml( $self->reportxml, 'UTF-8' );
}

=head2 CLASS METHODS

=head3 reporting_tag_xml

    my $xml = Koha::Authority::MergeRequest->reporting_tag_xml({
        record => $record, tag => $tag,
    });

=cut

sub reporting_tag_xml {
    my ( $class, $params ) = @_;
    return if !$params->{record} || !$params->{tag};

    my $newrecord = MARC::Record->new;
    $newrecord->encoding('UTF-8');
    my $reportfield = $params->{record}->field( $params->{tag} );
    return if !$reportfield;

    # For UNIMARC we need a field 100 that includes the encoding
    # at position 13 and 14
    if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
        $newrecord->append_fields(
            MARC::Field->new( '100', '', '', a => ' ' x 13 . '50' ),
        );
    }

    $newrecord->append_fields($reportfield);
    return $newrecord->as_xml(
        C4::Context->preference('marcflavour') eq 'UNIMARC'
        ? 'UNIMARCAUTH'
        : 'MARC21'
    );
}

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'NeedMergeAuthority';
}

=head1 AUTHOR

Marcel de Rooy (Rijksmuseum)

Koha Development Team

=cut

1;
