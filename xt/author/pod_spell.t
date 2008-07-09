#!/usr/bin/env perl
use strict;
use warnings;

=head2 pod_spell.t

This test script attempts to spellcheck text in perl's POD
documentation.

You must have Test::Spelling installed.

One good way to run this is with C<prove -v
xt/author/pod_spell.t>

=cut

use Test::More;
eval "use Test::Spelling";
plan skip_all => "Test::Spelling required for testing POD spelling" if $@;

all_pod_files_spelling_ok();

