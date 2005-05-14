#!/usr/bin/perl -w

# $Id$

# Copyright 2005 Katipo Communications
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

use strict;
use lib '/usr/local/koha/intranet/modules';
use Curses::UI;
use C4::Circulation::Circ2;
use C4::Search;

my $cui = new Curses::UI( -color_support => 1 );

my @menu = (
    {
        -label   => 'File',
        -submenu => [
            { -label => 'Issues   ^I', -value => \&issues },
            { -label => 'Returns  ^R', -value => \&returns },
            { -label => 'Exit     ^Q', -value => \&exit_dialog }
        ]
    },
);

my $menu = $cui->add(
    'menu', 'Menubar',
    -menu => \@menu,
    -fg   => "blue",
);

my $win1 = $cui->add(
    'win1', 'Window',
    -border => 1,
    -y      => 1,
    -bfg    => 'red',
    -width  => 40,
);

my $win2 = $cui->add(
    'win2', 'Window',
    -border => 1,
    -y      => 1,
    -x      => 40,
    -height => 10,
    -bfg    => 'red',
);

my $win3 = $cui->add(
    'win3', 'Window',
    -border => 1,
    -y      => 11,
    -x      => 40,
    -height => 10,
    -bfg    => 'red',
);

my $texteditor =
  $win1->add( "text", "TextEditor",
    -text => "Here is some text\n" . "And some more" );

$cui->set_binding( sub { $menu->focus() }, "\cX" );
$cui->set_binding( \&exit_dialog, "\cQ" );
$cui->set_binding( \&issues,      "\cI" );
$cui->set_binding( \&returns,     "\cR" );

$texteditor->focus();
$cui->mainloop();

sub exit_dialog() {
    my $return = $cui->dialog(
        -message => "Do you really want to quit?",
        -title   => "Are you sure???",
        -buttons => [ 'yes', 'no' ],

    );

    exit(0) if $return;
}

sub returns {
    my $barcode = $cui->question(
        -title    => 'Returns',
        -question => 'Barcode'
    );
    my $branch = 'MAIN';
    my %env;
    if ($barcode) {
        my ( $returned, $messages, $iteminformation, $borrower ) =
          returnbook( $barcode, $branch );
        if ( $borrower && $borrower->{'borrowernumber'} ) {
            $borrower =
              getpatroninformation( \%env, $borrower->{'borrowernumber'}, 0 );
            $win1->delete('borrowerdata');
            my $borrowerdata = $win1->add( 'borrowerdata', 'TextViewer',
                -text => "Cardnumber: $borrower->{'cardnumber'}\n"
                  . "Name: $borrower->{'title'} $borrower->{'firstname'} $borrower->{'surname'}"
            );

            $borrowerdata->focus();
        }
        else {
            $cui->error( -message => 'That item isnt on loan' );
        }
    }
}

sub issues {

    # this routine does the actual issuing

    my %env;
    my $borrowernumber;
    my $borrowerlist;

   # the librarian can overide system issue date, need to fetch values from them
    my $year;
    my $month;
    my $day;
    my $datedue;

    $win1->delete('text');

    # get a cardnumber or a name
    my $cardnumber = $cui->question(
        -title    => 'Issues',
        -question => 'Cardnumber'
    );

    # search for that borrower
    my ( $count, $borrowers ) =
      BornameSearch( \%env, $cardnumber, 'cardnumber', 'web' );
    my @borrowers = @$borrowers;
    if ( $#borrowers == -1 ) {
        $cui->error( -message =>
              'No borrowers match that name or cardnumber please try again.' );
    }
    elsif ( $#borrowers == 0 ) {
        $borrowernumber = $borrowers[0]->{'borrowernumber'};
    }
    else {
        $borrowerlist = \@borrowers;
    }

    if ($borrowernumber) {

        # if we have one single borrower, we can start issuing
        my $borrower = getpatroninformation( \%env, $borrowernumber, 0 );
        $win1->delete('borrowerdata');
        my $borrowerdata = $win1->add( 'borrowerdata', 'TextViewer',
            -text => "Cardnumber: $borrower->{'cardnumber'}\n"
              . "Name: $borrower->{'title'} $borrower->{'firstname'} $borrower->{'surname'}"
        );

        $borrowerdata->focus();

        $win3->delete('pastissues');
        my $issueslist = getissues($borrower);
        my $oldissues;
        foreach my $it ( keys %$issueslist ) {
            $oldissues .=
              $issueslist->{$it}->{'barcode'}
              . " $issueslist->{$it}->{'title'} $issueslist->{$it}->{'date_due'}\n";

        }

        my $pastissues =
          $win3->add( 'pastissues', 'TextViewer', -text => $oldissues, );
        $pastissues->focus();

        $win2->delete('currentissues');
        my $currentissues =
          $win2->add( 'currentissues', 'TextViewer',
            -text => "Todays issues go here", );
        $currentissues->focus();

        # go into a loop issuing until a blank barcode is given
        while ( my $barcode = $cui->question( -question => 'Barcode' ) ) {
            my $issueconfirmed;
            my ( $error, $question ) =
              canbookbeissued( \%env, $borrower, $barcode, $year, $month,
                $day );
            my $noerror    = 1;
            my $noquestion = 1;
            foreach my $impossible ( keys %$error ) {
                $cui->error( -message => $impossible );
                $noerror = 0;
            }

            foreach my $needsconfirmation ( keys %$question ) {
                $noquestion     = 0;
                $issueconfirmed = $cui->dialog(
                    -message => $needsconfirmation,
                    -title   => "Confirmation",
                    -buttons => [ 'yes', 'no' ],

                );

            }
            if ( $noerror && ( $noquestion || $issueconfirmed ) ) {
                issuebook( \%env, $borrower, $barcode, $datedue );
            }

        }

    }
    elsif ($borrowerlist) {
        my $listbox = $win1->add(
            'mylistbox',
            'Listbox',
            -values => [ 1, 2, 3 ],
            -labels => {
                1 => 'One',
                2 => 'Two',
                3 => 'Three'
            },
            -radio => 1,
        );

        $listbox->focus();
        my $selected = $listbox->get();
    }
    else {
    }
}
