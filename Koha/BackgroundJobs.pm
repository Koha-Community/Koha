package Koha::BackgroundJobs;

use Modern::Perl;
use base qw(Koha::Objects);
use Koha::BackgroundJob;

sub _type {
    return 'BackgroundJob';
}

sub object_class {
    return 'Koha::BackgroundJob';
}

1;
