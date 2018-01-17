#!/usr/bin/perl

# Copyright 2012, 2014 Mark Gavillet & PTFS Europe Ltd
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Output;
use Koha::Database;

my $input = CGI->new();

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'admin/edi_ean_accounts.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'edi_manage' },
    }
);

my $schema = Koha::Database->new()->schema();

my $id = scalar $input->param('id');
my $op = scalar $input->param('op') || 'display';

if ( $op eq 'ean_form' ) {
    my $e        = $schema->resultset('EdifactEan')->find($id);
    my @branches = $schema->resultset('Branch')->search(
        undef,
        {
            columns  => [ 'branchcode', 'branchname' ],
            order_by => 'branchname',
        }
    );
    $template->param(
        ean_form => 1,
        branches => \@branches,
        ean      => $e,
    );
}
elsif ( $op eq 'delete_confirm' ) {
    my $e = $schema->resultset('EdifactEan')->find($id);
    $template->param(
        delete_confirm => 1,
        ean            => $e,
    );
}
else {
    if ( $op eq 'save' ) {
        my $change = $id;
        if ($change) {
            $schema->resultset('EdifactEan')->find($id)->update(
                {
                    branchcode        => scalar $input->param('branchcode'),
                    description       => scalar $input->param('description'),
                    ean               => scalar $input->param('ean'),
                    id_code_qualifier => scalar $input->param('id_code_qualifier'),
                }
            );
        }
        else {
            my $new_ean = $schema->resultset('EdifactEan')->new(
                {
                    branchcode        => scalar $input->param('branchcode'),
                    description       => scalar $input->param('description'),
                    ean               => scalar $input->param('ean'),
                    id_code_qualifier => scalar $input->param('id_code_qualifier'),
                }
            );
            $new_ean->insert();
        }
    }
    elsif ( $op eq 'delete_confirmed' ) {
        my $e = $schema->resultset('EdifactEan')->find($id);
        $e->delete if $e;
    }
    my @eans = $schema->resultset('EdifactEan')->search(
        {},
        {
            join => 'branch',
        }
    );
    $template->param( display => 1 );
    $template->param( eans    => \@eans );
}

$template->param(
    code_qualifiers => [
        {
            code        => '14',
            description => 'EAN International',
        },
        {
            code        => '31B',
            description => 'US SAN Agency',
        },
        {
            code        => '91',
            description => 'Assigned by supplier',
        },
        {
            code        => '92',
            description => 'Assigned by buyer',
        },
    ]
);

output_html_with_http_headers( $input, $cookie, $template->output );
