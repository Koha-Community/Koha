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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

use CGI;
use autouse 'Data::Dumper' => qw(Dumper);

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Creators;
use C4::Patroncards;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "patroncards/print.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op = $cgi->param('op') || 'none';
my @label_ids = $cgi->param('label_id') if $cgi->param('label_id');   # this will handle individual card printing; we use label_id to maintain consistency with the column names in the creator_batches table
my @batch_ids = $cgi->param('batch_id') if $cgi->param('batch_id');
my $layout_id = $cgi->param('layout_id') || undef;
my $template_id = $cgi->param('template_id') || undef;
my $start_card = $cgi->param('start_card') || 1;
my @borrower_numbers = $cgi->param('borrower_number') if $cgi->param('borrower_number');
my $output_format = $cgi->param('output_format') || 'pdf';
my $referer = $cgi->param('referer') || undef;

my $layouts = undef;
my $templates = undef;
my $output_formats = undef;
my @batches = ();
my $multi_batch_count = scalar(@batch_ids);
my $card_count = scalar(@label_ids);
my $borrower_count = scalar(@borrower_numbers);

if ($op eq 'export') {
    if (@label_ids) {
        my $label_id_param = '&amp;label_id=';
        $label_id_param .= join ('&amp;label_id=',@label_ids);
        push (@batches, {create_script   => ($output_format eq 'pdf' ? 'create-pdf.pl' : 'create-csv.pl'),
                         batch_id        => $batch_ids[0],
                         template_id     => $template_id,
                         layout_id       => $layout_id,
                         start_card      => $start_card,
                         label_ids       => $label_id_param,
                         card_count      => scalar(@label_ids),
                        });
        $template->param(
                        batches     => \@batches,
                        referer     => $referer,
                        );
    }
    elsif (@borrower_numbers) {
        my $borrower_number_param = '&amp;borrower_number=';
        $borrower_number_param .= join ('&amp;borrower_number=',@borrower_numbers);
        push (@batches, {create_script   => ($output_format eq 'pdf' ? 'create-pdf.pl' : 'create-csv.pl'),
                         template_id     => $template_id,
                         layout_id       => $layout_id,
                         start_card      => $start_card,
                         borrower_numbers    => $borrower_number_param,
                         card_count      => scalar(@borrower_numbers),
                        });
        $template->param(
                        batches     => \@batches,
                        referer     => $referer,
                        );
    }
    elsif (@batch_ids) {
        foreach my $batch_id (@batch_ids) {
           push (@batches, {create_script   => ($output_format eq 'pdf' ? 'create-pdf.pl' : 'create-csv.pl'),
                            batch_id        => $batch_id,
                            template_id     => $template_id,
                            layout_id       => $layout_id,
                            start_card      => $start_card,
                            });
        }
        $template->param(
                        batches     => \@batches,
                        referer     => $referer,
                        );
    }
}
elsif ($op eq 'none') {
    # setup select menus for selecting layout and template for this run...
    $referer = $ENV{'HTTP_REFERER'};
    $referer =~ s/^.*?:\/\/.*?(\/.*)$/$1/m;
    @batch_ids = grep{$_ = {batch_id => $_}} @batch_ids;
    @label_ids = grep{$_ = {label_id => $_}} @label_ids;
    @borrower_numbers = grep{$_ = {borrower_number => $_}} @borrower_numbers;
    $templates = get_all_templates(field_list => 'template_id, template_code', filter => 'creator = "Patroncards"');
    $layouts = get_all_layouts(field_list => 'layout_id, layout_name', filter => 'creator = "Patroncards"');
    $output_formats = get_output_formats();
    $template->param(
                    batch_ids                   => \@batch_ids,
                    label_ids                   => \@label_ids,
                    borrower_numbers            => \@borrower_numbers,
                    templates                   => $templates,
                    layouts                     => $layouts,
                    output_formats              => $output_formats,
                    multi_batch_count           => $multi_batch_count,
                    card_count                  => $card_count,
                    borrower_count              => $borrower_count,
                    referer                     => $referer,
                    );
}
output_html_with_http_headers $cgi, $cookie, $template->output;
