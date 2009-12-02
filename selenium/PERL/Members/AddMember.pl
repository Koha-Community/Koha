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

$sel->open_ok("/cgi-bin/koha/members/memberentry.pl?op=add&amp;categorycode=PERS");
$sel->type_ok("surname", "Cocteau");
$sel->type_ok("firstname", "Jean");
$sel->type_ok("dateofbirth", "12/02/1967");
$sel->click_ok("sex-male");
$sel->select_ok("btitle", "label=Mr");
$sel->type_ok("address", "123, rue de la gaieté");
$sel->type_ok("city", "Marseille");
$sel->type_ok("cardnumber", "123141");
$sel->click_ok("save");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("Mr Jean Cocteau (123141)");
