package C4::Circulation::Date;

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

# $id:$

use strict;
use C4::Context;

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = do { my @v = '$Revision$' =~ /\d+/g;
    shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v );
};

@ISA = qw(Exporter);

@EXPORT = qw(
  &display_date_format
  &format_date
  &format_date_in_iso
);

=head1 DESCRIPTION

C4::Circulation::Date provides routines for format dates to display in human readable forms.

=head1 FUNCTIONS

=over 2

=cut

=head2 get_date_format

  $dateformat = get_date_format();

Takes no input, and returns the format that the library prefers dates displayed in


=cut

sub get_date_format {

    # Get the database handle
    my $dbh = C4::Context->dbh;
    return C4::Context->preference('dateformat');
}

=head2 display_date_format

  $displaydateformat = display_date_format();

Takes no input, and returns a string showing the format the library likes dates displayed in


=cut

sub display_date_format {
    my $dateformat = get_date_format();

    if ( $dateformat eq "us" ) {
        return "mm/dd/yyyy";
    }
    elsif ( $dateformat eq "metric" ) {
        return "dd/mm/yyyy";
    }
    elsif ( $dateformat eq "iso" ) {
        return "yyyy-mm-dd";
    }
    else {
        return
"Invalid date format: $dateformat. Please change in system preferences";
    }
}

=head2 format_date

  $formatteddate = format_date($date);

Takes a date, from mysql and returns it in the format specified by the library
This is less flexible than C4::Date::format_date, which can handle dates of many formats 
if you need that flexibility use C4::Date, if you are just using it to format the output from mysql as
in circulation.pl use this one, it is much faster.
=cut


sub format_date {
    my $olddate = shift;
    my $newdate;

    if ( !$olddate ) {
        return "";
    }

    my $dateformat = get_date_format();

    if ( $dateformat eq "us" ) {
    my @datearray=split('-',$olddate);
    $newdate = "$datearray[1]/$datearray[2]/$datearray[0]";
    }
    elsif ( $dateformat eq "metric" ) {
    my @datearray=split('-',$olddate);
    $newdate = "$datearray[2]/$datearray[1]/$datearray[0]";
    }
    elsif ( $dateformat eq "iso" ) {
        $newdate = $olddate;
    }
    else {
        return
"Invalid date format: $dateformat. Please change in system preferences";
    }
}

1;
