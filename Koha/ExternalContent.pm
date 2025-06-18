# Copyright 2014 Catalyst
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

package Koha::ExternalContent;

use Modern::Perl;
use Carp qw( croak );
use base qw(Class::Accessor);

use Koha;
use Koha::Logger;
use Koha::Patrons;
use C4::Auth;

__PACKAGE__->mk_accessors(qw(client koha_session_id koha_patron logger));

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

=head2 agent_string

Missing POD for agent_string.

=cut

sub agent_string {
    return 'Koha/' . Koha::version();
}

=head2 new

Missing POD for new.

=cut

sub new {
    my $class  = shift;
    my $params = shift || {};

    $params->{logger} = Koha::Logger->get();

    return bless $params, $class;
}

sub _koha_session {
    my $self       = shift;
    my $session_id = $self->koha_session_id or return;
    return C4::Auth::get_session($session_id);
}

=head2 get_from_koha_session

Missing POD for get_from_koha_session.

=cut

sub get_from_koha_session {
    my $self    = shift;
    my $key     = shift                or croak "No key";
    my $session = $self->_koha_session or return;
    return $session->param($key);
}

=head2 set_in_koha_session

Missing POD for set_in_koha_session.

=cut

sub set_in_koha_session {
    my $self    = shift;
    my $key     = shift or croak "No key";
    my $value   = shift;
    my $session = $self->_koha_session or croak "No Koha session";
    return $session->param( $key, $value );
}

=head2 koha_patron

Missing POD for koha_patron.

=cut

sub koha_patron {
    my $self = shift;

    if ( my $patron = $self->_koha_patron_accessor ) {
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
