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

$sel->open_ok("/cgi-bin/koha/mainpage.pl");
$sel->click_ok("//div[\@id='yui-main']/div/div/div[1]/h3[2]/a");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("link=C");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_element_present_ok("memberresultst");
$sel->select_ok("branchcode", "label=Bibliothèque de Luminy");
$sel->click_ok("//div[\@id='bd']/div[2]/form/input[3]");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_element_present_ok("memberresultst");
$sel->select_ok("categorycode", "label=Etudiant niveau M");
$sel->click_ok("//div[\@id='bd']/div[2]/form/input[3]");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_element_present_ok("memberresultst");
$sel->type_ok("//input[\@name='member' and \@value='']", "cas");
$sel->click_ok("//div[\@id='bd']/div[2]/form/input[3]");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_element_present_ok("memberresultst");
