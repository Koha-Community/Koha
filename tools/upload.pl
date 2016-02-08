#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2015 Rijksmuseum
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
use CGI qw/-utf8/;
use JSON;

use C4::Auth;
use C4::Output;
use Koha::Upload;

my $input  = CGI::->new;
my $op     = $input->param('op') // 'new';
my $plugin = $input->param('plugin');
my $index  = $input->param('index');         # MARC editor input field id
my $term   = $input->param('term');
my $id     = $input->param('id');
my $msg    = $input->param('msg');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/upload.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'upload_general_files' },
    }
);

$template->param(
    index      => $index,
    owner      => $loggedinuser,
    plugin     => $plugin,
);

my $upar = $plugin ? { public => 1 } : {};
if ( $op eq 'new' ) {
    $template->param(
        mode             => 'new',
        uploadcategories => Koha::Upload->getCategories,
    );
    output_html_with_http_headers $input, $cookie, $template->output;

} elsif ( $op eq 'search' ) {
    my $h = $id ? { id => $id } : { term => $term };
    my @uploads = Koha::Upload->new($upar)->get($h);
    $template->param(
        mode    => 'report',
        msg     => $msg,
        uploads => \@uploads,
    );
    output_html_with_http_headers $input, $cookie, $template->output;

} elsif ( $op eq 'delete' ) {
    # delete only takes the id parameter
    my $upl = Koha::Upload->new($upar);
    my ($fn) = $upl->delete( { id => $id } );
    my $e = $upl->err;
    my $msg =
        $fn ? JSON::to_json( { $fn => 6 } )
      : $e  ? JSON::to_json($e)
      :       undef;
    $template->param(
        mode             => 'deleted',
        msg              => $msg,
        uploadcategories => $upl->getCategories,
    );
    output_html_with_http_headers $input, $cookie, $template->output;

} elsif ( $op eq 'download' ) {
    my $upl = Koha::Upload->new($upar);
    my $rec = $upl->get( { id => $id, filehandle => 1 } );
    my $fh  = $rec->{fh};
    if ( !$rec || !$fh ) {
        $template->param(
            mode             => 'new',
            msg              => JSON::to_json( { $id => 5 } ),
            uploadcategories => $upl->getCategories,
        );
        output_html_with_http_headers $input, $cookie, $template->output;
    } else {
        my @hdr = $upl->httpheaders( $rec->{name} );
        print Encode::encode_utf8( $input->header(@hdr) );
        while (<$fh>) {
            print $_;
        }
        $fh->close;
    }
}
