#!/usr/bin/perl

use Getopt::Long;
use Pod::Usage;
use Term::ANSIColor;
use FindBin; # we need to enforce which C4::Installer is used in case more than one is installed

use lib $FindBin::Bin;

use C4::Installer::PerlModules;

use Modern::Perl;

my $help = 0;
my $missing = 0;
my $installed = 0;
my $upgrade = 0;
my $all = 0;
my $color = 0;
my $brief = 0;
my $req = 0;

GetOptions(
            'h|help|?'    => \$help,
            'm|missing'   => \$missing,
            'i|installed' => \$installed,
            'u|upgrade'   => \$upgrade,
            'a|all'       => \$all,
            'b|brief'     => \$brief,
            'r|required'  => \$req,
            'c|color'     => \$color,
          );

pod2usage(1) if $help || (!$missing && !$installed && !$upgrade && !$all);

my $koha_pm = C4::Installer::PerlModules->new;
$koha_pm->versions_info;

my @pm = ();

push @pm, 'missing_pm' if $missing || $all;
push @pm, 'upgrade_pm' if $upgrade || $all;
push @pm, 'current_pm' if $installed || $all;

if (!$brief) {
    print color 'bold blue' if $color;
    print"
                                              Installed         Required          Module is
Module Name                                   Version           Version            Required
--------------------------------------------------------------------------------------------
";
}

my $count = 0;
foreach my $type (@pm) {
    my $mod_type = $type;
    $mod_type =~ s/_pm$//;
    my $pm = $koha_pm->get_attr($type);
    foreach (@$pm) {
        foreach my $pm (keys(%$_)) {
            print color 'yellow' if $type eq 'upgrade_pm' && $color;
            print color 'red' if $type eq 'missing_pm' && $color;
            print color 'green' if $type eq 'current_pm' && $color;
            my $required = ($_->{$pm}->{'required'}?'Yes':'No');
            my $current_version = ($color ? $_->{$pm}->{'cur_ver'} :
                                   $type eq 'missing_pm' || $type eq 'upgrade_pm' ? $_->{$pm}->{'cur_ver'}." *" : $_->{$pm}->{'cur_ver'});
            if (!$brief) {
                if (($req && $required eq 'Yes') || !$req) {
format =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<       @<<<<<
$pm,                                          $current_version, $_->{$pm}->{'min_ver'},  $required
.
write;
                    $count++;
                }
            }
            else {
                if (($req && $required eq 'Yes') || !$req) {
                    print "$pm\n";
                    $count++;
                }
            }
        }
    }
}

if (!$brief) {
    print color 'bold blue' if $color;
    my $footer = "
--------------------------------------------------------------------------------------------
Total modules reported: $count                      ";

    if ($color) {
        $footer .= "\n\n";
    }
    else {
        $footer .= "* Module is missing or requires an upgrade.\n\n";
    }

    print $footer;
    print color 'reset' if $color;
}

1;

__END__

=head1 NAME

koha_perl_deps.pl

=head1 SYNOPSIS

 At least one of -a, -m, -i, or -u flags must specified to not trigger help.
 ./koha_perl_deps.pl -m [-b] [-r] [-c]
 ./koha_perl_deps.pl -u [-b] [-r] [-c]
 ./koha_perl_deps.pl -i [-b] [-r] [-c]
 ./koha_perl_deps.pl -a [-b] [-r] [-c]
 ./koha_perl_deps.pl [-[h?]]

=head1 OPTIONS

=over 8

=item B<-m|--missing>

lists all missing perl modules

=item B<-i|--installed>

lists all installed perl modules

=item B<-u|--upgrade>

lists all perl modules needing to be upgraded relative to Koha

=item B<-a|--all>

 lists all koha perl dependencies
 This is equivalent to '-m -i -u'.

=item B<-b|--brief>

lists only the perl dependency name.

=item B<-r|--required>

filters list to only required perl dependencies.

=item B<-c|--color>

formats the output in color; red = module is missing, yellow = module requires upgrading, green = module is installed and current

=item B<-h|--help|?>

prints this help text

=back

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2010 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along
with Koha; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut
