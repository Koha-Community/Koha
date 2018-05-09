#!/usr/bin/perl

# some simple tests of the elements of C4::External::BakerTaylor that do not require a valid username and password

use Modern::Perl;

use Test::More tests => 9;
use t::lib::Mocks;

BEGIN {
        use_ok('C4::External::BakerTaylor');
}

# test with mocked prefs
my $username= "testing_username";
my $password= "testing_password";
my $link_url = "http://wrongexample.com?ContentCafe.aspx?UserID=$username";

t::lib::Mocks::mock_preference( 'BakerTaylorUsername', $username );
t::lib::Mocks::mock_preference( 'BakerTaylorPassword', $password );
t::lib::Mocks::mock_preference( 'BakerTaylorBookstoreURL', $link_url );

my $image_url = "https://contentcafe2.btol.com/ContentCafe/Jacket.aspx?UserID=$username&Password=$password&Options=Y&Return=T&Type=S&Value=";
my $content_cafe = "https://contentcafe2.btol.com/ContentCafeClient/ContentCafe.aspx?UserID=$username&Password=$password&Options=Y&ItemKey=";

is( C4::External::BakerTaylor::image_url(), $image_url, "testing default image url");
is( C4::External::BakerTaylor::image_url("aa"), $image_url."aa", "testing image url construction");
is( C4::External::BakerTaylor::link_url(), $link_url, "testing default link url");
is( C4::External::BakerTaylor::link_url("bb"), "${link_url}bb", "testing link url construction");
is( C4::External::BakerTaylor::content_cafe_url(""), $content_cafe, "testing default content cafe url");
is( C4::External::BakerTaylor::content_cafe_url("cc"), "${content_cafe}cc", "testing content cafe url construction");
is( C4::External::BakerTaylor::http_jacket_link(""), undef, "testing empty http jacket link");
is( C4::External::BakerTaylor::availability(""), undef, "testing empty availability");
