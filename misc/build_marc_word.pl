#!/usr/bin/perl -w
#-----------------------------------
# Script Name: build_marc_word.pl
# Script Version: 0.1.0
# Date:  2004/06/05
# Author:  Joshua Ferraro [jmf at kados dot org]
# Description: This script builds a new marc_word
#  table with a reduced number of tags (only those
#  tags that should be searched) allowing for
#  faster and more accurate searching when used
#  with the SearchMarc routines.  Make sure that
#  the MARCaddword routine in Biblio.pm will index
#  characters >= 1 char; otherwise, searches like
#  "O'brian, Patrick" will fail as the search 
#  routines will seperate that query into "o", 
#  "brian", and "patrick".  (If "o" is not in the
#  database the search will fail)
# Usage: build_marc_word.pl
# Revision History:
#    0.1.0  2004/06/11:  first working version.
#    			 Thanks to Chris Cormack
#    			 for helping with the $data object
#    			 and Stephen Hedges for providing
#    			 the list of MARC tags.
# FixMe:
#   *Should add a few parameters like 'delete from
#    marc_word' or make script ask user whether to
#    perform that task ...
#   *Add a 'status' report as the data is loaded ... 
#-----------------------------------
use lib '/usr/local/koha/intranet/modules/';
use strict;
use C4::Context;
use C4::Biblio;
my $dbh=C4::Context->dbh;

#Here is where you name the tags that you wish to index.  If you
# are using MARC21 this set of default tags should be fine but you
# may need to add holdings tags specific to your library (e.g., holding
# branch for Nelsonville is 942k but that may not be the case for your
# library).
my @tags=(

#Tag documentation from http://lcweb.loc.gov/marc/bibliographic/ecbdhome.html

"020a", # INTERNATIONAL STANDARD BOOK NUMBER
"022a", # INTERNATIONAL STANDARD SERIAL NUMBER
"100a",	# MAIN ENTRY--PERSONAL NAME
"110a",	# MAIN ENTRY--CORPORATE NAME
"110b",	#   Subordinate unit
"110c",	#   Location of meeting
"111a", # MAIN ENTRY--MEETING NAME
"111c", #   Location of meeting
"130a", # MAIN ENTRY--UNIFORM TITLE 
"240a", # UNIFORM TITLE 
"245a", # TITLE STATEMENT
"245b", #   Remainder of title
"245c", #   Statement of responsibility, etc.
"245p", #   Name of part/section of a work
"246a", # VARYING FORM OF TITLE
"246b", #   Remainder of title
"260b", # PUBLICATION, DISTRIBUTION, ETC. (IMPRINT)
"440a", # SERIES STATEMENT/ADDED ENTRY--TITLE
"440p", #   Name of part/section of a work
"500a", # GENERAL NOTE
"505t", # FORMATTED CONTENTS NOTE (t is Title)
"511a", # PARTICIPANT OR PERFORMER NOTE
"520a", # SUMMARY, ETC.
"534a", # ORIGINAL VERSION NOTE 
"534k", #   Key title of original
"534t", #   Title statement of original
"586a", # AWARDS NOTE
"600a", # SUBJECT ADDED ENTRY--PERSONAL NAME 
"610a", # SUBJECT ADDED ENTRY--CORPORATE NAME
"611a", # SUBJECT ADDED ENTRY--MEETING NAME
"630a", # SUBJECT ADDED ENTRY--UNIFORM TITLE
"650a", # SUBJECT ADDED ENTRY--TOPICAL TERM
"651a", # SUBJECT ADDED ENTRY--GEOGRAPHIC NAME
"700a", # ADDED ENTRY--PERSONAL NAME
"710a", # ADDED ENTRY--CORPORATE NAME
"711a", # ADDED ENTRY--MEETING NAME
"720a", # ADDED ENTRY--UNCONTROLLED NAME
"730a", # ADDED ENTRY--UNIFORM TITLE
"740a", # ADDED ENTRY--UNCONTROLLED RELATED/ANALYTICAL TITLE
"752a", # ADDED ENTRY--HIERARCHICAL PLACE NAME
"800a", # SERIES ADDED ENTRY--PERSONAL NAME
"810a", # SERIES ADDED ENTRY--CORPORATE NAME
"811a", # SERIES ADDED ENTRY--MEETING NAME
"830a", # SERIES ADDED ENTRY--UNIFORM TITLE
"942k"  # Holdings Branch ?? Unique to NPL??
);

#note that subfieldcode in marc_subfield_table is subfieldid in marc_word ... even
#though there is another subfieldid in marc_subfield_table--very confusing naming conventions!

#For each tag we run a search to find the necessary data for building the marc_word table
foreach my $this_tagid(@tags) {
	my $query="SELECT bibid,tag,tagorder,subfieldcode,subfieldorder,subfieldvalue FROM marc_subfield_table WHERE tag=? AND subfieldcode=?";
	my $sth=$dbh->prepare($query);

	my ($tag, $subfieldid);

#split the tag into tag, subfield
	if ($this_tagid =~ s/(\D+)//) {
		$subfieldid = $1;
		$tag = $this_tagid;
	}
#Then we pass this information on to MARCaddword in Biblio.pm to actually perform the import into marc_word
	$sth->execute($tag, $subfieldid);
	while (my $data=$sth->fetchrow_hashref()){
		MARCaddword($dbh,$data->{'bibid'},$data->{'tag'},$data->{'tagorder'},$data->{'subfieldcode'},$data->{'subfieldorder'},$data->{'subfieldvalue'});
	}
}
$dbh->disconnect();
