#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 4;
use MARC::Record;
use C4::Biblio;
use C4::XISBN;
use C4::Context;
use C4::Search;
use t::lib::Mocks;
use Test::MockModule;

BEGIN {
    use_ok('C4::XISBN');
}

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

my $search_module = new Test::MockModule('C4::Search');

$search_module->mock('SimpleSearch', \&Mock_SimpleSearch );
my $errors;
my $context = C4::Context->new;

my ( $biblionumber_tag, $biblionumber_subfield ) =
  GetMarcFromKohaField( 'biblio.biblionumber', '' );
my ( $isbn_tag, $isbn_subfield ) =
  GetMarcFromKohaField( 'biblioitems.isbn', '' );

# Harry Potter and the Sorcerer's Stone, 1st American ed. 1997
my $isbn1 = '0590353403';
# ThingISBN match : Silent Wing, First Edition 1998
my $isbn2 = '0684843897';
# XISBN match : Harry Potter and the Sorcerer's Stone,
# 1. Scholastic mass market paperback printing1.
my $isbn3 = '043936213X';

my $biblionumber1 = _add_biblio_with_isbn($isbn1);
my $biblionumber2 = _add_biblio_with_isbn($isbn2);
my $biblionumber3 = _add_biblio_with_isbn($isbn3);

my $trial = C4::XISBN::_get_biblio_from_xisbn($isbn1);
is( $trial->{biblionumber},
    $biblionumber1, "Gets biblionumber like the previous test." );

## Test ThingISBN
t::lib::Mocks::mock_preference( 'ThingISBN', 1 );
t::lib::Mocks::mock_preference( 'XISBN', 0 );

my $results_thingisbn;
eval { $results_thingisbn = C4::XISBN::get_xisbns($isbn1); };
SKIP: {
    skip "Problem retrieving ThingISBN", 1
        unless $@ eq '';
    is( $results_thingisbn->[0]->{biblionumber},
        $biblionumber3,
        "Gets correct biblionumber from a book with a similar isbn using ThingISBN." );
}

## Test XISBN
t::lib::Mocks::mock_preference( 'ThingISBN', 0 );
t::lib::Mocks::mock_preference( 'XISBN', 1 );

my $results_xisbn;
eval { ($results_xisbn, $errors) = C4::XISBN::get_xisbns($isbn1); };
SKIP: {
    skip "Problem retrieving XISBN (" . $errors->{xisbn} . ")", 1
        if $errors->{xisbn};
    is( $results_xisbn->[0]->{biblionumber},
        $biblionumber3,
        "Gets correct biblionumber from a book with a similar isbn using XISBN." );
}

$dbh->rollback;

# Util subs

# Add new biblio with isbn and return biblionumber
sub _add_biblio_with_isbn {
    my $isbn = shift;

    my $marc_record = MARC::Record->new;
    my $field = MARC::Field->new( $isbn_tag, '', '', $isbn_subfield => $isbn );
    $marc_record->append_fields($field);
    my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $marc_record, '' );
    return $biblionumber;
}

# Mocked subs

# C4::Search::SimpleSearch
sub Mock_SimpleSearch {
    my $query = shift;
    my @results;

    $query =~ s/-//g;
    my $ret_biblionumber;
    if ( $query =~ /$isbn1/ ) {
        $ret_biblionumber = $biblionumber1;
    }
    elsif ( $query =~ /$isbn2/ ) {
        $ret_biblionumber = $biblionumber2;
    }
    elsif ( $query =~ /$isbn3/ ) {
        $ret_biblionumber = $biblionumber3;
    }

    my $record = MARC::Record->new;
    $record->leader('     ngm a22     7a 4500');
    my $biblionumber_field;
    if ( $biblionumber_tag < 10 ) {
        $biblionumber_field =
          MARC::Field->new( $biblionumber_tag, $ret_biblionumber );
    }
    else {
        $biblionumber_field = MARC::Field->new( $biblionumber_tag, '', '',
            $biblionumber_subfield => $ret_biblionumber );
    }
    $record->append_fields($biblionumber_field);

    my $indexing_mode = C4::Context->config('zebra_bib_index_mode') // 'dom';
    push @results, ( $indexing_mode eq 'dom' )
                    ? $record->as_xml()
                    : $record->as_usmarc() ;

    return ( undef, \@results, 1 );
}
