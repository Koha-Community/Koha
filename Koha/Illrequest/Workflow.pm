package Koha::Illrequest::Workflow;

# Copyright 2023 PTFS Europe Ltd
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

use JSON;
use MIME::Base64 qw( encode_base64 );
use URI::Escape  qw( uri_escape );
use Encode       qw( encode );

use Koha::Plugins;

=head1 NAME

Koha::Illrequest::Workflow - Koha ILL Workflow parent class

=head1 SYNOPSIS

Object-oriented parent class for ILL workflow stages

=head1 DESCRIPTION

This class contains methods do be used by ILL workflow stages

=head1 API

=head2 Class Methods

=head3 new

    my $availability = Koha::Illrequest::Workflow::Availability->new( $params, 'opac' )

Create a new Koha::Illrequest::Workflow child class object.
We store the metadata and ui_context

=cut

sub new {
    my ( $class, $metadata, $ui_context ) = @_;
    my $self = {};

    $self->{metadata}   = $metadata;
    $self->{ui_context} = $ui_context;

    bless $self, $class;

    return $self;
}

=head3 prep_metadata

    my $prepared = Koha::Illrequest::Workflow->prep_metadata($metadata);

Given our metadata, return a string representing that metadata that can be
passed in a URL (encoded in JSON then Base64 encoded)

=cut

sub prep_metadata {
    my ( $self, $metadata ) = @_;

    # We sort the metadata hashref by key before encoding it, primarily
    # so this function returns something predictable that we can test!
    my $json = JSON->new;
    $json->canonical( [1] );
    return uri_escape(
        encode_base64( encode( 'utf-8', $json->encode($metadata) ) ) );
}

=head1 AUTHOR

Pedro Amorim <pedro.amorim@ptfs-europe.com>

=cut

1;
