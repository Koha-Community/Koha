package C4::Interface::RenewalsCDK; #assumes C4/Interface/RenewalsCDK

#uses Newt

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

# FIXME - I'm pretty sure that this, along with the rest of the
# CDK-based stuff, is obsolete.

use strict;
use Cdk;
use C4::InterfaceCDK;
use Date::Manip;
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(renew_window);

sub renew_window {
  my ($env,$issueditems,$borrower,$amountowing,$odues)=@_;
  my $titlepanel = C4::InterfaceCDK::titlepanel($env,$env->{'sysarea'},"Renewals");
  my @sel = ("N ","Y ");
  my $issuelist = new Cdk::Selection ('Title'=>"Renew items",
    'List'=>\@$issueditems,'Choices'=>\@sel,
    'Height'=> 14,'Width'=>78,'Ypos'=>8);
  my $x = 0;
  my $borrbox = C4::InterfaceCDK::borrowerbox($env,$borrower,$amountowing);
  $borrbox->draw();
  my @renews = $issuelist->activate();
  $issuelist->erase();
  undef $titlepanel;
  undef $issuelist;
  undef $borrbox;
  return \@renews;
}
