#!/usr/bin/perl -w
#
# Copyright 2000-2002 Katipo Communications
#
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
#-----------------------------------
# Script Name: zed-koha-server.pl
# Script Version: 1.4
# Date:  2004/06/02
# Author:  Joshua Ferraro [jmf at kados dot org]
# Description: A very basic Z3950 Server 
# Usage: zed-koha-server.pl
# Revision History:
#    0.00  2003/08/14: 	Original version; search works.
#    0.01  2003/10/02: 	First functional version; search and fetch working
#                      	 records returned in USMARC (ISO2709) format,     
#			 Bath compliant to Level 1 in Functional Areas A, B.
#    0.02  2004/04/14:  Cleaned up documentation, etc. No functional 
#    			 changes.
#    1.30  2004/04/22:	Changing version numbers to correspond with CVS;
#    			 Fixed the substitution bug (e.g., 4=100 before 4=1);
#    			 Added support for the truncation attribute (5=1 and
#    			 5=100; thanks to Tomasz M. Wolniewicz for pointing
#    			 out these improvements)
#    1.4.0 2004/06/02:  Changed sql queries to account for the difference 
#    			 between bibid and biblionumber.  Thanks again to 
#    			 Tomasz M. Wolniewicz for suggesting a great solution
#    			 to this problem.
#-----------------------------------
# Note: After installing SimpleServer (indexdata.dk/simpleserver) and 
# changing the leader information in Koha's MARCgetbiblio subroutine in
# Biblio.pm you can run this script as root:
# 
# ./zed-koha-server.pl
#
# and the server will start running on port 9999 and will allow searching
# and retrieval of records in MARC21 (USMARC; ISO2709) bibliographic format.
# ----------------------------------
use DBI;
use Net::Z3950::OID;
use Net::Z3950::SimpleServer;
use MARC::Record;
use C4::Context;
use C4::Biblio;
use strict;
# my $dbh = C4::Context->dbh;
my @bib_list;		## Stores the list of biblionumbers in a query 
			## I should eventually move this to different scope

my $handler = Net::Z3950::SimpleServer->new(INIT => \&init_handler,
					    SEARCH => \&search_handler,
					    FETCH => \&fetch_handler);

$handler->launch_server("zed-koha-server.pl", @ARGV);

sub init_handler {
        my $args = shift;
        my $session = {};
	
	# FIXME: I should force use of my database name 
        $args->{IMP_NAME} = "Zed-Koha";
        $args->{IMP_VER} = "1.40";
        $args->{ERR_CODE} = 0;
        $args->{HANDLE} = $session;
        if (defined($args->{PASS}) && defined($args->{USER})) {
            printf("Received USER/PASS=%s/%s\n", $args->{USER},$args->{PASS});
        }

}


sub run_query {		## Run the query and store the biblionumbers: 
	my ($sql_query, $query, $args) = @_;
		my $dbh = C4::Context->dbh;
       	my $sth_get = $dbh->prepare("$sql_query");

       	## Send the query to the database:
       	$sth_get->execute($query);
	my $count = 0;
	while(my ($data)=$sth_get->fetchrow_array) {
		
		## Store Biblioitem info for later
		$bib_list[$count] = "$data";
  
  		## Implement count:
       		$count ++;
       	}
       	$args->{HITS} = $count;
       	print "got search: ", $args->{RPN}->{query}->render(), "\n";
}

