package C4::Circulation::Borrissues; #assumes C4/Circulation/Borrissues

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz


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
use DBI;
use C4::Database;
use C4::Print;
use C4::Format;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&printallissues);
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


sub printallissues {
  my ($env,$borrower)=@_;
  my @issues;
  my $dbh=C4Connect;
  my $query = "select * from issues,items,biblioitems,biblio
    where borrowernumber = '$borrower->{'borrowernumber'}' 
    and (returndate is null)
    and (issues.itemnumber = items.itemnumber)
    and (items.biblioitemnumber = biblioitems.biblioitemnumber)
    and (items.biblionumber = biblio.biblionumber) 
    order by date_due";
  my $sth = $dbh->prepare($query);
  $sth->execute();
  my $x;
  while (my $data = $sth->fetchrow_hashref) {
    @issues[$x] =$data;
    $x++;
  }
  $sth->finish();
  $dbh->disconnect();
  remoteprint ($env,\@issues,$borrower);
}
END { }       # module clean-up code here (global destructor)
