#!/usr/bin/perl
#
# Copyright 2008-2010 Foundations Bible College
# Parts copyright 2012 C & P Bibliography Services
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

package C4::Barcodes::ValueBuilder::incremental;
use C4::Context;
my $DEBUG = 0;

sub get_barcode {
    my ($args) = @_;
    my $nextnum;
    # not the best, two catalogers could add the same barcode easily this way :/
    my $query = "select max(abs(barcode)) from items";
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute();
    while (my ($count)= $sth->fetchrow_array) {
        $nextnum = $count;
    }
    $nextnum++;
    return $nextnum;
}

1;

package C4::Barcodes::ValueBuilder::hbyymmincr;
use C4::Context;
my $DEBUG = 0;

sub get_barcode {
    my ($args) = @_;
    my $nextnum = 0;
    my $year = substr($args->{year}, -2);
    my $month = $args->{mon};
    my $query = "SELECT MAX(CAST(SUBSTRING(barcode,-4) AS signed)) AS number FROM items WHERE barcode REGEXP ?";
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute("^[-a-zA-Z]{1,}$year$month");
    while (my ($count)= $sth->fetchrow_array) {
        $nextnum = $count if $count;
        $nextnum = 0 if $nextnum == 9999; # this sequence only allows for cataloging 9999 items per month
            warn "Existing incremental number = $nextnum" if $DEBUG;
    }
    $nextnum++;
    $nextnum = sprintf("%0*d", "4",$nextnum);
    $nextnum = $year . $month . $nextnum;
    warn "New hbyymmincr Barcode = $nextnum" if $DEBUG;
    my $scr = "
        for (i=0 ; i<document.f.field_value.length ; i++) {
            if (document.f.tag[i].value == '$args->{loctag}' && document.f.subfield[i].value == '$args->{locsubfield}') {
                fnum = i;
            }
        }
    if (\$('#' + id).val() == '') {
        \$('#' + id).val(document.f.field_value[fnum].value + '$nextnum');
    }
    ";
    return $nextnum, $scr;
}


package C4::Barcodes::ValueBuilder::annual;
use C4::Context;
my $DEBUG = 0;

sub get_barcode {
    my ($args) = @_;
    my $nextnum;
    my $query = "select max(cast( substring_index(barcode, '-',-1) as signed)) from items where barcode like ?";
    my $sth=C4::Context->dbh->prepare($query);
    $sth->execute("$args->{year}%");
    while (my ($count)= $sth->fetchrow_array) {
        warn "Examining Record: $count" if $DEBUG;
        $nextnum = $count if $count;
    }
    $nextnum++;
    $nextnum = sprintf("%0*d", "4",$nextnum);
    $nextnum = "$args->{year}-$nextnum";
    return $nextnum;
}

1;


=head1 Barcodes::ValueBuilder

This module is intended as a shim to ease the eventual transition from
having all barcode-related code in the value builder plugin .pl file
to using C4::Barcodes. Since the shift will require a rather significant
amount of refactoring, this module will return value builder-formatted
results, at first by merely running the code that was formerly in the
barcodes.pl value builder, but later by using C4::Barcodes.

=cut

1;
