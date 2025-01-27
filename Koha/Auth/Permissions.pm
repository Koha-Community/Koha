package Koha::Auth::Permissions;

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

use C4::Auth qw//;

=head1 NAME

Koha::Auth::Permissions - Class for setting up CAN_user_* permissions

=head1 SYNOPSIS

=head2 METHODS

=head3 get_authz_from_flags

=cut

sub get_authz_from_flags {
    my ( $class, $args ) = @_;
    my $flags = $args->{flags};
    my $authz;
    my $all_perms = C4::Auth::get_all_subpermissions();
    if ( $flags && $all_perms ) {
        foreach my $module ( keys %$all_perms ) {
            if (   ( $flags->{superlibrarian} == 1 )
                || ( defined( $flags->{$module} ) && $flags->{$module} == 1 ) )
            {
                foreach my $subperm ( keys %{ $all_perms->{$module} } ) {
                    $authz->{"CAN_user_${module}_${subperm}"} = 1;
                }
            } elsif ( ref( $flags->{$module} ) ) {
                foreach my $subperm ( keys %{ $flags->{$module} } ) {
                    $authz->{"CAN_user_${module}_${subperm}"} = 1;
                }
            }
        }
        foreach my $module ( keys %$flags ) {
            if (   ( $flags->{superlibrarian} == 1 )
                || ( $flags->{$module} == 1 )
                || ( ref( $flags->{$module} ) ) )
            {
                $authz->{"CAN_user_$module"} = 1;
            }
        }
    }
    return $authz;
}

1;
