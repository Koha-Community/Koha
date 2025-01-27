package Koha::ILL::Request::SupplierUpdate;

# Copyright 2022 PTFS Europe Ltd
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

=head1 NAME

Koha::ILL::Request::SupplierUpdate - Represents a single request update from a supplier

=head1 SYNOPSIS

Object-oriented class that provides an object allowing us to interact with
an update from a supplier

=head1 DESCRIPTION

Object-oriented class that provides an object allowing us to interact with
an update from a supplier

=head1 API

=head2 Class Methods

=head3 new

    my $update = Koha::ILL::Request::SupplierUpdate->new(
        $source_type,
        $source_name,
        $update
    );

Create a new Koha::ILL::Request::SupplierUpdate object .

=cut

sub new {
    my ( $class, $source_type, $source_name, $update, $request ) = @_;
    my $self = {};

    $self->{source_type} = $source_type;
    $self->{source_name} = $source_name;
    $self->{update}      = $update;
    $self->{request}     = $request;
    $self->{processors}  = [];

    bless $self, $class;

    return $self;
}

=head3 attach_processor

    Koha::ILL::Request::SupplierUpdate->attach_processor($processor);

Pushes a processor function onto the 'processors' arrayref

=cut

sub attach_processor {
    my ( $self, $processor ) = @_;
    push( @{ $self->{processors} }, $processor );
}

=head3 run_processors

    Koha::ILL::Request::SupplierUpdate->run_processors();

Iterates all processors on this object and runs each

=cut

sub run_processors {
    my ( $self, $options ) = @_;
    my $results = [];
    foreach my $processor ( @{ $self->{processors} } ) {
        my $processor_result = {
            name   => $processor->{name},
            result => {
                success => [],
                error   => []
            }
        };
        $processor->run( $self, $options, $processor_result->{result} );
        push @{$results}, $processor_result;
    }
    return $results;
}

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
