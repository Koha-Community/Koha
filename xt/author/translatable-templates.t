#!/usr/bin/perl

use strict;
use warnings;

=head2 translate-templates.t

This test verifies that all staff and OPAC template
files can be processed by the string extractor
without error; such errors usually indicate a 
construct that the extractor cannot parse.

=cut

use Test::More tests => 2;
use File::Temp qw/tempdir/;
use IPC::Open3;
use File::Spec;
use Symbol qw(gensym);

my $po_dir = tempdir(CLEANUP => 1);

chdir "misc/translator"; # for now, tmpl_process3.pl works only if run from its directory
test_string_extraction("opac",     "../../koha-tmpl/opac-tmpl/prog/en",     $po_dir);
test_string_extraction("intranet", "../../koha-tmpl/intranet-tmpl/prog/en", $po_dir);

sub test_string_extraction {
    my $module       = shift;
    my $template_dir = shift;
    my $po_dir       = shift;

    my $command = "./tmpl_process3.pl create -i $template_dir -s $po_dir/$module.po -r --pedantic-warnings";
   
    open (NULL, ">", File::Spec->devnull);
    print NULL "foo"; # avoid warning;
    my $pid = open3(gensym, ">&NULL", \*PH, $command); 
    my @warnings;
    while (<PH>) {
        # ignore some noise on STDERR
        next if /^\.* done\.$/;
        next if /^Warning: Can't determine original templates' charset/;
        next if /^Warning: Charset Out defaulting to/;
        next if /^Removing empty file /;
        next if /^I UTF-8 O UTF-8 at /;
        push @warnings, $_;
    }
    waitpid($pid, 0);

    ok($#warnings == -1, "$module templates are translatable") or diag join("\n", @warnings, '');
}
