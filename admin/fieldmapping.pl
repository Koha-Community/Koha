#!/usr/bin/perl
# Copyright 2009 SARL BibLibre
# Copyright 2017 Koha Development Team
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
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Biblio;
use C4::Output;

use Koha::BiblioFrameworks;
use Koha::FieldMappings;

my $query = new CGI;

my $frameworkcode = $query->param('framework') || "";
my $field         = $query->param('fieldname');
my $fieldcode     = $query->param('marcfield');
my $subfieldcode  = $query->param('marcsubfield');
my $op            = $query->param('op') || q{};
my $id            = $query->param('id');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/fieldmapping.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'manage_keywords2marc_mappings' },
        debug           => 1,
    }
);

# FIXME Add exceptions
if ( $op eq "delete" and $id ) {
    Koha::FieldMappings->find($id)->delete;
} elsif ( $field and $fieldcode ) {
    my $params = { frameworkcode => $frameworkcode, field => $field, fieldcode => $fieldcode, subfieldcode => $subfieldcode };
    my $exists = Koha::FieldMappings->search( $params )->count;;
    unless ( $exists ) {
        Koha::FieldMapping->new( $params )->store;
    }
}

my $fields = Koha::FieldMappings->search({ frameworkcode => $frameworkcode });

my $frameworks = Koha::BiblioFrameworks->search({}, { order_by => ['frameworktext'] });
my $framework  = $frameworks->search( { frameworkcode => $frameworkcode } )->next;
$template->param(
    frameworks => $frameworks,
    framework  => $framework,
    fields     => $fields,
);

output_html_with_http_headers $query, $cookie, $template->output;
