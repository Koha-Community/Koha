package C4::Groups;

#package to deal with Returns
#written 3/11/99 by olwen@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Circulation::Circ2;
#use C4::Accounts;
#use C4::InterfaceCDK;
#use C4::Circulation::Main;
#use C4::Format;
#use C4::Circulation::Renewals;
#use C4::Scan;
use C4::Stats;
#use C4::Search;
#use C4::Print;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&getgroups &groupmembers);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
#use vars qw(@more $stuff);
	
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


sub getgroups {
    my ($env) = @_;
    my %groups;
    my $dbh=&C4Connect;  
    my $sth=$dbh->prepare("select distinct groupshortname,grouplongname from borrowergroups");
    $sth->execute;
    while (my ($short, $long)=$sth->fetchrow) {
	$groups{$short}=$long;
    }
    $dbh->disconnect;
    return (\%groups);
}

sub groupmembers {
    my ($env, $group) = @_;
    my @members;
    my $dbh=&C4Connect;
    my $q_group=$dbh->quote($group);
    my $sth=$dbh->prepare("select borrowernumber from borrowergroups where groupshortname=$q_group");
    $sth->execute;
    while (my ($borrowernumber) = $sth->fetchrow) {
	my ($patron, $flags) = getpatroninformation($env, $borrowernumber);
	my $currentissues=currentissues($env, $patron);
	$patron->{'currentissues'}=$currentissues;
	push (@members, $patron);
    }
    return (\@members);
}


END { }       # module clean-up code here (global destructor)
