package KohaTest::Scripts;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Search;
sub testing_class { return; };

# Since this is an abstract base class, this prevents these tests from
# being run directly unless we're testing a subclass. It just makes
# things faster.
__PACKAGE__->SKIP_CLASS( 1 );


1;
