#!/usr/bin/perl

# some simple tests of the elements of C4::External::BakerTaylor that do not require a valid username and password

use strict;
use warnings;

use Test::More tests => 9;

BEGIN {
        use_ok('C4::External::BakerTaylor');
}

# for testing, to avoid using C4::Context
my $username="testing_username";
my $password="testing_password";

# taken from C4::External::BakerTaylor::initialize
my $image_url = "http://contentcafe2.btol.com/ContentCafe/Jacket.aspx?UserID=$username&Password=$password&Options=Y&Return=T&Type=S&Value=";

# test without initializing
is( C4::External::BakerTaylor::image_url(), undef, "testing image url pre initilization");
is( C4::External::BakerTaylor::link_url(), undef, "testing link url pre initilization");
is( C4::External::BakerTaylor::content_cafe_url(""), undef, "testing content cafe url pre initilization");
is( C4::External::BakerTaylor::http_jacket_link(""), undef, "testing http jacket link pre initilization");
is( C4::External::BakerTaylor::availability(""), undef, "testing availability pre initilization");

# intitialize
C4::External::BakerTaylor::initialize($username, $password, "link_url");

# testing basic results
is( C4::External::BakerTaylor::image_url("aa"), $image_url."aa", "testing image url construction");
is( C4::External::BakerTaylor::link_url("bb"), "link_urlbb", "testing link url construction");
is( C4::External::BakerTaylor::content_cafe_url("cc"), "http://contentcafe2.btol.com/ContentCafeClient/ContentCafe.aspx?UserID=$username&Password=$password&Options=Y&ItemKey=cc", "testing content cafe url  construction");
