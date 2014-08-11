use Modern::Perl;

use Test::More tests => 4;                      # last test to print

use_ok('Koha::Email');

my $from = 'chrisc@catalyst.net.nz';

ok( my $email = Koha::Email->new(), 'Create a Koha::Email Object');
ok( my %mail = $email->create_message_headers({from => $from}),'Set headers');
is ($mail{'From'}, $from, 'Set correctly');
