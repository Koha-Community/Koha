package Koha::Template::Plugin::Registers;

# Copyright PTFS Europe 2020

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

=head1 NAME

Koha::Template::Plugin::Registers

=head1 DESCRIPTION

The Registers plugin is a helper that returns register related session information for templates

=head1 SYNOPSIS

    [% USE Registers %]
    [% SET registers = Registers.all() %]
    [% SET registers = Registers.all( { filters => { current_branch => 1 } } );

=cut

use Modern::Perl;

use Template::Plugin;
use base qw( Template::Plugin );

use C4::Koha;
use C4::Context;
use Koha::Cash::Registers;

=head1 FUNCTIONS

=head2 session_register_id

Return the register_id for the register attached to the current session.

=cut

sub session_register_id {
    my ($self) = @_;

    return C4::Context->userenv
        ? C4::Context->userenv->{'register_id'}
        : '';
}

=head2 session_register_name

Return the register_name for the register attached to the current session.

=cut

sub session_register_name {
    my ($self) = @_;

    return C4::Context->userenv
        ? C4::Context->userenv->{'register_name'}
        : '';
}

=head2 all

    [% SET registers = Registers.all() %]
    [% SET registers = Registers.all( { filters => { current_branch => 1 } } );

Returns a list of all cash registers available that adhere to the passed filters.

=cut

sub all {
    my ( $self, $params ) = @_;

    return unless C4::Context->preference('UseCashRegisters');

    my $filters = $params->{filters} // {};
    my $where   = { archived => 0 };
    $where->{branch} = C4::Context->userenv->{'branch'}
        if ( $filters->{current_branch} && C4::Context->userenv );
    my $registers = Koha::Cash::Registers->search($where)->unblessed();

    my $selected = $params->{selected};
    for my $register ( @{$registers} ) {
        if ( defined($selected) ) {
            $register->{selected} = ( $register->{id} == $selected ) ? 1 : 0;
        } else {
            $register->{selected} =
                ( defined( $self->session_register_id ) && $register->{id} eq $self->session_register_id ) ? 1 : 0;
        }
    }

    return $registers;
}

1;
