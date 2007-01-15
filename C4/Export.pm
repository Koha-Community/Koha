#!/usr/bin/perl -w

package C4::Export;

use strict;
use C4::Context;
use HTML::Template;
require Exporter;
use C4::Database;
use C4::Interface::CGI::Output;
use CGI;
use Text::CSV_XS;
use XML::Simple;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
  &export_bibs_by_date_to_file
);

sub export_bibs_by_date_to_file {
    $DB::single = 1;

    my ( $start_date, $end_date, $format, $filename ) = @_;
    my $query = new CGI;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare(
        "select * from biblio, biblioitems, items, marc_biblio
        where (datecreated >= ? and datecreated <= ?)
        and (biblio.biblionumber = biblioitems.biblionumber)
        and (biblioitems.biblioitemnumber = items.biblioitemnumber)
        and (marc_biblio.biblionumber = biblio.biblionumber) limit 2"
    );
    $sth->execute( $start_date, $end_date );

    if ( $format eq 'csv' ) {
        print $query->header( -attachment => "$filename" );
        my $csv = Text::CSV_XS->new(
            {
                'quote_char'  => '"',
                'escape_char' => '"',
                'sep_char'    => ',',
                'binary'      => 1
            }
        );

        my $first;
        while ( my $rec = $sth->fetchrow_hashref ) {
            if ( !$first ) {
                my @cols = keys(%$rec);
                $csv->combine(@cols);
                my $string = $csv->string;
                print $string, "\n";
                $first = 1;
            }
            my @fields = values(%$rec);
            $csv->combine(@fields);
            my $string = $csv->string;
            print $string, "\n";
        }
    }
    elsif ( $format eq 'xml' ) {
        print $query->header(
            -attachment => "$filename",
            -type       => 'text/xml'
        );
        while ( my $rec = $sth->fetchrow_hashref ) {
            my $xml = XMLout( $rec, AttrIndent => 1, XMLDecl => 1 );
            print $xml, "\n";
        }
    }
}

1;
