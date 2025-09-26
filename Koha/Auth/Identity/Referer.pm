package Koha::Auth::Identity::Referer;

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

use C4::Context;

=head1 NAME

Koha::Auth::Identity::Referer

=head1 SYNOPSIS

    use Koha::Auth::Identity::Referer;

    Koha::Auth::Identity::Referer->store_referer({
        referer => $c->req->headers->referer,
        interface => $interface,
        session => $session,
    });

    my $target_uri = Koha::Auth::Identity::Referer->get_referer({
        session => $session,
    });

=head1 DESCRIPTION

    Class for working with HTTP referrers specifically for
    when doing SSO.

=head1 FUNCTIONS

=head2 store_referer

    Koha::Auth::Identity::Referer->store_referer({
        referer => $c->req->headers->referer,
        interface => $interface,
        session => $session,
    });

    If the referer is for a Koha URL, then it gets saved
    in a session variable for use after a successful SSO login.

=cut

sub store_referer {
    my ( $class, $args ) = @_;
    my $referer   = $args->{referer};
    my $interface = $args->{interface};
    my $session   = $args->{session};
    my $valid_referer;
    if ( $referer && $interface && $session ) {
        my $base_url;
        if ( $interface eq 'opac' ) {
            $base_url = C4::Context->preference('OPACBaseURL');
        } else {
            $base_url = C4::Context->preference('staffClientBaseURL');
        }
        if ( $base_url && $referer && $referer =~ /^\Q$base_url\E/ ) {
            my $referer_uri = URI->new($referer);

            #NOTE: Remove logout.x query param to prevent logout loops
            $referer_uri->query_param_delete('logout.x') if $referer_uri->query_param('logout.x');
            my $referer_to_save = $referer_uri->path_query();
            if ($referer_to_save) {

                #NOTE: Don't bother saving a root referer
                #NOTE: Don't save opac-main.pl because it should redirect to opac-user.pl
                unless ( ( $referer_to_save eq '/' ) || ( $referer_to_save eq '/cgi-bin/koha/opac-main.pl' ) ) {
                    $session->param( 'idp_referer', $referer_to_save );
                    $session->flush();
                }
            }
        }
    }
    return $valid_referer;
}

=head2 get_referer

    my $target_uri = Koha::Auth::Identity::Referer->get_referer({
        session => $session,
    });

    If a referer was stored in a session variable, then we retrieve
    it for use by SSO functionality. That is, after a successful SSO, we'll
    redirect to this referer, so we wind up back where we started.

=cut

sub get_referer {
    my ( $class, $args ) = @_;
    my $referer;
    my $session = $args->{session};
    if ($session) {
        my $idp_referer = $session->param('idp_referer');
        if ($idp_referer) {
            $referer = $idp_referer;
            $session->clear('idp_referer');
            $session->flush();
        }
    }
    return $referer;
}

1;
