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

    if this script has to modify the shelve content.

=item C<shelfnumber>

    to know on which shelve this script has to work.

=item C<addbarcode>

=item C<op>

    op can be equals to:
        * modifsave to save change on the shelves
        * modif to change the template to allow to modify the shelves.

=item C<viewshelf>

    to load the template with 'viewshelves param' which allow to read the shelves information.

=item C<shelves>

    if equals to 1. then call the function shelves which add
    or delete a shelf.

=item C<addshelf>

    if the param shelves = 1 then addshelf must be equals to the name of the shelf to add.

=back

=cut

use strict;
use CGI;
use C4::Output;
use C4::VirtualShelves;
use C4::Circulation;
use C4::Auth;
use C4::Output;
use C4::Biblio;

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
            if (/MOD-(\d*)/) {
                my $biblionumber = $1;
                if ( $query->param('remove') eq "on" ) {
                    DelFromShelf( $biblionumber, $shelfnumber );
                }
            }
        }
    }
}

	# set the default tab, etc.
	my $shelf_type = $query->param('display');
	if ((!$shelf_type) || ($shelf_type eq 'privateshelves'))  {
		$template->param(showprivateshelves => 1);
	} elsif ($shelf_type eq 'publicshelves') {
		$template->param(showpublicshelves => 1);
	}

# getting the Shelves list
my $shelflist = GetShelves( $loggedinuser, 2 );
$template->param( { loggedinuser => $loggedinuser } );
my $op = $query->param('op');

SWITCH: {
    if ( $op && ( $op eq 'modifsave' ) ) {
        ModShelf(
            $query->param('shelfnumber'), $query->param('shelfname'),
            $loggedinuser,                $query->param('category')
        );
        last SWITCH;
    }
    if ( $op && ( $op eq 'modif' ) ) {
        my ( $shelfnumber, $shelfname, $owner, $category ) =
          GetShelf( $query->param('shelf') );
        $template->param(
            edit                => 1,
            shelfnumber         => $shelfnumber,
            shelfname           => $shelfname,
            "category$category" => 1
        );

        #         editshelf($query->param('shelf'));
        last SWITCH;
    }
    if ( $query->param('viewshelf') ) {
        #check that the user can view the shelf
        my $shelfnumber = $query->param('viewshelf');
        if ( ShelfPossibleAction( $loggedinuser, $shelfnumber, 'view' ) ) {
            my $items = GetShelfContents($shelfnumber);
            $template->param(
                shelfname   => $shelflist->{$shelfnumber}->{'shelfname'},
                shelfnumber => $shelfnumber,
                viewshelf   => $query->param('viewshelf'),
                manageshelf => &ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' ),
                itemsloop   => $items,
            );
        }
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
                $template->param(
                    {
                        shelfnumber => $shelfnumber,
                        already     => 1
                    }
                );
            }
    }
    my @paramsloop;
    foreach ( $query->param() ) {
        my %line;
        if (/DEL-(\d+)/) {
            my $delshelf = $1;
            my ( $status, $count ) = DelShelf($delshelf);
            if ($status) {
                $line{'status'} = $status;
                $line{'count'}  = $count;
            }
        }

        #if the shelf is not deleted, %line points on null
        push( @paramsloop, \%line );
    }
    $template->param( paramsloop => \@paramsloop );
    my ($shelflist) = GetShelves( $loggedinuser, 2 );
    my $color = '';
    my @shelvesloop;
    foreach my $element ( sort keys %$shelflist ) {
        my %line;
        ( $color eq 1 ) ? ( $color = 0 ) : ( $color = 1 );
        $line{'toggle'}         = $color;
        $line{'shelf'}          = $element;
        $line{'shelfname'}      = $shelflist->{$element}->{'shelfname'};
        $line{'shelfvirtualcount'} = $shelflist->{$element}->{'count'};
        push( @shelvesloop, \%line );
    }
    $template->param(
        shelvesloop => \@shelvesloop,
        shelves     => 1,
    );
        last SWITCH;
    }
}

($shelflist) =
  GetShelves( $loggedinuser, 2 )
  ;    # rebuild shelflist in case a shelf has been added

