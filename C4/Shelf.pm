package Shelf;

=head1 NAME

Shelf - Perl extension for Virtual Bookshelves

=cut

use strict;
use C4::Context;
use Cache::FileCache;

=head1 VERSION

  $Id$

=cut

=head1 DESCRIPTION

Module for querying and stocking Virtual Bookshelves

   1. can contain a list of items, a list of biblioitems, or a list of biblios
   2. can have an arbitrary name, and will have a unique numerical identifier
   3. will have arbitrary metadata (properties) associated with it
	  * Sharing information (private, only visible by the owner of the
	    shelf; shared with a group of patrons; public, viewable by anybody)
	  * Special circulation rules - Do not return to home branch, do not
	    circulate, reduced loan time (ie 3 day loan)
	  * Search query term - if the shelf is the result of a query, the
	    query itself can be stored with the list of books that resulted
          * Creation date - useful for 'retiring' a stale cached query result
          * Access information - who has "write" or "read" access to the shelf.
	  * Searchable - If a patron can perform a search query on the contents
	    of this shelf


Patrons typically will only use "biblioitem" bookshelves, and will not need to
be presented with the differences between biblioitem and item bookshelves.


Some uses for VirtualBookshelves

   1. Cache search results for faster response on popular searches
   2. Name search results so that patrons can pull up saved searches
   3. Creation of sub-collections within a library or branch
   4. replacing "itemtypes" field... this would allow an individual item to be
	a member of more than one itemtype
   5. store a patron's reading record (if he chooses to store such data)
   6. store a patron's "To be read" list
   7. A teacher of a course could add a list of books to a shelf for his course
	and ask that those items be marked non-circulating so students always
	have access to them at the library.
	  * The teacher creates the list of materials that she wants to be
	    non-circulating (or reduced to 3-day loan) and marks them as such
	  * A librarian receives a notice that a shelf requires her attention.
	    He can pull up a list of the contents of the shelf, the owner of
	    the shelf, and the reason the owner is requesting this change in
	    circulation rules. The librarian can approve or deny the request.
	  * Optionally, create an access flag that grants teachers the right to
	    put items on modified circulation shelves without librarian
	    intervention.


=cut

=head1 METHODS

=head2 C<new()>

Base constructor for the class.

  my $shelf=Shelf->new(56);
      will load bookshelf 56.
  my $shelf=Shelf->new(-name => 'Fiction');
  my $shelf=Shelf->new('Fiction');
      will load the internal 'Fiction' shelf
  my $shelf=Shelf->new('Favourite Books', 'sjohnson');
  my $shelf=Shelf->new(-name => 'Favourite Books', -owner => 'sjohnson');
      will load sjohnson's "Favourite Books" bookshelf
  
  Any of the last four invocations will create a new shelf with the name and
  owner given if one doesn't already exist.


=cut

sub new {
    my $self = {};
    $self->{ID}	= undef;
    $self->{NAME}=undef;
    $self->{OWNDER}=undef;
    $self->{BIBLIOCONTENTS}={};
    $self->{BIBLIOITEMCONTENTS}={};
    $self->{ITEMCONTENTS}={};
    $self->{ATTRIBUTES}={};
    $self->{CACHE}=new Cache::FileCache( { 'namespace' => 'KohaShelves' } );

    if (@_) {
	my $dbh=C4::Context->dbh();
	shift;
	if ($#_ == 0) {
	    $self->{ID}=shift;
	    # load attributes of shelf #ID
	    my $sth;
	    $sth=$dbh->prepare("select bookshelfname,bookshelfowner from bookshelves where bookshelfid=?");
	    $sth->execute($self->{ID});
	    ($self->{NAME},$self->{OWNER}) = $sth->fetchrow;
	    $sth=$dbh->prepare("select attribute,value from bookshelfattributes where bookshelfid=?");
	    $sth->execute($self->{ID});
	    while (my ($attribute,$value) = $sth->fetchrow) {
		$self->{ATTRIBUTES}->{$attribute}=$value;
	    }
	} elsif ($#_) {
	    my ($name,$owner,$attributes);
	    if ($_[0] =~/^-/) {
		my %params=@_;
		$name=$params{name};
		$owner=$params{owner};
		$attributes=$params{attributes};
	    } else {
		$name=shift;
		$owner=shift;
		$attributes=shift;
	    }
	    my $sth=$dbh->prepare("select bookshelfid from bookshelves where bookshelfname=? and bookshelfowner=?");
	    $sth->execute($name, $owner);
	    if ($sth->rows) {
		($self->{ID})=$sth->fetchrow;
		$sth=$dbh->prepare("select attribute,value from bookshelfattributes where bookshelfid=?");
		$sth->execute($self->{ID});
		while (my ($attribute,$value) = $sth->fetchrow) {
		    $self->{ATTRIBUTES}->{$attribute}=$value;
		}
	    } else {
		$sth=$dbh->prepare("insert into bookshelves (bookshelfname, bookshelfowner) values (?, ?)");
		$sth->execute($name,$owner);
		$sth=$dbh->prepare("select bookshelfid from bookshelves where bookshelfname=? and bookshelfowner=?");
		$sth->execute($name,$owner);
		($self->{ID})=$sth->fetchrow();
		foreach my $attribute (keys %$attributes) {
		    my $value=$attributes->{$attribute};
		    $self->attribute($attribute,$value);
		}
	    }
	}
    }
    bless($self);
    return $self;
}


=head2 C<itemcontents()>

retrieve a slice of itemnumbers from a shelf.

    my $arrayref = $shelf->itemcontents(-orderby=>'title', 
    					-startat=>50,
					-number=>10	);

=cut

sub itemcontents {
    my $self=shift;
    my ($orderby,$startat,$number);
    if ($_[0]=~/^\-/) {
	my %params=@_;
	$orderby=$params{'-orderby'};
	$startat=$params{'-startat'};
	$number=$params{'-number'};
    } else {
	($orderby,$startat,$number)=@_;
    }
    $number--;
    unless ($self->{ITEMCONTENTS}->{orderby}->{$orderby}) {
	$self->loadcontents(-orderby=>$orderby, -startat=>$startat, -number=>$number);
    }
    my $endat=$startat+$number;
    my @return;
    foreach (@{$self->{ITEMCONTENTS}->{orderby}->{$orderby}}[$startat..$endat]) {
	push @return,$_;
    }
    return \@return;
}

=head2 C<biblioitemcontents()>

retrieve a slice of biblioitemnumbers from a shelf.

    my $arrayref = $shelf->biblioitemcontents(-orderby=>'title', 
    					      -startat=>50,
					      -number=>10	);

=cut

sub biblioitemcontents {
    my $self=shift;
    my ($orderby,$startat,$number);
    if ($_[0]=~/^\-/) {
	my %params=@_;
	$orderby=$params{'-orderby'};
	$startat=$params{'-startat'};
	$number=$params{'-number'};
    } else {
	($orderby,$startat,$number)=@_;
    }
    unless ($self->{BIBLIOITEMCONTENTS}->{orderby}->{$orderby}) {
	$self->loadcontents(-orderby=>$orderby, -startat=>$startat, -number=>$number);
    }
    my $endat=$startat+$number;
    my @return;
    foreach (@{$self->{BIBLIOITEMCONTENTS}->{orderby}->{$orderby}}[$startat..$endat]) {
	push @return,$_;
    }
    return \@return;
}

=head2 C<biblioitemcontents()>

retrieve a slice of biblionumbers from a shelf.

    my $arrayref = $shelf->bibliocontents(-orderby=>'title', 
    					  -startat=>50,
					  -number=>10	);

=cut

sub bibliocontents {
    my $self=shift;
    my ($orderby,$startat,$number);
    if ($_[0]=~/^\-/) {
	my %params=@_;
	$orderby=$params{'-orderby'};
	$startat=$params{'-startat'};
	$number=$params{'-number'};
    } else {
	($orderby,$startat,$number)=@_;
    }
    unless ($self->{BIBLIOCONTENTS}->{orderby}->{$orderby}) {
	$self->loadcontents(-orderby=>$orderby, -startat=>$startat, -number=>$number);
    }
    my $endat=$startat+$number;
    my @return;
    foreach (@{$self->{BIBLIOCONTENTS}->{orderby}->{$orderby}}[$startat..$endat]) {
	push @return,$_;
    }
    return \@return;
}


=head2 C<itemcounter()>

returns the number of items on the shelf

    my $itemcount=$shelf->itemcounter();

=cut
sub itemcounter {
    my $self=shift;
    unless ($self->{ITEMCONTENTS}->{orderby}->{'natural'}) {
	$self->loadcontents();
    }
    my @temparray=@{$self->{ITEMCONTENTS}->{orderby}->{'natural'}};
    return $#temparray+1;
}

sub shelfcontents {
    my $self=shift;
}


=head2 C<clearcontents()>

Removes all contents from the shelf.

    $shelf->clearcontents();

=cut

sub clearcontents {
    my $self=shift;
    my $dbh=C4::Context->dbh();
    my $sth=$dbh->prepare("delete from bookshelfcontents where bookshelfid=?");
    $sth->execute($self->{ID});
    foreach my $level ('ITEM', 'BIBLIOITEM', 'BIBLIO') {
	delete $self->{$level."CONTENTS"};
	$self->{$level."CONTENTS"}={};
    }
    $self->clearcache();

}



=head2 C<addtoshelf()>

adds an array of items to a shelf.  If any modifications are actually made to
the shelf then the per process caches and the FileCache for that shelf are
cleared.

  $shelf->addtoshelf(-add => [[ 45, 54, 67], [69, 87, 143]]);

=cut

sub addtoshelf {
    my $self=shift;
    my $add;
    if ($_[0]=~/^\-/) {
	my %params=@_;
	$add=$params{'-add'};
    } else {
	($add)=@_;
    }
    my $dbh=C4::Context->dbh();
    my $sth;
    my $bookshelfid=$self->{ID};
    my $clearcache=0;
    foreach (@$add) {
	my ($biblionumber,$biblioitemnumber,$itemnumber) = @$_;
	$sth=$dbh->prepare("select count(*) from bookshelfcontents where bookshelfid=? and itemnumber=? and biblioitemnumber=? and biblionumber=?");
	$sth->execute($bookshelfid,$itemnumber,$biblioitemnumber,$biblionumber);
	my $rows=$sth->fetchrow();
	if ($rows==0) {
	    $sth=$dbh->prepare("insert into bookshelfcontents (bookshelfid,biblionumber,biblioitemnumber,itemnumber) values (?,?,?,?)");
	    $sth->execute($bookshelfid,$biblionumber,$biblioitemnumber,$itemnumber);
	    $clearcache=1;
	}
    }
    ($clearcache) && ($self->clearcache());
}


sub removefromshelf {
    my $self=shift;
}

=head2 C<attribute()>

Returns or sets the value of a given attribute for the shelf.

  my $loanlength=$shelf->attribute('loanlength');
  $shelf->attribute('loanlength', '21 days');


=cut

sub attribute {
    my $self=shift;
    my ($attribute, $value);
    $attribute=shift;
    $value=shift;
    if ($value) {
	$self->{ATTRIBUTES}->{$attribute}=$value;
	my $dbh=C4::Context->dbh();
	my $sth=$dbh->prepare("select value from bookshelfattributes where bookshelfid=? and attribute=?");
	$sth->execute($self->{ID}, $attribute);
	if ($sth->rows) {
	    my $sti=$dbh->prepare("update bookshelfattributes set value=? where bookshelfid=? and attribute=?");
	    $sti->execute($value, $self->{ID}, $attribute);
	} else {
	    my $sti=$dbh->prepare("insert into bookshelfattributes (bookshelfid, attribute, value) values (?, ?, ?)");
	    $sti->execute($self->{ID}, $attribute, $value);
	}
    }
    return $self->{ATTRIBUTES}->{$attribute};
}


=head2 C<attributes()>

Returns a hash reference of the shelf attributes

    my $attributes=$shelf->attributes();
    my $loanlength=$attributes->{loanlength};

=cut

sub attributes {
    my $self=shift;
    return $self->{ATTRIBUTES};
}

=head2 C<clearcache()>

Clears the per process in-memory cache and the FileCache if any changes are
made to a shelf.

  $shelf->clearshelf();

=cut

sub clearcache {
    my $self=shift;
    foreach my $level ('ITEM','BIBLIOITEM','BIBLIO') {
	delete $self->{$level."CONTENTS"};
	foreach my $sorttype (('author', 'title')) {
	    $self->{CACHE}->remove($self->{ID}."_".$level."CONTENTS_".$sorttype);
	}
    }
}


=head2 C<loadcontents()>

loads the contents of a particular shelf and loads into a per process memory
cache as well as a shared Cache::FileCache.

This subroutine is normally only used internally (called by itemcontents,
biblioitemcontents, or bibliocontents).

  $shelf->loadcontents(-orderby => 'author', -startat => 30, -number => 10);


=cut

sub loadcontents {
    my $self=shift;
    my ($orderby,$startat,$number);
    if ($_[0]=~/^\-/) {
	my %params=@_;
	$orderby=$params{'-orderby'};
	$startat=$params{'-startat'};
	$number=$params{'-number'};
    } else {
	($orderby,$startat,$number)=@_;
    }
    my $bookshelfid=$self->{ID};
    ($orderby) || ($orderby='natural');
    $self->{ITEMCONTENTS}->{orderby}->{$orderby}=$self->{CACHE}->get( "$bookshelfid\_ITEMCONTENTS_$orderby" );
    $self->{BIBLIOITEMCONTENTS}->{orderby}->{$orderby}=$self->{CACHE}->get( "$bookshelfid\_BIBLIOITEMCONTENTS_$orderby" );
    $self->{BIBLIOCONTENTS}->{orderby}->{$orderby}=$self->{CACHE}->get( "$bookshelfid\_BIBLIOCONTENTS_$orderby" );
    if ( defined $self->{ITEMCONTENTS}->{orderby}->{$orderby}) {
	return;
    }
    my $dbh=C4::Context->dbh();
    my $sth;
    my $limit='';
    if ($startat && $number) {
	$limit="limit $startat,$number";
    }
    $limit='';
    my $biblionumbers;
    my $biblioitemnumbers;
    if ($orderby eq 'author') {
	$sth=$dbh->prepare("select itemnumber,BSC.biblionumber,BSC.biblioitemnumber from bookshelfcontents BSC, biblio B where BSC.biblionumber=B.biblionumber and bookshelfid=? order by B.author $limit");
    } elsif ($orderby eq 'title') {
	$sth=$dbh->prepare("select itemnumber,BSC.biblionumber,BSC.biblioitemnumber from bookshelfcontents BSC, biblio B where BSC.biblionumber=B.biblionumber and bookshelfid=? order by B.title $limit");
    } else {
	$sth=$dbh->prepare("select itemnumber,biblionumber,biblioitemnumber from bookshelfcontents where bookshelfid=? $limit");
    }
    $sth->execute($bookshelfid);
    my @results;
    my @biblioresults;
    my @biblioitemresults;
    while (my ($itemnumber,$biblionumber,$biblioitemnumber) = $sth->fetchrow) {
	unless ($biblionumbers->{$biblionumber}) {
	    $biblionumbers->{$biblionumber}=1;
	    push @biblioresults, $biblionumber;
	}
	unless ($biblioitemnumbers->{$biblioitemnumber}) {
	    $biblioitemnumbers->{$biblioitemnumber}=1;
	    push @biblioitemresults, $biblioitemnumber;
	}
	push @results, $itemnumber;
    }
    $self->{CACHE}->set("$bookshelfid\_ITEMCONTENTS_$orderby", \@results, "3 hours");
    $self->{CACHE}->set("$bookshelfid\_BIBLIOITEMCONTENTS_$orderby", \@results, "3 hours");
    $self->{CACHE}->set("$bookshelfid\_BIBLIOCONTENTS_$orderby", \@results, "3 hours");
    $self->{ITEMCONTENTS}->{orderby}->{$orderby}=\@results;
    $self->{BIBLIOOCONTENTS}->{orderby}->{$orderby}=\@biblioresults;
    $self->{BIBLIOITEMCONTENTS}->{orderby}->{$orderby}=\@biblioitemresults;
}



1;
