package Koha::App::Opac;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious';

use CGI::Compile;    # This module needs to be loaded early; do not remove

use Koha::Caches;
use Koha::Cache::Memory::Lite;

sub startup {
    my ($self) = @_;

    push @{ $self->plugins->namespaces }, 'Koha::App::Plugin';
    push @{ $self->static->paths },       $self->home->rel_file('koha-tmpl');
    $self->routes->namespaces( ['Koha::App::Controller'] );

    # Create routes for API
    $self->plugin('RESTV1');

    $self->plugin('CSRF');
    $self->plugin('Language');

    $self->hook( before_dispatch => \&_before_dispatch );
    $self->hook( around_action   => \&_around_action );

    my $r = $self->routes;

    $r->any('/cgi-bin/koha/*script')->to('CGI#opac')->name('cgi');

    $r->any('/')->to( cb => sub { shift->redirect_to('/cgi-bin/koha/opac-main.pl') } );
}

sub _before_dispatch {
    my $c = shift;

    my $path = $c->req->url->path->to_string;

    # Remove Koha version from URL
    $path =~ s/_\d{2}\.\d{7}\.(js|css)/.$1/;

    $c->req->url->path->parse($path);
}

sub _around_action {
    my ( $next, $c, $action, $last ) = @_;

    # Flush memory caches before every request
    Koha::Caches->flush_L1_caches();
    Koha::Cache::Memory::Lite->flush();

    return $next->();
}

1;

=encoding utf8

=head1 NAME

Koha::App::Opac - Mojolicious app for Koha's Opac Client

=head1 DESCRIPTION

Run the Koha Opac using Mojolicious servers

=head1 METHODS

=head2 startup

Called at application startup; Sets up routes, loads plugins and invokes hooks.

=cut
