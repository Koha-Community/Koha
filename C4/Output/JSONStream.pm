package C4::Output::JSONStream;
#
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

C4::Output::JSONStream - progressively build JSON data

=head1 SYNOPSIS

my $json = new C4::Output::JSONStream;

$json->param( issues => [ 'yes!', 'please', 'no', { emphasis = 'NO' } ] );
$json->param( stuff => 'realia' );

print $json->output;

=head1 DESCRIPTION

This module allows you to build JSON incrementally.

=cut

use strict;
use warnings;

use JSON;

sub new {
    my $class = shift;
    my $self = {
        data => {},
        options => {}
    };

    bless $self, $class;

    return $self;
}

sub param {
    my $self = shift;

    if ( @_ % 2 != 0 ) {
        die 'param() received odd number of arguments (should be called with param => "value" pairs)';
    }

    for ( my $i = 0; $i < $#_; $i += 2 ) {
        $self->{data}->{$_[$i]} = $_[$i + 1];
    }
}

sub output {
    my $self = shift;

    return to_json( $self->{data} );
}

1;
