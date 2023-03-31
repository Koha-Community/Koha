#!/usr/bin/perl
#
# Copyright 2013 ByWater
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
#

use Modern::Perl;

use CGI;

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use DBIx::Class::ResultClass::HashRefInflator;
use Koha::Database;
use Koha::MarcSubfieldStructures;
use Koha::BiblioFrameworks;
use Koha::KeyboardShortcuts;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'cataloguing/editor.tt',
        query           => $input,
        type            => 'intranet',
        flagsrequired   => {
            editcatalogue => {
                'edit_catalogue'  => 1,
                'advanced_editor' => 1
            },
        }
    }
);

my $schema = Koha::Database->new->schema;

my @keyboard_shortcuts = Koha::KeyboardShortcuts->search();

# Keyboard shortcuts
$template->param(
    shortcuts => \@keyboard_shortcuts,
);

# Available import batches
$template->{VARS}->{editable_batches} = [ $schema->resultset('ImportBatch')->search(
    {
        batch_type => [ 'batch', 'webservice' ],
        import_status => 'staged',
    },
    { result_class => 'DBIx::Class::ResultClass::HashRefInflator' },
) ];

# Needed information for cataloging plugins
$template->{VARS}->{DefaultLanguageField008} = pack( 'A3', C4::Context->preference('DefaultLanguageField008') || 'eng' );
$template->{VARS}->{DefaultCountryField008} = pack( 'A3', C4::Context->preference('DefaultCountryField008') || '|||' );

my $authtags = Koha::MarcSubfieldStructures->search({ authtypecode => { '!=' => '' }, 'frameworkcode' => '' });
$template->{VARS}->{authtags} = $authtags;

my $frameworks = Koha::BiblioFrameworks->search({}, { order_by => ['frameworktext'] });
$template->{VARS}->{frameworks} = $frameworks;

# Z39.50 servers
my $dbh = C4::Context->dbh;
$template->{VARS}->{z3950_servers} = $dbh->selectall_arrayref( q{
    SELECT * FROM z3950servers
    WHERE recordtype != 'authority' AND servertype = 'zed'
    ORDER BY `rank`,servername
}, { Slice => {} } );

output_html_with_http_headers $input, $cookie, $template->output;
