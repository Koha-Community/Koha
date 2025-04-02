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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

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

=item B<-a|--amount>

Sets the minimum amount the patron owes before we debar them.
Defaults to 0, meaning anyone that owes anything will be debared.

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

use Modern::Perl;
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use Koha::Script -cron;
use Koha::Patrons;
use Koha::Patron::Debarments;

use C4::Log qw( cronlogaction );

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

my ( $amount, $help, $confirm, $message, $expiration, $file, $verbose );
GetOptions(
    'a|amount:i'     => \$amount,
    'h|help'         => \$help,
    'c|confirm'      => \$confirm,
    'm|message:s'    => \$message,
    'f|file:s'       => \$file,
    'e|expiration:s' => \$expiration,
    'v|verbose'      => \$verbose,
) || pod2usage(2);
pod2usage(1) if $help;
pod2usage(1) unless $message || $file;

my $patrons = Koha::Patrons->filter_by_amount_owed( { more_than => $amount // 0 } );
$message = getMessageContent();

my $count_patrons = 0;
my $errors        = 0;
while ( my $patron = $patrons->next ) {
    print "Found patron " . $patron->id . "\n" if $verbose;
    if ( !$confirm ) {
        $count_patrons++;
        next;
    }

    # Don't crash, but keep debarring as long as you can!
    eval {
        Koha::Patron::Debarments::AddUniqueDebarment(
            {
                borrowernumber => $patron->id,
                expiration     => $expiration,
                type           => 'SUSPENSION',
                comment        => $message,
            }
        );
    };
    if ( my $error = $@ ) {
        warn 'debarment failed for patron ' . $patron->id . ": $error";
        $errors++;
        next;
    }
    $count_patrons++;
}

# Print totals
my $verb = $confirm ? 'Debarred' : 'Found';
print "debar_patrons_with_fines: $verb $count_patrons patrons";
print( $errors ? ", had $errors failures\n" : "\n" );

cronlogaction( { action => 'End', info => "COMPLETED" } );

sub getMessageContent {
    return $message if ($message);
    open( my $FH, "<:encoding(UTF-8)", $file ) or die "Could not open $file: $!\n";
    my @msg = <$FH>;
    close $FH;
    return join( "", @msg );
}

1;

__END__
