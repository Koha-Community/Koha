#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2011-2012 BibLibre
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
use CGI;
use Encode;

use C4::Auth;
use C4::Context;
use C4::Output;
use Koha::Upload;

my $input = CGI::->new;
my $hash = $input->param('id'); # historically called id (used in URLs?)

my $upl = Koha::Upload->new({ public => 1 });
my $rec = $upl->get({ hashvalue => $hash, filehandle => 1 });
my $fh = $rec->{fh};
if( !$rec || !$fh ) {
    my ( $template, $user, $cookie ) = get_template_and_user({
        query           => $input,
        template_name   => 'opac-retrieve-file.tt',
        type            => 'opac',
        authnotrequired => 1,
    });
    $template->param( hash => $hash );
    output_html_with_http_headers $input, $cookie, $template->output;
} else {
    my @hdr = $upl->httpheaders( $rec->{name} );
    print Encode::encode_utf8( $input->header( @hdr ) );
    while( <$fh> ) {
        print $_;
    }
    $fh->close;
}
