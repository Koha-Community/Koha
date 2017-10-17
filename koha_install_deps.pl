#!/usr/bin/perl

use Modern::Perl;
use C4::Installer::PerlModules;
use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );

use Getopt::Long;

my $help;

GetOptions(
    'h|help'             => \$help,
);

my $usage = << 'ENDUSAGE';

SYNOPSIS:

Finds missing perl deps and installs them. 
Use sudo to run this.

Lists problematic deps which have to install individually

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}

my $koha_pm = C4::Installer::PerlModules->new;
$koha_pm->versions_info;
my $pm = $koha_pm->get_attr("missing_pm");
foreach (@$pm) {
	foreach my $pm (keys(%$_)) {
		my $output = system('cpanm', $pm);
		print "$output\n";
		print "--------------------------------------------------------------------------------------------------------\n";
	}
}
print "\n\n";
print "--------------------------------------------------------------------------------------------------------\n";
print "INSTALL THESE INDIVIDUALLY\n";
print "--------------------------------------------------------------------------------------------------------\n";
my $missing = system("perl koha_perl_deps.pl -m -u");
print "$missing\n";
