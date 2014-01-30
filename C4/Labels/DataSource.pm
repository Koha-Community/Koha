package C4::Labels::DataSource;
# Copyright 2015 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use DateTime;
use Class::Inspector;
use Encode;

use Koha::ItemTypes;

=head SYNOPSIS

Define subroutines that process label printer source data into meaningful
printable components here.

All subroutines here starting with public_*
are exposed to the user as selectable Data Source functions.
This is to avoid namespace polluting modules like PDF::Reuse from exposing unintended data sources to the user.

All subroutines get the following parameters for the given item:
@PARAM1 HASHRef of database tables,
        {    biblio      => koha.biblio.*,
             biblioitem  => koha.biblioitems.*,
             item        => koha.items.*,
             homebranch  => koha.branches.*,
        }
@PARAM2 MARC::Record
@PARAM3 C4::Labels::Sheet::Element
@PARAM4 ARRAYRef of dataSourceFunction's parameters

Define the subroutine documentation in intranet-tmpl/prog/en/includes/labels/data-source-function-documentation.inc

=cut

sub public_location {
    my ($params) = @_;
    my $item = $params->[0]->{item};
    my $locCode = $item->{permanent_location} || $item->{location};
    return '' if(not($locCode));

    my $av = C4::Koha::GetAuthorisedValueByCode('LOC', $locCode);
    return $av;
}

sub public_signum {
    my ($params) = @_;
    my $record = $params->[1];

    #Get the proper SIGNUM (important) Use one of the Main Entries or the Title Statement
    my $leader = $record->leader(); #If this is a video, we calculate the signum differently, 06 = 'g'
    my $signumSource; #One of fields 100, 110, 111, 130, or 245 if 1XX is missing
    my $nonFillingCharacters = 0;

    if ($signumSource = $record->subfield('100', 'a')) {

    }
    elsif ($signumSource = $record->subfield('110', 'a')) {

    }
    elsif ($signumSource = $record->subfield('111', 'a')) {

    }
    elsif (substr($leader,6,1) eq 'g' && ($signumSource = $record->subfield('245', 'a'))) {
        $nonFillingCharacters = $record->field('245')->indicator(2);
    }
    elsif ($signumSource = $record->subfield('130', 'a')) {
        $nonFillingCharacters = $record->field('130')->indicator(1);
        $nonFillingCharacters = 0 if (not(defined($nonFillingCharacters)) || $nonFillingCharacters eq ' ');
    }
    elsif ($signumSource = $record->subfield('245', 'a')) {
        $nonFillingCharacters = $record->field('245')->indicator(2);
    }
    if ($signumSource) {
        return uc(substr($signumSource, $nonFillingCharacters, 3));
    }

    return undef;
}

sub public_signumVaara {
    my ($params) = @_;
    my $item = $params->[0]->{item};

    my $itemcallnumber = $item->{itemcallnumber}; #PKM 84.4 MAG
    my @parts = split(/\s+/, $itemcallnumber);
    return ($parts[2]) ? $parts[2] : undef;
}

sub public_title {
    my ($params) = @_;
    my $record = $params->[1];

    my $title = '';
    if (my $f245 = $record->field('245')) {
        my $sfA = $f245->subfield('a');
        my $sfB = $f245->subfield('b');
        my $sfN = $f245->subfield('n');
        my $sfP = $f245->subfield('p');

        $title .= $sfA if $sfA;
        $title .= $sfB if $sfB;
        $title .= $sfN if $sfN;
        $title .= $sfP if $sfP;
        $title = 'no subfields in $245' unless $title;
    }
    elsif (my $f111 = $record->field('111')) {
        my $sfA = $f111->subfield('a');
        $title = $sfA;
    }
    elsif (my $f130 = $record->field('130')) {
        my $sfA = $f130->subfield('a');
        $title = $sfA;
    }
    return $title;
}

#Build the content_description out of $300a,e
sub public_contentDescription {
    my ($params) = @_;
    my $record = $params->[1];

    my $contentDescription = '';
    if (my $f300 = $record->field('300')) {

        my @sfA = $f300->subfield('a');
        my $sfE = $f300->subfield('e');

        if (@sfA) {
            $contentDescription .= "@sfA";
        }
        if (@sfA && $sfE) {
            $contentDescription .= ' ';
        }
        if ($sfE) {
            $contentDescription .= $sfE;
        }
    }
    return $contentDescription;
}

sub public_itemtype {
    my ($params) = @_;
    my $item = $params->[0]->{item};
    my $it = Koha::ItemTypes->find($item->{itype});
    if (Encode::is_utf8($it->{description})) {
        return $it->{description};
    }
    else {
        return Encode::decode('UTF-8', $it->{description});
    }
}

sub public_oplibLabel {
    my ($params) = @_;
    my $item = $params->[0]->{item};

    my $locationCode = $item->{permanent_location} if $item->{permanent_location};
    $locationCode = $item->{location} if !$item->{permanent_location};
    return $locationCode;
}

sub public_yklVaara {
    my ($params) = @_;
    my $item = $params->[0]->{item};

    my $itemcallnumber = $item->{itemcallnumber}; #PKM 84.4 MAG
    my @parts = split(/\s+/, $itemcallnumber);
    return ($parts[1]) ? $parts[1] : undef;
}

sub public_yklKyyti {
    my ($params) = @_;
    my $item = $params->[0]->{item};

    my $itemcallnumber = $item->{itemcallnumber}; #84.2 SLO PK N
    my @parts = split(/\s+/, $itemcallnumber);
    return ($parts[0]) ? $parts[0] : undef;
}

1;