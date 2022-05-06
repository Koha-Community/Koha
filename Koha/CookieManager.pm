package Koha::CookieManager;

# Copyright 2022 Rijksmuseum, Koha Development Team
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
use CGI::Cookie;
# use Data::Dumper qw( Dumper );
# use List::MoreUtils qw( uniq );

use C4::Context;

use constant DENY_LIST_VAR => 'do_not_remove_cookie';

our $cookies;

=head1 NAME

Koha::CookieManager - Object for unified handling of cookies in Koha

=head1 SYNOPSIS

    use Koha::CookieManager;
    my $mgr = Koha::CookieManager->new;

    # Replace cookies
    $cookie_list = $mgr->replace_in_list( [ $cookie1, $cookie2_old ], $cookie2_new );

    # Clear cookies (governed by deny list entries in koha-conf)
    $cookie_list = $mgr->clear_unless( $cookie1, $cookie2, $cookie3_name );

=head1 DESCRIPTION

The current object allows you to clear cookies in a list based on the deny list
in koha-conf.xml. It also offers a method to replace the old version of a cookie
by a new one.

It could be extended by (gradually) routing cookie creation through it in order
to consistently fill cookie parameters like httponly, secure and samesite flag,
etc. And could serve to register all our cookies in a central location.

=head1 METHODS

=head2 new

    my $mgr = Koha::CookieManager->new({}); # parameters for extensions

=cut

sub new {
    my ( $class, $params ) = @_;
    my $self = bless $params//{}, $class;
    my $denied = C4::Context->config(DENY_LIST_VAR) || []; # expecting scalar or arrayref
    $denied = [ $denied ] if ref($denied) eq q{};
    $self->{_remove_unless} = { map { $_ => 1 } @$denied };
    $self->{_secure} = C4::Context->https_enabled;
    return $self;
}

=head2 clear_unless

    $cookies = $self->clear_unless( $query->cookie, @$cookies );

    Arguments: either cookie names or cookie objects (CGI::Cookie).
    Note: in the example above $query->cookie is a list of cookie names as returned
    by the CGI object.

    Returns an arrayref of cookie objects: empty, expired cookies for those passed
    by name or objects that are not on the deny list, together with the remaining
    (untouched) cookie objects that are on the deny list.

=cut

sub clear_unless {
    my ( $self, @cookies ) = @_;
    my @rv;
    my $seen = {};
    foreach my $c ( @cookies ) {
        my $name;
        my $type = ref($c);
        if( $type eq 'CGI::Cookie' ) {
            $name = $c->name;
        } elsif( $type ) { # not expected: ignore
            next;
        } else {
            $name = $c;
        }
        next if !$name;

        if( !$self->{_remove_unless}->{$name} ) {
            next if $seen->{$name};
            push @rv, CGI::Cookie->new(
                # -expires explicitly omitted to create shortlived 'session' cookie
                # -HttpOnly explicitly set to 0: not really needed here for the
                # cleared httponly cookies, while the js cookies should be 0
                -name => $name, -value => q{}, -HttpOnly => 0,
                $self->{_secure} ? ( -secure => 1 ) : (),
            );
            $seen->{$name} = 1; # prevent duplicates
        } elsif( $type eq 'CGI::Cookie' ) { # keep the last occurrence
            @rv = @{ $self->replace_in_list( \@rv, $c ) };
        }
    }
    return \@rv;
}

=head2 replace_in_list

    $list2 = $mgr->replace_in_list( $list1, $cookie );

    Add $cookie to $list1, removing older occurrences in list1.
    $list1 is a list of CGI::Cookie objects.
    $cookie must be a CGI::Cookie object; if it is not, only
    cookie objects in list1 are returned (filtering list1).

    Returns an arrayref of CGI::Cookie objects.

=cut

sub replace_in_list {
    my ( $self, $list, $cookie ) = @_;
    my $name = ref($cookie) eq 'CGI::Cookie' ? $cookie->name : q{};

    my @result;
    foreach my $c ( @$list ) {
        next if ref($c) ne 'CGI::Cookie';
        push @result, $c if !$name or $c->name ne $name;
    }
    push @result, $cookie if $name;
    return \@result;
}

=head1 INTERNAL ROUTINES

=cut

1;
