#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use Mail::Sendmail;
use MIME::QuotedPrint;
use MIME::Base64;

use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

my $query = new CGI;

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-sendbasketform.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });

my $bib_list=$query->param('bib_list');
my $email_add=$query->param('email_add');

if ($email_add) {
	my $email_from = C4::Context->preference('KohaAdminEmailAddress');

	my %mail = (	 To      => $email_add,
						 From    => $email_from);

	my ($template2, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-sendbasket.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });

	my @bibs = split(/\//, $bib_list);
	my @results;

	foreach my $biblionumber (@bibs) {
		$template2->param(biblionumber => $biblionumber);

		my $dat = &bibdata($biblionumber);
		my ($authorcount, $addauthor) = &addauthor($biblionumber);

		$dat->{'additional'}=$addauthor->[0]->{'author'};
		for (my $i = 1; $i < $authorcount; $i++) {
			$dat->{'additional'} .= "|" . $addauthor->[$i]->{'author'};
		}

		$dat->{'biblionumber'} = $biblionumber;
		
		push (@results, $dat);
	}

	my $resultsarray=\@results;
	$template2->param(BIBLIO_RESULTS => $resultsarray);

	# Getting template result
	my $template_res = $template2->output();

	# Analysing information and getting mail properties
	if ($template_res =~ /§SUBJECT§\n(.*)\n§END_SUBJECT§/s) { $mail{'subject'} = $1; }
	else { $mail{'subject'} = "no subject"; }

	my $email_header = "";
	if ($template_res =~ /§HEADER§\n(.*)\n§END_HEADER§/s) { $email_header = $1; }

	my $email_file = "basket.txt";
	if ($template_res =~ /§FILENAME§\n(.*)\n§END_FILENAME§/s) { $email_file = $1; }

	if ($template_res =~ /§MESSAGE§\n(.*)\n§END_MESSAGE§/s) { $mail{'body'} = $1; }

	my $boundary = "====" . time() . "====";
	$mail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";

	$email_header = encode_qp($email_header);

	$boundary = "--".$boundary;

	# Writing mail
	$mail{body} = <<END_OF_BODY;
$boundary
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

$email_header

$boundary
Content-Type: text/plain; name="$email_file"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="$email_file"

$mail{'body'}
$boundary--
END_OF_BODY

	# Sending mail
	if (sendmail %mail) {
	# do something if it works....
		warn "Mail sent ok\n";
		$template->param(SENT => "1");
		$template->param(email_add => $email_add);
	} else {
		# do something if it doesnt work....
		warn "Error sending mail: $Mail::Sendmail::error \n";
	}

	output_html_with_http_headers $query, $cookie, $template->output;
}
else {
	$template->param(bib_list => $bib_list);
	$template->param(url => "/cgi-bin/koha/opac-sendbasket.pl");
	output_html_with_http_headers $query, $cookie, $template->output;
}
