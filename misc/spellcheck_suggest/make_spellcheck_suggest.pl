#!/usr/bin/perl -w
## This Script creates a Koha suggest and spellcheck database
## for those features as visible on LibLime's opac: opac.liblime.com
## It also contains the needed specs for creating a table of
## queries for statistical purposes as well as a method of
## returning popular searches via the suggest and spellcheck.
## The code for running suggest and spellcheck can be found
## either in Koha 2.4 CVS (HEAD as of this writing) or at 
## LibLime's website in the downlaods
## section: http://liblime.com/c/downloads.html
##
##Author: Joshua Ferraro jmf at liblime dot com
##
## TODO: add suggest features, merge the two of them?
## There are a few configurable variables.  

## CONFIGURABLE VARIABLES ####################
##
 # These are the tags that have meaningful data
 # for the databases I've worked with (MARC21 only)
 # you may need to change them depending on your data
my @tags=(
#Tag documentation from http://lcweb.loc.gov/marc/bibliographic/ecbdhome.html
"020a", # INTERNATIONAL STANDARD BOOK NUMBER
#"022a", # INTERNATIONAL STANDARD SERIAL NUMBER
"100a", # MAIN ENTRY--PERSONAL NAME
"110a", # MAIN ENTRY--CORPORATE NAME
#"110b", #   Subordinate unit
#"110c", #   Location of meeting
#"111a", # MAIN ENTRY--MEETING NAME
#"111c", #   Location of meeting
"130a", # MAIN ENTRY--UNIFORM TITLE
"240a", # UNIFORM TITLE
"245a", # TITLE STATEMENT
"245b", #   Remainder of title
"245c", #   Statement of responsibility, etc.
"245p", #   Name of part/section of a work
"246a", # VARYING FORM OF TITLE
"246b", #   Remainder of title
#"260b", # PUBLICATION, DISTRIBUTION, ETC. (IMPRINT)
"440a", # SERIES STATEMENT/ADDED ENTRY--TITLE
"440p", #   Name of part/section of a work
#"500a", # GENERAL NOTE
"505t", # FORMATTED CONTENTS NOTE (t is Title)
"511a", # PARTICIPANT OR PERFORMER NOTE
#"520a", # SUMMARY, ETC.
"534a", # ORIGINAL VERSION NOTE
#"534k", #   Key title of original
#"534t", #   Title statement of original
#"586a", # AWARDS NOTE
"600a", # SUBJECT ADDED ENTRY--PERSONAL NAME
"610a", # SUBJECT ADDED ENTRY--CORPORATE NAME
"611a", # SUBJECT ADDED ENTRY--MEETING NAME
"630a", # SUBJECT ADDED ENTRY--UNIFORM TITLE
"650a", # SUBJECT ADDED ENTRY--TOPICAL TERM
"651a", # SUBJECT ADDED ENTRY--GEOGRAPHIC NAME
"700a", # ADDED ENTRY--PERSONAL NAME
"710a", # ADDED ENTRY--CORPORATE NAME
#"711a", # ADDED ENTRY--MEETING NAME
#"720a", # ADDED ENTRY--UNCONTROLLED NAME
"730a", # ADDED ENTRY--UNIFORM TITLE
"740a", # ADDED ENTRY--UNCONTROLLED RELATED/ANALYTICAL TITLE
#"752a", # ADDED ENTRY--HIERARCHICAL PLACE NAME
"800a", # SERIES ADDED ENTRY--PERSONAL NAME
#"810a", # SERIES ADDED ENTRY--CORPORATE NAME
#"811a", # SERIES ADDED ENTRY--MEETING NAME
"830a", # SERIES ADDED ENTRY--UNIFORM TITLE
#"942k"  # Holdings Branch ?? Unique to NPL??
);
## Leave this next bit alone
use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}
use C4::Context;
##
 # SUGGEST DATABASE INFO
 # You'll need to change this if you want to keep your 'suggest' database
 # separate from your Koha database -- simply comment out the next line
 # and uncomment the one after it, adding your site info (check out GRANT
 # syntax in the mysql manual if you're unsure how enable authentication)
#
my $dbh2 = C4::Context->dbh;
#
#my $dbh2=DBI->connect("DBI:mysql:<add your database name here>:localhost","<add your mysql user here>","<add your password here>");
########################################################################
## End of most common configurable variables: in most cases you won't need
## edit any further ... of course feel free to indulge yourself ;-)
########################################################################
my $dbh=C4::Context->dbh;
my $counter = 0;

# Check for existance of suggest database and add if it doesn't.
print "Step 1 of 5: Checking to make sure suggest tables exist\n";
my $check_tables_query = "select distinct resultcount from ?";
my @tables = ("notdistinctspchk", "notdistinctsugg", "spellcheck", "suggestions");
foreach my $table (@tables) {
  my $sth_check=$dbh2->prepare($check_tables_query) || die "cant prepare query: $DBI::errstr";
  my $rv = $sth_check->execute($table);
  if(!defined($rv)) {
    print "$table missing ... creating it now\n";
    my $create_this = "CREATE TABLE \'$table\' \(
  			display varchar\(40\) NOT NULL default \'\',
  			suggestion varchar\(40\) NOT NULL default \'\',
  			resultcount varchar\(40\) NOT NULL default \'0\'
			\) TYPE=MyISAM";
    my $sth_create = $dbh->prepare($create_this) || die "can't prepare query: $DBI::errstr";
    $sth_create->execute() || die "can't execute: $DBI::errstr";
    print "$table created ...\n";
  }else {
    print "$table exists ...  moving along\n";
  }
}
print "All tables present ... moving along\n";

