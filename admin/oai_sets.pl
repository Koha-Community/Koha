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

oai_sets.pl

=head1 DESCRIPTION

Admin page to describe OAI SETs

=cut

use Modern::Perl;

use CGI;
use C4::Auth;
use C4::Output;
use C4::OAI::Sets;

use Data::Dumper;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'admin/oai_sets.tt',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'parameters' => 'parameters_remaining_permissions' },
    debug           => 1,
} );

my $op = $input->param('op');

if($op && $op eq "new") {
    $template->param( op_new => 1 );
} elsif($op && $op eq "savenew") {
    my $spec = $input->param('spec');
    my $name = $input->param('name');
    my @descriptions = $input->param('description');
    AddOAISet({
        spec => $spec,
        name => $name,
        descriptions => \@descriptions
    });
} elsif($op && $op eq "mod") {
    my $id = $input->param('id');
    my $set = GetOAISet($id);
    $template->param(
        op_mod => 1,
        id => $set->{'id'},
        spec => $set->{'spec'},
        name => $set->{'name'},
        descriptions => [ map { {description => $_} } @{ $set->{'descriptions'} } ],
    );
} elsif($op && $op eq "savemod") {
    my $id = $input->param('id');
    my $spec = $input->param('spec');
    my $name = $input->param('name');
    my @descriptions = $input->param('description');
    ModOAISet({
        id => $id,
        spec => $spec,
        name => $name,
        descriptions => \@descriptions
    });
} elsif($op && $op eq "del") {
    my $id = $input->param('id');
    DelOAISet($id);
}

my $OAISets = GetOAISets;
my @sets_loop;
foreach(@$OAISets) {
    push @sets_loop, {
        id => $_->{'id'},
        spec => $_->{'spec'},
        name => $_->{'name'},
        descriptions => [ map { {description => $_} } @{ $_->{'descriptions'} } ]
    };
}

$template->param(
    sets_loop => \@sets_loop,
);

output_html_with_http_headers $input, $cookie, $template->output;
