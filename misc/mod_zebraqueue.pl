#!/usr/bin/perl

# Copyright 2012 Kyle M Hall
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

# script to add records to the zebraqueue from the commandline.

use Modern::Perl;

use Getopt::Long;
use Pod::Usage;

use C4::Biblio;

my @biblios;
my @authorities;
my $help;
my $verbose;

GetOptions(
    "b|biblio|biblionumber=s"       => \@biblios,
    "a|authority|authoritynumber=s" => \@authorities,
    'h|?|help'                      => \$help,
    'v|verbose'                     => \$verbose,
);

pod2usage( -exitval => 0 ) if ( $help || !( @biblios || @authorities ) );

foreach my $biblionumber (@biblios) {
    print "Adding bibliographic record $biblionumber to Zebra queue\n" if ($verbose);
    ModZebra( $biblionumber, "specialUpdate", "biblioserver" );
}

foreach my $authority (@authorities) {
    print "Adding authority record $authority to Zebra queue\n" if ($verbose);
    ModZebra( $authority, 'specialUpdate', "authorityserver" );
}

__END__

=head1 NAME

mod_zebraqueue.pl - Mark bibliographic and/or authority records for updating via the zebraqueue.

=head1 SYNOPSIS

mod_zebraqueue.pl -v -b $bib1 -b $bib2 -a $authority1 -a $authority2

=head1 OPTIONS

=over 8

=item B<-b, --biblio, --biblionumber>

The biblionumber of a record to be updated, repeatable.

=item B<-a, --authority, --authoritynumber>

The authoritynumber of the record to be updated, repeatable.

=item B<-h, -?, --help>

Prints this help message and exits.

=item B<-v, --verbose>

Be verbose

=back

=cut
