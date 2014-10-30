use Modern::Perl;

use t::lib::Mocks;
use Test::More tests => 4;                      # last test to print

use_ok('Koha::Email');

my $from = 'chrisc@catalyst.net.nz';
t::lib::Mocks::mock_preference('ReplytoDefault', $from);
t::lib::Mocks::mock_preference('ReturnpathDefault', $from);



ok( my $email = Koha::Email->new(), 'Create a Koha::Email Object');
ok( my %mail = $email->create_message_headers({from => $from}),'Set headers');
is ($mail{'From'}, $from, 'Set correctly');
