use Modern::Perl;
use Test::More;
use Scalar::Util qw(blessed);

use Try::Tiny;
use Koha::Exception::UnknownProgramState;

subtest "Throw and catch a Koha::Exception", \&tryCatch;
sub tryCatch {
  eval {

  try {
    Koha::Exception::UnknownProgramState->throw(error => 'Test this!');
    ok(0, 'Y U No error!');
  } catch {
    is(ref($_), 'Koha::Exception::UnknownProgramState', 'Is a proper Koha::Exception');
    ok($_->isa('Koha::Exception'), 'Is a Koha::Exception subclass');
    is($_->error, 'Test this!', 'Correct error message');
  };

  };
  ok(0, $@) if $@;
};

done_testing;
