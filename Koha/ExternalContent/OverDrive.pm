# Copyright 2014 Catalyst
#
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

package Koha::ExternalContent::OverDrive;

use Modern::Perl;
use Carp;

use base qw(Koha::ExternalContent);
use WebService::ILS::OverDrive::Patron;
use C4::Context;
use Koha::Logger;

use constant logger => Koha::Logger->get();

=head1 NAME

Koha::ExternalContent::OverDrive

=head1 SYNOPSIS

    Register return url with OverDrive:
      base app url + /cgi-bin/koha/external/overdrive/auth.pl

    use Koha::ExternalContent::OverDrive;
    my $od_client = Koha::ExternalContent::OverDrive->new();
    my $od_auth_url = $od_client->auth_url($return_page_url);

=head1 DESCRIPTION

A (very) thin wrapper around C<WebService::ILS::OverDrive::Patron>

Takes "OverDrive*" Koha preferences

=cut

sub new {
    my $class  = shift;
    my $params = shift || {};
    $params->{koha_session_id} or croak "No koha_session_id";

    my $self = $class->SUPER::new($params);
    unless ($params->{client}) {
        my $client_key     = C4::Context->preference('OverDriveClientKey')
          or croak("OverDriveClientKey pref not set");
        my $client_secret  = C4::Context->preference('OverDriveClientSecret')
          or croak("OverDriveClientSecret pref not set");
        my $library_id     = C4::Context->preference('OverDriveLibraryID')
          or croak("OverDriveLibraryID pref not set");
        my ($token, $token_type) = $self->get_token_from_koha_session();
        $self->client( WebService::ILS::OverDrive::Patron->new(
            client_id         => $client_key,
            client_secret     => $client_secret,
            library_id        => $library_id,
            access_token      => $token,
            access_token_type => $token_type,
            user_agent_params => { agent => $class->agent_string }
        ) );
    }
    return $self;
}

=head1 L<WebService::ILS::OverDrive::Patron> METHODS

Methods used without mods:

=over 4

=item C<error_message()>

=item C<patron()>

=item C<checkouts()>

=item C<holds()>

=item C<checkout($id, $format)>

=item C<checkout_download_url($id)>

=item C<return($id)>

=item C<place_hold($id)>

=item C<remove_hold($id)>

=back

Methods with slightly moded interfaces:

=head2 auth_url($page_url)

  Input: url of the page from which OverDrive authentication was requested

  Returns: Post OverDrive auth return handler url (see SYNOPSIS)

=cut

sub auth_url {
    my $self = shift;
    my $page_url = shift or croak "Page url not provided";

    my ($return_url, $page) = $self->_return_url($page_url);
    $self->set_return_page_in_koha_session($page);
    return $self->client->auth_url($return_url);
}

=head2 auth_by_code($code, $base_url)

  To be called in external/overdrive/auth.pl upon return from OverDrive auth

=cut

sub auth_by_code {
    my $self = shift;
    my $code = shift or croak "OverDrive auth code not provided";
    my $base_url = shift or croak "App base url not provided";

    my ($access_token, $access_token_type, $auth_token)
      = $self->client->auth_by_code($code, $self->_return_url($base_url));
    $access_token or die "Invalid OverDrive code returned";
    $self->set_token_in_koha_session($access_token, $access_token_type);

    if (my $koha_patron = $self->koha_patron) {
        $koha_patron->set({overdrive_auth_token => $auth_token})->store;
    }
    return $self->get_return_page_from_koha_session;
}

use constant AUTH_RETURN_HANDLER => "/cgi-bin/koha/external/overdrive/auth.pl";
sub _return_url {
    my $self = shift;
    my $page_url = shift or croak "Page url not provided";

    my ($base_url, $page) = ($page_url =~ m!^(https?://[^/]+)(.*)!);
    my $return_url = $base_url.AUTH_RETURN_HANDLER;

    return wantarray ? ($return_url, $page) : $return_url;
}

use constant RETURN_PAGE_SESSION_KEY => "overdrive.return_page";
sub get_return_page_from_koha_session {
    my $self = shift;
    my $return_page = $self->get_from_koha_session(RETURN_PAGE_SESSION_KEY) || "";
    $self->logger->debug("get_return_page_from_koha_session: $return_page");
    return $return_page;
}
sub set_return_page_in_koha_session {
    my $self = shift;
    my $return_page = shift || "";
    $self->logger->debug("set_return_page_in_koha_session: $return_page");
    return $self->set_in_koha_session( RETURN_PAGE_SESSION_KEY, $return_page );
}

use constant ACCESS_TOKEN_SESSION_KEY => "overdrive.access_token";
my $ACCESS_TOKEN_DELIMITER = ":";
sub get_token_from_koha_session {
    my $self = shift;
    my ($token, $token_type)
      = split $ACCESS_TOKEN_DELIMITER, $self->get_from_koha_session(ACCESS_TOKEN_SESSION_KEY) || "";
    $self->logger->debug("get_token_from_koha_session: ".($token || "(none)"));
    return ($token, $token_type);
}
sub set_token_in_koha_session {
    my $self = shift;
    my $token = shift || "";
    my $token_type = shift || "";
    $self->logger->debug("set_token_in_koha_session: $token $token_type");
    return $self->set_in_koha_session(
        ACCESS_TOKEN_SESSION_KEY,
        join($ACCESS_TOKEN_DELIMITER, $token, $token_type)
    );
}

=head1 OTHER METHODS

=head2 is_logged_in()

  Returns boolean

=cut

sub is_logged_in {
    my $self = shift;
    my ($token, $token_type) = $self->get_token_from_koha_session();
    $token ||= $self->auth_by_saved_token;
    return $token;
}

sub auth_by_saved_token {
    my $self = shift;

    my $koha_patron = $self->koha_patron or return;

    if (my $auth_token = $koha_patron->overdrive_auth_token) {
        my ($access_token, $access_token_type, $new_auth_token)
          = $self->client->auth_by_token($auth_token);
        $self->set_token_in_koha_session($access_token, $access_token_type);
        $koha_patron->set({overdrive_auth_token => $new_auth_token})->store;
        return $access_token;
    }

    return;
}

=head2 forget()

  Removes stored OverDrive token

=cut

sub forget {
    my $self = shift;

    $self->set_token_in_koha_session("", "");
    if (my $koha_patron = $self->koha_patron) {
        $koha_patron->set({overdrive_auth_token => undef})->store;
    }
}

use vars qw{$AUTOLOAD};
sub AUTOLOAD {
    my $self = shift;
    (my $method = $AUTOLOAD) =~ s/.*:://;
    my $od = $self->client;
    local $@;
    my $ret = eval { $od->$method(@_) };
    if ($@) {
        if ( $od->is_access_token_error($@) && $self->auth_by_saved_token ) {
            return $od->$method(@_);
        }
        die $@;
    }
    return $ret;
}
sub DESTROY { }

=head1 AUTHOR

CatalystIT

=cut

1;
