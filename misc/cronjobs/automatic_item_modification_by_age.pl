#!/usr/bin/perl

use Modern::Perl;

use Getopt::Long;
use Pod::Usage;
use JSON;

use C4::Context;
use C4::Items;

# Getting options
my ( $verbose, $help, $confirm );
my $result = GetOptions(
    'h|help'    => \$help,
    'v|verbose' => \$verbose,
    'c|confirm' => \$confirm,
);

pod2usage(1) if $help;
$verbose = 1 unless $confirm;

# Load configuration from the syspref
my $syspref_content = C4::Context->preference('automatic_item_modification_by_age_configuration');
my $rules = eval { JSON::from_json( $syspref_content ) };
pod2usage({ -message => "Unable to load the configuration : $@", -exitval => 1 })
    if $@;

my $report = C4::Items::ToggleNewStatus( { rules => $rules, report_only => not $confirm } );

if ( $verbose ) {
    if ( $report ) {
        say "Item to modify:";
        while ( my ( $itemnumber, $substitutions ) = each %$report ) {
            for my $substitution ( @$substitutions ) {
                if ( defined $substitution->{value} and $substitution->{value} ne q|| ) {
                   say "\titemnumber $itemnumber: $substitution->{field}=$substitution->{value}";
                } else {
                   say "\titemnumber $itemnumber: field $substitution->{field} to delete";
                }
            }
        }
    } else {
        say "There is no item to modify";
    }
}

exit(0);

__END__

=head1 NAME

automatic_item_modification_by_age.pl

=head1 SYNOPSIS

./automatic_item_modification_by_age.pl -h

Toggle recent acquisitions status.
Use this script to delete "new" status for items.

=head1 OPTIONS

=over 8

=item B<-h|--help>

Prints this help message.

=item B<-v|--verbose>

Set the verbose flag.

=item B<-c|--confirm>

The script will modify the items.

=back

=head1 AUTHOR

Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT

Copyright 2013 BibLibre

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.

=cut
