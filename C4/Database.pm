package C4::Database; #asummes C4/Database

#requires DBI.pm to be installed


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
use vars qw($VERSION @ISA @EXPORT);
  
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(
	&C4Connect &requireDBI
);


sub C4Connect  {
  my $dbname="c4";
   my ($database,$hostname,$user,$pass,%configfile);
   open (KC, "/etc/koha.conf");
   while (<KC>) {
     chomp;
     (next) if (/^\s*#/);
     if (/(.*)\s*=\s*(.*)/) {
       my $variable=$1;
       my $value=$2;
       # Clean up white space at beginning and end
       $variable=~s/^\s*//g;
       $variable=~s/\s*$//g;
       $value=~s/^\s*//g;
       $value=~s/\s*$//g;
       $configfile{$variable}=$value;
     }
   }
   $database=$configfile{'database'};
   $hostname=$configfile{'hostname'};
   $user=$configfile{'user'};
   $pass=$configfile{'pass'};
    
   my $dbh=DBI->connect("DBI:mysql:$database:$hostname",$user,$pass);
  return $dbh;
} # sub C4Connect

#------------------
# Helper subroutine to make sure database handle was passed properly
sub requireDBI {
    my (
	$dbh,
	$subrname,	# name of calling subroutine
    )=@_;

    unless ( ref($dbh) =~ /DBI::db/ ) {
	print "<pre>\nERROR: Subroutine $subrname called without proper DBI handle.\n" .
		"Please contact system administrator.\n</pre>\n";
	die "ERROR: Subroutine $subrname called without proper DBI handle.\n";
    }
} # sub requireDBI


END { }