print "Step 2 of 5: Deleting old data\n";
my $clear_out = "DELETE FROM notdistinctspchk";
# Clear out old data
my $sth_clear_out=$dbh2->prepare($clear_out) || die "cant prepare query";
$sth_clear_out->execute();
print "Step 3 of 5: Creating non-distinct table from various Koha tables\n";
my $query_words = "SELECT DISTINCT word, COUNT(word) FROM marc_word";
my $query_marc_subfields = "SELECT DISTINCT subfieldvalue, COUNT(subfieldvalue) FROM marc_subfield_table";
my $query_titles = "SELECT DISTINCT title, COUNT(title) FROM biblio GROUP BY title";
my $query_authors = "SELECT DISTINCT author, COUNT(author) FROM biblio GROUP BY author";

my @queries = ("$query_words", "$query_marc_subfields", "$query_titles", "$query_authors");

foreach my $query (@queries) {
	
	#we need to do some special stuff for marc_word and marc_subfield_table queries
	if ($query eq $queries[0]) { #marc_word
	my $listoftagsubfields;
	  my $notfirst;
	    foreach my $tag (@tags) {	
	      $listoftagsubfields.="$tag, ";
	      if (!$notfirst) {
	        $query.=" WHERE tagsubfield=\'$tag\'";
	        $notfirst = 1;
	      } else {
	        $query.=" OR tagsubfield=\'$tag\'";
	      }
	    }#foreach
	$query.=" GROUP BY word";
	print "Finished building marc_word list\n";
	print "Adding marc_word entries with the following tagsubfields:"."$listoftagsubfields"."\n";
	}

	if ($query eq $queries[1]) { #marc_subfield_table
	my $listofsubfieldstuff; #for testing
	my $notfirst;
          foreach my $tag (@tags) {
	    my $justtag = $tag;
	    $justtag =~ s/\D\Z//;
	    my $subfieldcode = $&;
	    $listofsubfieldstuff.="$justtag, "."$subfieldcode, ";
            if (!$notfirst) {
              $query.=" WHERE (tag=\'$justtag\' and subfieldcode=\'$subfieldcode\')";
	      $notfirst = 1;
            } else {
              $query.=" OR (tag=\'$justtag\' and subfieldcode=\'$subfieldcode\')";
            }
	  }#foreach
        $query.=" GROUP BY subfieldvalue";
	print "Finished building marc_subfield_table list\n";
	print "Adding marc_subfield_table entries with the following tags and subfields:"."$listofsubfieldstuff"."\n";
        }

	my $sth=$dbh->prepare($query) || die "cant prepare query";
	$sth->execute();

	my $insert = "INSERT INTO notdistinctspchk(suggestion,display,resultcount) VALUES(?,?,?)";

	my $sth2=$dbh2->prepare($insert);

	while (my ($phraseterm,$count)=$sth->fetchrow_array) {
		if ($phraseterm) {	
		  #$display looks exactly like the DB
		  my $display = $phraseterm;
		  #except for a few things
		  $display =~s/  / /g;
		  $display =~ s/^\s+//; #remove leading whitespace
		  $display  =~ s/\s+$//; #remove trailing whitespace
       		  $display =~ s/(\.|\/)/ /g;

		  #suggestion is tweaked for optimal searching
		  my $suggestion = $phraseterm;
		  $suggestion =~ tr/A-Z/a-z/;
		  $suggestion =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\})/ /g;
		  $suggestion =~s/(\Aand-or |\Aand\/or |\Aanon |\Aan |\Aa |\Abut |\Aby |\Ade |\Ader |\Adr |\Adu|et |\Afor |\Afrom |\Ain |\Ainto |\Ait |\Amy |\Anot |\Aon |\Aor |\Aper |\Apt |\Aspp |\Ato |\Avs |\Awith |\Athe )/ /g;
		  $suggestion =~s/( and-or | and\/or | anon | an | a | but | by | de | der | dr | du|et | for | from | in | into | it | my | not | on | or | per | pt | spp | to | vs | with | the )/ /g;

		  $suggestion =~s/  / /g;

		  $suggestion =~ s/^\s+//; #remove leading whitespace
		  $suggestion =~ s/\s+$//; #remove trailing whitespace
        
		  if (length($suggestion)>2) {
			$sth2->execute($suggestion,$display,$count) || die "can't execute write";
			$counter++;
		  } #if 
		} #if
	}#while
print $counter." more records added...\n";
$sth2->finish;
$sth->finish;
}

# Now grab distincts from there and insert into our REAL database

print "Step 4 of 5: Deleting old distinct entries\n";
my $clear_distincts = "DELETE FROM spellcheck";

# Clear out old data
my $sth_clear_distincts=$dbh2->prepare($clear_distincts) || die "cant prepare query";
$sth_clear_distincts->execute();

print "Step 5 of 5: Creating distinct spellcheck table out of non-distinct table\n";
my $query_distincts = "SELECT DISTINCT suggestion, display, COUNT(display) FROM notdistinctspchk GROUP BY suggestion";
my $insert_distincts = "INSERT INTO spellcheck(suggestion,display,resultcount) VALUES(?,?,?)";
my $distinctcounter = 0;

my $sth=$dbh2->prepare($query_distincts) || die "cant prepare query";
$sth->execute();
my $sth2=$dbh2->prepare($insert_distincts) || die "cant prepare query";
while (my ($suggestion,$display,$count)=$sth->fetchrow_array) {
	if ($count) {
		$sth2->execute($suggestion,$display,$count) || die "can't execute write";
		$distinctcounter++;
	}
}
print "Finished: total distinct items added to spellcheck: "."$distinctcounter\n";

$dbh->disconnect();
$dbh2->disconnect();
