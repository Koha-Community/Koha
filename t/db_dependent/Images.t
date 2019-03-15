use Modern::Perl;
use GD;
use Test::More tests => 4;

use C4::Images;
use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new;
my $biblio = $builder->build_sample_biblio;

my $path = 'koha-tmpl/intranet-tmpl/prog/img/koha-logo.png';
my $koha_logo = GD::Image->new($path);

{
    # True color == 0
    $koha_logo->trueColor(0);
    C4::Images::PutImage( $biblio->biblionumber, $koha_logo );

    my @imagenumbers = C4::Images::ListImagesForBiblio( $biblio->biblionumber );
    is( scalar(@imagenumbers), 1, "The image has been added to the biblio" );
    my $image = C4::Images::RetrieveImage($imagenumbers[0]);
    ok( length $image->{thumbnail} < length $image->{imagefile}, 'thumbnail should be shorter than the original image' );
}

{
    # True color == 1
    # Note that we are cheating here, the original file is not a true color image
    $koha_logo->trueColor(1);
    C4::Images::PutImage( $biblio->biblionumber, $koha_logo, 'replace' );

    my @imagenumbers = C4::Images::ListImagesForBiblio( $biblio->biblionumber );
    is( scalar(@imagenumbers), 1 , "The image replaced the previous image on the biblio" );
    my $image = C4::Images::RetrieveImage($imagenumbers[0]);
    ok( length $image->{thumbnail} > length $image->{imagefile}, 'thumbnail should be bigger than the original image.' );
    # Actually it should not be bigger, but we cheat with the trueColor flag
}
