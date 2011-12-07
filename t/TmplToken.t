#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;
use C4::TmplTokenType;
use Test::More tests => 7;

BEGIN {
        use_ok('C4::TmplToken');
}

ok (my $token = C4::TmplToken->new('test',C4::TmplTokenType::TEXT,10,'/tmp/translate.txt'), "Create new");
ok ($token->string eq 'test', "String works");
ok ($token->type == C4::TmplTokenType::TEXT, "Token works");
ok ($token->line_number == 10, "Line number works");
ok ($token->pathname eq '/tmp/translate.txt', "Path works");


ok ($token->text_p, "text_p works");
