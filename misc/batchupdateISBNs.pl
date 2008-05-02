#!/usr/bin/perl

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



=head1 batchupdateISBNs.pl 

    This script batch updates ISBN fields

=cut

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}
use C4::Context;
use MARC::File::XML;
use MARC::Record;
use Getopt::Long;

my ( $no_marcxml, $no_isbn, $help) = (0,0,0);

GetOptions(
    'noisbn'    => \$no_isbn,
    'noxml'     => \$no_marcxml,
    'h'         => \$help,
    'help'      => \$help,
);


$| = 1;
my $dbh   = C4::Context->dbh;

if($help){
    print qq(
        Option :
            \t-h        show this help
            \t-noisbn   don't remove '-' in biblioitems.isbn
            \t-noxml    don't remove '-' in biblioitems.marcxml in field 010a
            \n\n 
    );
    exit;
}

my $cpt_isbn = 0;
if(not $no_isbn){

    my $query_isbn = "
        SELECT biblioitemnumber,isbn FROM biblioitems WHERE isbn IS NOT NULL ORDER BY biblioitemnumber
    ";

    my $update_isbn = "
        UPDATE biblioitems SET isbn=? WHERE biblioitemnumber = ?
    ";

    my $sth = $dbh->prepare($query_isbn);
    $sth->execute;

    while (my $data = $sth->fetchrow_arrayref){
        my $biblioitemnumber = $data->[0];
        print "\rremoving '-' on isbn for biblioitemnumber $biblioitemnumber";
        
        # suppression des tirets de l'isbn
        my $isbn    = $data->[1];
        if($isbn){
            $isbn =~ s/-//g;
            
            #update 
            my $sth = $dbh->prepare($update_isbn);
            $sth->execute($isbn,$biblioitemnumber);
        }
        $cpt_isbn++;
    }
    print "$cpt_isbn updated";
}

if(not $no_marcxml){
    
    my $query_marcxml = "
        SELECT biblioitemnumber,marcxml FROM biblioitems WHERE isbn IS NOT NULL ORDER BY biblioitemnumber
    ";
    
    
    my $update_marcxml = "
        UPDATE biblioitems SET marcxml=? WHERE biblioitemnumber = ? 
    ";

    my $sth = $dbh->prepare($query_marcxml);
    $sth->execute;
    
    while (my $data = $sth->fetchrow_arrayref){
        
       my $biblioitemnumber = $data->[0];
       print "\rremoving '-' on marcxml for biblioitemnumber $biblioitemnumber";
        
        # suppression des tirets de l'isbn dans la notice
        my $marcxml = $data->[1];
        
        eval{
            my $record = MARC::Record->new_from_xml($marcxml,'UTF-8','UNIMARC');
            my @field = $record->field('010');
            my $flag = 0;
	    foreach my $field (@field){
                my $subfield = $field->subfield('a');
                if($subfield){
                    my $isbn = $subfield;
                    $isbn =~ s/-//g;
                    $field->update('a' => $isbn);
                    $flag = 1;
                }
	    }
            if($flag){
                $marcxml = $record->as_xml;
                # Update
                my $sth = $dbh->prepare($update_marcxml);
                $sth->execute($marcxml,$biblioitemnumber);
            }
        };
        if($@){
            print "\n /!\\ pb getting $biblioitemnumber : $@";
        }
    }
}
