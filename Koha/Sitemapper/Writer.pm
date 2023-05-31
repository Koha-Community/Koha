package Koha::Sitemapper::Writer;

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


use Moo;
use Modern::Perl;
use XML::Writer;
use IO::File;
use Koha::DateUtils qw( dt_from_string );


our $MAX = 50000;


has sitemapper => (is => 'rw', );

has current => ( is => 'rw', default => sub { $MAX } );

has count => ( is => 'rw', default => sub { 0 } );

has writer => ( is => 'rw',  );



sub _writer_create {
    my ($self, $name) = @_;
    $name = $self->sitemapper->dir . "/$name";
    my $fh = IO::File->new(">$name");
    unless ($fh) {
        say "Impossible to create file: $name";
        exit;
    }
    my $writer = XML::Writer->new(
        OUTPUT => $fh,
        DATA_MODE => 1,
        DATA_INDENT => 2,
    );
    $writer->xmlDecl("UTF-8");
    return $writer;
}


sub _writer_end {
    my $self = shift;
    return unless $self->writer;
    $self->writer->endTag();
    $self->writer->end();
    $self->writer->getOutput()->close();
}


sub write {
    my ($self, $biblionumber, $timestamp) = @_;

    if ( $self->current == $MAX ) {
        $self->_writer_end();
        $self->count( $self->count + 1 );
        my $w = $self->_writer_create( sprintf("sitemap%04d.xml", $self->count) );
        $w->startTag(
            'urlset',
            'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
            'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
            'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd');
        $self->writer($w);
        $self->current(0);
    }

    $self->current( $self->current + 1 );
    my $writer = $self->writer;
    my $url = $self->sitemapper->url .
              ($self->sitemapper->short ? '/bib/' : '/cgi-bin/koha/opac-detail.pl?biblionumber=') .
              $biblionumber;
    $writer->startTag('url');
        $writer->startTag('loc');
            $writer->characters($url);
        $writer->endTag();
        $writer->startTag('lastmod');
            $timestamp = substr($timestamp, 0, 10);
            $writer->characters($timestamp);
        $writer->endTag();
    $writer->endTag();
}


sub end {
    my $self = shift;

    $self->_writer_end();

    my $w = $self->_writer_create("sitemapindex.xml");
    $w->startTag('sitemapindex', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9');
    my $now = dt_from_string()->ymd;
    for my $i ( 1..$self->count ) {
        $w->startTag('sitemap');
            $w->startTag('loc');
                my $name = sprintf("sitemap%04d.xml", $i);
                $w->characters($self->sitemapper->url . "/$name");
            $w->endTag();
            $w->startTag('lastmod');
                $w->characters($now);
            $w->endTag();
        $w->endTag();
    }
    $w->endTag();
}


1;
