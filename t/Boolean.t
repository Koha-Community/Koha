
use strict;
use warnings;

use Test::More tests => 13;

BEGIN { use_ok( 'C4::Boolean', qw( true_p ) ); }

is( true_p('0'),     '0', 'recognizes \'0\' as false' );
is( true_p('false'), '0', 'recognizes \'false\' as false' );
is( true_p('off'),   '0', 'recognizes \'off\' as false' );
is( true_p('no'),    '0', 'recognizes \'no\' as false' );

is( true_p('1'),    '1', 'recognizes \'1\' as true' );
is( true_p('true'), '1', 'recognizes \'true\' as true' );
is( true_p('on'),   '1', 'recognizes \'on\' as true' );
is( true_p('yes'),  '1', 'recognizes \'yes\' as true' );
is( true_p('YES'),  '1', 'verified case insensitivity' );

is( true_p(undef), undef, 'recognizes undefined as not boolean' );
is( true_p('foo'), undef, 'recognizes \'foo\' as not boolean' );
