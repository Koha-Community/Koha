#!/usr/bin/perl -w

use Modern::Perl;
use Koha::Caches;

# Could take parameters to be less rude
Koha::Caches->get_instance()->flush_all;
Koha::Caches->get_instance('config')->flush_all;
Koha::Caches->get_instance('sysprefs')->flush_all;
