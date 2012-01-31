#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;
use C4::TmplTokenType;
use Test::More tests => 19;

BEGIN {
        use_ok('C4::TmplToken');
}

ok (my $token = C4::TmplToken->new('test',C4::TmplTokenType::TEXT,10,'/tmp/translate.txt'), "Create new");
ok ($token->string eq 'test', "String works");
ok ($token->type == C4::TmplTokenType::TEXT, "Token works");
ok ($token->line_number == 10, "Line number works");
ok ($token->pathname eq '/tmp/translate.txt', "Path works");


ok ($token->text_p, "text_p works");

is($token-> children(), undef, "testing children returns undef when given argument");

ok($token-> set_children(), "testing set_children with no arguments");

is($token-> parameters_and_fields(), "0", "testing Parameters and fields returns 0 when given argument");

is($token-> anchors(), "0", "testing anchors returns 0 when given argument");

is($token-> form(),undef, "testing form returns undef when given argument");

ok($token-> set_form(), "testing set_form with no arguments");

is($token-> js_data(),undef, "testing form returns undef when given argument");

ok($token-> set_js_data(), "testing set_js_data with no arguments");

is($token-> tag_p(),"", "testing tag_p returns '' when given argument");

is($token-> cdata_p(),"", "testing cdata_p returns '' when given argument");

is($token-> text_parametrized_p(),"", "testing text_parametrized returns '' when given argument");

is($token-> directive_p(),"", "testing directive_p returns '' when given argument");
