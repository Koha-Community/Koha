# Copyright 2017 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;
use Scalar::Util qw(blessed);
use Try::Tiny;

use Test::More;

use Koha::FloatingMatrix;
use Koha::FloatingMatrix::BranchRule;



subtest "Feature: Conditional float statement", \&_CheckConditionalFloat;
sub _CheckConditionalFloat {
  my ($item, $branchRule);
  $branchRule = {
      fromBranch => 'CPL',
      toBranch => 'FFL',
      floating => 'CONDITIONAL',
  };

  eval {

    ok($branchRule->{conditionRules} =
        "itype ne LEHTI and ccode ne PILA and location ne VIM and location ne MVIM and location ne NWN",
      "Given a basic BranchRule with lots of exclusion");
    ok($item = {
                itype => 'KOIRA',
                ccode => 'CODE',
                location => 'SHELF',
               },
      "And a simple Item");

    ok(Koha::FloatingMatrix::_CheckConditionalFloat(
           $item,
           Koha::FloatingMatrix::BranchRule->new($branchRule)),
      "Then the Item does float");



    ok($branchRule->{conditionRules} =
        "itype ne LEHTI xor itype ne KIRJA",
      "Given a basic BranchRule with xor");

    ok(! Koha::FloatingMatrix::_CheckConditionalFloat(
           $item,
           Koha::FloatingMatrix::BranchRule->new($branchRule)),
      "Then the Item doesn't float");



    ok($branchRule->{conditionRules} =
        'itype =~ LEHTI$ or itype =~ ^KOIRA',
      "Given a BranchRule using a regexp");

    ok(Koha::FloatingMatrix::_CheckConditionalFloat(
           $item,
           Koha::FloatingMatrix::BranchRule->new($branchRule)),
      "Then the Item does float");



    ok($branchRule->{conditionRules} =
        'itype =~ KOIRA$ or itype =~ ^KISSA',
      "Given a BranchRule using a regexp with a \$");

    ok(Koha::FloatingMatrix::_CheckConditionalFloat(
           $item,
           Koha::FloatingMatrix::BranchRule->new($branchRule)),
      "Then the Item does float");



    ok($branchRule->{conditionRules} =
        'itype =~ KOIRA or itype =~ ^KISSA and ccode eq CODE',
      "Given a BranchRule using a regexp and simple matching");

    ok(Koha::FloatingMatrix::_CheckConditionalFloat(
           $item,
           Koha::FloatingMatrix::BranchRule->new($branchRule)),
      "Then the Item does float");



    ok($branchRule->{conditionRules} =
        'itype =~ (KOIRA|KISSA|HAUVA) or location ne RAMPA',
      "Given a BranchRule using a regexp with round brackets");

    ok(Koha::FloatingMatrix::_CheckConditionalFloat(
           $item,
           Koha::FloatingMatrix::BranchRule->new($branchRule)),
      "Then the Item does float");



  };
  if ($@) { ok (0, $@); }
}


done_testing();
