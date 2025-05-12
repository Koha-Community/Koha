#!/usr/bin/env perl

=head1 podcorrectness.t

This test file checks all perl modules in the C4 directory for POD
correctness. It typically finds things like pod tags without blank
lines immediately before or after them, unknown directives, or =over,
=item, and =back in the wrong order.

One good way to run this is with C<prove -v xt/author/podcorrectness.t>

=cut

use Modern::Perl;
use Test::More;
use Test::Pod;

use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new;
my @files     = $dev_files->ls_perl_files;

all_pod_files_ok(@files);
