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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

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
	$VERSION = 0.02;
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw(&ImportBreeding &BreedingSearch);
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
    
    my $batch_id = 0;
    if ($batch_type eq 'z3950') {
        $batch_id = GetZ3950BatchId($filename);
    } else {
        # create a new one
        $batch_id = AddImportBatch('create_new', 'staging', 'batch', $filename, '');
    }
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
    my ($title,$isbn,$z3950random) = @_;
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
        if ($title) {
            $query .= "title like ?";
            push(@bind,"$title%");
        }
        if ($title && $isbn) {
            $query .= " and ";
        }
        if ($isbn) {
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

1;
__END__

