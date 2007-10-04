#!/usr/bin/perl

# $Id$

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use C4::Auth;
use CGI;
use C4::Context;
use C4::Koha;
use C4::Output;
use C4::Log;
use Date::Manip;

=head1 viewlog.pl

plugin that shows a stats on borrowers

=cut

my $input    = new CGI;
my $do_it    = $input->param('do_it');
my $module   = $input->param("module");
my $user     = $input->param("user");
my $action   = $input->param("action");
my $object   = $input->param("object");
my $info     = $input->param("info");
my $datefrom = $input->param("from");
my $dateto   = $input->param("to");
my $basename = $input->param("basename");
my $mime     = $input->param("MIME");
my $del      = $input->param("sep");
my $output   = $input->param("output") || "screen";

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/viewlog.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 1 },
        debug           => 1,
    }
);

if ($do_it) {

    my $results = GetLogs($datefrom,$dateto,$user,$module,$action,$object,$info);
    my $total = scalar @$results;
    
    if ( $output eq "screen" ) {

        # Printing results to screen
        $template->param (
            total    => $total,
            $module  => 1,
            looprow  => $results,
            do_it    => 1,
            datefrom => $datefrom,
            dateto   => $dateto,
            user     => $user,
            module   => $module,
            object   => $object,
            action   => $action,
            info     => $info,
        );
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }
    else {

        # Printing to a csv file
        print $input->header(
            -type       => 'application/vnd.sun.xml.calc',
            -attachment => "$basename.csv",
            -filename   => "$basename.csv"
        );
        my $sep;
        $sep = C4::Context->preference("delimiter");

        foreach my $line (@$results) {
            if ( $module eq "catalogue" ) {
                print $line->{timestamp} . $sep;
                print $line->{firstname} . $sep;
                print $line->{surname} . $sep;
                print $line->{action} . $sep;
                print $line->{info} . $sep;
                print $line->{title} . $sep;
                print $line->{author} . $sep;
            }
        }

        exit;
    }
}
else {
    my $dbh = C4::Context->dbh;
    my @values;
    my %labels;
    my %select;
    my $req;

    my @mime = ( C4::Context->preference("MIME") );

    my $CGIextChoice = CGI::scrolling_list(
        -name     => 'MIME',
        -id       => 'MIME',
        -values   => \@mime,
        -size     => 1,
        -multiple => 0
    );

    my @dels         = ( C4::Context->preference("delimiter") );
    my $CGIsepChoice = CGI::scrolling_list(
        -name     => 'sep',
        -id       => 'sep',
        -values   => \@dels,
        -size     => 1,
        -multiple => 0
    );

    $template->param(
        total        => 0,
        CGIextChoice => $CGIextChoice,
        CGIsepChoice => $CGIsepChoice
        DHTMLcalendar_dateformat => get_date_format_string_for_DHTMLcalendar(),
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
