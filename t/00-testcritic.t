#!/usr/bin/env perl

# This script can be used to run perlcritic on perl files in koha

use Modern::Perl;
use Test::NoWarnings qw( had_no_warnings );
use Test::More;
use English qw(-no_match_vars);

eval { require Test::Perl::Critic; };

if ($EVAL_ERROR) {
    my $msg = 'Test::Perl::Critic required to criticise code,';
    plan( skip_all => $msg );
}

Test::Perl::Critic->import( -profile => '.perlcriticrc' );
my @files = map { chomp; $_ } `git ls-tree -r HEAD --name-only`;    # only files part of git
all_critic_ok(@files);

had_no_warnings;
