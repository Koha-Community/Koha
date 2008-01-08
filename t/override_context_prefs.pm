use strict;
use warnings;

# This stub module is used to override
# the C4::Context sub preference for the 
# purpose of the test suite.  This allows
# non-DB-dependent tests of most modules,
# particularly the ones that include C4::Dates.

use C4::Context;

package C4::Context;
no warnings;
sub preference {
    my $self = shift;
    my $pref = shift;
    return 'us'           if $pref eq 'dateformat';
    return 'MARC21'       if $pref eq 'marcflavour';
    return 'Test Library' if $pref eq 'LibraryName';
    return;
}

1;
