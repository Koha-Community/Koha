package C4::Contract;

# Copyright 2009-2010 BibLibre SARL
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
#use warnings; FIXME - Bug 2505
use C4::SQLHelper qw(:all);

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&GetContract
		&AddContract
		&ModContract
		&DelContract
	);
}

=head1 NAME

C4::Contract - Koha functions for dealing with bookseller contracts.

=head1 SYNOPSIS

use C4::Contract;

=head1 DESCRIPTION

The functions in this module deal with contracts. They allow to
add a new contract, to modify it or to get some informations around
a contract.

This module is just a wrapper for C4::SQLHelper functions, so take a look at
SQLHelper centralised documentation to know how to use the following subs.

=cut

sub GetContract { SearchInTable("aqcontract", shift); }

sub AddContract { InsertInTable("aqcontract", shift); }

sub ModContract { UpdateInTable("aqcontract", shift); }

sub DelContract { DeleteInTable("aqcontract", shift); }

1;

__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
