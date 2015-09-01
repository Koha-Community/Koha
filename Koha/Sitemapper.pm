package Koha::Sitemapper;

#
# Copyright 2015 Tamil s.a.r.l.
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

use Moo;
use Modern::Perl;
use Koha::Sitemapper::Writer;
use C4::Context;


has url => ( is => 'rw', );

has dir => (
    is => 'rw',
    default => sub { '.' },
    trigger => sub {
        my ($self, $dir) = @_;
        unless (-d $dir) {
            say "This is not a valid directory: $dir";
            exit;
        }
    }
);

has short => ( is => 'rw', default => sub { 1 } );

has verbose => ( is => 'rw', default => sub { 0 } );

has sth => ( is => 'rw' );

has writer => ( is => 'rw', );

has count => ( is => 'rw', default => sub { 0 } );


sub run {
    my $self = shift;

    say "Creation of Sitemap files in '" . $self->dir . "' directory"
        if $self->verbose;

    $self->writer( Koha::Sitemapper::Writer->new( sitemapper => $self ) );
    my $sth = C4::Context->dbh->prepare(
         "SELECT biblionumber, timestamp FROM biblio" );
    $sth->execute();
    $self->sth($sth);

    while ( $self->process() ) {
        say "..... ", $self->count
            if $self->verbose && $self->count % 10000 == 0;
    }
}


sub process {
    my $self = shift;

    my ($biblionumber, $timestamp) = $self->sth->fetchrow;
    unless ($biblionumber) {
        $self->writer->end();
        say "Number of biblio records processed: ", $self->count, "\n" .
            "Number of Sitemap files:            ", $self->writer->count
            if $self->verbose;
        return;
    }

    $self->writer->write($biblionumber, $timestamp);
    $self->count( $self->count + 1 );
    return $self->count;
}


1;
