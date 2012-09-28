use Modern::Perl;
use Test::More tests => 4;
use MARC::Record;

use C4::Biblio qw( AddBiblio SetFieldMapping GetMarcFromKohaField );
use C4::Context;
use C4::Charset qw( SanitizeRecord );

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

my $frameworkcode = q||;

$dbh->do(q|
    DELETE FROM marc_subfield_structure WHERE kohafield='biblioitems.url'
|);
$dbh->do(qq|
    INSERT INTO marc_subfield_structure(frameworkcode,kohafield,tagfield,tagsubfield)
    VALUES ('$frameworkcode', 'biblioitems.url', '856', 'u')
|);
my ( $url_field, $url_subfield ) = C4::Biblio::GetMarcFromKohaField('biblioitems.url', $frameworkcode);

my $title = q|My title & a word & another word|;
my $url = q|http://www.example.org/index.pl?arg1=val1&amp;arg2=val2|;
my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'my author'),
    MARC::Field->new('245', ' ', ' ', a => $title),
    MARC::Field->new($url_field, ' ', ' ', $url_subfield => $url ),
);

my ($biblionumber, $biblioitemnumber) = AddBiblio($record, $frameworkcode);
my ( $sanitized_record, $has_been_modified ) = C4::Charset::SanitizeRecord( $record, $biblionumber );
is( $has_been_modified, 0, 'SanitizeRecord: the record has not been modified' );
is( $url, $sanitized_record->subfield($url_field, $url_subfield), 'SanitizeRecord: the url has not been modified');

$title = q|My title &amp;amp;amp; a word &amp;amp; another word|;
$record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'my author'),
    MARC::Field->new('245', ' ', ' ', a => $title),
    MARC::Field->new($url_field, ' ', ' ', $url_subfield => $url ),
);

($biblionumber, $biblioitemnumber) = AddBiblio($record, $frameworkcode);
( $sanitized_record, $has_been_modified ) = C4::Charset::SanitizeRecord( $record, $biblionumber );
is( $has_been_modified, 1, 'SanitizeRecord: the record has been modified' );
is( $url, $sanitized_record->subfield($url_field, $url_subfield), 'SanitizeRecord: the url has not been modified');

$dbh->rollback;
