#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Output;  # contains gettemplate
use C4::Interface::CGI::Output;
# use C4::Auth;
use C4::Context;
use CGI;

my $query = new CGI;

# find the script that called the online help using the CGI referer()

my $refer  = $query->referer();
$refer =~ /.*koha\/(.*)\.pl.*/;
my $from = "help/$1.tmpl";

my $template = gethelptemplate($from,"intranet");
# my $template
output_html_with_http_headers $query, "", $template->output;


sub gethelptemplate {
	my ($tmplbase) = @_;

	my $htdocs;
		$htdocs = C4::Context->config('intrahtdocs');
	my ($theme, $lang) = themelanguage($htdocs, $tmplbase, "intranet");
	unless (-e "$htdocs/$theme/$lang/$tmplbase") {
		$tmplbase="help/nohelp.tmpl";
		my ($theme, $lang) = themelanguage($htdocs, $tmplbase, "intranet");
	}
	my $template = HTML::Template->new(filename      => "$htdocs/$theme/$lang/$tmplbase",
				   die_on_bad_params => 0,
				   global_vars       => 1,
				   path              => ["$htdocs/$theme/$lang/includes"]);

	# XXX temporary patch for Bug 182 for themelang
	$template->param(themelang => '/intranet-tmpl' . "/$theme/$lang",
							interface => '/intranet-tmpl',
							theme => $theme,
							lang => $lang);
	return $template;
}
