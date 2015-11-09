#!/usr/bin/perl

# Copyright 2022 PTFS Europe
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

=head1 NAME

debar_patrons_with_fines.pl - Creates a debarment for all Patrons who have outstanding fines.

=head1 SYNOPSIS

    debar_patrons_with_fines.pl --help
    debar_patrons_with_fines.pl -m "Message for user"
    debar_patrons_with_fines.pl -f "/var/lib/koha/site/debar_message.txt"
    debar_patrons_with_fines.pl -m "Message for user" -e '2022-12-31'

=head1 DESCRIPTION

This script can be used to automatically debar patrons who have an outstanding
debt to the library.

=head1 OPTIONS

=over 8

=item B<-h|--help>

Display the help message and exit

=item B<-m|--message>

Add the passed message in the debarment comment

=item B<-f|--messagefile>

Add the content of the passed file in the debarment comment

=item B<-e|--expiration>

Expire the added debarment on the passed date

=item B<-c|--confirm>

Confirm that the script should actually undertake the debarments

=back

=cut

use strict;
use warnings;
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use Koha::Script -cron;
use Koha::Patrons;
use Koha::Patron::Debarments;

use C4::Log qw( cronlogaction );

my ( $help, $confirm, $message, $expiration, $file );
GetOptions(
    'h|help'         => \$help,
    'c|confirm:s'    => \$confirm,
    'm|message:s'    => \$message,
    'f|file:s'       => \$file,
    'e|expiration:s' => \$expiration,
) || pod2usage(2);
pod2usage(1) if $help;
pod2usage(1) unless ( $confirm && ( $message || $file ) );

cronlogaction();
my $badBorrowers = Koha::Patrons->filter_by_amount_owed( { more_than => 0 } );
$message = getMessageContent();

while ( my $bb = $badBorrowers->next ) {

    #Don't crash, but keep debarring as long as you can!
    eval {
        my $success = Koha::Patron::Debarments::AddDebarment(
            {
                borrowernumber => $bb->borrowernumber,
                expiration     => $expiration,
                type           => 'MANUAL',
                comment        => $message,
            }
        );
    };
    if ($@) {
        print $@. "\n";
    }
}

sub getMessageContent {
    return $message if ($message);
    open( my $FH, "<:encoding(UTF-8)", $file ) or die "$!\n";
    my @msg = <$FH>;
    close $FH;
    return join( "", @msg );
}

1;

__END__
