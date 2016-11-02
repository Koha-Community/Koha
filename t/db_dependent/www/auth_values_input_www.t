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
use Test::More tests => 33;
use Test::WWW::Mechanize;
use XML::Simple;
use JSON;
use File::Basename;
use File::Spec;
use POSIX;
use URI::Escape;
use Encode;

my $testdir = File::Spec->rel2abs( dirname(__FILE__) );

my $koha_conf = $ENV{KOHA_CONF};
my $xml       = XMLin($koha_conf);

eval{
    use C4::Context;
};
if ($@) {
    plan skip_all => "Tests skip. You must have a working Context\n";
}

my $user     = $ENV{KOHA_USER} || $xml->{config}->{user};
my $password = $ENV{KOHA_PASS} || $xml->{config}->{pass};
my $intranet = $ENV{KOHA_INTRANET_URL};

if (not defined $intranet) {
    plan skip_all => "Tests skip. You must set env. variable KOHA_INTRANET_URL to do tests\n";
}

my $dbh = C4::Context->dbh;

$intranet =~ s#/$##;

my $agent = Test::WWW::Mechanize->new( autocheck => 1 );
my $jsonresponse;
my ($category, $expected_base, $add_form_link_exists, $delete_form_link_exists);

# -------------------------------------------------- LOGIN


$agent->get_ok( "$intranet/cgi-bin/koha/mainpage.pl", 'connect to intranet' );
$agent->form_name('loginform');
$agent->field( 'password', $password );
$agent->field( 'userid',   $user );
$agent->field( 'branch',   '' );
$agent->click_ok( '', 'login to staff client' );
$agent->get_ok( "$intranet/cgi-bin/koha/mainpage.pl", 'load main page' );

#--------------------------------------------------- Test with corean and greek chars

$category = '学協会μμ';
$dbh->do(q|DELETE FROM authorised_values WHERE category = ?|, undef, $category);
$dbh->do(q|DELETE FROM authorised_value_categories WHERE category_name = ?|, undef, $category);

$expected_base = q|authorised_values.pl|;
$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl", 'Connect to Authorized values page' );
$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl?op=add_form", 'Open to create a new category' );
$agent->form_name('Aform');
$agent->field('category', $category);
$agent->click_ok( '', "Create new AV category " );

$agent->base_like(qr|$expected_base|, "check base");
$add_form_link_exists = 0;
for my $link ( $agent->links() ) {
    if ( $link->url =~ m|authorised_values.pl\?op=add_form&category=$category| ) {
        $add_form_link_exists = 1;
    }
}
is( $add_form_link_exists, 1, 'Add a new category button should be displayed');
$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl?op=add_form&category=$category", 'Open to create a new AV for this category' );

$agent->form_name('Aform');
$agent->field('authorised_value', 'επιμεq');
$agent->field('lib_opac', 'autdesc2');
$agent->field('lib', 'desc1');
$agent->field('branches', '');
$agent->click_ok( '', "Create a new value for the category" );

$agent->base_like(qr|$expected_base|, "check base");
$add_form_link_exists = 0;
$delete_form_link_exists = 0;
for my $link ( $agent->links() ) {
    if ( $link->url =~ m|authorised_values.pl\?op=add_form&category=$category| ) {
        $add_form_link_exists = 1;
    }elsif( $link->url =~ m|authorised_values.pl\?op=delete&searchfield=$category| ) {
        $delete_form_link_exists = 1;
    }
}
is( $add_form_link_exists, 1, 'Add a new category button should be displayed');
is( $delete_form_link_exists, 1, '');

$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl", 'Return to Authorized values page' );
$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl?searchfield=学協会μμ&offset=0", 'Search the values inserted' );
my $text = $agent->text() ;
#Tests on UTF-8
ok ( ( length(Encode::encode('UTF-8', $text)) != length($text) ) , 'UTF-8 are multi-byte. Good') ;
ok ($text =~  m/学協会μμ/, 'UTF-8 (Asia) chars are correctly present. Good');
ok ($text =~  m/επιμεq/, 'UTF-8 (Greek) chars are correctly present. Good');
my @links = $agent->links;
my $id_to_del ='';
foreach my $dato (@links){
    my $link = $dato->url;
    if ($link =~  m/op=delete\&searchfield=学協会μμ\&id=(\d+)/){
        $id_to_del = $1;
        last;
    }
}
if ($id_to_del) {
    $agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl?op=delete&searchfield=学協会μμ&id=$id_to_del", 'UTF_8 auth. value deleted' );
}else{
    ok($id_to_del ne undef, "error, link to delete not working");
}

#---------------------------------------- Test with only latin utf-8 (could be taken as Latin-1/ISO 8859-1)

$category = 'tòmas';
$dbh->do(q|DELETE FROM authorised_values WHERE category = ?|, undef, $category);
$dbh->do(q|DELETE FROM authorised_value_categories WHERE category_name = ?|, undef, $category);

$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl", 'Connect to Authorized values page' );
$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl?op=add_form", 'Open to create a new category' );
$agent->form_name('Aform');
$agent->field('category', $category);
$agent->click_ok( '', "Create new AV category" );

$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl?op=add_form&category=$category", 'Open to create a new AV for this category' );
$agent->form_name('Aform');
$agent->field('authorised_value', 'ràmen');
$agent->field('lib_opac', 'autdesc2');
$agent->field('lib', 'desc1');
$agent->field('branches', '');
$agent->click_ok( '', "Create a new value for the category" );

$expected_base = q|authorised_values.pl|;
$agent->base_like(qr|$expected_base|, "check base");
$add_form_link_exists = 0;
$delete_form_link_exists = 0;
for my $link ( $agent->links() ) {
    if ( $link->url =~ m|authorised_values.pl\?op=add_form&category=$category| ) {
        $add_form_link_exists = 1;
    }elsif( $link->url =~ m|authorised_values.pl\?op=delete&searchfield=$category| ) {
        $delete_form_link_exists = 1;
    }
}
is( $add_form_link_exists, 1, );
is( $delete_form_link_exists, 1, );

$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl", 'Return to Authorized values page' );
$agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl?searchfield=tòmas&offset=0", 'Search the values inserted' );
my $text2 = $agent->text() ;
#Tests on UTF-8
ok ( ( length(Encode::encode('UTF-8', $text)) != length($text) ) , 'UTF-8 are multi-byte. Good') ;
ok ($text2 =~  m/tòmas/, 'UTF-8 not Latin-1 first test is OK. Good');
ok ($text2=~  m/ràmen/, 'UTF-8 not Latin-1 second test is OK. Good');
my @links2 = $agent->links;
my $id_to_del2 ='';
foreach my $dato (@links2){
    my $link = $dato->url;
    if ($link =~  m/op=delete\&searchfield=tòmas\&id=(\d+)/){
        $id_to_del2 = $1;
        last;
    }
}
if ($id_to_del2) {
    $agent->get_ok( "$intranet/cgi-bin/koha/admin/authorised_values.pl?op=delete&searchfield=tòmas&id=$id_to_del2", 'UTF_8 auth. value deleted' );
}else{
    ok($id_to_del2 ne undef, "error, link to delete not working");
}

1;
