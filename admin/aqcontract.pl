#!/usr/bin/perl

#script to administer the contract table
#written 02/09/2008 by john.soros@biblibre.com

# Copyright 2008-2009 BibLibre SARL
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
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
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Bookseller qw/GetBookSellerFromId/;
use C4::Contract;

my $input          = new CGI;
my $contractnumber = $input->param('contractnumber');
my $booksellerid   = $input->param('booksellerid');
my $op             = $input->param('op') || '';

my $bookseller = GetBookSellerFromId($booksellerid);

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "admin/aqcontract.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'contracts_manage' },
        debug           => 1,
    }
);

$template->param(
    contractnumber => $contractnumber,
    booksellerid   => $booksellerid,
    booksellername => $bookseller->{name},
    basketcount   => $bookseller->{'basketcount'},
    subscriptioncount   => $bookseller->{'subscriptioncount'},
);

#ADD_FORM: called if $op is 'add_form'. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {
    $template->param( add_form => 1 );

   # if contractnumber exists, it's a modify action, so read values to modify...
    if ($contractnumber) {
        my $contract =
          @{ GetContract( { contractnumber => $contractnumber } ) }[0];

        $template->param(
            contractnumber      => $contract->{contractnumber},
            contractname        => $contract->{contractname},
            contractdescription => $contract->{contractdescription},
            contractstartdate => format_date( $contract->{contractstartdate} ),
            contractenddate   => format_date( $contract->{contractenddate} ),
        );
    } else {
        $template->param(
            contractnumber           => undef,
            contractname             => undef,
            contractdescription      => undef,
            contractstartdate        => undef,
            contractenddate          => undef,
        );
    }

    # END $OP eq ADD_FORM
}
#ADD_VALIDATE: called by add_form, used to insert/modify data in DB
elsif ( $op eq 'add_validate' ) {
## Please see file perltidy.ERR
    $template->param( add_validate => 1 );

    my $is_a_modif = $input->param("is_a_modif");

    if ( $is_a_modif ) {
        ModContract({
            contractstartdate   => format_date_in_iso( $input->param('contractstartdate') ),
            contractenddate     => format_date_in_iso( $input->param('contractenddate') ),
            contractname        => $input->param('contractname'),
            contractdescription => $input->param('contractdescription'),
            booksellerid        => $input->param('booksellerid'),
            contractnumber      => $input->param('contractnumber'),
        });
    } else {
        AddContract({
            contractname        => $input->param('contractname'),
            contractdescription => $input->param('contractdescription'),
            booksellerid        => $input->param('booksellerid'),
            contractstartdate   => format_date_in_iso( $input->param('contractstartdate') ),
            contractenddate     => format_date_in_iso( $input->param('contractenddate') ),
        });
    }

    print $input->redirect("/cgi-bin/koha/acqui/supplier.pl?booksellerid=$booksellerid");
    exit;

    # END $OP eq ADD_VALIDATE
}
#DELETE_CONFIRM: called by default form, used to confirm deletion of data in DB
elsif ( $op eq 'delete_confirm' ) {
    $template->param( delete_confirm => 1 );

    my $contract = @{GetContract( { contractnumber => $contractnumber } )}[0];

    $template->param(
        contractnumber      => $$contract{contractnumber},
        contractname        => $$contract{contractname},
        contractdescription => $$contract{contractdescription},
        contractstartdate   => format_date( $$contract{contractstartdate} ),
        contractenddate     => format_date( $$contract{contractenddate} ),
    );

    # END $OP eq DELETE_CONFIRM
}
#DELETE_CONFIRMED: called by delete_confirm, used to effectively confirm deletion of data in DB
elsif ( $op eq 'delete_confirmed' ) {
    $template->param( delete_confirmed => 1 );

    DelContract( { contractnumber => $contractnumber } );

    print $input->redirect("/cgi-bin/koha/acqui/supplier.pl?booksellerid=$booksellerid");
    exit;

    # END $OP eq DELETE_CONFIRMED
}
# DEFAULT: Builds a list of contracts and displays them
else {
    $template->param(else => 1);

    # get contracts
    my @contracts = @{GetContract( { booksellerid => $booksellerid } )};

    # format dates
    for ( @contracts ) {
        $$_{contractstartdate} = format_date($$_{contractstartdate});
        $$_{contractenddate}   = format_date($$_{contractenddate});
    }

    $template->param(loop => \@contracts);

    #---- END $OP eq DEFAULT
}

output_html_with_http_headers $input, $cookie, $template->output;

