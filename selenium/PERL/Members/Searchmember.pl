use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => "localhost", 
                                    port => 4444, 
                                    browser => "*chrome", 
                                    browser_url => "http://change-this-to-the-site-you-are-testing/" );

$sel->open_ok("/cgi-bin/koha/members/members-home.pl");
$sel->type_ok("searchmember", "Cocteau");
$sel->click_ok("//input[\@value='Search']");
$sel->wait_for_page_to_load_ok("30000");
$sel->text_is("searchheader", "Results 1 to 1 of 1 found for 'Cocteau'");
$sel->type_ok("searchmember", "123141");
$sel->select_ok("searchorderby", "label=Cardnumber");
$sel->click_ok("//input[\@value='Search']");
$sel->wait_for_page_to_load_ok("30000");
$sel->text_is("searchheader", "Results 1 to 1 of 1 found for '123141'");
$sel->click_ok("link=Cocteau, Jean");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("");
