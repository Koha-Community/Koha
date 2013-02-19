package Koha::Template::Plugin::Cache;

# Copyright Catalyst IT 2011

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

use strict;
use warnings;
use vars qw( $VERSION );
use base qw( Template::Plugin );
use Template::Plugin;
use C4::Context;
$VERSION = '0.01';

#------------------------------------------------------------------------
# new(\%options)
#------------------------------------------------------------------------

sub new {
    my ( $class, $context, $params ) = @_;
    my $cache;
    if ( $params->{cache} ) {
        $cache = delete $params->{cache};
    }
    else {
        require Koha::Cache;
        $cache = Koha::Cache->new( { 'cache_type' => 'memcached', 'cache_servers' => C4::Context->config('memcached_servers') });
    }
    my $self = bless {
        CACHE   => $cache,
        CONFIG  => $params,
        CONTEXT => $context,
    }, $class;
    return $self;
}

#------------------------------------------------------------------------
# $cache->include({
#                 template => 'foo.html',
#                 keys     => {'user.name', user.name},
#                 ttl      => 60, #seconds
#                });
#------------------------------------------------------------------------

sub inc {
    my ( $self, $params ) = @_;
    $self->_cached_action( 'include', $params );
}

sub proc {
    my ( $self, $params ) = @_;
    $self->_cached_action( 'process', $params );
}

sub _cached_action {
    my ( $self, $action, $params ) = @_;
    my $key;
    if ( $params->{key} ) {
        $key = delete $params->{key};
    }
    else {
        my $cache_keys = $params->{keys};
        $key = join(
            ':',
            (
                $params->{template},
                map { "$_=$cache_keys->{$_}" } keys %{$cache_keys}
            )
        );
    }
    my $result = $self->{CACHE}->get_from_cache($key);
    if ( !$result ) {
        $result = $self->{CONTEXT}->$action( $params->{template} );
        $self->{CACHE}->set_in_cache( $key, $result, $params->{ttl} );
    }
    return $result;
}

1;

=head1 NAME

Koha::Template::Plugin::Cache - cache output of templates

=head1 SYNOPSIS

  [% USE cache = Cache %]


  [% cache.inc(
                   'template' => 'slow.html',
                   'keys' => {'user.name' => user.name},
                   'ttl' => 360
                   ) %]

  # or with a pre-defined Cache::* object and key

  [% USE cache = Cache( cache => mycache ) %]

  [% cache.inc(
                       'template' => 'slow.html',
                       'key'      => mykey,
                       'ttl'      => 360
                       )  %]

__END__
