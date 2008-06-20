#!/usr/bin/env perl
use strict;
use warnings;

=head2 podcorrectness.t

This test file checks all perl modules in the C4 directory for POD
correctness. It typically finds things like pod tags withouth blank
lines immediately before or after them, unknown directives, or =over,
=item, and =back in the wrong order.

You must have Test::Pod installed.

One good way to run this is with C<prove -v
xt/author/podcorrectness.t>

=cut

use Test::More;
eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
my @poddirs = qw( C4 );
all_pod_files_ok( all_pod_files( @poddirs ) );

