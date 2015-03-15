
use Modern::Perl;

use Test::More tests => 22;
use Test::Warn;

BEGIN { use_ok( 'C4::Boolean', qw( true_p ) ); }

is( true_p('0'),     '0', 'recognizes \'0\' as false' );
is( true_p('nil'),   '0', 'recognizes \'nil\' as false' );
is( true_p('false'), '0', 'recognizes \'false\' as false' );
is( true_p('off'),   '0', 'recognizes \'off\' as false' );
is( true_p('no'),    '0', 'recognizes \'no\' as false' );
is( true_p('n'),     '0', 'recognizes \'n\' as false' );
is( true_p('NO'),    '0', 'verified case insensitivity' );

is( true_p('1'),    '1', 'recognizes \'1\' as true' );
is( true_p('-1'),   '1', 'recognizes \'-1\' as true' );
is( true_p('t'),    '1', 'recognizes \'t\' as true' );
is( true_p('true'), '1', 'recognizes \'true\' as true' );
is( true_p('on'),   '1', 'recognizes \'on\' as true' );
is( true_p('yes'),  '1', 'recognizes \'yes\' as true' );
is( true_p('y'),    '1', 'recognizes \'y\' as true' );
is( true_p('YES'),  '1', 'verified case insensitivity' );

my $result;
warning_like { $result = true_p(undef) }
             qr/^The given value does not seem to be interpretable as a Boolean value/,
             'Invalid boolean (undef) raises warning';
is( $result, undef, 'recognizes undefined as not boolean' );
warning_like { $result = true_p('foo') }
             qr/^The given value does not seem to be interpretable as a Boolean value/,
             'Invalid boolean (\'foo\') raises warning';
is( $result, undef, 'recognizes \'foo\' as not boolean' );
warning_like { $result = true_p([]) }
             qr/^The given value does not seem to be interpretable as a Boolean value/,
             'Invalid boolean (reference) raises warning';
is( $result, undef, 'recognizes a reference as not a boolean' );

1;
