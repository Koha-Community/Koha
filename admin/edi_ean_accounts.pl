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

use strict;
use warnings;
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
my $op     = $input->param('op');
$op ||= 'display';

if ( $op eq 'ean_form' ) {
    show_ean();
    $template->param( ean_form => 1 );
    my @branches = $schema->resultset('Branch')->search(
        undef,
        {
            columns  => [ 'branchcode', 'branchname' ],
            order_by => 'branchname',
        }
    );
    $template->param( branches => \@branches );
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

}
elsif ( $op eq 'delete_confirm' ) {
    show_ean();
    $template->param( delete_confirm => 1 );
}
else {
    if ( $op eq 'save' ) {
        my $change = $input->param('oldean');
        if ($change) {
            editsubmit();
        }
        else {
            addsubmit();
        }
    }
    elsif ( $op eq 'delete_confirmed' ) {
        delsubmit();
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

output_html_with_http_headers( $input, $cookie, $template->output );

sub delsubmit {
    my $ean = $schema->resultset('EdifactEan')->find(
        {
            branchcode => $input->param('branchcode'),
            ean        => $input->param('ean')
        }
    );
    $ean->delete;
    return;
}

sub addsubmit {

    my $new_ean = $schema->resultset('EdifactEan')->new(
        {
            branchcode        => $input->param('branchcode'),
            ean               => $input->param('ean'),
            id_code_qualifier => $input->param('id_code_qualifier'),
        }
    );
    $new_ean->insert();
    return;
}

sub editsubmit {
    $schema->resultset('EdifactEan')->search(
        {
            branchcode => $input->param('oldbranchcode'),
            ean        => $input->param('oldean'),
        }
      )->update_all(
        {
            branchcode        => $input->param('branchcode'),
            ean               => $input->param('ean'),
            id_code_qualifier => $input->param('id_code_qualifier'),
        }
      );
    return;
}

sub show_ean {
    my $branchcode = $input->param('branchcode');
    my $ean        = $input->param('ean');
    if ( $branchcode && $ean ) {
        my $e = $schema->resultset('EdifactEan')->find(
            {
                ean        => $ean,
                branchcode => $branchcode,
            }
        );
        $template->param( ean => $e );
    }
    return;
}
