#!/usr/bin/perl
# Copyright 2009 SARL BibLibre
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

use strict;
use warnings;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Biblio;
use C4::Koha;
use C4::Output;

use Koha::BiblioFrameworks;

my $query = new CGI;

my $frameworkcode = $query->param('framework') || "";
my $field         = $query->param('fieldname');
my $fieldcode     = $query->param('marcfield');
my $subfieldcode  = $query->param('marcsubfield');
my $op            = $query->param('op') || q{};
my $id            = $query->param('id');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/fieldmapping.tt",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
                 flagsrequired => {parameters => 'parameters_remaining_permissions'},
			     debug => 1,
			     });

if($op eq "delete" and $id){
    DeleteFieldMapping($id);
    print $query->redirect("/cgi-bin/koha/admin/fieldmapping.pl?framework=".$frameworkcode);
    exit;
}

# insert operation
if($field and $fieldcode){
    SetFieldMapping($frameworkcode, $field, $fieldcode, $subfieldcode);
}

my $fieldloop = GetFieldMapping($frameworkcode);

my $frameworks = Koha::BiblioFrameworks->search({}, { order_by => ['frameworktext'] });
my $framework  = $frameworks->search( { frameworkcode => $frameworkcode } )->next;
$template->param(
    frameworks => $frameworks,
    framework  => $framework,
    fields     => $fieldloop,
);

output_html_with_http_headers $query, $cookie, $template->output;
