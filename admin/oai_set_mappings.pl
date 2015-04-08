#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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

oai_set_mappings.pl

=head1 DESCRIPTION

Define mappings for a given set.
Mappings are conditions that define which biblio is included in which set.
A condition is in the form 200$a = 'abc'.
Multiple conditions can be defined for a given set. In this case,
the OR operator will be applied.

=cut

use Modern::Perl;

use CGI;
use C4::Auth;
use C4::Output;
use C4::OAI::Sets;

use Data::Dumper;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'admin/oai_set_mappings.tt',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'parameters' => 'parameters_remaining_permissions' },
    debug           => 1,
} );

my $id = $input->param('id');
my $op = $input->param('op');

if($op && $op eq "save") {
    my @marcfields = $input->param('marcfield');
    my @marcsubfields = $input->param('marcsubfield');
    my @operators = $input->param('operator');
    my @marcvalues = $input->param('marcvalue');

    my @mappings;
    my $i = 0;
    while($i < @marcfields and $i < @marcsubfields and $i < @marcvalues) {
        if($marcfields[$i] and $marcsubfields[$i]) {
            push @mappings, {
                marcfield    => $marcfields[$i],
                marcsubfield => $marcsubfields[$i],
                operator     => $operators[$i],
                marcvalue    => $marcvalues[$i]
            };
        }
        $i++;
    }
    ModOAISetMappings($id, \@mappings);
    $template->param(mappings_saved => 1);
}

my $set = GetOAISet($id);
my $mappings = GetOAISetMappings($id);

$template->param(
    id => $id,
    setName => $set->{'name'},
    setSpec => $set->{'spec'},
    mappings => $mappings,
);

output_html_with_http_headers $input, $cookie, $template->output;
