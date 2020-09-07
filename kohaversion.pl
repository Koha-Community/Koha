# the next koha public release version number;

use Modern::Perl;
use Koha;

sub kohaversion {
    our $VERSION = $Koha::VERSION;
    # version needs to be set this way
    # so that it can be picked up by Makefile.PL
    # during install
    return $VERSION;
}

1;
