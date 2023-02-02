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

use CGI qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::OAI::Sets qw( GetOAISet GetOAISetMappings ModOAISetMappings );


my $input = CGI->new;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'admin/oai_set_mappings.tt',
    query           => $input,
    type            => 'intranet',
    flagsrequired   => { 'parameters' => 'manage_oai_sets' },
} );

my $id = $input->param('id');
my $op = $input->param('op');

if($op && $op eq "save") {
    my @marcfields = $input->multi_param('marcfield');
    my @marcsubfields = $input->multi_param('marcsubfield');
    my @operators = $input->multi_param('operator');
    my @marcvalues = $input->multi_param('marcvalue');
    my @ruleoperators = $input->multi_param('rule_operator');
    my @ruleorders = $input->multi_param('rule_order');

    my @mappings;
    my $i = 0;
    while($i < @marcfields and $i < @marcsubfields and $i < @marcvalues) {
        if($marcfields[$i] ne '' and $marcsubfields[$i] ne '' ) {
            push @mappings, {
                marcfield     => $marcfields[$i],
                marcsubfield  => $marcsubfields[$i],
                operator      => $operators[$i],
                marcvalue     => $marcvalues[$i],
                rule_operator => $ruleoperators[$i],
                rule_order    => $i
            };
        }
        $i++;
    }
    $mappings[0]{'rule_operator'} = undef if (@mappings);
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
