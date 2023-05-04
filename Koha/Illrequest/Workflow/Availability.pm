package Koha::Illrequest::Workflow::Availability;

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

use base qw(Koha::Illrequest::Workflow);

use Koha::Plugins;

=head1 NAME

Koha::Illrequest::Workflow::Availability - Koha ILL Availability Searching

=head1 SYNOPSIS

Object-oriented class that provides availability searching via
availability plugins

=head1 DESCRIPTION

This class provides the ability to identify and fetch API services
that can be used to search for item availability

=head1 API

=head2 Class Methods

=head3 get_services

    my $services =
      Koha::Illrequest::Workflow::Availability->get_services($params);

Given our metadata, iterate plugins with the right method and
check if they can service our request and, if so, return an arrayref
of services. Optionally accept a hashref specifying additional filter
parameters

=cut

sub get_services {
    my ( $self, $params ) = @_;

    my $plugin_filter = { method => 'ill_availability_services' };

    if ( $params->{metadata} ) {
        $plugin_filter->{metadata} = $params->{metadata};
    }

    my @candidates = Koha::Plugins->new()->GetPlugins($plugin_filter);
    my @services   = ();
    foreach my $plugin (@candidates) {
        my $valid_service = $plugin->ill_availability_services(
            {
                metadata   => $self->{metadata},
                ui_context => $self->{ui_context},
            }
        );
        push @services, $valid_service if $valid_service;
    }

    return \@services;
}

=head3 show_availability

    my $show_availability =
    Koha::Illrequest::Workflow::Availability->show_availability($params);

Given $params, return true if availability should be shown

=cut

sub show_availability {
    my ( $self, $request ) = @_;

    my $services = $self->get_services;

    return

      # ILLCheckAvailability is enabled
      C4::Context->preference("ILLCheckAvailability")

      # At least 1 availability service exists
      && scalar @{$services}

      # Availability has not yet been checked
      && !$self->{metadata}->{checked_availability}

     # The form has been submitted and the backend is able to create the request
      && $request->_backend_capability( 'can_create_request',
        $self->{metadata} );
}

=head3 availability_template_params

    my $availability_template_params =
    Koha::Illrequest::Workflow::Availability->availability_template_params(
        $params);

Given $params, return true if availability should be shown

=cut

sub availability_template_params {
    my ( $self, $params ) = @_;

    $params->{method} = 'availability' if $self->{ui_context} eq 'staff';
    delete $params->{stage}            if $self->{ui_context} eq 'staff';
    my $services = $self->get_services;

    return (
        whole         => $params,
        metadata      => $self->prep_metadata($params),
        services_json => scalar encode_json($services),
        services      => $services,
        $self->{ui_context} eq 'opac'
        ? (
            illrequestsview => 1,
            message         => $params->{message},
            method          => 'availability',
          )
        : ()
    );
}

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
