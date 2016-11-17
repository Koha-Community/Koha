#!/usr/bin/env perl

# Copyright 2016 Koha-Suomi
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

use Test::More tests => 1;
use Test::Mojo;

use Module::Load::Conditional;
use Swagger2;

use C4::Context;
use Koha::Database;

my $swaggerPath = C4::Context->config('intranetdir') . "/api/v1/swagger";
my $swagger     = Swagger2->new( $swaggerPath . "/swagger.json" )->expand;
my $api_spec    = $swagger->api_spec->data;
my $schema = Koha::Database->new->schema;

# The basic idea of this test:
# 1. Find all definitions in Swagger under api/v1/definitions
# 2. Iterating over each definition, check 'type' of the definition
#    * If type is not 'object', definition is ok. We only want objects.
#    * If type is an 'object', attempt to load the corresponding Koha-object.
#        -> If corresponding Koha-object is not found, definition is ok.
#        -> If corresponding Koha-object is found and loaded, compare its
#           columns to properties of the object defined in Swagger.
#             --> If columns match properties, definition is ok.
#             --> If columns do not match properties, definition is not ok.
my @definition_names = keys %{ $api_spec->{definitions} };

subtest 'api/v1/definitions/*.json up-to-date with corresponding Koha-object' => sub {
    plan tests => 2*(scalar(@definition_names) - 1);

    foreach my $name (@definition_names) {
        my $definition = $api_spec->{definitions}->{$name};

        if ($definition->{type} eq "object") {
            my $kohaObject = _koha_object($name);

            unless ($kohaObject && $kohaObject->can("_columns")) {
                ok(1, "$name is an object, but not a Koha-object!");
                next;
            }

            my $columns_info = $schema->resultset( $kohaObject->_type )->result_source->columns_info;
            my $properties = $definition->{properties};
            my @missing = check_columns_exist($properties, $columns_info);
            if ( @missing ) {
                fail( "Columns are missing for $name: " . join(", ", @missing ) );
            } else {
                pass( "No columns are missing for $name" );
            }
            my @nullable= check_is_nullable($properties, $columns_info);
            if ( @nullable ) {
                fail( "Columns is nullable in DB, not in swagger file for $name: " . join(", ", @nullable ) );
            } else {
                pass( "No null are missing for $name" );
            }
        } else {
            ok(1, "$name type is not an object. It is ".$definition->{type}.".");
        }
    }
};

sub _koha_object {
    my ($name) = @_;

    $name = "Koha::" . ucfirst $name;

    if (Module::Load::Conditional::can_load(modules => {$name => undef})) {
        return bless {}, $name ;
    }
}

sub check_columns_exist {
    my ($properties, $columns_info) = @_;
    my @missing_column;
    for my $column_name ( keys %$columns_info ) {
        my $c_info = $columns_info->{$column_name};
        unless ( exists $properties->{$column_name} ) {
            push @missing_column, $column_name;
            next;
        }
    }
    return @missing_column;
}

sub check_is_nullable {
    my ($properties, $columns_info) = @_;
    my @missing_nullable;
    for my $column_name ( keys %$columns_info ) {
        my $c_info = $columns_info->{$column_name};
        if ( $c_info->{is_nullable} or $c_info->{datetime_undef_if_invalid} ) {
            my $type = $properties->{$column_name}{type};
            next unless $type; # FIXME Is it ok not to have type defined?
            unless ( ref($type) ) {
                push @missing_nullable, $column_name;
                next;
            }
            my $null_exists = grep {/^null$/} @$type;
            unless ( $null_exists ) {
                push @missing_nullable, $column_name;
                next;
            }
        }
    }
    return @missing_nullable;
}
