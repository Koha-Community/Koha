package C4::Barcodes::hbyymmincr;

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

use Modern::Perl;

use Carp qw( carp );

use C4::Context;

# FIXME We should certainly remove output_pref from here
use Koha::DateUtils qw( dt_from_string output_pref );

use constant WIDTH => 4;    # FIXME: too small for sizeable or multi-branch libraries?

use vars qw(@ISA);

BEGIN {
    @ISA = qw(C4::Barcodes);
}

=head1 Functions

=cut

# Generates barcode where hb = home branch Code, yymm = year/month catalogued, incr = incremental number,
# 	increment resets yearly -fbcit

=head2 db_max

Missing POD for db_max.

=cut

sub db_max {
    my $self  = shift;
    my $width = WIDTH;
    my $query =
        "SELECT SUBSTRING(barcode,-$width) AS chunk, barcode FROM items WHERE barcode REGEXP ? ORDER BY chunk DESC LIMIT 1";
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
    my $year   = substr( $iso, 2, 2 );    # i.e. "08" for 2008
    my $andtwo = $width + 2;
    $sth->execute( "^[a-zA-Z]{1,}" . $year . "[0-9]{$andtwo}" )
        ;    # the extra two digits are the month.  we don't care what they are, just that they are there.
    unless ( $sth->rows ) {
        warn "No existing hbyymmincr barcodes found.  Reverting to initial value.";
        return $self->initial;
    }
    my ($row) = $sth->fetchrow_hashref;
    my $max = $row->{barcode};
    return ( $max || 0 );
}

=head2 initial

Missing POD for initial.

=cut

sub initial {
    my $self = shift;

    # FIXME: populated branch?
    my $iso = output_pref( { dt => dt_from_string, dateformat => 'iso', dateonly => 1 } );    # like "2008-07-02"
    warn "HBYYMM Barcode was not passed a branch, default is blank" if ( $self->branch eq '' );
    my $width = WIDTH;
    return $self->branch . substr( $iso, 2, 2 ) . substr( $iso, 5, 2 ) . sprintf( '%' . "$width.$width" . 'd', 1 );
}

=head2 parse

Missing POD for parse.

=cut

sub parse {    # return 3 parts of barcode: non-incrementing, incrementing, non-incrementing
    my $self    = shift;
    my $barcode = (@_) ? shift : $self->value;
    my $branch  = $self->branch;
    unless ( $barcode =~ /($branch\d{4})(\d+)$/ ) {
        carp "Barcode '$barcode' has no incrementing part!";
        return ( $barcode, undef, undef );
    }
    return ( $1, $2, '' );    # the third part is in anticipation of barcodes that include checkdigits
}

=head2 branch

Missing POD for branch.

=cut

sub branch {
    my $self = shift;
    (@_) and $self->{branch} = shift;
    return $self->{branch};
}

# Commented out (BZ 16635)
#sub width {
#    my $self = shift;
#    (@_) and $width = shift;  # hitting the class variable.
#    return $width;
#}

=head2 process_head

Missing POD for process_head.

=cut

sub process_head {    # (self,head,whole,specific)
    my ( $self, $head, $whole, $specific ) = @_;
    $specific and return $head;    # if this is built off an existing barcode, just return the head unchanged.
    $head =~ s/\d{4}$//;           # else strip the old yymm
    my $iso = output_pref( { dt => dt_from_string, dateformat => 'iso', dateonly => 1 } );    # like "2008-07-02"
    return $head . substr( $iso, 2, 2 ) . substr( $iso, 5, 2 );
}

=head2 new_object

Missing POD for new_object.

=cut

sub new_object {
    my $class_or_object = shift;

    my $type = ref($class_or_object) || $class_or_object;

    my $from_obj =
        ref($class_or_object)
        ? 1
        : 0;    # are we building off another Barcodes object?

    my $self = $class_or_object->default_self('hbyymmincr');
    bless $self, $type;

    $self->branch( @_ ? shift : $from_obj ? $class_or_object->branch : '' );
    warn "HBYYMM Barcode created with no branchcode, default is blank" if ( $self->branch() eq '' );

    return $self;
}

1;
__END__

=head1 NOTICE 

This format is deprecated and SHOULD NOT BE USED.

It is fairly clear the originator of the format did not intend to accommodate
multiple branch libraries, given that the format caps the available namespace to
10,000 barcodes per year TOTAL.  

Also, the question of what to do with an item that changes branch is unsettled.  
Nothing prevents the barcode from working fine, but it will look out of place
with the old branchcode in it.  Rebarcoding a single item is trivial, but if you
consider the scenario of branches being consolidated, it is an unnecessary 
burden to force the rebarcoding of thousands of items, especially when the format
will limit you to under 10,000 on the year!

The main purpose of the format seems to be to get the branch code into the barcode.
This is wholly unnecessary, since the barcodes can be printed with the branchcode
directly on it, without it being part of the barcode itself.  

The API for this module should exist almost exclusively through C4::Barcodes.  
One novel aspect of this format is the fact that the barcode is tied to a branch.  

=cut
