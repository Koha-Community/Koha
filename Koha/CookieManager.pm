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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI::Cookie;

# use Data::Dumper qw( Dumper );
# use List::MoreUtils qw( uniq );

use C4::Context;

# The cookies on the following list are removed unless koha-conf.xml indicates otherwise.
# koha-conf.xml may also contain additional cookies to be removed.
# Not including here: always_show_holds, catalogue_editor_, issues-table-load-immediately-circulation,
# and ItemEditorSessionTemplateId.
# TODO Not sure about branch (rotatingcollections), patronSessionConfirmation (circulation.pl)
use constant MANAGED_COOKIE_PREFIXES => qw{
    bib_list
    CGISESSID
    holdfor holdforclub
    intranet_bib_list
    JWT
    KohaOpacLanguage
    LastCreatedItem
    marctagstructure_selectdisplay
    search_path_code
    searchToOrder
};
use constant PATH_EXCEPTIONS => {
    always_show_holds => '/cgi-bin/koha/reserve',
};
use constant KEEP_COOKIE_CONF_VAR   => 'do_not_remove_cookie';
use constant REMOVE_COOKIE_CONF_VAR => 'remove_cookie';

our $cookies;

=head1 NAME

Koha::CookieManager - Object for unified handling of cookies in Koha

=head1 SYNOPSIS

    use Koha::CookieManager;
    my $mgr = Koha::CookieManager->new;

    # Replace cookies
    $cookie_list = $mgr->replace_in_list( [ $cookie1, $cookie2_old ], $cookie2_new );

    # Clear cookies
    $cookie_list = $mgr->clear_unless( $cookie1, $cookie2, $cookie3_name );

=head1 DESCRIPTION

The current object allows you to remove cookies on the hardcoded list
in this module, refined by 'keep' or 'remove' entries in koha-conf.xml.
Note that a keep entry overrules a remove.

This module also offers a method to replace the old version of a cookie
by a new one.

The module could be extended by (gradually) routing cookie creation
through it in order to consistently fill cookie parameters like httponly,
secure and samesite flag, etc. And could serve to register all our cookies
in a central location.

=head1 METHODS

=head2 new

    my $mgr = Koha::CookieManager->new({}); # parameters for extensions

=cut

sub new {
    my ( $class, $params ) = @_;
    my $self = bless $params // {}, $class;

    # Get keep and remove list from koha-conf (scalar or arrayref)
    my $keep_list = C4::Context->config(KEEP_COOKIE_CONF_VAR) || [];
    $self->{_keep_list} = ref($keep_list) ? $keep_list : [$keep_list];
    my $remove_list = C4::Context->config(REMOVE_COOKIE_CONF_VAR) || [];
    $self->{_remove_list} = ref($remove_list) ? $remove_list : [$remove_list];

    $self->{_secure} = C4::Context->https_enabled;
    return $self;
}

=head2 clear_unless

    $cookies = $self->clear_unless( $query->cookie, @$cookies );

    Arguments: either cookie names or cookie objects (CGI::Cookie).
    Note: in the example above $query->cookie is a list of cookie names as returned
    by the CGI object.

    Returns an arrayref of cookie objects: empty, expired cookies for
    cookies on the remove list, together with the remaining (untouched)
    cookie objects.

=cut

sub clear_unless {
    my ( $self, @cookies ) = @_;
    my @rv;
    my $seen = {};
    foreach my $c (@cookies) {
        my $name;
        my $type = ref($c);
        if ( $type eq 'CGI::Cookie' ) {
            $name = $c->name;
        } elsif ($type) {    # not expected: ignore
            next;
        } else {
            $name = $c;
        }
        next if !$name;

        if ( $self->_should_be_removed($name) ) {
            next if $seen->{$name};
            $seen->{$name} = 1;    # prevent duplicates
            if ($type) {
                $c->max_age(0);
                push @rv, _correct_path($c);
            } else {
                push @rv, _correct_path( CGI::Cookie->new( -name => $name, -value => q{}, '-max-age' => 0 ) );
            }
        } elsif ( $type eq 'CGI::Cookie' ) {    # keep the last occurrence
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
    foreach my $c (@$list) {
        next if ref($c) ne 'CGI::Cookie';
        push @result, $c if !$name or $c->name ne $name;
    }
    push @result, $cookie if $name;
    return \@result;
}

# INTERNAL ROUTINES

sub _should_be_removed {
    my ( $self, $name ) = @_;

    # Is this a controlled cookie? Or is it added as 'keep' or 'remove' in koha-conf.xml?
    # The conf entries are treated as prefix (no longer as regex).
    return unless grep { $name =~ /^$_/ } MANAGED_COOKIE_PREFIXES(), @{ $self->{_remove_list} };
    return !grep { $name =~ /^$_/ } @{ $self->{_keep_list} };
}

sub _correct_path {
    my $cookie_object = shift;
    my $path          = PATH_EXCEPTIONS->{ $cookie_object->name } or return $cookie_object;
    $cookie_object->path($path);
    return $cookie_object;
}

=head1 ADDITIONAL COMMENTS

    How do the keep or remove lines in koha-conf.xml work?

    <do_not_remove_cookie>some_cookie</do_not_remove_cookie>
    The name some_cookie should refer here to a cookie that is on the
    hardcoded list in this module. If you do not want it to be cleared
    (removed) on logout, include this line.
    You might want to do this e.g. for KohaOpacLanguage.

    <remove_cookie>another_cookie</remove_cookie>
    The name another_cookie refers here to a cookie that is not on the
    hardcoded list but you want this cookie to be cleared/removed on logout.
    It could be a custom cookie.

    Note that both directives use the cookie name as a prefix. So if you
    add a remove line for cookie1, it also affects cookie12, etc.
    Since a keep line overrules a remove line, this allows you to add
    lines for removing cookie1 and not removing cookie12 in order to
    remove cookie1, cookie11, cookie13 but not cookie12, etc.

=cut

1;
