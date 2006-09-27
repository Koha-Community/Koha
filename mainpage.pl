#!/usr/bin/perl 
use strict;
use C4::Interface::CGI::Output;
use CGI;
use C4::Auth;
use C4::Suggestions;
use C4::Koha;
use C4::BookShelves;
use C4::NewsChannels;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "intranet-main.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1, circulate => 1,
			     				parameters => 1, borrowers => 1,
							permissions =>1, reserveforothers=>1,
							editcatalogue => 1, updatecharges => 1, },
			     debug => 1,
			     });

my $lang = "koha";
my $error=$query->param('error');
$template->param(error        =>$error);
my ($opac_news_count, $all_opac_news) = &get_opac_news(undef, $lang);
# if ($opac_news_count > 4) {$template->param(more_opac_news => 1);}
$template->param(opac_news        => $all_opac_news);
$template->param(opac_news_count  => $opac_news_count);

my $marc_p = C4::Context->boolean_preference("marc");
$template->param(NOTMARC => !$marc_p);
my $new_suggestions = &CountSuggestion("ASKED");
$template->param(new_suggestions => $new_suggestions);


my $count_pending_request = CountShelfRequest(undef, "PENDING");
$template->param(count_pending_request => $count_pending_request);
output_html_with_http_headers $query, $cookie, $template->output();

