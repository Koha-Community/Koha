#!/usr/bin/perl

# This file is part of Koha.
#
# Script to manage the opac news.
# written 11/04
# Casta�eda, Carlos Sebastian - seba3c@yahoo.com.ar - Physics Library UNLP Argentina
# Modified to include news to KOHA intranet - tgarip@neu.edu.tr NEU library -Cyprus
# Copyright 2000-2002 Katipo Communications
# Copyright (C) 2013    Mark Tompsett
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
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Koha;
use C4::Context;
use C4::Output;
use C4::NewsChannels;
use C4::Languages qw(getTranslatedLanguages);
use Date::Calc qw/Date_to_Days Today/;
use Koha::DateUtils;

my $cgi = new CGI;

my $id             = $cgi->param('id');
my $title          = $cgi->param('title');
my $content        = $cgi->param('content');
my $expirationdate;
if ( $cgi->param('expirationdate') ) {
    $expirationdate = output_pref({ dt => dt_from_string( scalar $cgi->param('expirationdate') ), dateformat => 'iso', dateonly => 1 });
}
my $timestamp      = output_pref({ dt => dt_from_string( scalar $cgi->param('timestamp') ), dateformat => 'iso', dateonly => 1 });
my $number         = $cgi->param('number');
my $lang           = $cgi->param('lang');
my $branchcode     = $cgi->param('branch');
my $error_message  = $cgi->param('error_message');

# Foreign Key constraints work with NULL, not ''
# NULL = All branches.
$branchcode = undef if (defined($branchcode) && $branchcode eq '');

my $new_detail = get_opac_new($id);

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/koha-news.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'edit_news' },
        debug           => 1,
    }
);

# Pass error message if there is one.
$template->param( error_message => $error_message ) if $error_message;

# get lang list
my @lang_list;
my $tlangs = getTranslatedLanguages() ;

foreach my $language ( @$tlangs ) {
    foreach my $sublanguage ( @{$language->{'sublanguages_loop'}} ) {
        push @lang_list,
        {
            language => $sublanguage->{'rfc4646_subtag'},
            selected => ( $new_detail->{lang} eq $sublanguage->{'rfc4646_subtag'} ? 1 : 0 ),
        };
    }
}

$template->param( lang_list   => \@lang_list,
                  branchcode  => $branchcode );

my $op = $cgi->param('op') // '';

if ( $op eq 'add_form' ) {
    $template->param( add_form => 1 );
    if ($id) {
        if($new_detail->{lang} eq "slip"){ $template->param( slip => 1); }
        $template->param( 
            op => 'edit',
            id => $new_detail->{'idnew'}
        );
        $template->{VARS}->{'new_detail'} = $new_detail;
    }
    else {
        $template->param( op => 'add' );
    }
}
elsif ( $op eq 'add' ) {
    if ($title) {
        add_opac_new(
            {
                title          => $title,
                content        => $content,
                lang           => $lang,
                expirationdate => $expirationdate,
                timestamp      => $timestamp,
                number         => $number,
                branchcode     => $branchcode,
                borrowernumber => $borrowernumber,
            }
        );
        print $cgi->redirect("/cgi-bin/koha/tools/koha-news.pl");
    }
    else {
        print $cgi->redirect("/cgi-bin/koha/tools/koha-news.pl?error_message=title_missing");
    }
}
elsif ( $op eq 'edit' ) {
    upd_opac_new(
        {
            idnew          => $id,
            title          => $title,
            content        => $content,
            lang           => $lang,
            expirationdate => $expirationdate,
            timestamp      => $timestamp,
            number         => $number,
            branchcode     => $branchcode,
        }
    );
    print $cgi->redirect("/cgi-bin/koha/tools/koha-news.pl");
}
elsif ( $op eq 'del' ) {
    my @ids = $cgi->multi_param('ids');
    del_opac_new( join ",", @ids );
    print $cgi->redirect("/cgi-bin/koha/tools/koha-news.pl");
}

else {

    my ( $opac_news_count, $opac_news ) = &get_opac_news( undef, $lang, $branchcode );
    
    foreach my $new ( @$opac_news ) {
        next unless $new->{'expirationdate'};
        my @date = split (/-/,$new->{'expirationdate'});
        if ($date[0]*$date[1]*$date[2]>0 && Date_to_Days( @date ) < Date_to_Days(&Today) ){
			$new->{'expired'} = 1;
        }
    }
    
    $template->param(
        opac_news       => $opac_news,
        opac_news_count => $opac_news_count,
		);
}
$template->param( lang => $lang );
output_html_with_http_headers $cgi, $cookie, $template->output;
