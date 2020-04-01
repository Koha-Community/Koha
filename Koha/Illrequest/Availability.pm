package Koha::Illrequest::Availability;

# Copyright 2019 PTFS Europe Ltd
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
use URI::Escape qw( uri_escape );
use Encode qw( encode );

use Koha::Plugins;

=head1 NAME

Koha::Illrequest::Availability - Koha ILL Availability Searching

=head1 SYNOPSIS

Object-oriented class that provides availability searching via
availability plugins

=head1 DESCRIPTION

This class provides the ability to identify and fetch API services
that can be used to search for item availability

=head1 API

=head2 Class Methods

=head3 new

    my $availability = Koha::Illrequest::Logger->new($metadata);

Create a new Koha::Illrequest::Availability object.
We also store the metadata to be used for searching

=cut

sub new {
    my ( $class, $metadata ) = @_;
    my $self  = {};

    $self->{metadata} = $metadata;

    bless $self, $class;

    return $self;
}

=head3 get_services

    my $services = Koha::Illrequest::Availability->get_services($params);

Given our metadata, iterate plugins with the right method and
check if they can service our request and, if so, return an arrayref
of services. Optionally accept a hashref specifying additional filter
parameters

=cut

sub get_services {
    my ( $self, $params ) = @_;

    my $plugin_filter = {
        method => 'ill_availability_services'
    };

    if ($params->{metadata}) {
        $plugin_filter->{metadata} = $params->{metadata};
    }

    my @candidates = Koha::Plugins->new()->GetPlugins($plugin_filter);
    my @services = ();
    foreach my $plugin(@candidates) {
        my $valid_service = $plugin->ill_availability_services({
            metadata => $self->{metadata},
            ui_context => $params->{ui_context}
        });
        push @services, $valid_service if $valid_service;
    }

    return \@services;
}

=head3 prep_metadata

    my $prepared = Koha::Illrequest::Availability->prep_metadata($metadata);

Given our metadata, return a string representing that metadata that can be
passed in a URL (encoded in JSON then Base64 encoded)

=cut

sub prep_metadata {
    my ( $self, $metadata ) = @_;

    # We sort the metadata hashref by key before encoding it, primarily
    # so this function returns something predictable that we can test!
    my $json = JSON->new;
    $json->canonical([1]);
    return uri_escape(encode_base64(encode('utf-8',$json->encode($metadata))));
}

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
