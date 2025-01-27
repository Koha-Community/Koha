#!/usr/bin/perl
# vim: et ts=4 sw=4
# Copyright BibLibre
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

# This script clones issuing rules from a library to another
# parameters :
#  - frombranch : the branch we want to clone issuing rules from
#  - tobranch   : the branch we want to clone issuing rules to
#
# The script can be called with one of the parameters, both or none

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use Koha::CirculationRules;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/clone-rules.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_circ_rules' },
    }
);

my $op         = $input->param("op") || q{};
my $frombranch = $input->param("frombranch");
my $tobranch   = $input->param("tobranch");

$template->param( frombranch => $frombranch ) if ($frombranch);
$template->param( tobranch   => $tobranch )   if ($tobranch);

if ( $op eq 'cud-clone' && $frombranch && $tobranch && $frombranch ne $tobranch ) {
    $frombranch = ( $frombranch ne '*' ? $frombranch : undef );
    $tobranch   = ( $tobranch ne '*'   ? $tobranch   : undef );

    Koha::CirculationRules->search( { branchcode => $tobranch } )->delete;

    my $rules = Koha::CirculationRules->search( { branchcode => $frombranch } );
    $rules->clone($tobranch);
} else {
    $template->param( error => 1 );
}

output_html_with_http_headers $input, $cookie, $template->output;

