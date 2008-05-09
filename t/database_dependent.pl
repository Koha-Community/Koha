#!/usr/bin/perl

use warnings;
use strict;

=head2



=cut

use C4::Context;
use Data::Dumper;
use Test::More;

use Test::Class::Load qw ( . ); # run from the t directory

KohaTest::clear_test_database();
KohaTest::create_test_database();

KohaTest::start_zebrasrv();
KohaTest::start_zebraqueue_daemon();

if ($ENV{'TEST_CLASS'}) {
    # assume only one test class is specified;
    # should extend to allow multiples, but that will 
    # mean changing how test classes are loaded.
    eval "KohaTest::$ENV{'TEST_CLASS'}->runtests";
} else {
    Test::Class->runtests;
}

KohaTest::stop_zebraqueue_daemon();
KohaTest::stop_zebrasrv();

