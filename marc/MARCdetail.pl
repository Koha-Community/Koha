#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains picktemplate
use CGI;
use C4::Search;
use MARC::Record;
use C4::Biblio;
use C4::Catalogue;
 
my $query=new CGI;


my $language='french';


my %configfile;
open (KC, "/etc/koha.conf");
while (<KC>) {
    chomp;
    (next) if (/^\s*#/
	    );
    if (/(.*)\s*=\s*(.*)/) {
	my $variable=$1;
	my $value=$2;
	# Clean up white space at beginning and end
	$variable=~s/^\s*//g;
	$variable=~s/\s*$//g;
	$value=~s/^\s*//g;
	$value=~s/\s*$//g;
	$configfile{$variable}=$value;
    }
}

    
my $biblionumber=$query->param('bib');
my $tag=$query->param('tag');
if (! defined $tag) { $tag='2XX';}
#print STDERR "BIB : $biblionumber // TAG : $tag\n";
if (! defined $biblionumber) {
    my $includes=$configfile{'includes'};
    ($includes) || ($includes="/usr/local/www/hdl/htdocs/includes");
    my $templatebase="MARCdetailbiblioselect.tmpl";
    my $theme=picktemplate($includes, $templatebase);
    my $template = HTML::Template->new(filename => "$includes/templates/$theme/$templatebase", die_on_bad_params => 0, path => [$includes]);
    print "Content-Type: text/html\n\n", $template->output;

} else {
    &showmarcrecord($biblionumber,$tag);
}

sub showmarcrecord {
    my ($biblionumber,$tag) = @_;
    my $dbh=&C4Connect;
    my $sth=$dbh->prepare("select liblibrarian from marc_subfield_structure where tagfield=? and tagsubfield=?");
    my $record =MARCgetbiblio($dbh,$biblionumber);
# open template
    my $templatebase="catalogue/MARCdetail.tmpl";
    my $includes=$configfile{'includes'};
    ($includes) || ($includes="/usr/local/www/hdl/htdocs/includes");
    my $theme=picktemplate($includes, $templatebase);
    my $template = HTML::Template->new(filename => "$includes/templates/$theme/$templatebase", die_on_bad_params => 0, path => [$includes]);
# fill arrays
    my @loop_data =();
    my @fields = $record->field($tag);
    foreach my $field (@fields) {
	my @subf=$field->subfields;
	for my $i (0..$#subf) {
	    $sth->execute($field->tag(), $subf[$i][0]);
	    my $row=$sth->fetchrow_hashref;
	    my %row_data;
	    $row_data{marc_lib}=$row->{'liblibrarian'};
	    $row_data{marc_value}=$subf[$i][1];
	    $row_data{marc_tag}=$field->tag().$subf[$i][0];
	    push(@loop_data, \%row_data);
#	    print $field->tag(), " ", $field->indicator(1),$field->indicator(2), "subf: ", $subf[$i][0]," =",$subf[$i][1]," <-- \n";
	}
    }
    
# fill template with arrays
    $template->param(biblionumber => $biblionumber);
    $template->param(marc =>\@loop_data);
    print "Content-Type: text/html\n\n", $template->output;
    
}
