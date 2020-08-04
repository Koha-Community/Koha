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

use Modern::Perl;

use Template::Plugin;
use base qw( Template::Plugin );

use C4::Koha;
use C4::Context;
use Koha::Cash::Registers;

sub session_register_id {
    my ($self) = @_;

    return C4::Context->userenv ?
        C4::Context->userenv->{'register_id'} :
        '';
}

sub session_register_name {
    my ($self) = @_;

    return C4::Context->userenv
      ? C4::Context->userenv->{'register_name'}
      : '';
}

=head2

    [% SET registers = Registers.all() %]
    [% SET registers = Registers.all( { filters => { current_branch => 1 } } );

Returns a list of all cash registers available that adhere to the passed filters.

=cut

sub all {
    my ( $self, $params ) = @_;

    my $filters = $params->{filters};
    my $where;
    $where->{branch} = C4::Context->userenv->{'branch'}
      if $filters->{current_branch};
    my $registers = Koha::Cash::Registers->search($where)->unblessed();
    for my $register ( @{$registers} ) {
        $register->{selected} = ( defined( $self->session_register_id )
              && $register->{id} == $self->session_register_id ) ? 1 : 0;
    }

    return $registers;
}

1;
