# the next koha public release version number;
# the kohaversion is divided in 4 parts :
# - #1 : the major number. 3 atm
# - #2 : the functionnal release. 00 atm
# - #3 : the subnumber, moves only on a public release
# - #4 : the developer version. The 4th number is the database subversion. 
#        used by developers when the database changes. updatedatabase take care of the changes itself
#        and is automatically called by Auth.pm when needed.

use strict;

sub kohaversion {
    our $VERSION = '3.00.00.107';
    # version needs to be set this way
    # so that it can be picked up by Makefile.PL
    # during install
    return $VERSION;
}

1;
