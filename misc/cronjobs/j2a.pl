#!/usr/bin/perl 

# 2011 Liz Rea - Northeast Kansas Library System <lrea@nekls.org>

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

use strict;
use warnings;

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}


use C4::Context;
use C4::Members;
use Getopt::Long;
use Pod::Usage;

=head1 NAME

juv2adult.pl - convert juvenile/child patrons from juvenile patron category and category code to corresponding adult patron category and category code when they reach the upper age limit defined in the Patron Categories.

=head1 SYNOPSIS

juv2adult.pl [ -b=<branchcode> -f=<categorycode> -t=<categorycode> ]

 Options:
   --help					brief help message
   --man					full documentation
   -v						verbose mode
   -n						take no action, display only
   -b	<branchname>	only deal with patrons from this library/branch
   -f	<categorycode>	change patron category from this category
   -t	<categorycode>	change patron category to this category
=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<-v>

Verbose. Without this flag set, only fatal errors are reported.

=item B<-n>

No Action. With this flag set, script will report changes but not actually execute them on the database.

=item B<-b>

changes patrons for one specific branch. Use the value in the
branches.branchcode table.

=item B<-f>

*required* defines the juvenile category to update. Expects the code from categories.categorycode.

=item B<-t>

*required* defines the category juvenile patrons will be converted to. Expects the code from categories.categorycode.

=back

=head1 DESCRIPTION

This script is designed to update patrons from juvenile to adult patron types, remove the guarantor, and update their category codes appropriately when they reach the upper age limit defined in the Patron Categories.

=head1 USAGE EXAMPLES

C<juv2adult.pl> - Suggests that you read this help. :)

C<juv2adult.pl> -b=<branchcode> -f=<categorycode> -t=<categorycode>  - Processes a single branch, and updates the patron categories from fromcat to tocat.

C<juv2adult.pl> -f=<categorycode> -t=<categorycode> -v -n - Processes all branches, shows all messages, and reports the patrons who would be affected. Takes no action on the database.
=cut

# These variables are set by command line options.
# They are initially set to default values.


my $help    = 0;
my $man     = 0;
my $verbose = 0;
my $noaction = 0;
my $mybranch;
my $fromcat;
my $tocat;

GetOptions(
    'help|?'         => \$help,
    'man'            => \$man,
    'v'              => \$verbose,
    'n'				 => \$noaction,
    'f=s'	     => \$fromcat,
    't=s'	     => \$tocat,
    'b=s'      => \$mybranch,
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

if(not $fromcat && $tocat) { #make sure we've specified the info we need.
	print "please specify -help for usage tips.\n";
		exit;
}

my $dbh=C4::Context->dbh;
my @branches = C4::Branch::GetBranches();
#get today's date, format it and subtract upperagelimit
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year +=1900;
$mon +=1; if ($mon < 10) {$mon = "0".$mon;}
if ($mday < 10) {$mday = "0".$mday;}
# get the upperagelimit from the category to be transitioned from
my $query=qq|SELECT upperagelimit from categories where categorycode =?|;
my $sth=$dbh->prepare( $query );
$sth->execute( $fromcat )
   or die "Couldn't execute statement: " . $sth->errstr;
my $agelimit = $sth->fetchrow_array();
if ( not $agelimit ) {

	die "No patron category $fromcat. Please try again. \n";
}
$query=qq|SELECT categorycode from categories where categorycode=?|;
$sth=$dbh->prepare( $query );
$sth->execute( $tocat )
	or die "Couldn't execute statement: " . $sth->errstr;
my $tocatage = $sth->fetchrow_array();
if ( not $tocatage ){
	die "No patron category $tocat. Please try again. \n";
}
$sth->finish(  );
$year -=$agelimit;

$verbose and print "The age limit for category $fromcat is $agelimit\n";

my $itsyourbirthday = "$year-$mon-$mday";


if ( not $noaction) {
	if ( $mybranch ) { #yep, we received a specific branch to work on.
		$verbose and print "Looking for patrons of $mybranch to update from $fromcat to $tocat that were born before $itsyourbirthday\n";
		my $query=qq|UPDATE borrowers
		   SET guarantorid ='0',
		    categorycode =?
		   WHERE dateofbirth<=?
		   AND dateofbirth!='0000-00-00'
		   AND branchcode=?
		   AND categorycode IN (select categorycode from categories where category_type='C' and categorycode=?)|;
		my $sth=$dbh->prepare($query);
		my $res = $sth->execute( $tocat, $itsyourbirthday, $mybranch, $fromcat ) or die "can't execute";
		if ($res eq '0E0') { print "No patrons updated\n";
		} else { print "Updated $res patrons\n"; }
	} else { # branch was not supplied, processing all branches
		$verbose and print "Looking in all branches for patrons to update from $fromcat to $tocat that were born before $itsyourbirthday\n";
		foreach my $branchcode (@branches) {
			my $query=qq|UPDATE borrowers
			   SET guarantorid ='0',
			    categorycode =?
			   WHERE dateofbirth<=?
			   AND dateofbirth!='0000-00-00'
			   AND categorycode IN (select categorycode from categories where category_type='C' and categorycode=?)|;
			my $sth=$dbh->prepare($query);
			my $res = $sth->execute( $tocat, $itsyourbirthday, $fromcat ) or die "can't execute";
			if ($res eq '0E0') { print "No patrons updated\n";
			} else { print "Updated $res patrons\n"; }
	}
	}
} else {
	my $birthday;
	if ( $mybranch ) {
		$verbose and print "Displaying patrons that would be updated from $fromcat to $tocat from $mybranch\n";
		my $query=qq|SELECT firstname,
		 surname,
		 cardnumber,
		 dateofbirth
		FROM borrowers
		WHERE dateofbirth<=?
		AND dateofbirth!='0000-00-00'
		AND branchcode=?
		AND categorycode IN (select categorycode from categories where category_type='C' and categorycode=?)|;
		my $sth=$dbh->prepare( $query );
		$sth->execute( $itsyourbirthday, $mybranch, $fromcat )
		   or die "Couldn't execute statement: " . $sth->errstr;
		while ( my @res = $sth->fetchrow_array()) {
	            my $firstname = $res[0];
	            my $surname = $res[1];
	            my $barcode = $res[2];
	            $birthday = $res[3];
	            print "$firstname $surname $barcode $birthday\n";
	          }
	} else {
		$verbose and print "Displaying patrons that would be updated from $fromcat to $tocat.\n";
		my $query=qq|SELECT firstname,
		 surname,
		 cardnumber,
		 dateofbirth
		FROM borrowers
		WHERE dateofbirth<=?
		AND dateofbirth!='0000-00-00'
		AND categorycode IN (select categorycode from categories where category_type='C' and categorycode=?)|;
		my $sth=$dbh->prepare( $query );
		$sth->execute( $itsyourbirthday, $fromcat )
		   or die "Couldn't execute statement: " . $sth->errstr;
		while ( my @res = $sth->fetchrow_array()) {
	            my $firstname = $res[0];
	            my $surname = $res[1];
	            my $barcode = $res[2];
	            $birthday = $res[3];
	            print "$firstname $surname $barcode $birthday\n";
	          }
	}
	$sth->finish(  );
}
