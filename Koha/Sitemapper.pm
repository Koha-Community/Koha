package Koha::Sitemapper;

#
# Copyright 2015 Tamil s.a.r.l.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Moo;

use Koha::Biblios;
use Koha::Sitemapper::Writer;


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
    my ( $self, $where ) = @_;
    my $filter = $where ? \$where : {};

    say "Creation of Sitemap files in '" . $self->dir . "' directory"
        if $self->verbose;

    $self->writer( Koha::Sitemapper::Writer->new( sitemapper => $self ) );
    my $rs = Koha::Biblios->search( $filter, { columns => [ qw/biblionumber timestamp/ ] });

    while ( $self->process($rs) ) {
        say "..... ", $self->count
            if $self->verbose && $self->count % 10000 == 0;
    }
}


sub process {
    my ( $self, $rs ) = @_;

    my $biblio = $rs->next;
    unless( $biblio ) {
        $self->writer->end();
        say "Number of biblio records processed: ", $self->count, "\n" .
            "Number of Sitemap files:            ", $self->writer->count
            if $self->verbose;
        return;
    }

    $self->writer->write( $biblio->biblionumber, $biblio->timestamp );
    $self->count( $self->count + 1 );
    return $self->count;
}


1;
