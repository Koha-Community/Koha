#!/usr/bin/perl

# Script to manage the opac news.
# written 11/04
# Casta�eda, Carlos Sebastian - seba3c@yahoo.com.ar - Physics Library UNLP Argentina
# Modified to include news to KOHA intranet - tgarip@neu.edu.tr NEU library -Cyprus
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
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Context;
use C4::Dates qw(format_date_in_iso);
use C4::Output;
use C4::NewsChannels;
use C4::Languages qw(getTranslatedLanguages);
use Date::Calc qw/Date_to_Days Today/;

my $cgi = new CGI;

my $id             = $cgi->param('id');
my $title          = $cgi->param('title');
my $new            = $cgi->param('new');
my $expirationdate = format_date_in_iso($cgi->param('expirationdate'));
my $number         = $cgi->param('number');
my $lang           = $cgi->param('lang');

my $new_detail = get_opac_new($id);

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/koha-news.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'edit_news' },
        debug           => 1,
    }
);

# get lang list
my @lang_list;
my $tlangs = getTranslatedLanguages() ;
foreach my $language ( @$tlangs ) {
    push @lang_list,
      {
        language => $language->{'rfc4646_subtag'},
        selected => ( $new_detail->{lang} eq $language->{'rfc4646_subtag'} ? 1 : 0 ),
      };
}

$template->param( lang_list => \@lang_list );

my $op = $cgi->param('op');

if ( $op eq 'add_form' ) {
    $template->param( add_form => 1 );
    if ($id) {
        $template->param( 
            op => 'edit',
            id => $new_detail->{'idnew'}
        );
        $template->param($new_detail);
    }
    else {
        $template->param( op => 'add' );
    }
}
elsif ( $op eq 'add' ) {
    add_opac_new( $title, $new, $lang, $expirationdate, $number );
    print $cgi->redirect("/cgi-bin/koha/tools/koha-news.pl");
}
elsif ( $op eq 'edit' ) {
    upd_opac_new( $id, $title, $new, $lang, $expirationdate, $number );
    print $cgi->redirect("/cgi-bin/koha/tools/koha-news.pl");
}
elsif ( $op eq 'del' ) {
    my @ids = $cgi->param('ids');
    del_opac_new( join ",", @ids );
    print $cgi->redirect("/cgi-bin/koha/tools/koha-news.pl");
}

else {

    my ( $opac_news_count, $opac_news ) = &get_opac_news( undef, $lang );
    
    foreach my $new ( @$opac_news ) {
        next unless $new->{'expirationdate'};
       	#$new->{'expirationdate'}=format_date_in_iso($new->{'expirationdate'});
        my @date = split (/-/,$new->{'expirationdate'});
        if ($date[0]*$date[1]*$date[2]>0 && Date_to_Days( @date ) < Date_to_Days(&Today) ){
			$new->{'expired'} = 1;
        }
    }
    
    $template->param(
        $lang           => 1,
        opac_news       => $opac_news,
        opac_news_count => $opac_news_count,
		);
}
$template->param(
				DHTMLcalendar_dateformat =>  C4::Dates->DHTMLcalendar(),
				dateformat    => C4::Context->preference("dateformat"),
		);
output_html_with_http_headers $cgi, $cookie, $template->output;
