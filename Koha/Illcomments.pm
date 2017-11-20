package Koha::Illcomments;

# TODO Add POD

use Modern::Perl;
use Koha::Database;
use Koha::Illcomment;
use base qw(Koha::Objects);

sub _type {
    return 'Illcomments';
}

sub object_class {
    return 'Koha::Illcomment';
}

1;
