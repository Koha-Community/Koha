package Koha::ILL::Request::SupplierUpdateProcessor;

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

Koha::ILL::Request::SupplierUpdateProcessor - Represents a SupplerUpdate processor

=head1 SYNOPSIS

Object-oriented class that provides an object allowing us to perform processing on
a SupplierUpdate

=head1 DESCRIPTION

Object-oriented base class that provides an object allowing us to perform processing on
a SupplierUpdate
** This class should not be directly instantiated, it should only be sub-classed **

=head1 API

=head2 Class Methods

=head3 new

    my $processor = Koha::ILL::Request::SupplierUpdateProcessor->new(
        $target_source_type,
        $target_source_name
    );

Create a new Koha::ILL::Request::SupplierUpdateProcessor object .

=cut

sub new {
    my ( $class, $target_source_type, $target_source_name, $processor_name ) = @_;
    my $self = {};

    $self->{target_source_type} = $target_source_type;
    $self->{target_source_name} = $target_source_name;
    $self->{name}               = $processor_name;

    bless $self, $class;

    return $self;
}

=head3 run

    Koha::ILL::Request::SupplierUpdateProcessor->run();

Runs the processor

=cut

sub run {
    my ($self) = @_;
    my ( $package, $filename ) = caller;
    warn __PACKAGE__ . " run should only be invoked by a subclass\n";
}

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