sub search_handler {		
    	my($args) = @_;
	## Place the user's query into a variable 
	my $query = $args->{QUERY};
	
	## The actual Term
	my $term = $args->{term};
	$term =~ s| |\%|g;
        $term .= "\%";         ## Add the wildcard to search term

	$_ = "$query";
             	   
                ## Strip out the junk and call the mysql query subroutine:
	if (/1=7/) {         	## isbn
		$query =~ s|\@attrset 1.2.840.10003.3.1 \@attr 1=7 ||g;
		$query  =~ s|"||g;
		$query =~ s| |%|g;
	
		## Bib-1 Structure Attributes:
		$query =~ s|\@attr||g;

		$query =~ s|4=100||g;   ## date (un-normalized)
		$query =~ s|4=101||g;   ## name (normalized)
		$query =~ s|4=102||g;   ## sme (un-normalized)
		$query =~ s|4=1||g;	## Phrase
                $query =~ s|4=2||g;	## Keyword
                $query =~ s|4=3||g;	## Key 
                $query =~ s|4=4||g;	## year 
		$query =~ s|4=5||g;	## Date (normalized)
		$query =~ s|4=6||g;	## word list
       		$query =~ s|5=100||g;	## truncation
		$query =~ s|5=1||g;	## truncation
	        $query =~ s|\@and ||g;
		$query =~ s|2=3||g;

		$query =~ s|,|%|g;	## replace commas with wildcard
		$query .= "\%";         ## Add the wildcard to search term
	 	$query .= "\%";         ## Add the wildcard to search term
		print "The term was:\n";
		print "$term\n";        
		print "The query was:\n";        
		print "$query\n";
		my $sql_query = "SELECT marc_biblio.bibid FROM marc_biblio RIGHT JOIN biblioitems ON marc_biblio.biblionumber = biblioitems.biblionumber WHERE biblioitems.isbn LIKE ?";
		&run_query($sql_query, $query, $args);

	} 
        elsif (/1=1003/) {	## author
        	$query =~ s|\@attrset||g;
		$query =~ s|1.2.840.10003.3.1||g;
		$query =~ s|1=1003||g;
 
               ## Bib-1 Structure Attributes:
                $query =~ s|\@attr ||g;

	        $query =~ s|4=100||g;  ## date (un-normalized)
		$query =~ s|4=101||g;  ## name (normalized)
		$query =~ s|4=102||g;  ## sme (un-normalized)
                $query =~ s|4=1||g;    ## Phrase
                $query =~ s|4=2||g;    ## Keyword
                $query =~ s|4=3||g;    ## Key
                $query =~ s|4=4||g;    ## year
                $query =~ s|4=5||g;    ## Date (normalized)
                $query =~ s|4=6||g;    ## word list
		$query =~ s|5=100||g;   ## truncation
                $query =~ s|5=1||g;     ## truncation
		
		$query =~ s|2=3||g;
		$query =~ s|"||g;
        	$query =~ s| |%|g;
		$query .= "\%";		## Add the wildcard to search term
		print "$query\n";
		my $sql_query = "SELECT marc_biblio.bibid FROM marc_biblio RIGHT JOIN biblio ON marc_biblio.biblionumber = biblio.biblionumber WHERE biblio.author LIKE ?";
                &run_query($sql_query, $query, $args);
## used for debugging--works!
##              print "@bib_list\n";
        } 
	elsif (/1=4/) {      	## title
        	$query =~ s|\@attrset||g;
		$query =~ s|1.2.840.10003.3.1||g;
		$query =~ s|1=4||g;
        	$query  =~ s|"||g;
 		$query  =~ s| |%|g;
		
		## Bib-1 Structure Attributes:
                $query =~ s|\@attr||g;

                $query =~ s|4=100||g;  ## date (un-normalized)
		$query =~ s|4=101||g;  ## name (normalized)
		$query =~ s|4=102||g;  ## sme (un-normalized)
		$query =~ s|4=1||g;    ## Phrase
                $query =~ s|4=2||g;    ## Keyword
                $query =~ s|4=3||g;    ## Key
                $query =~ s|4=4||g;    ## year
                $query =~ s|4=5||g;    ## Date (normalized)
                $query =~ s|4=6||g;    ## word list
		$query =~ s|5=100||g;   ## truncation
		$query =~ s|5=1||g;     ## truncation
		
		$query =~ s|2=3||g;
		#$query =~ s|\@and||g;
		$query .= "\%";         ## Add the wildcard to search term
		print "The term was:\n";
                print "$term\n";
                print "The query was:\n";
                print "$query\n";
		my $sql_query = "SELECT marc_biblio.bibid FROM marc_biblio RIGHT JOIN biblio ON marc_biblio.biblionumber = biblio.biblionumber WHERE biblio.title LIKE ?";
        	&run_query($sql_query, $query, $args);
	}
	elsif (/1=21/) {         ## subject 
                $query =~ s|\@attrset 1.2.840.10003.3.1 \@attr 1=21 ||g;
                $query  =~ s|"||g;
                $query  =~ s| |%|g;
              
		## Bib-1 Structure Attributes:
                $query =~ s|\@attr ||g;
                $query =~ s|4=100||g;  ## date (un-normalized)
		$query =~ s|4=101||g;  ## name (normalized)
		$query =~ s|4=102||g;  ## sme (un-normalized)
						
                $query =~ s|4=1||g;    ## Phrase
                $query =~ s|4=2||g;    ## Keyword
                $query =~ s|4=3||g;    ## Key
                $query =~ s|4=4||g;    ## year
                $query =~ s|4=5||g;    ## Date (normalized)
                $query =~ s|4=6||g;    ## word list
		$query =~ s|5=100||g;   ## truncation
		$query =~ s|5=1||g;     ## truncation
		
		$query .= "\%";         ## Add the wildcard to search term
                print "$query\n";
		my $sql_query = "SELECT marc_biblio.bibid FROM marc_biblio RIGHT JOIN biblio ON marc_biblio.biblionumber = biblio.biblionumber WHERE biblio.subject LIKE ?";
                &run_query($sql_query, $query, $args);
        }
	elsif (/1=1016/) {       ## any 
                $query =~ s|\@attrset 1.2.840.10003.3.1 \@attr 1=1016 ||g;
                $query  =~ s|"||g;
                $query  =~ s| |%|g;
                
		## Bib-1 Structure Attributes:
                $query =~ s|\@attr||g;

		$query =~ s|4=100||g;  ## date (un-normalized)
		$query =~ s|4=101||g;  ## name (normalized)
		$query =~ s|4=102||g;  ## sme (un-normalized)
						
                $query =~ s|4=1||g;    ## Phrase
                $query =~ s|4=2||g;    ## Keyword
                $query =~ s|4=3||g;    ## Key
                $query =~ s|4=4||g;    ## year
                $query =~ s|4=5||g;    ## Date (normalized)
                $query =~ s|4=6||g;    ## word list
                $query =~ s|5=100||g;   ## truncation
		$query =~ s|5=1||g;     ## truncation
		
		$query .= "\%";         ## Add the wildcard to search term
                print "$query\n";
		my $sql_query = "SELECT bibid FROM marc_word WHERE word LIKE?";
                &run_query($sql_query, $query, $args);
        }
}
sub fetch_handler {
        my ($args) = @_;
        # warn "in fetch_handler";      ## troubleshooting
        my $offset = $args->{OFFSET};
        $offset -= 1;                   ## because $args->{OFFSET} 1 = record #1
        chomp (my $bibid = $bib_list[$offset]); ## Not sure about this
				## print "the bibid is:$bibid\n";
				my $dbh = C4::Context->dbh;
				my $MARCRecord = &MARCgetbiblio($dbh,$bibid);
				$MARCRecord->leader('     nac  22     1u 4500');
		## Set the REP_FORM
		$args->{REP_FORM} = &Net::Z3950::OID::unimarc;
		
		## Return the record string to the client 
			$args->{RECORD} = $MARCRecord->as_usmarc();
# 	        $args->{RECORD} = $recordstringdone;

}


## This stuff doesn't work yet...I should include boolean searching someday
## though
package Net::Z3950::RPN::Term;
sub render {
    my $self = shift;
    return '"' . $self->{term} . '"';
}

package Net::Z3950::RPN::And;
sub render {
    my $self = shift;
    return '(' . $self->[0]->render() . ' AND ' .
                 $self->[1]->render() . ')';
}

package Net::Z3950::RPN::Or;
sub render {
    my $self = shift;
    return '(' . $self->[0]->render() . ' OR ' .
                 $self->[1]->render() . ')';
}

package Net::Z3950::RPN::AndNot;
sub render {
    my $self = shift;
    return '(' . $self->[0]->render() . ' ANDNOT ' .
                 $self->[1]->render() . ')';
}
