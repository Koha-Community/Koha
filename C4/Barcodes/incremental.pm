#!/usr/bin/perl

package C4::Barcodes::incremental;

# Copyright 2008 LibLime
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
use warnings;

use vars qw($VERSION @ISA);

BEGIN {
    $VERSION = 0.01;
    @ISA = qw(C4::Barcodes);
}

1;
__END__

=doc

Since incremental is the default in C4::Barcodes, we do not override anything here.
In fact, this file is more of a place holder.

=cut

