package Koha::App::Plugin::RESTV1;

# Copyright 2020 BibLibre
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

use Mojo::Base 'Mojolicious::Plugin';

use Koha::REST::V1;

sub register {
    my ( $self, $app ) = @_;

    my $v1 = Koha::REST::V1->new( config => { route => '/v1' } );
    $app->routes->any('/api')->partial(1)->to( app => $v1 );
}

1;

=encoding utf8

=head1 NAME

Koha::App::Plugin::RESTV1

=head1 DESCRIPTION

Koha App Plugin used to intercept api calls and route them to the dedicated REST API Mojolicious App.

=head1 METHODS

=head2 register

Called at application startup; Sets up a router to catch all calls to /api and pass them through to Koha::REST::V1.

=cut
