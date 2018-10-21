#!/usr/bin/perl

# Copyright 2018 The National Library of Finland
#
# This file is part of Koha.
#

use C4::Context;

my $dbh = C4::Context->dbh();

#Upgrade the old value:
my $ssrules = C4::Context->preference('SSRules');
if ($ssrules) {
  print "Detected old 'SSRules' = '$ssrules'. Updating it.\n";
  my ($ageLimit, $allowedBorrowerCategories) = split(':', $ssrules);
  print "Detected age limit = '$ageLimit', allowed borrower categories '$allowedBorrowerCategories'.\n";

  my $new = <<YAML;
---
TaC: 1
Permission: 1
CardExpired: 1
CardLost: 1
Debarred: 1
MaxFines: 1
OpeningHours: 1
YAML
  $new .= "MinimumAge: $ageLimit\n" if $ageLimit;
  $new .= "BorrowerCategories: $allowedBorrowerCategories\n" if $allowedBorrowerCategories;

  print "New 'SSRules':\n$new\n";

  C4::Context->set_preference('SSRules', $new);

  print "Upgrade done (KD-1159-2: SSRules extension)\n";
}
else {
  print "Upgrade done (KD-1159-2: SSRules extension - Feature was not in use)\n";
}

