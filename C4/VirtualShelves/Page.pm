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
use C4::VirtualShelves qw/:DEFAULT GetShelvesSummary/;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Auth qw/get_session/;
use C4::Members;
use C4::Output;
use C4::Date qw/format_date/;
use Exporter;

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
	# getting the Shelves list
	my $shelflist = GetShelves( $loggedinuser, 2 );
	my $op = $query->param('op');
    my $imgdir = getitemtypeimagesrc();
    my $itemtypes = GetItemTypes();
    
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
my $shelf_type = $query->param('display');
if (defined $shelf_type) {
	if ($shelf_type eq 'privateshelves')  {
		$template->param(showprivateshelves => 1);
	} elsif ($shelf_type eq 'publicshelves') {
		$template->param(showpublicshelves => 1);
		$showadd = 0;
	} else {
		$debug and warn "Invalid 'display' param ($shelf_type)";
	}
} else {
	$template->param(showprivateshelves => 1);
}

my($okmanage, $okview);
my $shelfnumber = $query->param('shelfnumber') || $query->param('viewshelf');
if ($shelfnumber) {
	$okmanage = &ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' );
	$okview   = &ShelfPossibleAction( $loggedinuser, $shelfnumber, 'view' );
}

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
			$shelf->{'owner'} = $loggedinuser if $type eq 'intranet';	#we only overwrite the list owner if &ModShelf was called from the staff client

			ModShelf( $shelfnumber, $shelf );
			$shelflist = GetShelves( $loggedinuser, 2 );    # refresh after mods
		} elsif ( $op eq 'modif' ) {
			my ( $shelfnumber2, $shelfname, $owner, $category, $sortfield ) =GetShelf( $shelfnumber );
			$template->param(
				edit                => 1,
				shelfnumber         => $shelfnumber2,
				shelfname           => $shelfname,
				owner               => $owner,
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
			my $items = GetShelfContents($shelfnumber);
			for my $this_item (@$items) {
				$this_item->{imageurl} = $imgdir."/".$itemtypes->{ $this_item->{itemtype}  }->{'imageurl'};
				$this_item->{'description'} = $itemtypes->{ $this_item->{itemtype} }->{'description'};
				$this_item->{'dateadded'} = format_date($this_item->{'dateadded'});
			}
			$showadd = 1;
			my $i = 0;
			foreach (grep {$i++ % 2} @$items) {     # every other item
				$_->{toggle} = 1;
			}
			# my $manageshelf = &ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' );
			# ($manageshelf) and $showadd = 1;
			$template->param(
				shelfname   => $shelflist->{$shelfnumber}->{'shelfname'},
				shelfnumber => $shelfnumber,
				viewshelf   => $shelfnumber,
				manageshelf => &ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' ),
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
                $query->param('category')
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
			my $number = $1;
			unless (defined $shelflist->{$number}) {
				push(@paramsloop, {unrecognized=>$number}); last;
	  		}
			unless (ShelfPossibleAction($loggedinuser, $number, 'manage')) {
				push(@paramsloop, {nopermission=>$shelfnumber}); last;
			}
			my $contents = GetShelfContents($number);
			if (my $count = scalar @$contents){
				unless (scalar grep {/^CONFIRM-$number$/} $query->param()) {
					push(@paramsloop, {need_confirm=>$shelflist->{$number}->{shelfname}, count=>$count});
					$shelflist->{$number}->{confirm} = $number;
					$stay = 0;
					next;
				}
			} 
			my $name = $shelflist->{$number}->{'shelfname'};
			unless (DelShelf($number)) {
				push(@paramsloop, {delete_fail=>$name}); last;
			}
			delete $shelflist->{$number};
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
# rebuild shelflist in case a shelf has been added
# $shelflist = GetShelves( $loggedinuser, 2 );
$showadd and $template->param(showadd => 1);
my @shelvesloop;
my @shelveslooppriv;
my $numberCanManage = 0;

foreach my $element (sort { lc($shelflist->{$a}->{'shelfname'}) cmp lc($shelflist->{$b}->{'shelfname'}) } keys %$shelflist) {
	my %line;
	$shelflist->{$element}->{shelf} = $element;
	my $category = $shelflist->{$element}->{'category'};
	my $owner    = $shelflist->{$element}->{ 'owner'  };
	my $canmanage = ShelfPossibleAction( $loggedinuser, $element, 'manage' );
	$shelflist->{$element}->{"viewcategory$category"} = 1;
	$shelflist->{$element}->{canmanage} = $canmanage;
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
if ($template->param( 'shelves' ) or
	$template->param(  'edit'   ) ) {
	$template->param( seflag => 1);
}

my $sessionID = $query->cookie("CGISESSID") ;
my $session = get_session($sessionID);
my $shelves = GetShelvesSummary($loggedinuser, 2, 10);
$session->param('shelves', $shelves);
$template->param( barshelves     => scalar (@$shelves));
$template->param( barshelvesloop => $shelves);

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
