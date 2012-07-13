#!/usr/bin/env perl
use strict;
use warnings;

# This script can be used to run perlcritic on perl files in koha
# It calls its own custom perlcriticrc
# The script is purely optional requiring Test::Perl::Critic to be installed 
# and the environment variable TEST_QA to be set
# At present only the directories in @dirs will pass the tests in 'Gentle' mode

use File::Spec;
use Test::More;
use English qw(-no_match_vars);

my @all_koha_dirs = qw( acqui admin authorities basket C4 catalogue cataloguing circ debian errors
labels members misc offline_circ opac patroncards reports reserve reviews rotating_collections
serials sms suggestion t tags test tools virtualshelves Koha);

my @dirs = qw( acqui admin authorities basket catalogue cataloguing circ debian errors labels
    offline_circ reserve reviews rotating_collections serials sms virtualshelves );

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

