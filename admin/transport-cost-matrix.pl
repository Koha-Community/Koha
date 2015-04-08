#!/usr/bin/perl
# Copyright 2000-2002 Katipo Communications
# copyright 2010 BibLibre
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
use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::Debug;
use C4::Branch; # GetBranches
use C4::HoldsQueue qw(TransportCostMatrix UpdateTransportCostMatrix);

use Data::Dumper;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/transport-cost-matrix.tt",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {parameters => 1},
                            debug => 1,
                            });
my $use_transport_cost_matrix = C4::Context->preference("UseTransportCostMatrix");

my $update = $input->param('op') eq 'set-cost-matrix';

my ($cost_matrix, $have_matrix);
unless ($update) {
    $cost_matrix = TransportCostMatrix();
    $have_matrix = keys %$cost_matrix if $cost_matrix;
}

my $branches = GetBranches();
my @branchloop = map { code => $_,
                       name => $branches->{$_}->{'branchname'} },
                 sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} }
                 keys %$branches;
my (@branchfromloop, @cost, @errors);
foreach my $branchfrom ( @branchloop ) {
    my $fromcode = $branchfrom->{code};

    my %from_row = ( code => $fromcode, name => $branchfrom->{name} );
    foreach my $branchto ( @branchloop ) {
        my $tocode = $branchto->{code};

        my %from_to_input_def = ( code => $tocode, name => $branchto->{name} );
        push @{ $from_row{branchtoloop} }, \%from_to_input_def;

        if ($fromcode eq $tocode) {
            $from_to_input_def{skip} = 1;
            next;
        }

        (my $from_to = "${fromcode}_${tocode}") =~ s/\W//go;
         $from_to_input_def{id} = $from_to;
        my $input_name   = "cost_$from_to";
        my $disable_name = "disable_$from_to";

        if ($update) {
            my $value = $from_to_input_def{value} = $input->param($input_name);
            if ( $input->param($disable_name) ) {
                $from_to_input_def{disabled} = 1;
            }
            else {
                push @errors, "$from_row{name} -> $from_to_input_def{name}"
                  unless $value =~ /\d/o && $value >= 0.0;
            }
        }
        else {
            if ($have_matrix) {
                if ( my $cell = $cost_matrix->{$tocode}{$fromcode} ) {
                    $from_to_input_def{value} = $cell->{cost};
                    $from_to_input_def{disabled} = 1 if $cell->{disable_transfer};
                } else {
                    # matrix has been previously initialized, but a branch referenced here was created afterward.
                    $from_to_input_def{disabled} = 1;
                }
            } else {
                # First time initializing the matrix
                $from_to_input_def{disabled} = 1;
            }
        }
    }

#              die Dumper(\%from_row);
    push @branchfromloop, \%from_row;
}

if ($update && !@errors) {
    my @update_recs = map {
        my $from = $_->{code};
        map { frombranch => $from, tobranch => $_->{code}, cost => $_->{value}, disable_transfer => $_->{disabled} || 0 },
            grep { $_->{code} ne $from }
            @{ $_->{branchtoloop} };
    } @branchfromloop;

    UpdateTransportCostMatrix(\@update_recs);
}

$template->param(
    branchloop => \@branchloop,
    branchfromloop => \@branchfromloop,
    WARNING_transport_cost_matrix_off => !$use_transport_cost_matrix,
    errors => \@errors,
);
output_html_with_http_headers $input, $cookie, $template->output;

exit 0;
