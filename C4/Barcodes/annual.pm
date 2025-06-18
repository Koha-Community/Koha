package C4::Barcodes::annual;

# Copyright 2008 LibLime
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;

use Carp qw( carp );

use C4::Context;

# FIXME We should certainly remove output_pref from here
use Koha::DateUtils qw( dt_from_string output_pref );

use vars qw(@ISA);
use vars qw($width);

BEGIN {
    @ISA   = qw(C4::Barcodes);
    $width = 4;
}

sub db_max {
    my $self = shift;
    my $query =
        "SELECT substring_index(barcode,'-',-1) AS chunk,barcode FROM items WHERE barcode LIKE ? ORDER BY chunk DESC LIMIT 1";

    # FIXME: unreasonably expensive query on large datasets (I think removal of group by does this?)
    my $sth = C4::Context->dbh->prepare($query);
    my ($iso);
    if (@_) {
        my $input = shift;
        $iso = output_pref( { dt => dt_from_string( $input, 'iso' ), dateformat => 'iso', dateonly => 1 } )
            ;    # try to set the date w/ 2nd arg
        unless ($iso) {
            warn "Failed to create 'iso' Dates object with input '$input'.  Reverting to today's date.";
            $iso = output_pref( { dt => dt_from_string, dateformat => 'iso', dateonly => 1 } ); # failover back to today
        }
    } else {
        $iso = output_pref( { dt => dt_from_string, dateformat => 'iso', dateonly => 1 } );
    }
    my $year = substr( $iso, 0, 4 );    # YYYY
    $sth->execute("$year-%");
    my $row = $sth->fetchrow_hashref;
    return $row->{barcode};
}

sub initial () {
    my $self = shift;
    return
        substr( output_pref( { dt => dt_from_string, dateformat => 'iso', dateonly => 1 } ), 0, 4 ) . '-'
        . sprintf( '%' . "$width.$width" . 'd', 1 );
}

sub parse {
    my $self    = shift;
    my $barcode = (@_) ? shift : $self->value;
    unless ( $barcode =~ /(\d{4}-)(\d+)$/ ) {    # non-greedy match in first part
        carp "Barcode '$barcode' has no incrementing part!";
        return ( $barcode, undef, undef );
    }
    return ( $1, $2, '' );    # the third part is in anticipation of barcodes that include checkdigits
}

sub width {
    my $self = shift;
    (@_) and $width = shift;    # hitting the class variable.
    return $width;
}

sub process_head {
    my ( $self, $head, $whole, $specific ) = @_;
    $specific and return $head;    # if this is built off an existing barcode, just return the head unchanged.
    return
        substr( output_pref( { dt => dt_from_string, dateformat => 'iso', dateonly => 1 } ), 0, 4 )
        . '-';                     # else get new YYYY-
}

sub new_object {
    my $class = shift;
    my $type  = ref($class) || $class;
    my $self  = $type->default_self('annual');
    return bless $self, $type;
}

1;
__END__

