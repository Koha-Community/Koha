package Koha::RDF;

# Copyright 2017 Prosentient Systems
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
use URI;

use C4::Context;

sub new {
    my ($class, $args) = @_;
    $args = {} unless defined $args;
    return bless ($args, $class);
}

sub mint_uri {
    my ($self,$type,$number) = @_;
    my $new_uri;
    my $preference = C4::Context->preference('OPACBaseURL');
    if ($preference){
        my $uri = URI->new($preference);
        if ( $uri && $uri->can('scheme') && $uri->scheme && ($uri->scheme eq 'http' || $uri->scheme eq 'https') ){
            if ($type && $number){
                if ($type eq 'biblio'){
                    #NOTE: This is arbitrary and based on default Apache configuration at the time of writing this module
                    $uri->path("bib/$number");
                    $new_uri = $uri;
                }
            }
        }
    }
    return $new_uri;
}

1;
