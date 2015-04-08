package install_misc::UpgradeBackup;

# Copyright (C) 2008 LibLime
#
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

use strict;
#use warnings; FIXME - Bug 2505
use File::Compare qw(compare);
use Cwd qw(cwd);
use File::Copy;
use File::Find;
use File::Spec;
use Exporter;

use vars qw(@ISA @EXPORT $VERSION);

@ISA = ('Exporter');
@EXPORT = ('backup_changed_files');
$VERSION = '3.00';

=head1 NAME

install_misc::UpgradeBackup

=head1 DESCRIPTION

This is a helper module used during a 'make upgrade' that
creates backups of files updated during an upgrade.

=cut

sub backup_changed_files {
    my $from_to = shift;
    my $suffix = shift;
    my $verbose = shift;
    my $inc_uninstall = shift;

    my $cwd = cwd();
    foreach my $sourceroot (sort keys %$from_to) {
        my $targetroot = $from_to->{$sourceroot};
        my $currdir = File::Spec->catdir($cwd, $sourceroot);

        next unless -d $currdir;

        chdir $currdir or die "could not change to $currdir: $!";
       
        # expand path
        find(sub {
            return unless -f $_;
            my $filename = $_;

            my $targetdir  = File::Spec->catdir($targetroot, $File::Find::dir);
            my $targetfile = File::Spec->catfile($targetdir, $filename);
            my $sourcedir  = File::Spec->catdir($currdir, $File::Find::dir);
            my $sourcefile = File::Spec->catfile($sourcedir, $filename);

            if (-f $targetfile) {
                my ($size) = (stat $sourcefile)[7];
                my $backup = $targetfile . $suffix;
                unless (-s $targetfile == $size and not compare($sourcefile, $targetfile)) {
                    print "Backed up $targetfile to $backup\n";
                    File::Copy::copy($targetfile, $backup);        
                }
            }
        }, ".");
    }
}

=head1 AUTHOR

Code based on parts of ExtUtils::Install in order to
approximately track how it identifies files to
install.

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
