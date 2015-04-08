#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
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
#use warnings; FIXME - Bug 2505
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
my $op          = $input->param('op');
$searchfield =~ s/\,//g;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/itemtypes.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
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

my $sip_media_type = $input->param('sip_media_type');
undef($sip_media_type) if defined($sip_media_type) and $sip_media_type =~ /^\s*$/;

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
        rentalcharge    => sprintf( "%.2f", $data->{'rentalcharge'} ),
        notforloan      => $data->{'notforloan'},
        imageurl        => $data->{'imageurl'},
        template        => C4::Context->preference('template'),
        summary         => $data->{summary},
        checkinmsg      => $data->{'checkinmsg'},
        checkinmsgtype  => $data->{'checkinmsgtype'},
        imagesets       => $imagesets,
        remote_image    => $remote_image,
        sip_media_type  => $data->{sip_media_type},
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
                 , rentalcharge = ?
                 , notforloan = ?
                 , imageurl = ?
                 , summary = ?
                 , checkinmsg = ?
                 , checkinmsgtype = ?
                 , sip_media_type = ?
            WHERE itemtype = ?
        ';
        $sth = $dbh->prepare($query2);
        $sth->execute(
            $input->param('description'),
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
            $input->param('checkinmsg'),
            $input->param('checkinmsgtype'),
            $sip_media_type,
            $input->param('itemtype')
        );
    }
    else {    # add a new itemtype & not modif an old
        my $query = "
            INSERT INTO itemtypes
                (itemtype,description,rentalcharge, notforloan, imageurl, summary, checkinmsg, checkinmsgtype, sip_media_type)
            VALUES
                (?,?,?,?,?,?,?,?,?);
            ";
        my $sth = $dbh->prepare($query);
		my $image = $input->param('image');
        $sth->execute(
            $input->param('itemtype'),
            $input->param('description'),
            $input->param('rentalcharge'),
            $input->param('notforloan') ? 1 : 0,
            $image eq 'removeImage' ?           ''                 :
            $image eq 'remoteImage' ? $input->param('remoteImage') :
            $image,
            $input->param('summary'),
            $input->param('checkinmsg'),
            $input->param('checkinmsgtype'),
            $sip_media_type,
        );
    }

    print $input->redirect('itemtypes.pl');
    exit;

    # END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
    # called by default form, used to confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirm' ) {
    # Check both items and biblioitems
    my $sth = $dbh->prepare('
        SELECT COUNT(*) AS total FROM (
            SELECT itemtype AS t FROM biblioitems
            UNION ALL
            SELECT itype AS t FROM items
        ) AS tmp
        WHERE tmp.t=?
    ');
    $sth->execute($itemtype);
    my $total = $sth->fetchrow_hashref->{'total'};

    my $sth =
      $dbh->prepare(
"select itemtype,description,rentalcharge from itemtypes where itemtype=?"
      );
    $sth->execute($itemtype);
    my $data = $sth->fetchrow_hashref;
    $template->param(
        itemtype        => $itemtype,
        description     => $data->{description},
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
    my @loop;
    foreach my $itemtype ( @{$results} ) {
        $itemtype->{imageurl} = getitemtypeimagelocation( 'intranet', $itemtype->{imageurl} );
        $itemtype->{rentalcharge} = sprintf( '%.2f', $itemtype->{rentalcharge} );
        push( @loop, $itemtype );
    }

    $template->param(
        loop           => \@loop,
    );
}    #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;
