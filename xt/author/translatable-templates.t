#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
=head2 translate-templates.t

This test verifies that all staff and OPAC template
files can be processed by the string extractor
without error; such errors usually indicate a 
construct that the extractor cannot parse.

=cut

use Test::More;
use File::Temp qw/tempdir/;
use IPC::Open3;
use File::Spec;
use Symbol qw(gensym);
use utf8;

my $po_dir = tempdir(CLEANUP => 1);

# Find OPAC themes
my $opac_dir  = 'koha-tmpl/opac-tmpl';
opendir ( my $dh, $opac_dir ) or die "can't opendir $opac_dir: $!";
my @opac_themes = grep { not /^\.|lib|js|xslt/ } readdir($dh);
close $dh;

# Find STAFF themes
my $staff_dir = 'koha-tmpl/intranet-tmpl';
opendir ( $dh, $staff_dir ) or die "can't opendir $staff_dir: $!";
my @staff_themes = grep { not /^\.|lib|js/ } readdir($dh);
close $dh;

chdir "misc/translator"; # for now, tmpl_process3.pl works only if run from its directory

# Check translatable of OPAC themes
for my $theme ( @opac_themes ) {
    test_string_extraction("opac_$theme",     "../../koha-tmpl/opac-tmpl/$theme/en",     $po_dir);
}

# Check translatable of STAFF themes
for my $theme ( @staff_themes ) {
    test_string_extraction("staff_$theme",     "../../koha-tmpl/intranet-tmpl/$theme/en",     $po_dir);
}

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
        # the output of msmerge, that consist in .... followed by a "done" (localized), followed by a .
        # The "done" localized can include diacritics, so ignoring the whole word
        # FIXME PP: the flow is not correct UTF8, testing \p{IsLetter} does not work, but I think this regexp will do the job
        next if (/^\.+ .*\.$/);
        # other Koha-specific catses that should not worry us
        next if /^Warning: Can't determine original templates' charset/;
        next if /^Warning: Charset Out defaulting to/;
        next if /^Removing empty file /;
        next if /^I UTF-8 O UTF-8 at /;
        push @warnings, $_;
    }
    waitpid($pid, 0);

    ok($#warnings == -1, "$module templates are translatable") or diag join("\n", @warnings, '');
}

done_testing();
