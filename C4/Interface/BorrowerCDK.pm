package C4::Interface::BorrowerCDK; #asummes C4/Interface/BorrowerCDK

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

use C4::InterfaceCDK;
use strict;
use Cdk;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&BorrowerAddress);
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
# the functions below that use them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();
			    
# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;
sub BorrowerAddress {
  my ($env,$bornum,$borrower)=@_;
  my $titlepanel = titlepanel($env,$env{'sysarea'},"Update Borrower");
  $titlepanel->draw();
  my BorrAdd = BorrAddpame   

sub BorrAddpanel {
  my ($env,$bornum,$borrower)=@_;
  my $titlepanel = titlepanel($env,$env{'sysarea'},"Update Borrower");
  my @rowtitl = ("Card Number","Surname","First Name","Other Names","Initials",
     "Address","Area","Town","Telephone","Email","Fax Number","Alt Address",
     "Alt Area","Alt Town","Alt Phone","Contact Name");
  my @coltitles = ("");
  my @coltypes  = ("UMIXED");
  my @colwidths = (40);
  my $entrymatrix = new Cdk::Matrix (
    'ColTitles'=> \@coltitles,
    'RowTitles'=> \@rowtitles,
    'ColWidths'=> \@colwidths,
    'ColTypes'=>  \@coltypes,
    'Vrows'=>     16,
    'Vcols'=>     1,
    'RowSpace'=>  0);
  my @data;
  $data[0] = $borrower{'cardnumber'};
  $data[1] = $borrower{'surname'};
  $data[2] = $borrower{'firstname'};
  $data[3] = $borrower{'
  $entrymatrix->inject('Input'=>"KEY_DOWN");
  my $reason;
  my ($rows,$cols,$info) = $entrymatrix->activate();
  my @responses;
  if (!defined $rows) {
     $reason = "Circ";
  } else {
     my $i = 0;
     while ($i < $numflds) {
        $responses[$i] =$info->[$i][0];
	$i++;
     }     
  } 
  return($reason,@responses);
}

END { }       # module clean-up code here (global destructor)
