#!/usr/bin/perl

# Copyright BibLibre 2012
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

=head1 NAME

ajax-updatedb-getinfos.pl

=head1 DESCRIPTION
this script returns comments for a updatedatabase version

=cut

use Modern::Perl;
use CGI;
use JSON;
use C4::Update::Database;
use C4::Output;

my $input = new CGI;
my $version = $input->param('version');

my $filepath;
my $queries;
eval {
    $filepath = C4::Update::Database::get_filepath( $version );
    $queries = C4::Update::Database::get_queries( $filepath );
};

my $param = {comments => "", queries => ""};
if ( $@ ){
    $param->{errors} = $@;
} else {
    if ( exists $queries->{comments} and @{ $queries->{comments} } ) {
        $param->{comments} = join ( "<br/>", @{ $queries->{comments} } );
    }

    if ( exists $queries->{queries} and @{ $queries->{queries} } ) {
        $param->{queries} = join ( "<br/>", @{ $queries->{queries} } );
    }
}

my $json_text = to_json( $param, { utf8 => 1 } );

output_with_http_headers $input, undef, $json_text, 'json';
