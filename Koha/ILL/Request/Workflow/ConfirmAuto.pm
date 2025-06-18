package Koha::ILL::Request::Workflow::ConfirmAuto;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use base qw(Koha::ILL::Request::Workflow);

use JSON qw( encode_json );

=head1 NAME

Koha::ILL::Request::Workflow::ConfirmAuto - Koha ILL ConfirmAuto Workflow

=head1 SYNOPSIS

Object-oriented class that provides the AutoILLBackendPriority confirmation screen

=head1 DESCRIPTION

This class provides the ability to verify if it should render the AutoILLBackendPriority
confirmation screen and handle the template params accordingly

=head1 API

=head2 Class Methods

=head3 show_confirm_auto

    my $show_confirm_auto =
    Koha::ILL::Request::Workflow::ConfirmAuto->show_confirm_auto($params);

Given $request, returns true if confirm auto should be shown

=cut

sub show_confirm_auto {
    my ( $self, $request ) = @_;

    return

        # AutoILLBackendPriority is enabled
        C4::Context->preference("AutoILLBackendPriority")

        # Confirm auto has not yet been submitted
        && !$self->{metadata}->{confirm_auto_submitted}

        # The form has been submitted and the backend is able to create the request
        && $request->_backend_capability( 'can_create_request', $self->{metadata} );

}

=head3 confirm_auto_template_params

Given $params, returns the template parameters for rendering the confirm auto screen

=cut

sub confirm_auto_template_params {
    my ( $self, $params ) = @_;

    $params->{method} = 'confirmautoill' if $self->{ui_context} eq 'staff';
    delete $params->{stage}              if $self->{ui_context} eq 'staff';

    my @backends = $self->get_priority_backends( $self->{ui_context} );
    return (
        whole              => $params,
        metadata           => $self->prep_metadata($params),
        core_fields        => Koha::ILL::Backend::Standard->_get_core_fields,
        auto_backends_json => scalar encode_json( \@backends ),
        $self->{ui_context} eq 'opac'
        ? (
            illrequestsview => 1,
            message         => $params->{message},
            op              => 'confirmautoill',
            )
        : ()
    );
}

=head3 get_priority_backends

Returns backends ordered by AutoILLBackendPriority

=cut

sub get_priority_backends {
    my ( $self, $ui_context ) = @_;

    my $opac_backends;
    $opac_backends = Koha::ILL::Request::Config->new->opac_available_backends() if $ui_context eq 'opac';

    my @backends;
    my @priority_enabled_backends = split ",", C4::Context->preference('AutoILLBackendPriority');
    foreach my $backend (@priority_enabled_backends) {
        next if $ui_context eq 'opac' && !grep { $_ eq $backend } @$opac_backends;
        my $loaded_backend          = Koha::ILL::Request->new->load_backend($backend);
        my $availability_check_info = $loaded_backend->_backend->availability_check_info( $self->{metadata} );
        push @backends, $availability_check_info if $availability_check_info;
    }
    return @backends;
}

1;
