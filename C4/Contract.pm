package C4::Contract;

# Copyright 2009-2010 BibLibre SARL
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

use Modern::Perl;
use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
use Koha::Database;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
        &GetContracts
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

=cut


=head2 GetContracts

$contractlist = GetContracts({
    booksellerid => $booksellerid,
    activeonly => $activeonly
});

Looks up the contracts that belong to a bookseller

Returns a list of contracts

=over

=item C<$booksellerid> is the "id" field in the "aqbooksellers" table.

=item C<$activeonly> if exists get only contracts that are still active.

=back

=cut

sub GetContracts {
    my ($filters) = @_;
    if( $filters->{activeonly} ) {
        $filters->{contractenddate} = {'>=' => \'now()'};
        delete $filters->{activeonly};
    }

    my $rs = Koha::Database->new()->schema->resultset('Aqcontract');
    $rs = $rs->search($filters);
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    return [ $rs->all ];
}

=head2 GetContract

$contract = GetContract( { contractnumber => $contractnumber } );

Looks up the contract that has PRIMKEY (contractnumber) value $contractID

Returns a contract

=cut

sub GetContract {
    my ($params) = @_;
    my $contractnumber = $params->{contractnumber};

    return unless $contractnumber;

    my $contracts = GetContracts({
        contractnumber => $contractnumber,
    });
    return $contracts->[0];
}

sub AddContract {
    my ($contract) = @_;
    return unless($contract->{booksellerid});

    my $rs = Koha::Database->new()->schema->resultset('Aqcontract');
    return $rs->create($contract)->id;
}

sub ModContract {
    my ($contract) = @_;
    my $result = Koha::Database->new()->schema->resultset('Aqcontract')->find($contract);
    return unless($result);

    $result = $result->update($contract);
    return $result->in_storage;
}

sub DelContract {
    my ($contract) = @_;
    return unless($contract->{contractnumber});

    my $result = Koha::Database->new()->schema->resultset('Aqcontract')->find($contract);
    return unless($result);

    eval { $result->delete };
    return !( $result->in_storage );
}

1;

__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
