#!/usr/bin/env perl

# This script can be used to run perlcritic on perl files in koha
# It calls its own custom perlcriticrc
# The script is purely optional requiring Test::Perl::Critic to be installed 
# and the environment variable TEST_QA to be set
# At present only the directories in @dirs will pass the tests in 'Gentle' mode

use Modern::Perl;
use File::Spec;
use Test::More;
use English qw(-no_match_vars);

my @dirs = qw(
    acqui
    admin
    authorities
    basket
    catalogue
    cataloguing
    circ
    debian
    errors
    labels
    members
    offline_circ
    reserve
    reviews
    rotating_collections
    serials
    sms
    virtualshelves
    Koha
    C4/SIP
);

if ( not $ENV{TEST_QA} ) {
    my $msg = 'Author test. Set $ENV{TEST_QA} to a true value to run';
    plan( skip_all => $msg );
}

eval { require Test::Perl::Critic; };

if ( $EVAL_ERROR ) {
    my $msg = 'Test::Perl::Critic required to criticise code,';
    plan( skip_all => $msg );
}

my $rcfile = File::Spec->catfile( 't', 'perlcriticrc' );
Test::Perl::Critic->import( -profile => $rcfile);
all_critic_ok(@dirs);

