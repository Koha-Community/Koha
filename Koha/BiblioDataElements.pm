package Koha::BiblioDataElements;

# Copyright Vaara-kirjastot 2015
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Carp;
use DateTime;
use DateTime::Format::HTTP;
use Try::Tiny;
use Scalar::Util qw(blessed);
use MARC::Record;
use MARC::File::XML;

use C4::Biblio::Chunker;
use Koha::Database;
use Koha::BiblioDataElement;

use Koha::Exception::FeatureUnavailable;

use base qw(Koha::Objects);

sub _type {
    return 'BiblioDataElement';
}

sub object_class {
    return 'Koha::BiblioDataElement';
}

=head UpdateBiblioDataElements

    Koha::BiblioDataElements::UpdateBiblioDataElements([$limit]);

Finds all biblioitems that have changed since the last time biblio_data_elements has been updated.
Extracts biblio_data_elements from those MARCXMLs'.
@PARAM1, Boolean, should we UPDATE all biblioitems BiblioDataElements or simply increment changes?
@PARAM2, Int, the SQL LIMIT-clause, or undef.
@PARAM3, Int, verbosity level. See update_biblio_data_elements.pl-cronjob
=cut

sub UpdateBiblioDataElements {
    my ($forceRebuild, $limit, $verbose, $oldDbi) = @_;

    $verbose = 0 unless $verbose; #Prevent undefined comparison errors

    if ($forceRebuild) {
        forceRebuild($limit, $verbose, $oldDbi);
    }
    else {
        try {
            my $biblioitems = _getBiblioitemsNeedingUpdate($limit, $verbose);

            if ($biblioitems && ref $biblioitems eq 'ARRAY') {
                print "Found '".scalar(@$biblioitems)."' biblioitems-records to update.\n" if $verbose > 0;
                foreach my $biblioitem (@$biblioitems) {
                    eval {
                        UpdateBiblioDataElement($biblioitem, $verbose, $oldDbi);
                    };
                    warn $@ if $@;
                }
            }
            elsif ($verbose > 0) {
                print "Nothing to UPDATE\n";
            }
        } catch {
            if (blessed($_) && $_->isa('Koha::Exception::FeatureUnavailable')) {
                forceRebuild($limit, $verbose, $oldDbi);
            }
            elsif (blessed($_)) {
                $_->rethrow();
            }
            else {
                die $_;
            }
        };
    }
}

sub forceRebuild {
    my ($limit, $verbose, $oldDbi) = @_;

    $verbose = 0 unless $verbose; #Prevent undefined comparison errors

    my $chunker = C4::Biblio::Chunker->new(undef, $limit, undef, $verbose);
    while (my $biblioitems = $chunker->getChunk(undef, $limit)) {
        foreach my $biblioitem (@$biblioitems) {
            eval {
                UpdateBiblioDataElement($biblioitem, $verbose, $oldDbi);
            };
            warn $@ if $@;
        }
    }
}
=head UpdateBiblioDataElement

    Koha::BiblioDataElements::UpdateBiblioDataElement($biblioitem, $verbose);

Takes biblioitems and MARCXML and picks the needed data_elements to the koha.biblio_data_elements -table.
@PARAM1, Koha::Biblioitem or a HASH of koha.biblioitems-row.
@PARAM2, Int, verbosity level. See update_biblio_data_elements.pl-cronjob

=cut

sub UpdateBiblioDataElement {
    my ($biblioitem, $verbose, $oldDbi) = @_;
    $verbose = 0 unless $verbose; #Prevent undef errors

    #Get the bibliodataelement from input which can be a Koha::Object or a HASH from DBI
    #or create a new one if the biblioitem is new.
    my $bde; #BiblioDataElement-object
    my $marcxml;
    my $deleted;
    my $itemtype;
    my $biblioitemnumber;
    if (blessed $biblioitem && $biblioitem->isa('Koha::Object')) {
        if ($oldDbi) {
            $bde = Koha::BiblioDataElement::DBI_getBiblioDataElement($biblioitem->biblioitemnumber());
        }
        else {
            my @bde = Koha::BiblioDataElements->search({biblioitemnumber => $biblioitem->biblioitemnumber()});
            $bde = $bde[0];
        }

        $marcxml = C4::Biblio::GetXmlBiblio( $biblioitem->biblioitemnumber );
        $deleted = $biblioitem->deleted();
        $itemtype = $biblioitem->itemtype();
        $biblioitemnumber = $biblioitem->biblioitemnumber();
    }
    else {
        if ($oldDbi) {
            $bde = Koha::BiblioDataElement::DBI_getBiblioDataElement($biblioitem->{biblioitemnumber});
        }
        else {
            my @bde = Koha::BiblioDataElements->search({biblioitemnumber => $biblioitem->{biblioitemnumber}});
            $bde = $bde[0];
        }

        $marcxml = C4::Biblio::GetXmlBiblio( $biblioitem->{biblioitemnumber} );
        $deleted = $biblioitem->{deleted};
        $itemtype = $biblioitem->{itemtype};
        $biblioitemnumber = $biblioitem->{biblioitemnumber};
    }
    $bde = Koha::BiblioDataElement->new({biblioitemnumber => $biblioitemnumber}) if (not($bde) && not($oldDbi));

    #Make a MARC::Record out of the XML.
    my $record = eval { MARC::Record::new_from_xml( $marcxml, "utf8", C4::Context->preference('marcflavour') ) };
    if ($@) {
        die $@;
    }

    #Start creating data_elements.
    $bde->isFiction($record);
    $bde->isMusicalRecording($record);
    $bde->setDeleted($deleted);
    $bde->setItemtype($itemtype);
    $bde->isSerial($itemtype);
    $bde->setLanguages($record);
    $bde->setEncodingLevel($record);
    if ($oldDbi) {
        Koha::BiblioDataElement::DBI_insertBiblioDataElement($bde, $biblioitemnumber) unless $bde->{biblioitemnumber};
        Koha::BiblioDataElement::DBI_updateBiblioDataElement($bde) if $bde->{biblioitemnumber};
    }
    else {
        $bde->store();
    }
}

