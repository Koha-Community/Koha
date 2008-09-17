#!/usr/bin/perl
use strict;

use CGI;
use XML::LibXSLT;
use XML::LibXML;
use C4::Koha;
use C4::Auth;
use C4::Biblio;
use C4::Languages qw(getTranslatedLanguages);

my $query=new CGI;
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-detail.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			     });

# load the languages
my @languages_options = getTranslatedLanguages($query);
my $languages_count = @languages_options;
if($languages_count > 1){
        $template->param(languages => \@languages_options);
}
my $biblionumber=$query->param('biblionumber');
$template->param(biblionumber => $biblionumber);

# grab the XML, run it through our stylesheet, push it out to the browser
my $xmlrecord = GetXmlBiblio($biblionumber);
#my $xslfile = "/home/kohacat/etc/xslt/MARC21slim2HTML.xsl";
#my $xslfile = "/home/kohacat/etc/xslt/MARC21slim2English.xsl";
my $xslfile = C4::Context->config('intranetdir')."/koha-tmpl/intranet-tmpl/prog/en/xslt/compact.xsl";
my $parser = XML::LibXML->new();
my $xslt = XML::LibXSLT->new();
my $source = $parser->parse_string($xmlrecord);
my $style_doc = $parser->parse_file($xslfile);
my $stylesheet = $xslt->parse_stylesheet($style_doc);
my $results = $stylesheet->transform($source);
my $newxmlrecord = $stylesheet->output_string($results);
print "Content-type: text/html\n\n";
print $newxmlrecord;
