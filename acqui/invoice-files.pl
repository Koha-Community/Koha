#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014 Jacek Ablewicz
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

invoice-files.pl

=head1 DESCRIPTION

Manage files associated with invoice

=cut

use Modern::Perl;
use File::LibMagic;

use CGI;
use C4::Auth        qw( get_template_and_user );
use C4::Output      qw( output_html_with_http_headers output_error );
use C4::Acquisition qw( GetInvoice GetInvoiceDetails );
use Koha::Misc::Files;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => 'acqui/invoice-files.tt',
        query         => $input,
        type          => 'intranet',
        flagsrequired => { 'acquisition' => '*' },
    }
);

if ( !C4::Context->preference('AcqEnableFiles') ) {
    output_error( $input, '404' );
}

#NOTE: 'image/svg+xml' is not a safe type as the XML can contain Javascript
my $allowed_ftypes = {
    'application/pdf' => 1,
    'image/png'       => 1,
    'image/jpeg'      => 1,
    'image/gif'       => 1,
    'image/webp'      => 1,
};

my $invoiceid = $input->param('invoiceid') // '';
my $op        = $input->param('op')        // '';
my %errors;

my $mf = Koha::Misc::Files->new( tabletag => 'aqinvoices', recordid => $invoiceid );
defined($mf) || do { $op = 'none'; $errors{'invalid_parameter'} = 1; };

if ( $op eq 'download' ) {
    my $file_id = $input->param('file_id');
    my $file    = $mf->GetFile( id => $file_id );

    my $fname = $file->{'file_name'};
    my $ftype = $file->{'file_type'};

    my $magic           = File::LibMagic->new();
    my $magic_info      = $magic->info_from_string( $file->{'file_content'} );
    my $magic_mime_type = $magic_info->{mime_type};
    if ( $input->param('view') && ( $magic_mime_type && $allowed_ftypes->{$magic_mime_type} ) ) {
        print $input->header(
            -type                     => $file->{'file_type'},
            -charset                  => 'utf-8',
            'Content-Security-Policy' => "default-src 'none';"
        );
    } else {
        print $input->header(
            -type       => $file->{'file_type'},
            -charset    => 'utf-8',
            -attachment => $file->{'file_name'},
        );
    }
    print $file->{'file_content'};
} else {
    my $details = GetInvoiceDetails($invoiceid);
    $template->param(
        invoiceid     => $details->{'invoiceid'},
        invoicenumber => $details->{'invoicenumber'},
        suppliername  => $details->{'suppliername'},
        booksellerid  => $details->{'booksellerid'},
        datereceived  => $details->{'datereceived'},
    );

    if ( $op eq 'cud-upload' ) {
        my $uploaded_file = $input->upload('uploadfile');

        if ($uploaded_file) {
            my $filename = $input->param('uploadfile');
            my $mimetype = $input->uploadInfo($filename)->{'Content-Type'};

            $errors{'empty_upload'} = 1 if ( -z $uploaded_file );
            unless (%errors) {
                my $file_content = do { local $/; <$uploaded_file>; };
                if ( $mimetype =~ /^application\/(force-download|unknown)$/i && $filename =~ /\.pdf$/i ) {
                    $mimetype = 'application/pdf';
                }
                $mf->AddFile(
                    name        => $filename,
                    type        => $mimetype,
                    content     => $file_content,
                    description => scalar $input->param('description')
                );
            }
        } else {
            $errors{'no_file'} = 1;
        }
    } elsif ( $op eq 'cud-delete' ) {
        $mf->DelFile( id => scalar $input->param('file_id') );
    }

    $template->param(
        files  => ( defined($mf) ? $mf->GetFilesInfo() : undef ),
        errors => \%errors
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
