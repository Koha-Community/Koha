#!/usr/bin/env perl

# This script can be used to run perlcritic on perl files in koha
# The script is purely optional requiring Test::Perl::Critic to be installed 
# and the environment variable TEST_QA to be set

use Modern::Perl;
use Test::More;
use English qw(-no_match_vars);

if ( not $ENV{TEST_QA} ) {
    my $msg = 'Author test. Set $ENV{TEST_QA} to a true value to run';
    plan( skip_all => $msg );
}

eval { require Test::Perl::Critic; };

if ( $EVAL_ERROR ) {
    my $msg = 'Test::Perl::Critic required to criticise code,';
    plan( skip_all => $msg );
}

Test::Perl::Critic->import( -profile => '.perlcriticrc');
all_critic_ok('.');
