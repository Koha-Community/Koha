package C4::BookShelves; #asummes C4/BookShelves

#
# $Header$
#
#
# Change log is at the bottom of the file
#
#requires DBI.pm to be installed

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Circulation::Circ2;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&GetShelfList &GetShelfContents &AddToShelf &RemoveFromShelf &AddShelf &RemoveShelf);

sub AddShelf {
}

sub RemoveShelf {
}
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

my $dbh=C4Connect();

sub GetShelfList {
    my $sth=$dbh->prepare("select shelfnumber,shelfname from bookshelf");
    $sth->execute;
    my %shelflist;
    while (my ($shelfnumber, $shelfname) = $sth->fetchrow) {
	my $sti=$dbh->prepare("select count(*) from shelfcontents where shelfnumber=$shelfnumber");
	$sti->execute;
	my ($count) = $sti->fetchrow;
	$shelflist{$shelfnumber}->{'shelfname'}=$shelfname;
	$shelflist{$shelfnumber}->{'count'}=$count;
    }
    return(\%shelflist);
}


sub GetShelfContents {
    my ($env, $shelfnumber) = @_;
    my @itemlist;
    my $sth=$dbh->prepare("select itemnumber from shelfcontents where shelfnumber=$shelfnumber order by itemnumber");
    $sth->execute;
    while (my ($itemnumber) = $sth->fetchrow) {
	my ($item) = getiteminformation($env, $itemnumber, 0);
	push (@itemlist, $item);
    }
    return (\@itemlist);
}

sub AddToShelf {
    my ($env, $itemnumber, $shelfnumber) = @_;
    my $sth=$dbh->prepare("select * from shelfcontents where shelfnumber=$shelfnumber and itemnumber=$itemnumber");
    $sth->execute;
    if ($sth->rows) {
# already on shelf
    } else {
	$sth=$dbh->prepare("insert into shelfcontents (shelfnumber, itemnumber, flags) values ($shelfnumber, $itemnumber, 0)");
	$sth->execute;
    }
}

sub RemoveFromShelf {
    my ($env, $itemnumber, $shelfnumber) = @_;
    my $sth=$dbh->prepare("delete from shelfcontents where shelfnumber=$shelfnumber and itemnumber=$itemnumber");
    $sth->execute;
}

sub AddShelf {
    my ($env, $shelfname) = @_;
    my $q_shelfname=$dbh->quote($shelfname);
    my $sth=$dbh->prepare("select * from bookshelf where shelfname=$q_shelfname");
    $sth->execute;
    if ($sth->rows) {
	return(0, "Shelf \"$shelfname\" already exists");
    } else {
	$sth=$dbh->prepare("insert into bookshelf (shelfname) values ($q_shelfname)");
	$sth->execute;
	return (1, "Done");
    }
}

sub RemoveShelf {
    my ($env, $shelfnumber) = @_;
    my $sth=$dbh->prepare("select count(*) from shelfcontents where shelfnumber=$shelfnumber");
    $sth->execute;
    my ($count)=$sth->fetchrow;
    if ($count) {
	return (0, "Shelf has $count items on it");
    } else {
	$sth=$dbh->prepare("delete from bookshelf where shelfnumber=$shelfnumber");
	$sth->execute;
	return (1, "Done");
    }
}

			
END { }       # module clean-up code here (global destructor)


#
# $Log$
# Revision 1.2  2001/02/07 23:47:43  tonnesen
# Added header and log substition variables
#
# Revision 1.1  2001/02/07 20:27:17  tonnesen
# Start of code to implement virtual bookshelves in Koha.
#
#
