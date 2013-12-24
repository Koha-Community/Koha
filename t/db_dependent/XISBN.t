#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 5;
use MARC::Record;
use C4::Biblio;
use C4::XISBN;
use C4::Context;
use Test::MockModule;

BEGIN {
    use_ok('C4::XISBN');
}

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

my $context = C4::Context->new;

my ( $biblionumber_tag, $biblionumber_subfield ) =
  GetMarcFromKohaField( 'biblio.biblionumber', '' );
my ( $isbn_tag, $isbn_subfield ) =
  GetMarcFromKohaField( 'biblioitems.isbn', '' );

# Harry Potter and the Sorcerer's Stone, 1st American ed. 1997
my $isbn1 = '0590353403';
# ThingISBN match : Silent Wing, First Edition 1998
my $isbn2 = '0684843897';
# XISBN match : Harry Potter and the Philosopher's Stone, Magic ed. 2000
my $isbn3 = '1551923963';

my $biblionumber1 = _add_biblio_with_isbn($isbn1);
my $biblionumber2 = _add_biblio_with_isbn($isbn2);
my $biblionumber3 = _add_biblio_with_isbn($isbn3);

my $trial = C4::XISBN::get_biblionumber_from_isbn($isbn1);
is( $trial->[0]->{biblionumber},
    $biblionumber1,
    "It gets the correct biblionumber from the only isbn we have added." );

$trial = C4::XISBN::_get_biblio_from_xisbn($isbn1);
is( $trial->{biblionumber},
    $biblionumber1, "Gets biblionumber like the previous test." );

$context->set_preference( 'ThingISBN', 1 );
$context->set_preference( 'XISBN', 0 );
my $results_thingisbn = C4::XISBN::get_xisbns($isbn1);
is( $results_thingisbn->[0]->{biblionumber},
    $biblionumber3,
    "Gets correct biblionumber from a book with a similar isbn using ThingISBN." );

$context->set_preference( 'ThingISBN', 0 );
$context->set_preference( 'XISBN', 1 );
my $results_xisbn = C4::XISBN::get_xisbns($isbn1);
is( $results_xisbn->[0]->{biblionumber},
    $biblionumber3,
    "Gets correct biblionumber from a book with a similar isbn using XISBN." );

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

$dbh->rollback;