=head GetLatestDataElementUpdateTime

    Koha::BiblioDataElements::GetLatestDataElementUpdateTime($forceRebuild, $verbose);

Finds the last time koha.biblio_data_elements has been UPDATED.
If the table is empty, returns undef
@PARAM1, Int, verbosity level. See update_biblio_data_elements.pl-cronjob
@RETURNS DateTime or undef
=cut
sub GetLatestDataElementUpdateTime {
    my ($verbose) = @_;
    my $dbh = C4::Context->dbh();
    my $sthLastModTime = $dbh->prepare("SELECT MAX(last_mod_time) as last_mod_time FROM biblio_data_elements;");
    $sthLastModTime->execute( );
    my $rv = $sthLastModTime->fetchrow_hashref();
    my $lastModTime = ($rv && $rv->{last_mod_time}) ? $rv->{last_mod_time} : undef;
    print "Latest koha.biblio_data_elements updating time '".($lastModTime || '')."'\n" if $verbose > 0;
    return undef if(not($lastModTime) || $lastModTime =~ /^0000-00-00/);
    my $dt = DateTime::Format::HTTP->parse_datetime($lastModTime);
    $dt->set_time_zone( C4::Context->tz() );
    return $dt;
}

=head _getBiblioitemsNeedingUpdate
Finds the biblioitems whose timestamp (time last modified) is bigger than the biggest last_mod_time in koha.biblio_data_elements
=cut

sub _getBiblioitemsNeedingUpdate {
    my ($limit, $verbose) = @_;
    my @cc = caller(0);

    if ($limit) {
        $limit = " LIMIT $limit ";
        $limit =~ s/;//g; #Evade SQL injection :)
    }
    else {
        $limit = '';
    }

    print '#'.DateTime->now(time_zone => C4::Context->tz())->iso8601().'# Fetching biblioitems  #'."\n" if $verbose > 0;

    my $lastModTime = GetLatestDataElementUpdateTime($verbose) || Koha::Exception::FeatureUnavailable->throw($cc[3]."():> You must do a complete rebuilding since none of the biblios have been indexed yet.");
    $lastModTime = $lastModTime->iso8601();

    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("
            (SELECT bi.biblioitemnumber, bi.itemtype, bmt.metadata, 0 AS deleted FROM biblioitems bi LEFT JOIN biblio_metadata bmt ON bi.biblionumber=bmt.biblionumber
             WHERE bi.timestamp >= ? $limit
            ) UNION (
             SELECT bi.biblioitemnumber, bi.itemtype, bmt.metadata, 1 AS deleted FROM biblioitems bi LEFT JOIN biblio_metadata bmt ON bi.biblionumber=bmt.biblionumber
             WHERE bi.timestamp >= ? $limit
            )
    ");
    $sth->execute( $lastModTime, $lastModTime );
    if ($sth->err) {
        Koha::Exception::DB->throw(error => $cc[3]."():> ".$sth->errstr);
    }
    my $biblioitems = $sth->fetchall_arrayref({});

    print '#'.DateTime->now(time_zone => C4::Context->tz())->iso8601().'# Biblioitems fetched #'."\n" if $verbose > 0;

    return $biblioitems;
}

=head verifyFeatureIsInUse

    my $ok = Koha::BiblioDataElements::verifyFeatureIsInUse($verbose);

@PARAM1 Integer, see --verbose in update_biblio_data_elements.pl
@RETURNS Flag, 1 if this feature is properly configured
@THROWS Koha::Exception::FeatureUnavailable if this feature is not in use.
=cut

sub verifyFeatureIsInUse {
    my ($verbose) = @_;
    $verbose = 0 unless $verbose;

    my $now = DateTime->now(time_zone => C4::Context->tz());
    my $lastUpdateTime = Koha::BiblioDataElements::GetLatestDataElementUpdateTime($verbose) || DateTime::Format::HTTP->parse_datetime('1900-01-01 01:01:01');
    my $difference = $now->subtract_datetime( $lastUpdateTime );
    if ($difference->in_units( 'days' ) > 2) {
        my @cc = caller(0);
        Koha::Exception::FeatureUnavailable->throw(error => $cc[3]."():> koha.biblio_data_elements-table is stale. You must configure cronjob 'update_biblio_data_elements.pl' to run daily.");
    }
    return 1;
}

=head markForReindex

    Koha::BiblioDataElements::markForReindex();

Marks all BiblioDataElements to be updated during the next indexing.

=cut

sub markForReindex {
    my $dbh = C4::Context->dbh();
    $dbh->do("UPDATE biblio_data_elements SET last_mod_time = '1900-01-01 01:01:01'");
}

1;
