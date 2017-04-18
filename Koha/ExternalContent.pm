# Copyright 2014 Catalyst
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

package Koha::ExternalContent;

use Modern::Perl;
use Carp;
use base qw(Class::Accessor);

use Koha;
use Koha::Patrons;
use C4::Auth;

__PACKAGE__->mk_accessors(qw(client koha_session_id koha_patron));

=head1 NAME

Koha::ExternalContent

=head1 SYNOPSIS

 use Koha::ExternalContent;
 my $externalcontent = Koha::ExternalContent->new();

=head1 DESCRIPTION

Base class for interfacing with external content providers.

Subclasses provide clients for particular systems. This class provides
common methods for getting Koha patron.

=head1 METHODS

=cut

sub agent_string {
    return 'Koha/'.Koha::version();
}

sub new {
    my $class     = shift;
    my $params    = shift || {};
    return bless $params, $class;
}

sub _koha_session {
    my $self = shift;
    my $session_id = $self->koha_session_id or return;
    return C4::Auth::get_session($session_id);
}

sub get_from_koha_session {
    my $self = shift;
    my $key = shift or croak "No key";
    my $session = $self->_koha_session or return;
    return $session->param($key);
}

sub set_in_koha_session {
    my $self = shift;
    my $key = shift or croak "No key";
    my $value = shift;
    my $session = $self->_koha_session or croak "No Koha session";
    return $session->param($key, $value);
}

sub koha_patron {
    my $self = shift;

    if (my $patron = $self->_koha_patron_accessor) {
        return $patron;
    }

    my $id = $self->get_from_koha_session('number')
      or return;
    my $patron = Koha::Patrons->find($id)
      or die "Invalid patron number in session";
    return $self->_koha_patron_accessor($patron);
}

=head1 AUTHOR

CatalystIT

=cut

1;
