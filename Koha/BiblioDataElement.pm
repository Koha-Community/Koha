package Koha::BiblioDataElement;

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

use Koha::Database;

use Koha::Exception::DB;

use base qw(Koha::Object);

sub type {
    return 'BiblioDataElement';
}

sub isFiction {
    my ($self, $record) = @_;
    my $col = 'fiction';
    my $val = 0;

    my $sf = $record->subfield('084','a');
    if ($sf && $sf =~/^8[1-5].*/) { #ykl numbers 81.* to 85.* are fiction.
        $val = 1;
    }
    ($self->{dbi}) ? $self->{$col} = $val : $self->set({$col => $val});
}

sub isMusicalRecording {
    my ($self, $record) = @_;
    my $col = 'musical';
    my $val = 0;

    my $sf = $record->subfield('084','a');
    if ($sf && $sf =~/^78.*/) { #ykl number 78 is a musical recording.
        $val = 1;
    }
    ($self->{dbi}) ? $self->{$col} = $val : $self->set({$col => $val});
}

sub isSerial {
    my ($self, $itemtype) = @_;
    my $col = 'serial';
    my $val = 0;

    my $serial = ($itemtype && ($itemtype eq 'AL' || $itemtype eq 'SL')) ? 1 : 0;
    if ($serial) {
        $val = 1;
    }
    ($self->{dbi}) ? $self->{$col} = $val : $self->set({$col => $val});
}

sub setItemtype {
    my ($self, $itemtype) = @_;
    my $col = 'itemtype';

    ($self->{dbi}) ? $self->{$col} = $itemtype : $self->set({$col => $itemtype});
}

=head setLanguages

    $bde->setLanguage($record);

Sets the languages- and primary_language-columns.
Primary language defaults to FIN if 041$a is not defined, or if there are multiple
041$a including one or more 'FIN'.
If no 'FIN' is found, we next default to 'SWE', if that is not present
we take the first instance of 041$a

@PARAM1, MARC::Record

=cut

sub setLanguages {
    my ($self, $record) = @_;

    my $primaryLanguage = 'FIN'; #Did we find the primary language?
    my $languages = '';
    my @sb; #StrinBuilder to efficiently collect language Strings and concatenate them
    my $f041 = $record->field('041');

    ##Starting looking for default languages and first instance of subfield 'a'
    my ($firstA, $finFound, $sweFound);
    if ($f041) {
        my @sfs = $f041->subfields();
        @sfs = sort {$a->[0] cmp $b->[0]} @sfs;

        foreach my $sf (@sfs) {
            unless (ref $sf eq 'ARRAY' && $sf->[0] && $sf->[1]) { #Code to fail :)
                next;
            }
            push @sb, $sf->[0].':'.$sf->[1];

            if ($sf->[0] eq 'a') { #We got the primary language subfield
                $primaryLanguage = $sf->[1];
                $firstA = $primaryLanguage unless $firstA;

                if ($primaryLanguage eq 'fin') {
                    $finFound = $primaryLanguage;
                }
                elsif ($primaryLanguage eq 'swe') {
                    $sweFound = $primaryLanguage;
                }
            }
        }
        $languages = join(',',@sb) if scalar(@sb);
    }
    $primaryLanguage = $finFound || $sweFound || $firstA || $primaryLanguage; #Keep the default if no others were found

    ($self->{dbi}) ? $self->{'languages'} = $languages : $self->set({'languages' => $languages});
    ($self->{dbi}) ? $self->{'primary_language'} = $primaryLanguage : $self->set({'primary_language' => $primaryLanguage});
}

sub setDeleted {
    my ($self, $deleted) = @_;
    my $col = 'deleted';

    ($self->{dbi}) ? $self->{$col} = $deleted : $self->set({$col => $deleted});
}

sub setEncodingLevel {
    my ($self, $record) = @_;
    my $col = 'encoding_level';
    my $val = '';

    my $l = $record->leader();
    $val = substr($l,17,1); #17 - Encoding level

    ($self->{dbi}) ? $self->{$col} = $val : $self->set({$col => $val});
}


=head PERFORMANCE IMPROVEMENT TESTS USING DBI

    THIS MODULE IS SUPER SLOW, LOOKING TO SPEED IT USING plain DBI

=cut

sub DBI_new {
    my ($class, $bdeHash, $biblioitemnumber) = @_;
    unless ($bdeHash && ref $bdeHash eq 'HASH') {
        $bdeHash = {};
    }
    bless($bdeHash, $class);
    $bdeHash->{dbi} = 1;
    return $bdeHash;
}

sub DBI_getBiblioDataElement {
    my ($biblioitemnumber) = @_;
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("
        SELECT * FROM biblio_data_elements
        WHERE biblioitemnumber = ?;
    ");
    $sth->execute( $biblioitemnumber );
    if ($sth->err) {
        my @cc = caller(0);
        Koha::Exception::DB->throw(error => $cc[3]."():> ".$sth->errstr);
    }
    my $bde = $sth->fetchrow_hashref();
    return Koha::BiblioDataElement->DBI_new($bde, $biblioitemnumber);
}

sub DBI_updateBiblioDataElement {
    my ($bde) = @_;
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("
        UPDATE biblio_data_elements
        SET deleted = ?,
            primary_language = ?,
            languages = ?,
            fiction = ?,
            musical = ?,
            itemtype = ?,
            serial = ?,
            encoding_level = ?
        WHERE biblioitemnumber = ?;
    ");
    $sth->execute( $bde->{deleted}, $bde->{primary_language}, $bde->{languages}, $bde->{fiction}, $bde->{musical}, $bde->{itemtype}, $bde->{serial}, $bde->{encoding_level}, $bde->{biblioitemnumber} );
    if ($sth->err) {
        my @cc = caller(0);
        Koha::Exception::DB->throw(error => $cc[3]."():> ".$sth->errstr);
    }
}

sub DBI_insertBiblioDataElement {
    my ($bde, $biblioitemnumber) = @_;
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("
        INSERT INTO biblio_data_elements
            (biblioitemnumber, deleted, primary_language, languages, fiction, musical, itemtype, serial, encoding_level)
            VALUES
            (?               , ?      , ?               , ?        , ?      , ?      , ?       , ?     , ?);
    ");
    $sth->execute( $biblioitemnumber, $bde->{deleted}, $bde->{primary_language}, $bde->{languages}, $bde->{fiction}, $bde->{musical}, $bde->{itemtype}, $bde->{serial}, $bde->{encoding_level} );
    if ($sth->err) {
        my @cc = caller(0);
        Koha::Exception::DB->throw(error => $cc[3]."():> ".$sth->errstr);
    }
}

1;
