#!/usr/bin/perl

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


=head1 NAME

    opac-shelves.pl

=head1 DESCRIPTION

    this script is used to script to provide virtualshelf management

=head1 CGI PARAMETERS

=over 4

=item C<modifyshelfcontents>

    if this script has to modify the shelf content.

=item C<shelfnumber>

    to know on which shelf this script has to work.

=item C<addbarcode>

=item C<op>

    op can equal the following values:
        * 'modifsave' to save changes on the shelves
        * 'modif' to change the template to allow modification of the shelves.

=item C<viewshelf>

    to load the template with 'viewshelves param' which allows reading the shelves information.

=item C<shelves>

    if == 1, then call the function shelves to add or delete a shelf.

=item C<addshelf>

    if the param shelves == 1, then addshelf must be equals to the name of the shelf to add.

=back

=cut

use strict;
use warnings;
use CGI;
use C4::Output;
use C4::VirtualShelves;
use C4::Circulation;
use C4::Auth;
use C4::Output;
use C4::Biblio;

use vars qw($debug);

BEGIN { 
	$debug = $ENV{DEBUG} || 0;
}

my $query = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-shelves.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
    }
);

if ( $query->param('modifyshelfcontents') ) {
    my $shelfnumber = $query->param('viewshelf');
    my $barcode     = $query->param('addbarcode');
    my ($item) = GetItemnumberFromBarcode($barcode);
    my ($biblio) = GetBiblioFromItemNumber($item->{'itemnumber'});
    if ( ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' ) ) {
        AddToShelf( $biblio->{'biblionumber'}, $shelfnumber );
        foreach ( $query->param ) {
            /REM-(\d+)/ or next;
            DelFromShelf( $1, $shelfnumber );	# $1 is biblionumber
        }
    }
}

my $showadd = 1;
# set the default tab, etc.
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

# getting the Shelves list
my $shelflist = GetShelves( $loggedinuser, 2 );
$template->param( { loggedinuser => $loggedinuser } );
my $op = $query->param('op');

SWITCH: {
	if ( $op ) {
		if ( $op eq 'modifsave' ) {
			ModShelf(
				$query->param('shelfnumber'), $query->param('shelfname'),
				$loggedinuser,                $query->param('category'), $query->param('sortfield')
			);
			$shelflist = GetShelves( $loggedinuser, 2 );	# refresh after mods
		} elsif ( $op eq 'modif' ) {
			my ( $shelfnumber, $shelfname, $owner, $category, $sortfield ) =GetShelf( $query->param('shelf') );
			$template->param(
				edit                => 1,
				shelfnumber         => $shelfnumber,
				shelfname           => $shelfname,
				"category$category" => 1,
				"sort_$sortfield"   => 1,
			);
		}
		last SWITCH;
	}
	if ( $query->param('viewshelf') ) {
        #check that the user can view the shelf
        my $shelfnumber = $query->param('viewshelf');
        if ( ShelfPossibleAction( $loggedinuser, $shelfnumber, 'view' ) ) {
            my $items = GetShelfContents($shelfnumber);
			$showadd = 1;
            $template->param(
                shelfname   => $shelflist->{$shelfnumber}->{'shelfname'},
                shelfnumber => $shelfnumber,
                viewshelf   => $query->param('viewshelf'),
                manageshelf => &ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' ),
                itemsloop   => $items,
            );
        } # else {;}  # FIXME - some kind of warning *may* be in order
        last SWITCH;
    }
    if ( $query->param('shelves') ) {
        if ( my $newshelf = $query->param('addshelf') ) {
            my $shelfnumber = AddShelf(
                $newshelf,
                $query->param('owner'),
                $query->param('category')
            );

            if ( $shelfnumber == -1 ) {    #shelf already exists.
				$showadd = 1;
                $template->param(
                        shelfnumber => $shelfnumber,
                        already     => $newshelf,
                );
            } else {
            	print $query->redirect("/cgi-bin/koha/opac-shelves.pl?viewshelf=$shelfnumber");
				exit;		# can't redirect AND expect %line to DO anything!
			}
        }
        my @paramsloop;
        foreach ( $query->param() ) {
			/^DEL-(\d+)/ or next;
			my %line;
			( $line{status}, $line{count} ) = DelShelf($1);
			(defined $shelflist->{$1}) and delete $shelflist->{$1};
			# print $query->redirect("/cgi-bin/koha/opac-shelves.pl"); exit;
			# can't redirect and expect %line to DO anything!
			push( @paramsloop, \%line );
        }
		$showadd = 1;
        $template->param( 
			paramsloop => \@paramsloop,
            shelves    => 1,
        );
        last SWITCH;
    }
}

# rebuilding shelflist (in case a shelf has been added) is not necessary since add redirects!

$showadd and $template->param(showadd => 1);
my $color = 0;
my @shelvesloop;
my @shelveslooppriv;

foreach my $element (sort { lc($shelflist->{$a}->{'shelfname'}) cmp lc($shelflist->{$b}->{'shelfname'}) } keys %$shelflist) {
	my %line;
	$color = ($color) ? 0 : 1;
	$line{'toggle'} = $color;
	$line{'shelf'} = $element;
	$line{'shelfname'} = $shelflist->{$element}->{'shelfname'};
	$line{'sortfield'} = $shelflist->{$element}->{'sortfield'};
	$line{"category".$shelflist->{$element}->{'category'}} = 1;
	$line{'shelfvirtualcount'} = $shelflist->{$element}->{'count'};
	$line{'canmanage'} = ShelfPossibleAction($loggedinuser,$element,'manage');
	if ($shelflist->{$element}->{'owner'} eq $loggedinuser) {
		$line{'mine'} = 1;
	} else {
		$line{'firstname'} = $shelflist->{$element}->{'firstname'};
		$line{ 'surname' } = $shelflist->{$element}->{ 'surname' };
	}
	if ($shelflist->{$element}->{'category'} eq 2) {
		push (@shelvesloop,     \%line);
	} elsif ($shelflist->{$element}->{'category'} eq 1) {
        push (@shelveslooppriv, \%line);
    }
}

$template->param(
    shelveslooppriv => \@shelveslooppriv,
    shelvesloop     => \@shelvesloop,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
);

output_html_with_http_headers $query, $cookie, $template->output;
