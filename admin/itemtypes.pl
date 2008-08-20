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

=head1 admin/itemtypes.pl

script to administer the categories table
written 20/02/2002 by paul.poulain@free.fr
 This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

 ALGO :
 this script use an $op to know what to do.
 if $op is empty or none of the above values,
	- the default screen is build (with all records, or filtered datas).
	- the   user can clic on add, modify or delete record.
 if $op=add_form
	- if primkey exists, this is a modification,so we read the $primkey record
	- builds the add/modify form
 if $op=add_validate
	- the user has just send datas, so we create/modify the record
 if $op=delete_form
	- we show the record having primkey=$primkey and ask for deletion validation form
 if $op=delete_confirm
	- we delete the record having primkey=$primkey

=cut

use strict;
use CGI;

use List::Util qw/min/;
use File::Spec;

use C4::Koha;
use C4::Context;
use C4::Auth;
use C4::Output;

sub StringSearch {
    my ( $searchstring, $type ) = @_;
    my $dbh = C4::Context->dbh;
    $searchstring =~ s/\'/\\\'/g;
    my @data = split( ' ', $searchstring );
    my $sth = $dbh->prepare(
        "SELECT * FROM itemtypes WHERE (description LIKE ?) ORDER BY itemtype"
	);
    $sth->execute("$data[0]%");
    return $sth->fetchall_arrayref({});		# return ref-to-array of ref-to-hashes
								# like [ fetchrow_hashref(), fetchrow_hashref() ... ]
}

my $input       = new CGI;
my $searchfield = $input->param('description');
my $script_name = "/cgi-bin/koha/admin/itemtypes.pl";
my $itemtype    = $input->param('itemtype');
my $pagesize    = 10;
my $op          = $input->param('op');
$searchfield =~ s/\,//g;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/itemtypes.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 1 },
        debug           => 1,
    }
);

$template->param(script_name => $script_name);
if ($op) {
	$template->param($op  => 1); # we show only the TMPL_VAR names $op
} else {
    $template->param(else => 1);
}

my $dbh = C4::Context->dbh;

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {
    #---- if primkey exists, it's a modify action, so read values to modify...
    my $data;
    if ($itemtype) {
        my $sth = $dbh->prepare("select * from itemtypes where itemtype=?");
        $sth->execute($itemtype);
        $data = $sth->fetchrow_hashref;
    }

    my $imagesets = C4::Koha::getImageSets( checked => $data->{'imageurl'} );

    my $remote_image = undef;
    if ( defined $data->{imageurl} and $data->{imageurl} =~ /^http/i ) {
        $remote_image = $data->{imageurl};
    }

    $template->param(
        itemtype        => $itemtype,
        description     => $data->{'description'},
        renewalsallowed => $data->{'renewalsallowed'},
        rentalcharge    => sprintf( "%.2f", $data->{'rentalcharge'} ),
        notforloan      => $data->{'notforloan'},
        imageurl        => $data->{'imageurl'},
        template        => C4::Context->preference('template'),
        summary         => $data->{summary},
        imagesets       => $imagesets,
        remote_image    => $remote_image,
    );

    # END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
    # called by add_form, used to insert/modify data in DB
}
elsif ( $op eq 'add_validate' ) {
    my $query = "
        SELECT itemtype
        FROM   itemtypes
        WHERE  itemtype = ?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($itemtype);
    if ( $sth->fetchrow ) {		# it's a modification
        my $query2 = '
            UPDATE itemtypes
            SET    description = ?
                 , renewalsallowed = ?
                 , rentalcharge = ?
                 , notforloan = ?
                 , imageurl = ?
                 , summary = ?
            WHERE itemtype = ?
        ';
        $sth = $dbh->prepare($query2);
        $sth->execute(
            $input->param('description'),
            $input->param('renewalsallowed'),
            $input->param('rentalcharge'),
            ( $input->param('notforloan') ? 1 : 0 ),
            (
                $input->param('image') eq 'removeImage' ? '' : (
                      $input->param('image') eq 'remoteImage'
                    ? $input->param('remoteImage')
                    : $input->param('image') . ""
                )
            ),
            $input->param('summary'),
            $input->param('itemtype')
        );
    }
    else {    # add a new itemtype & not modif an old
        my $query = "
            INSERT INTO itemtypes
                (itemtype,description,renewalsallowed,rentalcharge, notforloan, imageurl,summary)
            VALUES
                (?,?,?,?,?,?,?);
            ";
        my $sth = $dbh->prepare($query);
		my $image = $input->param('image');
        $sth->execute(
            $input->param('itemtype'),
            $input->param('description'),
            $input->param('renewalsallowed'),
            $input->param('rentalcharge'),
            $input->param('notforloan') ? 1 : 0,
            $image eq 'removeImage' ?           ''                 :
            $image eq 'remoteImage' ? $input->param('remoteImage') :
            $image,
            $input->param('summary'),
        );
    }

    print $input->redirect('itemtypes.pl');
    exit;

    # END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
    # called by default form, used to confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirm' ) {
    # Check both categoryitem and biblioitems, see Bug 199
    my $total = 0;
    for my $table ('biblioitems') {
        my $sth =
          $dbh->prepare(
            "select count(*) as total from $table where itemtype=?");
        $sth->execute($itemtype);
        $total += $sth->fetchrow_hashref->{total};
    }

    my $sth =
      $dbh->prepare(
"select itemtype,description,renewalsallowed,rentalcharge from itemtypes where itemtype=?"
      );
    $sth->execute($itemtype);
    my $data = $sth->fetchrow_hashref;
    $template->param(
        itemtype        => $itemtype,
        description     => $data->{description},
        renewalsallowed => $data->{renewalsallowed},
        rentalcharge    => sprintf( "%.2f", $data->{rentalcharge} ),
        imageurl        => $data->{imageurl},
        total           => $total
    );

    # END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
  # called by delete_confirm, used to effectively confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirmed' ) {
    my $itemtype = uc( $input->param('itemtype') );
    my $sth      = $dbh->prepare("delete from itemtypes where itemtype=?");
    $sth->execute($itemtype);
    $sth = $dbh->prepare("delete from issuingrules where itemtype=?");
    $sth->execute($itemtype);
    print $input->redirect('itemtypes.pl');
    exit;
    # END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
}
else {    # DEFAULT
    my ($results) = StringSearch( $searchfield, 'web' );
    my $page = $input->param('page') || 1;
    my $first = ( $page - 1 ) * $pagesize;

    # if we are on the last page, the number of the last word to display
    # must not exceed the length of the results array
    my $last = min( $first + $pagesize - 1, scalar @{$results} - 1, );
    my $toggle = 0;
    my @loop;
    foreach my $itemtype ( @{$results}[ $first .. $last ] ) {
        $itemtype->{toggle} = ($toggle++ % 2) ? 0 : 1 ;
        $itemtype->{imageurl} = getitemtypeimagelocation( 'intranet', $itemtype->{imageurl} );
        $itemtype->{rentalcharge} = sprintf( '%.2f', $itemtype->{rentalcharge} );
        push( @loop, $itemtype );
    }

    $template->param(
        loop           => \@loop,
        pagination_bar => pagination_bar(
            $script_name, getnbpages( scalar @{$results}, $pagesize ),
            $page,        'page'
        )
    );
}    #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;
