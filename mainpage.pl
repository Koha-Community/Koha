#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains gettemplate
use C4::Interface::CGI::Output;
use CGI;
use C4::Auth;
use C4::AuthoritiesMarc;
use C4::Koha;
use C4::NewsChannels;
my $query = new CGI;
my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype (sort { $authtypes->{$a} <=> $authtypes->{$b} } keys %$authtypes) {
	my %row =(value => $thisauthtype,
				authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
			);
	push @authtypesloop, \%row;
}

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "intranet-main.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1, circulate => 1,
			     				parameters => 1, borrowers => 1,
							permissions =>1, reserveforothers=>1,
							borrow => 1, reserveforself => 1,
							editcatalogue => 1, updatecharges => 1, },
			     debug => 1,
			     });

my $marc_p = C4::Context->boolean_preference("marc");
$template->param(NOTMARC => !$marc_p);
$template->param(authtypesloop => \@authtypesloop);

my ($koha_news_count, $all_koha_news) = &get_opac_news(undef, 'koha');
$template->param(koha_news        => $all_koha_news);
$template->param(koha_news_count  => $koha_news_count);

output_html_with_http_headers $query, $cookie, $template->output;
