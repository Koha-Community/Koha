use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::MockObject;

use t::lib::Mocks;
use Koha::Util::Navigation;

subtest 'Tests for local_referer' => sub {
    plan tests => 11;

    my ( $referer, $base );
    my $cgi = Test::MockObject->new;
    $cgi->mock( 'referer', sub { $referer } );
    $cgi->mock( 'url',     sub { $base } );      # base for [opac-]changelanguage

    # Start with filled OPACBaseIRL
    t::lib::Mocks::mock_preference( 'OPACBaseURL', 'https://koha.nl' );
    $referer = 'https://somewhere.com/myscript';
    is( Koha::Util::Navigation::local_referer($cgi), '/', 'External referer' );

    my $search = '/cgi-bin/koha/opac-search.pl?q=perl';
    $referer = "https://koha.nl$search";
    is( Koha::Util::Navigation::local_referer($cgi), $search, 'opac-search' );

    $referer = 'https://koha.nl/custom/stuff';
    is( Koha::Util::Navigation::local_referer($cgi), '/', 'custom url' );

    t::lib::Mocks::mock_preference( 'OPACBaseURL', 'http://kohadev.myDNSname.org:8080' );
    $referer = "http://kohadev.mydnsname.org:8080$search";
    is(
        Koha::Util::Navigation::local_referer($cgi), $search,
        'local_referer is comparing $OPACBaseURL case insensitive'
    );

    # trailing backslash
    t::lib::Mocks::mock_preference( 'OPACBaseURL', 'http://koha.nl/' );
    $referer = "http://koha.nl$search";
    is( Koha::Util::Navigation::local_referer($cgi), $search, 'opac-search, trailing backslash' );

    # no OPACBaseURL
    t::lib::Mocks::mock_preference( 'OPACBaseURL', '' );
    $referer = 'https://somewhere.com/myscript';
    $base    = 'http://koha.nl';
    is( Koha::Util::Navigation::local_referer($cgi), '/', 'no opacbaseurl, external' );

    $referer = "https://koha.nl$search";
    $base    = 'https://koha.nl';
    is( Koha::Util::Navigation::local_referer($cgi), $search, 'no opacbaseurl, opac-search' );
    $base = 'http://koha.nl';
    is( Koha::Util::Navigation::local_referer($cgi), $search, 'no opacbaseurl, opac-search, protocol diff' );

    # base contains https, referer http (this should be very unusual)
    # test parameters remove_language. staff
    t::lib::Mocks::mock_preference( 'staffClientBaseURL', '' );
    $search  = '/cgi-bin/koha/catalogue/search.pl?q=perl';            # staff
    $referer = "http://koha.nl:8080$search&language=zz-ZZ&debug=1";
    $base    = 'https://koha.nl:8080';
    is(
        Koha::Util::Navigation::local_referer( $cgi, { remove_language => 1, staff => 1 } ), $search . '&debug=1',
        'no baseurl, staff search, protocol diff (base https)'
    );

    # custom script, test fallback parameter
    $referer = 'https://koha.nl/custom/stuff';
    $base    = 'https://koha.nl';
    is(
        Koha::Util::Navigation::local_referer( $cgi, { fallback => 'ZZZ' } ), 'ZZZ',
        'no opacbaseurl, custom url, test fallback'
    );
    $base = 'http://koha.nl';
    is( Koha::Util::Navigation::local_referer($cgi), '/', 'no opacbaseurl, custom url, protocol diff' );
};
