#!/usr/bin/perl

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

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Database::Columns;
use Koha::Notice::Templates;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name => 'preservation/home.tt',
        query         => $query,
        type          => 'intranet',
        flagsrequired => { preservation => '*' },
    }
);

my $columns = Koha::Database::Columns::columns;
$template->param(
    db_columns => {
        map {
            my $table = $_;
            map { ( $table . '.' . $_ => $columns->{$table}->{$_} ) }
                keys %{ $columns->{$table} }
        } qw( biblio biblioitems items )
    },
    api_mappings => {
        items       => Koha::Item->to_api_mapping,
        biblioitems => Koha::Biblioitem->to_api_mapping,
        biblio      => Koha::Biblio->to_api_mapping,
    },
    notice_templates => [
        map { { id => $_->id, code => $_->code, name => $_->name } }
            Koha::Notice::Templates->search( { module => 'preservation' } )->as_list
    ],
);

output_html_with_http_headers $query, $cookie, $template->output;
