package C4::Print; #assumes C4/Print.pm


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
require Exporter;
#use C4::InterfaceCDK;

use C4::Context;


use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Print - Koha module dealing with printing

=head1 SYNOPSIS

  use C4::Print;

=head1 DESCRIPTION

The functions in this module handle sending text to a printer.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&remoteprint &printreserve &printslip);

=item remoteprint

  &remoteprint($env, $items, $borrower);

Prints the list of items in C<$items> to a printer.

C<$env> is a reference-to-hash. C<$env-E<gt>{queue}> specifies the
queue to print to; if it is empty or has the special value C<nulllp>,
C<&remoteprint> will print to the file F</tmp/kohaiss>.

C<$borrower> is a reference-to-hash giving information about a patron.
This may be gotten from C<&getpatroninformation>. The patron's name
will be printed in the output.

C<$items> is a reference-to-list, where each element is a
reference-to-hash describing a borrowed item. C<$items> may be gotten
from C<&currentissues>.

=cut
#'
# FIXME - It'd be nifty if this could generate pretty PostScript.
sub remoteprint {
  my ($env,$items,$borrower)=@_;

  (return) unless (C4::Context->boolean_preference('printcirculationslips'));
  my $queue = $env->{'queue'};
  # FIXME - If 'queue' is undefined or empty, then presumably it should
  # mean "use the default queue", whatever the default is. Presumably
  # the default depends on the physical location of the machine.
  # FIXME - Perhaps "print to file" should be a supported option. Just
  # set the queue to "file" (or " file", if real queues aren't allowed
  # to have spaces in them). Or perhaps if $queue eq "" and
  # $env->{file} ne "", then that should mean "print to $env->{file}".
  if ($queue eq "" || $queue eq 'nulllp') {
    open (PRINTER,">/tmp/kohaiss");
  } else {
    # FIXME - This assumes that 'lpr' exists, and works as expected.
    # This is a reasonable assumption, but only because every other
    # printing package has a wrapper script called 'lpr'. It'd still
    # be better to be able to customize this.
    open(PRINTER, "| lpr -P $queue > /dev/null") or die "Couldn't write to queue:$queue!\n";
  }
#  print $queue;
  #open (FILE,">/tmp/$file");
  my $i=0;
  my $brdata = $env->{'brdata'};	# FIXME - Not used
  # FIXME - This is HLT-specific. Put this stuff in a customizable
  # site-specific file somewhere.
  print PRINTER "Horowhenua Library Trust\r\n";
#  print PRINTER "$brdata->{'branchname'}\r\n";
  print PRINTER "Phone: 368-1953\r\n";
  print PRINTER "Fax:    367-9218\r\n";
  print PRINTER "Email:  renewals\@library.org.nz\r\n\r\n\r\n";
  print PRINTER "$borrower->{'cardnumber'}\r\n";
  print PRINTER "$borrower->{'title'} $borrower->{'initials'} $borrower->{'surname'}\r\n";
  # FIXME - Use   for ($i = 0; $items->[$i]; $i++)
  # Or better yet,   foreach $item (@{$items})
  while ($items->[$i]){
#    print $i;
    my $itemdata = $items->[$i];
    # FIXME - This is just begging for a Perl format.
    print PRINTER "$i $itemdata->{'title'}\r\n";
    print PRINTER "$itemdata->{'barcode'}";
    print PRINTER " "x15;
    print PRINTER "$itemdata->{'date_due'}\r\n";
    $i++;
  }
  print PRINTER "\r\n\r\n\r\n\r\n\r\n\r\n\r\n";
  if ($env->{'printtype'} eq "docket"){
    #print chr(27).chr(105);
  }
  close PRINTER;
  #system("lpr /tmp/$file");
}

sub printreserve {
  my($env, $branchname, $bordata, $itemdata)=@_;
  my $file=time;
  my $printer = $env->{'printer'};
  (return) unless (C4::Context->boolean_preference('printreserveslips'));
  if ($printer eq "" || $printer eq 'nulllp') {
    open (PRINTER,">>/tmp/kohares");
  } else {
    open (PRINTER, "| lpr -P $printer >/dev/null") or die "Couldn't write to queue:$!\n";
  }
  my @da = localtime(time());
  my $todaysdate = "$da[2]:$da[1]  $da[3]/$da[4]/$da[5]";

#(1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", $datearr[3]);
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

  &printslip($env, $borrowernumber)

  print a slip for the given $borrowernumber
  
=cut
#'
sub printslip {
    my ($env,$borrowernumber)=@_;
    my ($borrower, $flags) = getpatroninformation($env,$borrowernumber,0);
    $env->{'todaysissues'}=1;
    my ($borrowerissues) = currentissues($env, $borrower);
    $env->{'nottodaysissues'}=1;
    $env->{'todaysissues'}=0;
    my ($borroweriss2)=currentissues($env, $borrower);
    $env->{'nottodaysissues'}=0;
    my $i=0;
    my @issues;
    foreach (sort {$a <=> $b} keys %$borrowerissues) {
	$issues[$i]=$borrowerissues->{$_};
	my $dd=$issues[$i]->{'date_due'};
	#convert to nz style dates
	#this should be set with some kinda config variable
	my @tempdate=split(/-/,$dd);
	$issues[$i]->{'date_due'}="$tempdate[2]/$tempdate[1]/$tempdate[0]";
	$i++;
    }
    foreach (sort {$a <=> $b} keys %$borroweriss2) {
	$issues[$i]=$borroweriss2->{$_};
	my $dd=$issues[$i]->{'date_due'};
	#convert to nz style dates
	#this should be set with some kinda config variable
	my @tempdate=split(/-/,$dd);
	$issues[$i]->{'date_due'}="$tempdate[2]/$tempdate[1]/$tempdate[0]";
	$i++;
    }
    remoteprint($env,\@issues,$borrower);
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut
