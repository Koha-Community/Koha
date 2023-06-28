package Koha::Illrequest::Workflow::TypeDisclaimer;

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

use POSIX qw( strftime );

use base qw(Koha::Illrequest::Workflow);

=head1 NAME

Koha::Illrequest::TypeDisclaimer - Koha ILL TypeDisclaimer

=head1 SYNOPSIS

Object-oriented class that provides the ILL request type disclaimer

=head1 DESCRIPTION

This class provides the ability to verify if it should render type disclaimer
and handle the template params accordingly

=head1 API

=head2 Class Methods

=head3 show_type_disclaimer

    my $show_type_disclaimer =
    Koha::Illrequest::TypeDisclaimer->show_type_disclaimer($params);

Given $params, return true if type disclaimer should be shown

=cut

sub show_type_disclaimer {
    my ( $self, $request ) = @_;

    my $disc_sys_pref = $self->_get_type_disclaimer_sys_pref;

    my $disc_info =
      $self->_get_type_disclaimer_info( $self->_get_type_disclaimer_sys_pref,
        $self->{metadata}->{type} );

    return

      # ILLModuleDisclaimerByType contains correct YAML
      %{$disc_sys_pref}

      # Check that we have info to display for this type
      && $disc_info

      # ILLModuleDisclaimerByType contains at least 'all'
      && $disc_sys_pref->{all}

      # Type disclaimer has not yet been submitted
      && !$self->{metadata}->{type_disclaimer_submitted}

     # The form has been submitted and the backend is able to create the request
      && $request->_backend_capability( 'can_create_request',
        $self->{metadata} );
}

=head3 type_disclaimer_template_params

    my $type_disclaimer_template_params =
    Koha::Illrequest::TypeDisclaimer->type_disclaimer_template_params(
        $params);

Given $params, return true if type disclaimer should be rendered

=cut

sub type_disclaimer_template_params {
    my ( $self, $params ) = @_;

    my $disc_info =
      $self->_get_type_disclaimer_info( $self->_get_type_disclaimer_sys_pref,
        $params->{type} );

    $params->{method} = 'typedisclaimer' if $self->{ui_context} eq 'staff';
    delete $params->{stage}              if $self->{ui_context} eq 'staff';

    return (
        whole      => $params,
        metadata   => $self->prep_metadata($params),
        disclaimer => $disc_info,
        $self->{ui_context} eq 'opac'
        ? (
            illrequestsview => 1,
            message         => $params->{message},
            method          => 'typedisclaimer',
          )
        : ()
    );
}

=head3 after_request_created

    $type_disclaimer->after_request_created($params, $request);

Actions that need to be done after the request has been created

=cut

sub after_request_created {
    my ( $self, $params, $request ) = @_;

    # Store type disclaimer date and value
    my $type_disclaimer_date = {
        illrequest_id => $request->illrequest_id,
        type          => "type_disclaimer_date",
        value         => strftime( "%Y-%m-%dT%H:%M:%S", localtime( time() ) ),
        readonly      => 0
    };
    Koha::Illrequestattribute->new($type_disclaimer_date)->store;

    my $type_disclaimer_value = {
        illrequest_id => $request->illrequest_id,
        type          => "type_disclaimer_value",
        value         => $params->{type_disclaimer_value},
        readonly      => 0
    };
    Koha::Illrequestattribute->new($type_disclaimer_value)->store;
}

=head3 _get_type_disclaimer_info

    my $type_disclaimer_info =
      $self->_get_type_disclaimer_info( $type_disclaimer_sys_pref, $request_type );

Given ILLModuleDisclaimerByType sys pref and type, returns the respective
type disclaimer info
Returns undef if sys pref is empty or malformed
=cut

sub _get_type_disclaimer_info {
    my ( $self, $disc_sys_pref, $type ) = @_;

    my @matching_request_type =
      map ( $_ eq $type ? $_ : (), keys %$disc_sys_pref );

    my $disc_info = undef;
    if ( scalar @matching_request_type ) {
        return if $disc_sys_pref->{$type}->{bypass};

        $disc_info->{text}   = $disc_sys_pref->{$type}->{text};
        $disc_info->{av_cat} = $disc_sys_pref->{$type}->{av_category_code};
    }
    elsif ( $disc_sys_pref->{all} ) {
        $disc_info->{text}   = $disc_sys_pref->{all}->{text};
        $disc_info->{av_cat} = $disc_sys_pref->{all}->{av_category_code};
    }
    return $disc_info;
}

=head3 _get_type_disclaimer_sys_pref

    my $disc_sys_pref = $self->_get_type_disclaimer_sys_pref;

Returns YAML from ILLModuleDisclaimerByType syspref
Returns empty if empty or YAML error

=cut

sub _get_type_disclaimer_sys_pref {
    my ($self) = @_;

    return C4::Context->yaml_preference("ILLModuleDisclaimerByType") // {};
}

=head1 AUTHOR

Pedro Amorim <pedro.amorim@ptfs-europe.com>

=cut

1;
