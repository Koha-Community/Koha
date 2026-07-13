#!/usr/bin/perl

# Copyright 2007 Liblime
# Parts copyright 2010 BibLibre
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

# Script to take some borrowers data in a known format and load it into Koha
#
# File format
#
# cardnumber,surname,firstname,title,othernames,initials,streetnumber,streettype,
# address line , address line 2, city, zipcode, country, email, phone, mobile, fax, work email, work phone,
# alternate streetnumber, alternate streettype, alternate address line 1, alternate city,
# alternate zipcode, alternate country, alternate email, alternate phone, date of birth, branchcode,
# categorycode, enrollment date, expiry date, noaddress, lost, debarred, contact surname,
# contact firstname, contact title, borrower notes, contact relationship
# gender, username, opac note, contact note, password, sort one, sort two
#
# any fields except cardnumber can be blank but the number of fields must match
# dates should be in the format you have set up Koha to expect
# branchcode and categorycode need to be valid

use Modern::Perl;

use Try::Tiny qw( catch try );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit output_html_with_http_headers );
use Koha::BackgroundJob::PatronImport;
use Koha::Database::Columns;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patron::Attribute::Types;
use Koha::Patron::Categories;
use Koha::Patrons;
use Koha::UploadedFiles;

use Text::CSV;

use CGI qw ( -utf8 );

my $extended = C4::Context->preference('ExtendedPatronAttributes');

my @columnkeys = map { $_ ne 'borrowernumber' ? $_ : () } Koha::Patrons->columns();
push( @columnkeys, 'patron_attributes' ) if $extended;
push( @columnkeys, qw( guarantor_relationship guarantor_id ) );

my $input = CGI->new();
my $op    = $input->param('op') // q{};

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "tools/import_borrowers.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'import_patrons' },
    }
);

# get the patron categories and pass them to the template
my @patron_categories =
    Koha::Patron::Categories->search_with_library_limits( {}, { order_by => ['description'] } )->as_list;
$template->param( categories      => \@patron_categories );
$template->param( borrower_fields => Koha::Database::Columns->columns->{borrowers} );

if ( $input->param('sample') ) {
    our $csv = Text::CSV->new( { binary => 1, formula => 'empty' } );    # binary needed for non-ASCII Unicode
    print $input->header(
        -type       => 'application/vnd.sun.xml.calc',                   # 'application/vnd.ms-excel' ?
        -attachment => 'patron_import.csv',
    );
    $csv->combine(@columnkeys);
    print $csv->string, "\n";
    exit 0;
}

my @preserve_fields = $input->multi_param('preserve_existing');

my $uploadedfileid = $input->param('uploadedfileid');
my $matchpoint     = $input->param('matchpoint');
my $welcome_new    = $input->param('welcome_new');
if ($matchpoint) {
    $matchpoint =~ s/^patron_attribute_//;
}

#create a patronlist
my $createpatronlist = $input->param('createpatronlist') || 0;
my $dt               = dt_from_string();
my $timestamp        = $dt->ymd('-') . ' ' . $dt->hms(':');

if ( $op eq 'cud-import' && $uploadedfileid ) {

    my $upload         = Koha::UploadedFiles->find($uploadedfileid);
    my $patronlistname = ( $upload ? $upload->filename : $uploadedfileid ) . ' (' . $timestamp . ')';

    my %defaults;
    for my $k (@columnkeys) {
        my $v = scalar $input->param($k);
        $defaults{$k} = $v if defined $v && length $v;
    }

    my $overwrite_passwords = defined $input->param('overwrite_passwords') ? 1 : 0;
    my $update_dateexpiry   = $input->param('update_dateexpiry') // "";

    my $job = Koha::BackgroundJob::PatronImport->new;
    try {
        my $job_id = $job->enqueue(
            {
                uploaded_file_id                => $uploadedfileid,
                defaults                        => \%defaults,
                matchpoint                      => $matchpoint,
                overwrite_cardnumber            => scalar $input->param('overwrite_cardnumber'),
                overwrite_passwords             => $overwrite_passwords,
                preserve_extended_attributes    => scalar $input->param('ext_preserve') || 0,
                preserve_fields                 => \@preserve_fields,
                update_dateexpiry               => $update_dateexpiry                 ? 1 : 0,
                update_dateexpiry_from_today    => $update_dateexpiry eq "now"        ? 1 : 0,
                update_dateexpiry_from_existing => $update_dateexpiry eq "dateexpiry" ? 1 : 0,
                send_welcome                    => $welcome_new,
                createpatronlist                => $createpatronlist,
                patronlistname                  => $patronlistname,
            }
        );

        if ($job_id) {
            $template->param(
                op     => 'enqueued',
                job_id => $job_id,
            );
        } else {
            $template->param(
                op    => 'enqueued',
                error => 'cannot_enqueue_job',
            );
        }
    } catch {
        if ( $job->id ) {
            $template->param(
                op     => 'enqueued',
                job_id => $job->id,
                error  => 'job_failed_to_queue',
            );
        } else {
            $template->param(
                op    => 'enqueued',
                error => 'cannot_enqueue_job',
            );
        }
    };

} else {
    if ($extended) {
        my @matchpoints     = ();
        my $attribute_types = Koha::Patron::Attribute::Types->search;

        while ( my $attr_type = $attribute_types->next ) {
            if ( $attr_type->unique_id() ) {
                push @matchpoints,
                    { code => "patron_attribute_" . $attr_type->code(), description => $attr_type->description() };
            }
        }
        $template->param( matchpoints => \@matchpoints );
    }
}

output_html_with_http_headers $input, $cookie, $template->output;
