#!/usr/bin/perl

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

# $Id$

=head1 NAME

lateissues

=head1 DESCRIPTION

this script display late issue by types.

=head1 PARAMETERS

=over 4

=item supplierid
the id of the supplier this script has to search late issues.

=back

=cut

use strict;
use CGI;
use C4::Auth;
use C4::Serials;
use C4::Acquisition;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Bookseller;

my $query = new CGI;
# my $title = $query->param('title');
# my $ISSN = $query->param('ISSN');
# my @subscriptions = GetSubscriptions($title,$ISSN);

my $supplierid = $query->param('supplierid');
my %supplierlist = GetSuppliersWithLateIssues;
my @select_supplier;
push @select_supplier,"";
foreach my $supplier (keys %supplierlist){
    push @select_supplier, $supplier
}
my $CGIsupplier=CGI::scrolling_list(
            -name     => 'supplierid',
            -values   => \@select_supplier,
            -default  => $supplierid,
            -labels   => \%supplierlist,
            -size     => 1,
            -multiple => 0 );

my ($count,@lateissues);
($count,@lateissues) = GetLateIssues($supplierid) ;
my @supplierinfo=GetBookSeller($supplierid) if $supplierid;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/lateissues.tmpl",
                query => $query,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {catalogue => 1},
                debug => 1,
                });

$template->param(
    CGIsupplier => $CGIsupplier,
    lateissues => \@lateissues,
    phone => $supplierinfo[0]->{phone},
    booksellerfax => $supplierinfo[0]->{booksellerfax},
    bookselleremail => $supplierinfo[0]->{bookselleremail},
    );
output_html_with_http_headers $query, $cookie, $template->output;
