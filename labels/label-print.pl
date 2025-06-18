#!/usr/bin/perl
#
# Copyright 2009 Foundations Bible College.
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

use CGI qw ( -utf8 );

use C4::Context;
use C4::Auth          qw( get_template_and_user );
use C4::Output        qw( output_html_with_http_headers );
use C4::Creators::Lib qw(
    get_all_layouts
    get_all_templates
    get_output_formats
);
use C4::Labels::Batch;

my $cgi = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "labels/label-print.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

my $op = $cgi->param('op') || 'none';
my @label_ids;
@label_ids = $cgi->multi_param('label_id') if $cgi->param('label_id');    # this will handle individual label printing
my @batch_ids;
@batch_ids = $cgi->multi_param('batch_id') if $cgi->param('batch_id');
my $layout_id   = $cgi->param('layout_id')   || undef;
my $template_id = $cgi->param('template_id') || undef;
my $start_label = $cgi->param('start_label') || 1;
my @item_numbers;
@item_numbers = $cgi->multi_param('item_number') if $cgi->param('item_number');
my $output_format = $cgi->param('output_format') || 'pdf';
my $referer       = $cgi->param('referer')       || undef;

my $txt_from       = $cgi->param('from') || undef;
my $txt_to         = $cgi->param('to')   || undef;
my $from           = int($txt_from)      || undef;
my $to             = int($txt_to)        || undef;
my $barcode_length = length($txt_from)   || undef;

my $layouts           = undef;
my $templates         = undef;
my $output_formats    = undef;
my @batches           = ();
my $multi_batch_count = scalar(@batch_ids) || ( $from && $to ) ? 1 : 0;
my $label_count       = scalar(@label_ids);
my $item_count        = scalar(@item_numbers);

if ( $op eq 'cud-export' ) {
    if (@label_ids) {
        my $label_id_param = '&amp;label_id=';
        $label_id_param .= join( '&amp;label_id=', @label_ids );
        push(
            @batches,
            {
                create_script => ( $output_format eq 'pdf' ? 'label-create-pdf.pl' : 'label-create-csv.pl' ),
                batch_id      => $batch_ids[0],
                template_id   => $template_id,
                layout_id     => $layout_id,
                start_label   => $start_label,
                label_ids     => $label_id_param,
                label_count   => scalar(@label_ids),
            }
        );
        $template->param(
            batches => \@batches,
            referer => $referer,
        );
    } elsif (@item_numbers) {
        my $item_number_param = '&amp;item_number=';
        $item_number_param .= join( '&amp;item_number=', @item_numbers );
        push(
            @batches,
            {
                create_script => ( $output_format eq 'pdf' ? 'label-create-pdf.pl' : 'label-create-csv.pl' ),
                template_id   => $template_id,
                layout_id     => $layout_id,
                start_label   => $start_label,
                item_numbers  => $item_number_param,
                label_count   => scalar(@item_numbers),
            }
        );
        $template->param(
            batches => \@batches,
            referer => $referer,
        );
    } elsif (@batch_ids) {
        foreach my $batch_id (@batch_ids) {
            push(
                @batches,
                {
                    create_script => ( $output_format eq 'pdf' ? 'label-create-pdf.pl' : 'label-create-csv.pl' ),
                    batch_id      => $batch_id,
                    template_id   => $template_id,
                    layout_id     => $layout_id,
                    start_label   => $start_label,
                }
            );
        }
        $template->param(
            batches => \@batches,
            referer => $referer,
        );
    } elsif ( $from and $to ) {
        my $dbh = C4::Context->dbh;

        my $sth = $dbh->prepare(
            'SELECT COUNT(*) AS has_barcode FROM creator_layouts WHERE printing_type LIKE("%BAR%") AND layout_id = ?;');
        $sth->execute($layout_id);
        if ( $sth->fetchrow_hashref->{'has_barcode'} == 0 ) {
            $sth = $dbh->prepare(
                'SELECT COUNT(*) AS existing_count FROM items WHERE CAST(barcode AS unsigned) BETWEEN ? AND ?;');
            $sth->execute( $from, $to );
            if ( $sth->fetchrow_hashref->{'existing_count'} < ( $to - $from + 1 ) ) {
                $template->param( warn_empty_range => 1 );
            }
        }

        push(
            @batches,
            {
                create_script  => 'label-create-pdf.pl',
                from           => $from,
                to             => $to,
                barcode_length => $barcode_length,
                template_id    => $template_id,
                layout_id      => $layout_id,
                start_label    => $start_label,
            }
        );
        $template->param(
            batches => \@batches,
            referer => $referer,
        );
    }
} elsif ( $op eq 'none' ) {

    # setup select menus for selecting layout and template for this run...
    $referer = $ENV{'HTTP_REFERER'};
    $referer =~ s/^.*?:\/\/.*?(\/.*)$/$1/m;
    @batch_ids    = map { { batch_id    => $_ } } @batch_ids;
    @label_ids    = map { { label_id    => $_ } } @label_ids;
    @item_numbers = map { { item_number => $_ } } @item_numbers;
    $templates    = get_all_templates(
        { fields => [qw( template_id template_code )], filters => { creator => "Labels" }, orderby => 'template_code' }
    );
    $layouts = get_all_layouts(
        { fields => [qw( layout_id layout_name )], filters => { creator => "Labels" }, orderby => 'layout_name' } );
    $output_formats = get_output_formats();
    $template->param(
        batch_ids         => \@batch_ids,
        label_ids         => \@label_ids,
        item_numbers      => \@item_numbers,
        templates         => $templates,
        layouts           => $layouts,
        output_formats    => $output_formats,
        multi_batch_count => $multi_batch_count,
        label_count       => $label_count,
        item_count        => $item_count,
        referer           => $referer,
        from              => $from,
        to                => $to,
        barcode_length    => $barcode_length,
        txt_from          => $txt_from,
        txt_to            => $txt_to
    );
}
output_html_with_http_headers $cgi, $cookie, $template->output;
