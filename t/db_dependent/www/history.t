#!/usr/bin/perl

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

use utf8;
use XML::Simple;
use Encode;

use Test::More; #See plan tests => \d+ below
use Test::WWW::Mechanize;

my $koha_conf = $ENV{KOHA_CONF};
my $xml       = XMLin($koha_conf);

my $user     = $ENV{KOHA_USER} || $xml->{config}->{user};
my $password = $ENV{KOHA_PASS} || $xml->{config}->{pass};
my $intranet = $ENV{KOHA_INTRANET_URL};


eval{
    use C4::Context;
};
if ($@) {
    plan skip_all => "Tests skip. You must have a working Context\n";
}
elsif (not defined $intranet) {
    plan skip_all => "Tests skip. You must set env. variable KOHA_INTRANET_URL to do tests\n";
}
else {
    plan tests => 4;
}


$intranet =~ s#/$##;

my $agent = Test::WWW::Mechanize->new( autocheck => 1 );

# Login
$agent->get_ok( "$intranet/cgi-bin/koha/mainpage.pl", 'Load the intranet login page' );
$agent->form_name('loginform');
$agent->field( 'password', $password );
$agent->field( 'userid',   $user );
$agent->field( 'branch',   '' );
$agent->click( '', 'Login to the intranet' );
$agent->get_ok( "$intranet/cgi-bin/koha/about.pl", 'Load the about page' );

# Test about > timeline is correctly encoded
my $encoded_latin_name    = Encode::encode('UTF-8', 'Frédéric Demians');
my $encoded_cyrillic_name = Encode::encode('UTF-8', 'Сергій Дубик');
my $history_page          = Encode::encode('UTF-8', $agent->text());

like( $history_page, qr/$encoded_latin_name/, "Latin characters with umlauts show correctly on the history page." );
like( $history_page, qr/$encoded_cyrillic_name/, "Cyrillic characters with umlauts show correctly on the history page." );

