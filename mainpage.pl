#!/usr/bin/perl

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
#

use strict;

use CGI;
use C4::Output;
use C4::Auth;
use C4::AuthoritiesMarc;
use C4::Koha;
use C4::NewsChannels;
my $query     = new CGI;
my $authtypes = getauthtypes;
my @authtypesloop;

foreach my $thisauthtype (
    sort { $authtypes->{$a} <=> $authtypes->{$b} }
    keys %$authtypes
  )
{
    my %row = (
        value        => $thisauthtype,
        authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
    );
    push @authtypesloop, \%row;
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "intranet-main.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => {
            catalogue => 1,
        },
    }
);

my $marc_p = C4::Context->boolean_preference("marc");

$template->param(
    NOTMARC       => !$marc_p,
    authtypesloop => \@authtypesloop
);

my $all_koha_news   = &GetNewsToDisplay("koha");
my $koha_news_count = scalar @$all_koha_news;

$template->param(
    koha_news       => $all_koha_news,
    koha_news_count => $koha_news_count
);

output_html_with_http_headers $query, $cookie, $template->output;