my $color='';
my @shelvesloop;
my @shelveslooppriv;
foreach my $element (sort keys %$shelflist) {
		my %line;
		my %linepriv;
		($color eq 0) ? ($color=1) : ($color=0);
		if ($shelflist->{$element}->{'category'} eq 2) {
		$line{'color'}= $color;
		$line{'shelf'}=$element;
		$line{'shelfname'}=$shelflist->{$element}->{'shelfname'};
		$line{"category".$shelflist->{$element}->{'category'}} = 1;
		$line{'mine'} = 1 if $shelflist->{$element}->{'owner'} eq $loggedinuser;
		$line{'shelfbookcount'}=$shelflist->{$element}->{'count'};
		$line{'canmanage'} = ShelfPossibleAction($loggedinuser,$element,'manage');
		$line{'firstname'}=$shelflist->{$element}->{'firstname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
		$line{'surname'}=$shelflist->{$element}->{'surname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
		
		push (@shelvesloop, \%line);
		} elsif ($shelflist->{$element}->{'category'} eq 1) {
		$linepriv{'color'}= $color;
                $linepriv{'shelf'}=$element;
                $linepriv{'shelfname'}=$shelflist->{$element}->{'shelfname'};
                $linepriv{"category".$shelflist->{$element}->{'category'}} = 1;
                $linepriv{'mine'} = 1 if $shelflist->{$element}->{'owner'} eq $loggedinuser;
                $linepriv{'shelfbookcount'}=$shelflist->{$element}->{'count'};
                $linepriv{'canmanage'} = ShelfPossibleAction($loggedinuser,$element,'manage');
                $linepriv{'firstname'}=$shelflist->{$element}->{'firstname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
                $linepriv{'surname'}=$shelflist->{$element}->{'surname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
		push (@shelveslooppriv, \%linepriv);
		}
}

$template->param(
	shelveslooppriv => \@shelveslooppriv,
    shelvesloop             => \@shelvesloop,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
);

output_html_with_http_headers $query, $cookie, $template->output;



#
# Revision 1.12  2007/04/24 13:54:29  hdl
# functions that were in C4::Interface::CGI::Output are now in C4::Output.
# So this implies quite a change for files.
# Sorry about conflicts which will be caused.
# directory Interface::CGI should now be dropped.
# I noticed that many scripts (reports ones, but also some circ/stats.pl or opac-topissues) still use Date::Manip.
#
# Revision 1.11  2007/04/17 08:52:19  tipaul
# circulation cleaning continued: bufixing
#
# Revision 1.10  2007/04/04 16:46:23  tipaul
# HUGE COMMIT : code cleaning circulation.
#
# some stuff to do, i'll write a mail on koha-devel NOW !
#
# Revision 1.9  2007/03/09 15:12:54  tipaul
# rel_3_0 moved to HEAD
#
# Revision 1.8.2.12  2007/01/15 17:19:30  toins
# enable to add checked items to a shelf.
# Some display enhancements.
#
# Revision 1.8.2.11  2007/01/10 10:52:58  toins
# adding syspref directly to Auth.pm instead of to the template.
#
# Revision 1.8.2.10  2007/01/10 10:12:48  toins
# Adding OpacTopissue, OpacCloud, OpacAuthorithies to the template->param.
# + Some cleanup.
#
# Revision 1.8.2.9  2006/12/15 17:43:24  toins
# sync with intranet.
#
# Revision 1.8.2.8  2006/12/14 17:59:17  toins
# add the link to "BiblioDefaultView systempref" and not to opac-detail.pl
#
# Revision 1.8.2.7  2006/12/14 17:22:55  toins
# virtualshelves work perfectly with mod_perl and are cleaned.
#
# Revision 1.8.2.6  2006/12/14 16:04:25  toins
# sync with intranet.
#
# Revision 1.8.2.5  2006/12/11 17:10:06  toins
# fixing some bugs on virtualshelves.
#
# Revision 1.8.2.4  2006/12/07 15:42:15  toins
# synching opac & intranet.
# fix some broken link & bugs.
# removing warn compilation.
#
# Revision 1.8.2.3  2006/11/30 18:23:51  toins
# theses scripts don't need to use C4::Search.
#
