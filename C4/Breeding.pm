package C4::Breeding;

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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use C4::Biblio;
use C4::Koha;
use C4::Charset;
use MARC::File::USMARC;
use C4::ImportBatch;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA = qw(Exporter);
    @EXPORT = qw(&ImportBreeding &BreedingSearch &Z3950Search);
}

=head1 NAME

C4::Breeding : module to add biblios to import_records via
               the breeding/reservoir API.

=head1 SYNOPSIS

    use C4::Scan;
    &ImportBreeding($marcrecords,$overwrite_biblio,$filename,$z3950random,$batch_type);

    C<$marcrecord> => the MARC::Record
    C<$overwrite_biblio> => if set to 1 a biblio with the same ISBN will be overwritted.
                                if set to 0 a biblio with the same isbn will be ignored (the previous will be kept)
                                if set to -1 the biblio will be added anyway (more than 1 biblio with the same ISBN 
                                possible in the breeding
    C<$encoding> => USMARC
                        or UNIMARC. used for char_decoding.
                        If not present, the parameter marcflavour is used instead
    C<$z3950random> => the random value created during a z3950 search result.

=head1 DESCRIPTION

    ImportBreeding import MARC records in the reservoir (import_records/import_batches tables).
    the records can be properly encoded or not, we try to reencode them in utf-8 if needed.
    works perfectly with BNF server, that sends UNIMARC latin1 records. Should work with other servers too.

=head2 ImportBreeding

	ImportBreeding($marcrecords,$overwrite_biblio,$filename,$encoding,$z3950random,$batch_type);

	TODO description

=cut

sub ImportBreeding {
    my ($marcrecords,$overwrite_biblio,$filename,$encoding,$z3950random,$batch_type) = @_;
    my @marcarray = split /\x1D/, $marcrecords;
    
    my $dbh = C4::Context->dbh;
    
    my $batch_id = GetZ3950BatchId($filename);
    my $searchisbn = $dbh->prepare("select biblioitemnumber from biblioitems where isbn=?");
    my $searchissn = $dbh->prepare("select biblioitemnumber from biblioitems where issn=?");
    # FIXME -- not sure that this kind of checking is actually needed
    my $searchbreeding = $dbh->prepare("select import_record_id from import_biblios where isbn=? and title=?");
    
#     $encoding = C4::Context->preference("marcflavour") unless $encoding;
    # fields used for import results
    my $imported=0;
    my $alreadyindb = 0;
    my $alreadyinfarm = 0;
    my $notmarcrecord = 0;
    my $breedingid;
    for (my $i=0;$i<=$#marcarray;$i++) {
        my ($marcrecord, $charset_result, $charset_errors);
        ($marcrecord, $charset_result, $charset_errors) = 
            MarcToUTF8Record($marcarray[$i]."\x1D", C4::Context->preference("marcflavour"), $encoding);
        
        # Normalize the record so it doesn't have separated diacritics
        SetUTF8Flag($marcrecord);

#         warn "$i : $marcarray[$i]";
        # FIXME - currently this does nothing 
        my @warnings = $marcrecord->warnings();
        
        if (scalar($marcrecord->fields()) == 0) {
            $notmarcrecord++;
        } else {
            my $oldbiblio = TransformMarcToKoha($dbh,$marcrecord,'');
            # if isbn found and biblio does not exist, add it. If isbn found and biblio exists, 
            # overwrite or ignore depending on user choice
            # drop every "special" char : spaces, - ...
            $oldbiblio->{isbn} = C4::Koha::_isbn_cleanup($oldbiblio->{isbn}); # FIXME C4::Koha::_isbn_cleanup should be public
            # search if biblio exists
            my $biblioitemnumber;
            if ($oldbiblio->{isbn}) {
                $searchisbn->execute($oldbiblio->{isbn});
                ($biblioitemnumber) = $searchisbn->fetchrow;
            } else {
                if ($oldbiblio->{issn}) {
                    $searchissn->execute($oldbiblio->{issn});
                	($biblioitemnumber) = $searchissn->fetchrow;
                }
            }
            if ($biblioitemnumber && $overwrite_biblio ne 2) {
                $alreadyindb++;
            } else {
                # FIXME - in context of batch load,
                # rejecting records because already present in the reservoir
                # not correct in every case.
                # search in breeding farm
                if ($oldbiblio->{isbn}) {
                    $searchbreeding->execute($oldbiblio->{isbn},$oldbiblio->{title});
                    ($breedingid) = $searchbreeding->fetchrow;
                } elsif ($oldbiblio->{issn}){
                    $searchbreeding->execute($oldbiblio->{issn},$oldbiblio->{title});
                    ($breedingid) = $searchbreeding->fetchrow;
                }
                if ($breedingid && $overwrite_biblio eq '0') {
                    $alreadyinfarm++;
                } else {
                    if ($breedingid && $overwrite_biblio eq '1') {
                        ModBiblioInBatch($breedingid, $marcrecord);
                    } else {
                        my $import_id = AddBiblioToBatch($batch_id, $imported, $marcrecord, $encoding, $z3950random);
                        $breedingid = $import_id;
                    }
                    $imported++;
                }
            }
        }
    }
    return ($notmarcrecord,$alreadyindb,$alreadyinfarm,$imported,$breedingid);
}


=head2 BreedingSearch

($count, @results) = &BreedingSearch($title,$isbn,$random);
C<$title> contains the title,
C<$isbn> contains isbn or issn,
C<$random> contains the random seed from a z3950 search.

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the C<import_records> and
C<import_biblios> tables of the Koha database.

=cut

sub BreedingSearch {
    my ($search,$isbn,$z3950random) = @_;
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my ($query,@bind);
    my $sth;
    my @results;

    $query = "SELECT import_record_id, file_name, isbn, title, author
              FROM  import_biblios 
              JOIN import_records USING (import_record_id)
              JOIN import_batches USING (import_batch_id)
              WHERE ";
    if ($z3950random) {
        $query .= "z3950random = ?";
        @bind=($z3950random);
    } else {
        @bind=();
        if (defined($search) && length($search)>0) {
            $search =~ s/(\s+)/\%/g;
            $query .= "title like ? OR author like ?";
            push(@bind,"%$search%", "%$search%");
        }
        if ($#bind!=-1 && defined($isbn) && length($isbn)>0) {
            $query .= " and ";
        }
        if (defined($isbn) && length($isbn)>0) {
            $query .= "isbn like ?";
            push(@bind,"$isbn%");
        }
    }
    $sth   = $dbh->prepare($query);
    $sth->execute(@bind);
    while (my $data = $sth->fetchrow_hashref) {
            $results[$count] = $data;
            # FIXME - hack to reflect difference in name 
            # of columns in old marc_breeding and import_records
            # There needs to be more separation between column names and 
            # field names used in the templates </soapbox>
            $data->{'file'} = $data->{'file_name'};
            $data->{'id'} = $data->{'import_record_id'};
            $count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub breedingsearch


=head2 Z3950Search

Z3950Search($pars, $template);

Parameters for Z3950 search are all passed via the $pars hash. It may contain isbn, title, author, dewey, subject, lccall, controlnumber, stdid, srchany.
Also it should contain an arrayref id that points to a list of id's of the z3950 targets to be queried (see z3950servers table).
This code is used in acqui/z3950_search and cataloging/z3950_search.
The second parameter $template is a Template object. The routine uses this parameter to store the found values into the template.

=cut

sub Z3950Search {
    my ($pars, $template)= @_;

    my $dbh   = C4::Context->dbh;
    my @id= @{$pars->{id}};
    my $random= $pars->{random};
    my $page= $pars->{page};
    my $biblionumber= $pars->{biblionumber};

    my $isbn= $pars->{isbn};
    my $issn= $pars->{issn};
    my $title= $pars->{title};
    my $author= $pars->{author};
    my $dewey= $pars->{dewey};
    my $subject= $pars->{subject};
    my $lccn= $pars->{lccn};
    my $lccall= $pars->{lccall};
    my $controlnumber= $pars->{controlnumber};


my $show_next       = 0;
my $total_pages     = 0;

my $noconnection;
my $attr = '';
my $term;
my $host;
my $server;
my $database;
my $port;
my $marcdata;
my @encoding;
my @results;
my $count;
my $toggle;
my $record;
my $oldbiblio;
my $errmsg;
my @serverhost;
my @servername;
my @breeding_loop = ();


    my @oConnection;
    my @oResult;
    my @errconn;
    my $s = 0;
    my $query;
    my $nterms=0;
    if ($isbn) {
        $term=$isbn;
        $query .= " \@attr 1=7 \@attr 5=1 \"$term\" ";
        $nterms++;
    }
    if ($issn) {
        $term=$issn;
        $query .= " \@attr 1=8 \@attr 5=1 \"$term\" ";
        $nterms++;
    }
    if ($title) {
        utf8::decode($title);
        $query .= " \@attr 1=4 \"$title\" ";
        $nterms++;
    }
    if ($author) {
        utf8::decode($author);
        $query .= " \@attr 1=1003 \"$author\" ";
        $nterms++;
    }
    if ($dewey) {
        $query .= " \@attr 1=16 \"$dewey\" ";
        $nterms++;
    }
    if ($subject) {
        utf8::decode($subject);
        $query .= " \@attr 1=21 \"$subject\" ";
        $nterms++;
    }
    if ($lccn) {
        $query .= " \@attr 1=9 $lccn ";
        $nterms++;
    }
    if ($lccall) {
        $query .= " \@attr 1=16 \@attr 2=3 \@attr 3=1 \@attr 4=1 \@attr 5=1 \@attr 6=1 \"$lccall\" ";
        $nterms++;
    }
    if ($controlnumber) {
        $query .= " \@attr 1=12 \"$controlnumber\" ";
        $nterms++;
    }
for my $i (1..$nterms-1) {
    $query = "\@and " . $query;
}
warn "query ".$query  if $DEBUG;

    foreach my $servid (@id) {
        my $sth = $dbh->prepare("select * from z3950servers where id=?");
        $sth->execute($servid);
        while ( $server = $sth->fetchrow_hashref ) {
            warn "serverinfo ".join(':',%$server) if $DEBUG;
            my $option1      = new ZOOM::Options();
            $option1->option( 'async' => 1 );
            $option1->option( 'elementSetName', 'F' );
            $option1->option( 'databaseName',   $server->{db} );
            $option1->option( 'user', $server->{userid} ) if $server->{userid};
            $option1->option( 'password', $server->{password} )
              if $server->{password};
            $option1->option( 'preferredRecordSyntax', $server->{syntax} );
            $oConnection[$s] = create ZOOM::Connection($option1)
              || $DEBUG
              && warn( "" . $oConnection[$s]->errmsg() );
            warn( "server data", $server->{name}, $server->{port} ) if $DEBUG;
            $oConnection[$s]->connect( $server->{host}, $server->{port} )
              || $DEBUG
              && warn( "" . $oConnection[$s]->errmsg() );
            $serverhost[$s] = $server->{host};
            $servername[$s] = $server->{name};
            $encoding[$s]   = ($server->{encoding}?$server->{encoding}:"iso-5426");
            $s++;
        }    ## while fetch
    }    # foreach
    my $nremaining  = $s;
    my $firstresult = 1;

    for ( my $z = 0 ; $z < $s ; $z++ ) {
        warn "doing the search" if $DEBUG;
        $oResult[$z] = $oConnection[$z]->search_pqf($query)
          || $DEBUG
          && warn( "somthing went wrong: " . $oConnection[$s]->errmsg() );

        # $oResult[$z] = $oConnection[$z]->search_pqf($query);
    }

  warn "# nremaining = $nremaining\n" if $DEBUG;

  while ( $nremaining-- ) {

    my $k;
    my $event;
    while ( ( $k = ZOOM::event( \@oConnection ) ) != 0 ) {
        $event = $oConnection[ $k - 1 ]->last_event();
        warn( "connection ", $k - 1, ": event $event (",
            ZOOM::event_str($event), ")\n" )
          if $DEBUG;
        last if $event == ZOOM::Event::ZEND;
    }

    if ( $k != 0 ) {
        $k--;
        warn "event from $k server = ",$serverhost[$k] if $DEBUG;
        my ( $error, $errmsg, $addinfo, $diagset ) =
          $oConnection[$k]->error_x();
        if ($error) {
            if ($error =~ m/^(10000|10007)$/ ) {
                push(@errconn, {'server' => $serverhost[$k]});
            }
            $DEBUG and warn "$k $serverhost[$k] error $query: $errmsg ($error) $addinfo\n";
        }
        else {
            my $numresults = $oResult[$k]->size();
            warn "numresults = $numresults" if $DEBUG;
            my $i;
            my $result = '';
            if ( $numresults > 0  and $numresults >= (($page-1)*20)) {
                $show_next = 1 if $numresults >= ($page*20);
                $total_pages = int($numresults/20)+1 if $total_pages < ($numresults/20);
                for ($i = ($page-1)*20; $i < (($numresults < ($page*20)) ? $numresults : ($page*20)); $i++) {
                    my $rec = $oResult[$k]->record($i);
                    if ($rec) {
                        my $marcrecord;
                        $marcdata   = $rec->raw();

                        my ($charset_result, $charset_errors);
                        ($marcrecord, $charset_result, $charset_errors) =
                          MarcToUTF8Record($marcdata, C4::Context->preference('marcflavour'), $encoding[$k]);
####WARNING records coming from Z3950 clients are in various character sets MARC8,UTF8,UNIMARC etc
## In HEAD i change everything to UTF-8
# In rel2_2 i am not sure what encoding is so no character conversion is done here
##Add necessary encoding changes to here -TG

                        # Normalize the record so it doesn't have separated diacritics
                        SetUTF8Flag($marcrecord);

                        my $oldbiblio = TransformMarcToKoha( $dbh, $marcrecord, "" );
                        $oldbiblio->{isbn}   =~ s/ |-|\.//g if $oldbiblio->{isbn};
                        # pad | and ( with spaces to allow line breaks in the HTML
                        $oldbiblio->{isbn} =~ s/\|/ \| /g if $oldbiblio->{isbn};
                        $oldbiblio->{isbn} =~ s/\(/ \(/g if $oldbiblio->{isbn};

                        $oldbiblio->{issn} =~ s/ |-|\.//g if $oldbiblio->{issn};
                        # pad | and ( with spaces to allow line breaks in the HTML
                        $oldbiblio->{issn} =~ s/\|/ \| /g if $oldbiblio->{issn};
                        $oldbiblio->{issn} =~ s/\(/ \(/g if $oldbiblio->{issn};
                          my (
                            $notmarcrecord, $alreadyindb, $alreadyinfarm,
                            $imported,      $breedingid
                          )
                          = ImportBreeding( $marcdata, 2, $serverhost[$k], $encoding[$k], $random, 'z3950' );
                        my %row_data;
                        $row_data{server}       = $servername[$k];
                        $row_data{isbn}         = $oldbiblio->{isbn};
                        $row_data{lccn}         = $oldbiblio->{lccn};
                        $row_data{title}        = $oldbiblio->{title};
                        $row_data{author}       = $oldbiblio->{author};
                        $row_data{breedingid}   = $breedingid;
                        $row_data{biblionumber} = $biblionumber;
                        push( @breeding_loop, \%row_data );

                    } else {
                        push(@breeding_loop,{'server'=>$servername[$k],'title'=>join(': ',$oConnection[$k]->error_x()),'breedingid'=>-1,'biblionumber'=>-1});
                    } # $rec
                }    # upto 5 results
            }    #$numresults
        }
    }    # if $k !=0
    my $numberpending = $nremaining - 1;

    my @servers = ();
    foreach my $id (@id) {
        push(@servers,{id => $id});
    }

    $template->param(
        breeding_loop => \@breeding_loop,
        server        => $servername[$k],
        numberpending => $numberpending,
        current_page => $page,
        servers => \@servers,
        total_pages => $total_pages,
    );
    $template->param(show_nextbutton=>1) if $show_next;
    $template->param(show_prevbutton=>1) if $page != 1;

    #  print  $template->output  if $firstresult !=1;
    $firstresult++;

  } # while nremaining

    $template->param(
        breeding_loop => \@breeding_loop,
        #server        => $servername[$k],
        numberpending => $nremaining > 0 ? $nremaining : 0,
        errconn       => \@errconn
    );

}

1;
__END__

