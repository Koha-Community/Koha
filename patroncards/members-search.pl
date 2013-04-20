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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;

use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Debug;

my $cgi = CGI->new;

my $batch_id = $cgi->param('batch_id') || 0;
my $startfrom = $cgi->param('startfrom')||1;
my $resultsperpage = $cgi->param('resultsperpage')||C4::Context->preference("PatronsPerPage")||20;
my $category = $cgi->param('category') || undef;
my $member = $cgi->param('member') || '';
utf8::decode($member);
my $orderby = $cgi->param('orderby') || undef;

my @categories=C4::Category->all;
my %categories_display;

foreach my $category (@categories) {
    my $hash={
        category_description=>$$category{description},
        category_type=>$$category{category_type}
    };
    $categories_display{$$category{categorycode}} = $hash;
}

my ($template, $loggedinuser, $cookie) = get_template_and_user({
                template_name => "patroncards/members-search.tmpl",
                query => $cgi,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {borrowers => 1},
                debug => 1,});

$orderby = "surname,firstname" unless $orderby;
$member =~ s/,//g;   #remove any commas from search string
$member =~ s/\*/%/g;

if ($member || $category) {
    my $results = $category ? Search({''=>$member, categorycode=>$category}, $orderby)
                            : Search($member, $orderby);
    my $count = $results ? @$results : 0;

    my @resultsdata = ();
    my $to = ($count>($startfrom * $resultsperpage)?$startfrom * $resultsperpage:$count);
    for (my $i = ($startfrom-1) * $resultsperpage; $i < $to; $i++){
        #find out stats
        my ($od,$issue,$fines) = GetMemberIssuesAndFines($results->[$i]{'borrowernumber'});
        my %row = (
            count               => $i + 1,
                %{$categories_display{$results->[$i]{categorycode}}},
            borrowernumber      => $results->[$i]{'borrowernumber'},
            cardnumber          => $results->[$i]{'cardnumber'},
            surname             => $results->[$i]{'surname'},
            firstname           => $results->[$i]{'firstname'},
            categorycode        => $results->[$i]{'categorycode'},
            address             => $results->[$i]{'address'},
            address2            => $results->[$i]{'address2'},
            city                => $results->[$i]{'city'},
            zipcode             => $results->[$i]{'zipcode'},
            country             => $results->[$i]{'country'},
            branchcode          => $results->[$i]{'branchcode'},
            overdues            => $od,
            issues              => $issue,
            odissue             => "$od/$issue",
            fines               => ($fines ? sprintf("%.2f",$fines) : ''),
            borrowernotes       => $results->[$i]{'borrowernotes'},
            sort1               => $results->[$i]{'sort1'},
            sort2               => $results->[$i]{'sort2'},
            dateexpiry          => C4::Dates->new($results->[$i]{'dateexpiry'},'iso')->output('syspref'),
        );
        push(@resultsdata, \%row);
    }
    my $base_url = '?' . join('&amp;', map { $_->{term} . '=' . $_->{val} } (
                                            { term => 'member',         val => $member         },
                                            { term => 'category',       val => $category       },
                                            { term => 'orderby',        val => $orderby        },
                                            { term => 'resultsperpage', val => $resultsperpage },
                                            { term => 'batch_id',       val => $batch_id       },)
                                        );
    $template->param(
        paginationbar   => pagination_bar(
                                            $base_url,  int( $count / $resultsperpage ) + 1,
                                            $startfrom, 'startfrom'
                                         ),
        startfrom       => $startfrom,
        from            => ($startfrom-1) * $resultsperpage + 1,
        to              => $to,
        multipage       => ($count != $to || $startfrom != 1),
        searching       => "1",
        member          => $member,
        category_type   => $category,
        numresults      => $count,
        resultsloop     => \@resultsdata,
        batch_id        => $batch_id,
    );
}
else {
    $template->param( batch_id => $batch_id);
}

$template->param( 'alphabet' => C4::Context->preference('alphabet') || join ' ', 'A' .. 'Z' );

output_html_with_http_headers $cgi, $cookie, $template->output;

__END__

#script to do a borrower enquiry/bring up borrower details etc
#written 20/12/99 by chris@katipo.co.nz


