package Koha::SMTP::Servers;

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

use Koha::Database;
use Koha::Exceptions;

use Koha::SMTP::Server;

use base qw(Koha::Objects);

=head1 NAME

Koha::SMTP::Servers - Koha SMTP Server Object set class

=head1 API

=head2 Class methods

=head3 get_default

    my $server = Koha::SMTP::Servers->new->get_default;

Returns the default I<Koha::SMTP::Server> object.

=cut

sub get_default {
    my ($self) = @_;

    my $default = $self->search( { is_default => 1 }, { rows => 1 } )->single;

    unless ($default) {    # no database default
        my $smtp_config = C4::Context->config('smtp_server');

        if ($smtp_config) {    # use koha-conf.xml
            $default = Koha::SMTP::Server->new($smtp_config);
        } else {
            $default = Koha::SMTP::Server->new( $self->default_setting );
        }

        $default->{_is_system_default} = 1;
    }

    return $default;
}

=head2 Internal methods

=head3 _type

Return type of object, relating to Schema ResultSet

=cut

sub _type {
    return 'SmtpServer';
}

=head3 default_setting

    my $hash = Koha::SMTP::Servers::default_setting;

Returns the default setting that is to be used when no user-defined default
SMTP server is provided

=cut

sub default_setting {
    return {
        name      => 'localhost',
        host      => 'localhost',
        port      => 25,
        timeout   => 120,
        ssl_mode  => 'disabled',
        user_name => undef,
        password  => undef,
        debug     => 0
    };
}

=head3 object_class

Return object class

=cut

sub object_class {
    return 'Koha::SMTP::Server';
}

1;
