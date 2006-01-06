#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use HTML::Template;

use C4::Context;
use C4::Auth;       # get_template_and_user
use C4::Interface::CGI::Output;
use C4::BookShelves;
use C4::Koha;
use C4::Members;

my $input = new CGI;
my $kohaVersion = C4::Context->config("kohaversion");
my $dbh = C4::Context->dbh;
my $query="Select itemtype,description from itemtypes order by description";
my $sth=$dbh->prepare($query);
$sth->execute;
my  @itemtype;
my %itemtypes;
while (my ($value,$lib) = $sth->fetchrow_array) {
	push @itemtype, $value;
	$itemtypes{$value}=$lib;
}

my $CGIitemtype=CGI::scrolling_list( -name     => 'value',
			-values   => \@itemtype,
			-labels   => \%itemtypes,
			-size     => 1,
			-multiple => 0 );
$sth->finish;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-main.tmpl",
			     type => "opac",
			     query => $input,
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });
my $borrower = getmember('',$borrowernumber);
my @options;
my $counter=0;
foreach my $language (getalllanguages()) {
	next if $language eq 'images';
	next if $language eq 'CVS';
	next if $language=~ /png$/;
	next if $language=~ /css$/;
	my $selected='0';
#                            next if $currently_selected_languages->{$language};
	push @options, { language => $language, counter => $counter };
	$counter++;
}
my $languages_count = @options;

if($languages_count > 1){
		$template->param(languages => \@options);
}
$template->param(CGIitemtype => $CGIitemtype,
				suggestion => C4::Context->preference("suggestion"),
				virtualshelves => C4::Context->preference("virtualshelves"),
				textmessaging => $borrower->{textmessaging},
				opaclargeimage => C4::Context->preference("opaclargeimage"),
                                kohaversion => $kohaVersion
);
output_html_with_http_headers $input, $cookie, $template->output;
