#!/usr/bin/perl

# Script for handling import of MARC data into Koha db
#   and Z39.50 lookups

# Koha library project  www.koha-community.org

# Licensed under the GPL

# Copyright 2000-2002 Katipo Communications
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

# standard or CPAN modules used
use CGI qw ( -utf8 );
use CGI::Cookie;
use MARC::File::USMARC;
use Try::Tiny;

# Koha modules used
use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Matcher;
use Koha::UploadedFiles;
use C4::MarcModificationTemplates qw( GetModificationTemplates );
use Koha::Plugins;
use Koha::ImportBatches;
use Koha::BackgroundJob::StageMARCForImport;

my $input = CGI->new;

my $fileID                     = $input->param('uploadedfileid');
my $matcher_id                 = $input->param('matcher');
my $overlay_action             = $input->param('overlay_action');
my $nomatch_action             = $input->param('nomatch_action');
my $parse_items                = $input->param('parse_items');
my $item_action                = $input->param('item_action');
my $comments                   = $input->param('comments');
my $record_type                = $input->param('record_type');
my $encoding                   = $input->param('encoding') || 'UTF-8';
my $format                     = $input->param('format') || 'ISO2709';
my $marc_modification_template = $input->param('marc_modification_template_id');
my $basketno                   = $input->param('basketno');
my $booksellerid               = $input->param('booksellerid');
my $profile_id                 = $input->param('profile_id');
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/stage-marc-import.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { tools => 'stage_marc_import' },
    }
);

$template->param(
    basketno     => $basketno,
    booksellerid => $booksellerid,
);

if ($fileID) {
    my $upload = Koha::UploadedFiles->find( $fileID );
    my $filepath = $upload->full_path;
    my $filename = $upload->filename;

    my $params = {
        record_type                => $record_type,
        encoding                   => $encoding,
        format                     => $format,
        filepath                   => $filepath,
        filename                   => $filename,
        marc_modification_template => $marc_modification_template,
        comments                   => $comments,
        parse_items                => $parse_items,
        matcher_id                 => $matcher_id,
        overlay_action             => $overlay_action,
        nomatch_action             => $nomatch_action,
        item_action                => $item_action,
        basket_id                  => $basketno,
        vendor_id                  => $booksellerid,
        profile_id                 => $profile_id,
    };
    try {
        my $job_id = Koha::BackgroundJob::StageMARCForImport->new->enqueue( $params );
        if ($job_id) {
            $template->param(
                job_enqueued => 1,
                job_id => $job_id,
            );
        }
    }
    catch {
        warn $_;
        push @messages,
          {
            type  => 'error',
            code  => 'cannot_enqueue_job',
            error => $_,
          };
    };

} else {
    # initial form
    if ( C4::Context->preference("marcflavour") eq "UNIMARC" ) {
        $template->param( "UNIMARC" => 1 );
    }
    my @matchers = C4::Matcher::GetMatcherList();
    $template->param( available_matchers => \@matchers );

    my @templates = GetModificationTemplates();
    $template->param( MarcModificationTemplatesLoop => \@templates );

    if ( C4::Context->config('enable_plugins') ) {

        my @plugins = Koha::Plugins->new()->GetPlugins({
            method => 'to_marc',
        });
        $template->param( plugins => \@plugins );
    }
}

$template->param( messages => \@messages );

output_html_with_http_headers $input, $cookie, $template->output;
