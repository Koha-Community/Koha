# Copyright 2017 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;
use Test::More;
use Try::Tiny;
use Scalar::Util qw(blessed);

use C4::BatchOverlay::RuleManager;



subtest "_loadBatchOverlayRules exceptions", \&loadBatchOverlayRules_exceptions;
sub loadBatchOverlayRules_exceptions {
  my ($badBatchOverlayRule);
  eval {

  ok($badBatchOverlayRule = {
    xcludeExceptions => ["This is a typo in the config", "There is not such root directive!"],
  }, 'Given a malformed root element (Ruleset)');

  my $ruleManager = bless ({}, 'C4::BatchOverlay::RuleManager');
  try {
    $ruleManager->_loadBatchOverlayRules($badBatchOverlayRule);
  } catch {
    my $e = $_;
    is(ref($e), 'Koha::Exception::FeatureUnavailable', 'Got proper exception class');
    like($e->error, qr/given Ruleset name 'xcludeExceptions' is not a HASH reference./, 'Got correct exception message');
  };


  ok($badBatchOverlayRule = {
    default => {}, #Left concise for brevity.
  }, 'Given a malformed default rule');

  my $ruleManager = bless ({}, 'C4::BatchOverlay::RuleManager');
  try {
    $ruleManager->_loadBatchOverlayRules($badBatchOverlayRule);
  } catch {
    my $e = $_;
    is(ref($e), 'Koha::Exception::FeatureUnavailable', 'Got proper exception class');
    like($e->error, qr/ is missing directive /, 'Got correct exception message');
  };

  };
  ok(0, $@) if $@;
}



done_testing();
