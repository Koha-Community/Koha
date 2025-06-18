package Koha::XSLT::HTTPS;

# Copyright 2022 Rijksmuseum
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

=head1 NAME

Koha::XSLT::HTTPS - Helper module to resolve issues with https stylesheets

=head1 SYNOPSIS

    Koha::XSLT::HTTPS->load( $filename );

=head1 DESCRIPTION

This module collects the contents of https XSLT styleheets where
libxml2/libxslt fail to do so. This should be considered as a
temporary workaround.

A similar problem comes up with xslt include files. The module could
be extended to resolve these issues too. What holds me back now, is
the fact that we need to parse the whole xslt code.

=cut

use Modern::Perl;
use LWP::UserAgent;

use Koha::Exceptions::XSLT;

=head1 METHODS

=head2 load

     Koha::XSLT::HTTPS->load( $filename );

=cut

sub load {
    my ( $class, $filename ) = @_;

    Koha::Exceptions::XSLT::MissingFilename->throw if !$filename;
    return { location => $filename }               if $filename !~ /^https:\/\//;

    my $ua   = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );
    my $resp = $ua->get($filename);
    if ( $resp->is_success ) {
        my $contents = $resp->decoded_content;

        # $contents = $self->_resolve_includes( $contents );
        return { string => $contents };
    }
    Koha::Exceptions::XSLT::FetchFailed->throw;
}

sub _resolve_includes {

    # We could parse the code for includes/imports, fetch them and change refs
    my ( $self, $code ) = @_;

    # TODO Extend it
    return $code;
}

1;

=head1 AUTHOR

    Marcel de Rooy, Rijksmuseum Amsterdam, The Netherlands

=cut
