# Copyright 2016 Catalyst
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

package Koha::ExternalContent::RecordedBooks;

use Modern::Perl;
use Carp;

use base qw(Koha::ExternalContent);
use WebService::ILS::RecordedBooks::PartnerPatron;
use WebService::ILS::RecordedBooks::Partner;
use C4::Context;
use Koha::Logger;

use constant logger => Koha::Logger->get();

__PACKAGE__->mk_accessors(qw(domain is_identified));

=head1 NAME

Koha::ExternalContent::RecordedBooks

=head1 SYNOPSIS

    use Koha::ExternalContent::RecordedBooks;
    my $od_client = Koha::ExternalContent::RecordedBooks->new();
    my $od_auth_url = $od_client->auth_url();

=head1 DESCRIPTION

A (very) thin wrapper around C<WebService::ILS::RecordedBooks::Patron>

Takes "RecordedBooks*" Koha preferences

=cut

sub new {
    my $class  = shift;
    my $params = shift || {};

    my $self = $class->SUPER::new($params);
    unless ($params->{client}) {
        my $client_secret  = C4::Context->preference('RecordedBooksClientSecret')
          or croak("RecordedBooksClientSecret pref not set");
        my $library_id     = C4::Context->preference('RecordedBooksLibraryID')
          or croak("RecordedBooksLibraryID pref not set");
        my $domain         = C4::Context->preference('RecordedBooksDomain');
        my $patron = $params->{koha_session_id} ? $self->koha_patron : undef;
        my $email;
        if ($patron) {
            $email = $patron->email
              or $self->logger->warn("User with no email, cannot identify with RecordedBooks");
        }
        my $client;
        if ($email) {
            local $@;
            $client = eval { WebService::ILS::RecordedBooks::PartnerPatron->new(
                client_secret     => $client_secret,
                library_id        => $library_id,
                domain            => $domain,
                user_id           => $email,
            ) };
            $self->logger->warn("Invalid RecordedBooks user $email ($@)") if $@;
            $self->is_identified($client);
        }
        $client ||= WebService::ILS::RecordedBooks::Partner->new(
                client_secret     => $client_secret,
                library_id        => $library_id,
                domain            => $domain,
        );
        $self->client( $client );
    }
    return $self;
}

=head1 METHODS

L<WebService::ILS::RecordedBooks::PartnerPatron> methods used without mods:

=over 4

=item C<error_message()>

=back

=cut

use vars qw{$AUTOLOAD};
sub AUTOLOAD {
    my $self = shift;
    (my $method = $AUTOLOAD) =~ s/.*:://;
    return $self->client->$method(@_);
}
sub DESTROY { }

1;
