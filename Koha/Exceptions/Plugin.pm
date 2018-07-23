package Koha::Exceptions::Plugin;

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

use Modern::Perl;

use Koha::Exceptions::Exception;

use Exception::Class (
    'Koha::Exceptions::Plugin' => {
        isa         => 'Koha::Exceptions::Exception',
    },
    'Koha::Exceptions::Plugin::ForbiddenAction' => {
        isa         => 'Koha::Exceptions::Plugin',
        description => 'The plugin is trying to do something it is not allowed to'
    },
    'Koha::Exceptions::Plugin::MissingMethod' => {
        isa         => 'Koha::Exceptions::Plugin',
        description => 'Required method is missing',
        fields      =>  ['plugin_name','method']
    }
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ( $msg) {
        if ( $self->isa('Koha::Exceptions::Plugin::MissingMethod') ) {
            $msg = sprintf("Cannot use plugin (%s) because the it doesn't implement the '%s' method which is required.", $self->plugin_name, $self->method );
        }
    }

    return $msg;
}

=head1 NAME

Koha::Exceptions::Plugin - Base class for Plugin exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Plugin

Generic Plugin exception

=head2 Koha::Exceptions::Plugin::MissingMethod

Exception to be used when a plugin is required to implement a specific
method and it doesn't.

=head3 Parameters

=over

=item plugin_name: the plugin name for display purposes

=item method: the missing method

=back

=head1 Class methods

=head2 full_message

Overloaded method for exception stringifying.

=cut

1;
