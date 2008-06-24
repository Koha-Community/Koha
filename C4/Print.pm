package C4::Print;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use C4::Context;
use C4::Circulation;
use C4::Members;
use C4::Dates qw(format_date);

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 3.01;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(&remoteprint &printreserve &printslip);
}

=head1 NAME

C4::Print - Koha module dealing with printing

=head1 SYNOPSIS

  use C4::Print;

=head1 DESCRIPTION

The functions in this module handle sending text to a printer.

=head1 FUNCTIONS

=over 2

=item remoteprint

  &remoteprint($items, $borrower);

Prints the list of items in C<$items> to a printer.

C<$borrower> is a reference-to-hash giving information about a patron.
This may be gotten from C<&GetMemberDetails>. The patron's name
will be printed in the output.

C<$items> is a reference-to-list, where each element is a
reference-to-hash describing a borrowed item. C<$items> may be gotten
from C<&GetBorrowerIssues>.

=cut

# FIXME - It'd be nifty if this could generate pretty PostScript.
sub remoteprint ($$) {
    my ($items, $borrower) = @_;

    (return)
      unless ( C4::Context->boolean_preference('printcirculationslips') );
    my $queue = '';

    # FIXME - If 'queue' is undefined or empty, then presumably it should
    # mean "use the default queue", whatever the default is. Presumably
    # the default depends on the physical location of the machine.
    # FIXME - Perhaps "print to file" should be a supported option. Just
    # set the queue to "file" (or " file", if real queues aren't allowed
    # to have spaces in them). Or perhaps if $queue eq "" and
    # $env->{file} ne "", then that should mean "print to $env->{file}".
    if ( $queue eq "" || $queue eq 'nulllp' ) {
        open( PRINTER, ">/tmp/kohaiss" );
    }
    else {

        # FIXME - This assumes that 'lpr' exists, and works as expected.
        # This is a reasonable assumption, but only because every other
        # printing package has a wrapper script called 'lpr'. It'd still
        # be better to be able to customize this.
        open( PRINTER, "| lpr -P $queue > /dev/null" )
          or die "Couldn't write to queue:$queue!\n";
    }

    #  print $queue;
    #open (FILE,">/tmp/$file");
    my $i      = 0;
    # FIXME - This is HLT-specific. Put this stuff in a customizable
    # site-specific file somewhere.
    print PRINTER "Horowhenua Library Trust\r\n";
    print PRINTER "Phone: 368-1953\r\n";
    print PRINTER "Fax:    367-9218\r\n";
    print PRINTER "Email:  renewals\@library.org.nz\r\n\r\n\r\n";
    print PRINTER "$borrower->{'cardnumber'}\r\n";
    print PRINTER
      "$borrower->{'title'} $borrower->{'initials'} $borrower->{'surname'}\r\n";

    # FIXME - Use   for ($i = 0; $items->[$i]; $i++)
    # Or better yet,   foreach $item (@{$items})
    while ( $items->[$i] ) {

        #    print $i;
        my $itemdata = $items->[$i];

        # FIXME - This is just begging for a Perl format.
        print PRINTER "$i $itemdata->{'title'}\r\n";
        print PRINTER "$itemdata->{'barcode'}";
        print PRINTER " " x 15;
        print PRINTER "$itemdata->{'date_due'}\r\n";
        $i++;
    }
    print PRINTER "\r\n" x 7 ;
    close PRINTER;

    #system("lpr /tmp/$file");
}

sub printreserve {
    my ( $branchname, $bordata, $itemdata ) = @_;
    my $printer = '';
    (return) unless ( C4::Context->boolean_preference('printreserveslips') );
    if ( $printer eq "" || $printer eq 'nulllp' ) {
        open( PRINTER, ">>/tmp/kohares" )
		  or die "Could not write to /tmp/kohares";
    }
    else {
        open( PRINTER, "| lpr -P $printer >/dev/null" )
          or die "Couldn't write to queue:$!\n";
    }
    my @da = localtime();
    my $todaysdate = "$da[2]:$da[1]  " . C4::Dates->today();
    my $slip = <<"EOF";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Date: $todaysdate;

ITEM RESERVED: 
$itemdata->{'title'} ($itemdata->{'author'})
barcode: $itemdata->{'barcode'}

COLLECT AT: $branchname

BORROWER:
$bordata->{'surname'}, $bordata->{'firstname'}
card number: $bordata->{'cardnumber'}
Phone: $bordata->{'phone'}
$bordata->{'streetaddress'}
$bordata->{'suburb'}
$bordata->{'town'}
$bordata->{'emailaddress'}


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EOF
    print PRINTER $slip;
    close PRINTER;
    return $slip;
}

=item printslip

  &printslip($borrowernumber)

  print a slip for the given $borrowernumber
  
=cut

#'
sub printslip ($) {
    my ( $borrowernumber ) = shift;
    my ( $borrower ) = GetMemberDetails( $borrowernumber);
	my ($countissues,$issueslist) = GetPendingIssues($borrowernumber); 
	foreach my $it (@$issueslist){
		$it->{'date_due'}=format_date($it->{'date_due'});
    }		
    my @issues = sort { $b->{'timestamp'} <=> $a->{'timestamp'} } @$issueslist;
    remoteprint(\@issues, $borrower );
}

END { }    # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut
