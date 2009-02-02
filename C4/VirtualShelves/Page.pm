package C4::VirtualShelves::Page;

#
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

# perldoc at the end of the file, per convention.

use strict;
use warnings;
use CGI;
use C4::VirtualShelves qw/:DEFAULT RefreshShelvesSummary/;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Auth qw/get_session/;
use C4::Members;
use C4::Output;
use C4::Dates qw/format_date/;
use Exporter;
use Data::Dumper;

use vars qw($debug @EXPORT @ISA $VERSION);

BEGIN {
	$VERSION = 1.01;
	@ISA = qw(Exporter);
	@EXPORT = qw(&shelfpage);
    $debug = $ENV{DEBUG} || 0;
}

our %pages = (
	intranet => {
		redirect=>'/cgi-bin/koha/virtualshelves/shelves.pl',
	},
	opac => {
		redirect=>'/cgi-bin/koha/opac-shelves.pl',
	},
);

sub shelfpage ($$$$$) {
	my ($type, $query, $template, $loggedinuser, $cookie ) = @_;
	($pages{$type}) or $type = 'opac';
	$query or die "No query";
	$template or die "No template";
	$template->param( { loggedinuser => $loggedinuser } );
	my @paramsloop;
	my $totitems;
	my $shelfoff = ($query->param('shelfoff') ? $query->param('shelfoff') : 1);
	my $itemoff = ($query->param('itemoff') ? $query->param('itemoff') : 1);
	my $displaymode = ($query->param('display') ? $query->param('display') : 'publicshelves');
	my ($shelflimit, $shelfoffset, $shelveslimit, $shelvesoffset);
	# FIXME: These limits should not be hardcoded...
	$shelflimit = 20;	# Limits number of items returned for a given query
	$shelfoffset = ($itemoff - 1) * 20;		# Sets the offset to begin retrieving items at
	$shelveslimit = 20;	# Limits number of shelves returned for a given query (row_count)
	$shelvesoffset = ($shelfoff - 1) * 20;		# Sets the offset to begin retrieving shelves at (offset)
	# getting the Shelves list
	my $category = (($displaymode eq 'privateshelves') ? 1 : 2);
	my ($shelflist, $totshelves) = GetShelves( $category, $shelveslimit, $shelvesoffset, $loggedinuser );
	#Get a list of private shelves for possible deletion. Only do this when we've defaulted to public shelves
    my ($privshelflist, $privtotshelves); 
    if ($category == 2) {
        ($privshelflist, $privtotshelves) = GetShelves( 1, $shelveslimit, $shelvesoffset, $loggedinuser );
    }
	my $op = $query->param('op');
#    my $imgdir = getitemtypeimagesrc();
#    my $itemtypes = GetItemTypes();
    
# the format of this is unindented for ease of diff comparison to the old script
# Note: do not mistake the assignment statements below for comparisons!

if ( $query->param('modifyshelfcontents') ) {
	my ($shelfnumber,$barcode,$item,$biblio);
    if ($shelfnumber = $query->param('viewshelf')) {
    	if (ShelfPossibleAction($loggedinuser, $shelfnumber, 'manage')) {
    		if ($barcode = $query->param('addbarcode')) {
    			if ($item = GetItem( 0, $barcode )) {
    				$biblio = GetBiblioFromItemNumber($item->{'itemnumber'});
        			AddToShelf($biblio->{'biblionumber'}, $shelfnumber) or 
						push @paramsloop, {duplicatebiblio=>$barcode};
				} else { push @paramsloop, {failgetitem=>$barcode}; }
        	} else { 
				(grep {/REM-(\d+)/} $query->param) or push @paramsloop, {nobarcode=>1};
        		foreach ($query->param) {
					/REM-(\d+)/ or next;
					$debug and warn 
						"SHELVES: user $loggedinuser removing item $1 from shelf $shelfnumber";
					DelFromShelf($1, $shelfnumber);	 # $1 is biblionumber
				}
			}
		} else { push @paramsloop, {nopermission=>$shelfnumber}; }
    } else { push @paramsloop, {noshelfnumber=>1}; }
}

my $showadd = 1;
# set the default tab, etc. (for OPAC)
my $shelf_type = ($query->param('display') ? $query->param('display') : 'publicshelves');
if (defined $shelf_type) {
	if ($shelf_type eq 'privateshelves')  {
		$template->param(showprivateshelves => 1);
	} elsif ($shelf_type eq 'publicshelves') {
		$template->param(showpublicshelves => 1);
		$showadd = 0;
	} else {
		$debug and warn "Invalid 'display' param ($shelf_type)";
	}
} elsif ($loggedinuser == -1) {
	$template->param(showpublicshelves => 1);
} else {
	$template->param(showprivateshelves => 1);
}

my($okmanage, $okview);
my $shelfnumber = $query->param('shelfnumber') || $query->param('viewshelf');
if ($shelfnumber) {
	$okmanage = ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' );
	$okview   = ShelfPossibleAction( $loggedinuser, $shelfnumber, 'view' );
}

my $delflag = 0;

SWITCH: {
	if ( $op ) {
		unless ($okmanage) {
			push @paramsloop, {nopermission=>$shelfnumber};
			last SWITCH;
		}
		if ( $op eq 'modifsave' ) {
			my $shelf = {
    			'shelfname'		=> $query->param('shelfname'),
				'category'		=> $query->param('category'),
				'sortfield'		=> $query->param('sortfield'),
			};

			ModShelf( $shelfnumber, $shelf );

		} elsif ( $op eq 'modif' ) {
			my ( $shelfnumber2, $shelfname, $owner, $category, $sortfield ) =GetShelf( $shelfnumber );
			my $member = GetMember($owner,'borrowernumber');
			my $ownername = defined($member) ? $member->{firstname} . " " . $member->{surname} : '';
			$template->param(
				edit                => 1,
				shelfnumber         => $shelfnumber2,
				shelfname           => $shelfname,
				owner               => $owner,
				ownername			=> $ownername,
				"category$category"	=> 1,
				category			=> $category,
				"sort_$sortfield"   => 1,
			);
		}
		last SWITCH;
	}
    if ($shelfnumber = $query->param('viewshelf') ) {
        #check that the user can view the shelf
		if ( ShelfPossibleAction( $loggedinuser, $shelfnumber, 'view' ) ) {
			my $items;
			($items, $totitems) = GetShelfContents($shelfnumber, $shelflimit, $shelfoffset);
			for my $this_item (@$items) {
				# the virtualshelfcontents table does not store these columns nor are they retrieved from the items
				# and itemtypes tables, so I'm commenting them out for now to quiet the log -crn
				#$this_item->{imageurl} = $imgdir."/".$itemtypes->{ $this_item->{itemtype}  }->{'imageurl'};
				#$this_item->{'description'} = $itemtypes->{ $this_item->{itemtype} }->{'description'};
				$this_item->{'dateadded'} = format_date($this_item->{'dateadded'});
			}
			push @paramsloop, {display => 'privateshelves'} if $category == 1;
			$showadd = 1;
			my $i = 0;
			foreach (grep {$i++ % 2} @$items) {     # every other item
				$_->{toggle} = 1;
			}
			my $manageshelf = ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' );
			$template->param(
				shelfname   => $shelflist->{$shelfnumber}->{'shelfname'} || $privshelflist->{$shelfnumber}->{'shelfname'},
				shelfnumber => $shelfnumber,
				viewshelf   => $shelfnumber,
				manageshelf => $manageshelf,
				itemsloop => $items,
			);
		} else { push @paramsloop, {nopermission=>$shelfnumber} };
        last SWITCH;
    }
    if ( $query->param('shelves') ) {
		my $stay = 1;
        if (my $newshelf = $query->param('addshelf')) {
			# note: a user can always add a new shelf
            my $shelfnumber = AddShelf(
                $newshelf,
                $query->param('owner'),
                $query->param('category'),
                $query->param('sortfield')
            );
			$stay = 1;
            if ( $shelfnumber == -1 ) {    #shelf already exists.
				$showadd = 1;
				push @paramsloop, { already => $newshelf };
                $template->param(shelfnumber => $shelfnumber);
            } else {
            	print $query->redirect($pages{$type}->{redirect} . "?viewshelf=$shelfnumber");
            	exit;
			}
        }
		foreach ($query->param()) {
			/DEL-(\d+)/ or next;
			$delflag = 1;
			my $number = $1;
			unless (defined $shelflist->{$number} || defined $privshelflist->{$number}) {
				push(@paramsloop, {unrecognized=>$number}); last;
	  		}
			unless (ShelfPossibleAction($loggedinuser, $number, 'manage')) {
				push(@paramsloop, {nopermission=>$shelfnumber}); last;
			}
			my $contents;
			($contents, $totshelves) = GetShelfContents($number, $shelveslimit, $shelvesoffset);
			if (my $count = scalar @$contents){
				unless (scalar grep {/^CONFIRM-$number$/} $query->param()) {
					if (defined $shelflist->{$number}) {
						push(@paramsloop, {need_confirm=>$shelflist->{$number}->{shelfname}, count=>$count});
						$shelflist->{$number}->{confirm} = $number;
					} else {
						push(@paramsloop, {need_confirm=>$privshelflist->{$number}->{shelfname}, count=>$count});
						$privshelflist->{$number}->{confirm} = $number;
					}
					$stay = 0;
					next;
				}
			} 
			my $name;
			if (defined $shelflist->{$number}) {
				$name = $shelflist->{$number}->{'shelfname'};
				delete $shelflist->{$number};
			} else {
				$name = $privshelflist->{$number}->{'shelfname'};
				delete $privshelflist->{$number};
			}
			unless (DelShelf($number)) {
				push(@paramsloop, {delete_fail=>$name}); last;
			}
			push(@paramsloop, {delete_ok=>$name});
			# print $query->redirect($pages{$type}->{redirect}); exit;
			$stay = 0;
		}
		$showadd = 1;
		$stay and $template->param(shelves => 1);
		last SWITCH;
	}
}

(@paramsloop) and $template->param(paramsloop => \@paramsloop);
$showadd and $template->param(showadd => 1);
my @shelvesloop;
my @shelveslooppriv;
my $numberCanManage = 0;

# rebuild shelflist in case a shelf has been added
($shelflist, $totshelves) = GetShelves( $category, $shelveslimit, $shelvesoffset, $loggedinuser ) unless $delflag;
foreach my $element (sort { lc($shelflist->{$a}->{'shelfname'}) cmp lc($shelflist->{$b}->{'shelfname'}) } keys %$shelflist) {
	my %line;
	$shelflist->{$element}->{shelf} = $element;
	my $category = $shelflist->{$element}->{'category'};
	my $owner    = $shelflist->{$element}->{ 'owner'  };
	my $canmanage = ShelfPossibleAction( $loggedinuser, $element, 'manage' );
	$shelflist->{$element}->{"viewcategory$category"} = 1;
	$shelflist->{$element}->{manageshelf} = $canmanage;
	if ($owner eq $loggedinuser or $canmanage) {
		$shelflist->{$element}->{'mine'} = 1;
	} 
	my $member = GetMember($owner,'borrowernumber');
	$shelflist->{$element}->{ownername} = defined($member) ? $member->{firstname} . " " . $member->{surname} : '';
	$numberCanManage++ if $canmanage;	# possibly outmoded
	if ($shelflist->{$element}->{'category'} eq '1') {
		(scalar(@shelveslooppriv) % 2) and $shelflist->{$element}->{toggle} = 1;
		push (@shelveslooppriv, $shelflist->{$element});
	} else {
		(scalar(@shelvesloop)     % 2) and $shelflist->{$element}->{toggle} = 1;
		push (@shelvesloop, $shelflist->{$element});
	}
}

my $url = $type eq 'opac' ? "/cgi-bin/koha/opac-shelves.pl" : "/cgi-bin/koha/virtualshelves/shelves.pl";
my %qhash = ();
foreach (qw(display viewshelf)) {
    $qhash{$_} = $query->param($_) if $query->param($_);
}
(scalar keys %qhash) and $url .= '?' . join '&', map {"$_=$qhash{$_}"} keys %qhash;
if ($query->param('viewshelf')) {
	$template->param( {pagination_bar => pagination_bar($url, (int($totitems/$shelflimit)) + (($totitems % $shelflimit) > 0 ? 1 : 0), $itemoff, "itemoff")} );
} else {
	$template->param( {pagination_bar => pagination_bar($url, (int($totshelves/$shelveslimit)) + (($totshelves % $shelveslimit) > 0 ? 1 : 0), $shelfoff, "shelfoff")} );
}
$template->param(
    shelveslooppriv => \@shelveslooppriv,
    shelvesloop     => \@shelvesloop,
    shelvesloopall  => [(@shelvesloop, @shelveslooppriv)],
    numberCanManage => $numberCanManage,
	"BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
);
if ($template->param('viewshelf') or
	$template->param( 'shelves' ) or
	$template->param(  'edit'   ) ) {
	$template->param(vseflag => 1);
}
if ($template->param( 'shelves' ) or    # note: this part looks duplicative, but is intentional
	$template->param(  'edit'   ) ) {
	$template->param( seflag => 1);
}

#FIXME:	This refresh really only needs to happen when there is a modification of some sort
#		to the shelves, but the above code is so convoluted in its handling of the various
#		options, it is easier to do this refresh every time C4::VirtualShelves::Page.pm is
#		called

my ($total, $pubshelves, $barshelves) = RefreshShelvesSummary($query->cookie("CGISESSID"),$loggedinuser,($loggedinuser == -1 ? 20 : 10));

if (defined $barshelves) {
	$template->param( 	barshelves     	=> scalar (@{$barshelves->[0]}),
						barshelvesloop 	=> $barshelves->[0],
					);
	$template->param(	bartotal		=> $total->{'bartotal'}, ) if ($total->{'bartotal'} > scalar (@{$barshelves->[0]}));
}

if (defined $pubshelves) {
	$template->param( 	pubshelves     	=> scalar (@{$pubshelves->[0]}),
						pubshelvesloop 	=> $pubshelves->[0],
					);
	$template->param(	pubtotal		=> $total->{'pubtotal'}, ) if ($total->{'pubtotal'} > scalar (@{$pubshelves->[0]}));
}

output_html_with_http_headers $query, $cookie, $template->output;
}	

1;
__END__

=head1 NAME

    VirtualShelves/Page.pm

=head1 DESCRIPTION

    Module used for both OPAC and intranet pages.

=head1 CGI PARAMETERS

=over 4

=item C<modifyshelfcontents>

    If this script has to modify the shelf content.

=item C<shelfnumber>

    To know on which shelf to work.

=item C<addbarcode>

=item C<op>

    Op can be:
        * modif: show the template allowing modification of the shelves;
        * modifsave: save changes from modif mode.

=item C<viewshelf>

    Load template with 'viewshelves param' displaying the shelf's information.

=item C<shelves>

    If the param shelves == 1, then add or delete a shelf.

=item C<addshelf>

    If the param shelves == 1, then addshelf is the name of the shelf to add.

=back

=cut
