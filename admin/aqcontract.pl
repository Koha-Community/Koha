#!/usr/bin/perl

#script to administer the contract table
#written 02/09/2008 by john.soros@biblibre.com

# Copyright 2008-2009 BibLibre SARL
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
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Contract;
use Koha::DateUtils;

use Koha::Acquisition::Booksellers;

my $input          = new CGI;
my $contractnumber = $input->param('contractnumber');
my $booksellerid   = $input->param('booksellerid');
my $op             = $input->param('op') || 'list';

my $bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "admin/aqcontract.tt",
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
    booksellername => $bookseller->name,
    basketcount   => $bookseller->baskets->count,
    active         => $bookseller->active,
    subscriptioncount   => $bookseller->subscriptions->count,
);

#ADD_FORM: called if $op is 'add_form'. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {
    $template->param( add_form => 1 );

   # if contractnumber exists, it's a modify action, so read values to modify...
    if ($contractnumber) {
        my $contract = GetContract({
            contractnumber => $contractnumber
        });

        $template->param(
            contractnumber      => $contract->{contractnumber},
            contractname        => $contract->{contractname},
            contractdescription => $contract->{contractdescription},
            contractstartdate   => $contract->{contractstartdate},
            contractenddate     => $contract->{contractenddate},
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

    my $contractstart_dt = eval { dt_from_string( scalar $input->param('contractstartdate') ); };
    my $contractend_dt = eval { dt_from_string( scalar $input->param('contractenddate') ); };
    unless ( $contractstart_dt and $contractend_dt ) {
        my $today = dt_from_string;
        $contractstart_dt ||= $today;
        $contractend_dt   ||= $today;
    }

    if ( $is_a_modif ) {
        ModContract({
            contractstartdate   => eval { output_pref({ dt => dt_from_string( $contractstart_dt ), dateformat => 'iso', dateonly => 1 } ); },
            contractenddate     => eval { output_pref({ dt => dt_from_string( $contractend_dt ), dateformat => 'iso', dateonly => 1 } ); },
            contractname        => scalar $input->param('contractname'),
            contractdescription => scalar $input->param('contractdescription'),
            booksellerid        => scalar $input->param('booksellerid'),
            contractnumber      => scalar $input->param('contractnumber'),
        });
    } else {
        AddContract({
            contractname        => scalar $input->param('contractname'),
            contractdescription => scalar $input->param('contractdescription'),
            booksellerid        => scalar $input->param('booksellerid'),
            contractstartdate   => eval { output_pref({ dt => dt_from_string( scalar $input->param('contractstartdate') ), dateformat => 'iso', dateonly => 1 } ); },
            contractenddate     => eval { output_pref({ dt => dt_from_string( scalar $input->param('contractenddate') ), dateformat => 'iso', dateonly => 1 } ); },
        });
    }

    print $input->redirect("/cgi-bin/koha/acqui/supplier.pl?booksellerid=$booksellerid");
    exit;

    # END $OP eq ADD_VALIDATE
}
#DELETE_CONFIRM: called by default form, used to confirm deletion of data in DB
elsif ( $op eq 'delete_confirm' ) {
    $template->param( delete_confirm => 1 );

    my $contract = GetContract( { contractnumber => $contractnumber } );

    $template->param(
        contractnumber      => $$contract{contractnumber},
        contractname        => $$contract{contractname},
        contractdescription => $$contract{contractdescription},
        contractstartdate   => $$contract{contractstartdate},
        contractenddate     => $$contract{contractenddate},
    );

    # END $OP eq DELETE_CONFIRM
}
#DELETE_CONFIRMED: called by delete_confirm, used to effectively confirm deletion of data in DB
elsif ( $op eq 'delete_confirmed' ) {
    my $deleted = DelContract( { contractnumber => $contractnumber } );

    if ( $deleted ) {
        print $input->redirect("/cgi-bin/koha/acqui/supplier.pl?booksellerid=$booksellerid");
        exit;
    } else {
        $template->param( error => 'not_deleted' );
        $op = 'list';
    }

    # END $OP eq LIST
}
# DEFAULT: Builds a list of contracts and displays them
if ( $op eq 'list' ) {
    $template->param(else => 1);

    # get contracts
    my @contracts = @{GetContracts( { booksellerid => $booksellerid } )};

    # format dates
    for my $contract ( @contracts ) {
        $contract->{contractstartdate} =  output_pref({ dt => dt_from_string( $contract->{contractstartdate} ), dateonly => 1 });
        $contract->{contractenddate}   =  output_pref({ dt => dt_from_string( $contract->{contractenddate} ), dateonly => 1 }),
    }

    $template->param(loop => \@contracts);

    #---- END $OP eq DEFAULT
}

output_html_with_http_headers $input, $cookie, $template->output;

