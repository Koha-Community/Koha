package Koha::SMTP::Server;

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
use Koha::Exceptions::Object;
use Koha::SMTP::Servers;

use base qw(Koha::Object);

=head1 NAME

Koha::SMTP::Server - Koha SMTP Server Object class

=head1 API

=head2 Class methods

=head3 store

    $server->store;

Overloaded store method.

=cut

sub store {
    my ($self) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            Koha::SMTP::Servers->search->update( { is_default => 0 },
                { no_triggers => 1 } )
              if $self->is_default;

            $self = $self->SUPER::store;
        }
    );

    return $self;
}

=head3 transport

    my $transport = $smtp_server->transport;
    $email->transport($transport);
    $email->send_or_die;

Returns an I<Email::Sender::Transport::SMTP::Persistent> object that can be used directly
with Email::Sender.

=cut

sub transport {
    my ($self) = @_;

    my $params = {
        host => $self->host,
        port => $self->port,
    };

    $params->{ssl} = $self->ssl_mode
        unless $self->ssl_mode eq 'disabled';

    $params->{timeout} = $self->timeout
        if $self->timeout;

    $params->{sasl_username} = $self->user_name
        if $self->user_name;

    $params->{sasl_password} = $self->password
        if $self->password;

    $params->{debug} = $self->debug;

    require Email::Sender::Transport::SMTP::Persistent;
    my $transport = Email::Sender::Transport::SMTP::Persistent->new( $params );

    return $transport;
}

=head3 libraries

    my $libraries = $smtp_server->libraries

Accessor to get the list of libraries that are linked to this SMTP server

=cut

sub libraries {
    my ($self) = @_;

    my @library_ids = $self->_result->library_smtp_servers->get_column('library_id')->all;
    return Koha::Libraries->search( { branchcode => { -in => \@library_ids } } );
}

=head3 is_system_default

    if ( $smtp_server->is_system_default ) { ... }

Method that tells if a Koha::SMTP::Server is the hardcoded one.

=cut

sub is_system_default {
    my ($self) = @_;

    return $self->{_is_system_default};
}

=head3 to_api

    my $json = $smtp_server->to_api;

Overloaded method that returns a JSON representation of the Koha::SMTP::Server object,
suitable for API output.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $json = $self->SUPER::to_api( $params );
    delete $json->{password};

    return $json;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::SMTP::Server object
on the API.

=cut

sub to_api_mapping {
    return {
        id => 'smtp_server_id'
    };
}

=head2 Internal methods

=head3 _type

Return type of Object relating to Schema ResultSet

=cut

sub _type {
    return 'SmtpServer';
}

1;
