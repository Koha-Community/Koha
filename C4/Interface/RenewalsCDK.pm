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

use strict;
use Cdk;
use C4::InterfaceCDK;
use Date::Manip;
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(renew_window);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);
# non-exported package globals go here
use vars qw(@more $stuff);
	
# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();
		    
# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();
	
# all file-scoped lexicals must be created before
# the functions below that se them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

#defining keystrokes used for screens

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;

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
			       
END { }       # module clean-up code here (global destructor)


