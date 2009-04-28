#!/usr/bin/perl

# Copyright 2008 BibLibre, BibLibre, Paul POULAIN
#                SAN Ouest Provence
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 admin/aqbudgetperiods.pl

script to administer the budget periods table
 This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

 ALGO :
 this script use an $op to know what to do.
 if $op is empty or none of the above values,
	- the default screen is build (with all records, or filtered datas).
	- the   user can clic on add, modify or delete record.
 if $op=add_form
	- if primkey exists, this is a modification,so we read the $primkey record
	- builds the add/modify form
 if $op=add_validate
	- the user has just send datas, so we create/modify the record
 if $op=delete_confirm
	- we show the record having primkey=$primkey and ask for deletion validation form
 if $op=delete_confirmed
	- we delete the record having primkey=$primkey

=cut

## modules
use strict;
use Number::Format qw(format_price);
use CGI;
use List::Util qw/min/;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Koha;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Acquisition;
use C4::Budgets;
use C4::Debug;

my $dbh = C4::Context->dbh;

my $input       = new CGI;

my $searchfield          = $input->param('searchfield');
my $budget_period_id     = $input->param('budget_period_id');
my $budget_period_active = $input->param('budget_period_active');
my $budget_period_locked = $input->param('budget_period_locked');
my $op                   = $input->param('op');

#my $sort1_authcat = $input->param('sort1_authcat');
#my $sort2_authcat = $input->param('sort2_authcat');

my $pagesize    = 10;
$searchfield =~ s/\,//g;

my ($template, $borrowernumber, $cookie, $staff_flags ) = get_template_and_user(
	{   template_name   => "admin/aqbudgetperiods.tmpl",
		query           => $input,
		type            => "intranet",
		authnotrequired => 0,
		flagsrequired   => { acquisition => 'period_manage' },
		debug           => 1,
	}
);

my $script_name = "/cgi-bin/koha/admin/aqbudgetperiods.pl";  # ???

my ( $count, $results ) = GetBudgetPeriods();
### $count
$template->param( period_button_only => 1 ) if ($count == 0) ;

my $cur = GetCurrency();
$template->param( cur => $cur->{symbol} );
my $cur_format = C4::Context->preference("CurrencyFormat");
my $num;

if ( $cur_format eq 'US' ) {
    $num = new Number::Format(
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ',',
        'mon_decimal_point' => '.'
    );
} elsif ( $cur_format eq 'FR' ) {
    $num = new Number::Format(
        'decimal_fill'      => '2',
        'decimal_point'     => ',',
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ' ',
        'thousands_sep'     => ' ',
        'mon_decimal_point' => ','
    );
}

if   ($op) { $template->param( $op    => 1 ); }
else       { $template->param( 'else' => 1 ); }

# ADD OR MODIFY A BUDGET PERIOD - BUILD SCREEN
if ( $op eq 'add_form' ) {
    ## add or modify a budget period (preparation)
    ## get information about the budget period that must be modified

#    my ( $default, $sort1_authcat_dropbox, $sort1_default, $sort2_default );
#    my ( $default, t );

    if ($budget_period_id) {    # MOD
        my $data;
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(qq|
                                        SELECT * FROM aqbudgetperiods
                                        WHERE budget_period_id=?    | );
        $sth->execute($budget_period_id);
        $data = $sth->fetchrow_hashref;
        $sth->finish;

        # get dropboxes
        $template->param(
            budget_period_id          => $budget_period_id,
            budget_period_startdate   => format_date( $data->{'budget_period_startdate'} ),
            budget_period_enddate     => format_date( $data->{'budget_period_enddate'} ),
            budget_period_description => $data->{'budget_period_description'},
            budget_period_total       => sprintf ("%.2f",  $data->{'budget_period_total'} ),
            budget_period_active      => $data->{'budget_period_active'},
            budget_period_locked      => $data->{'budget_period_locked'},
        );
    } # IF-MOD
    $template->param(              DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),     );
}

elsif ( $op eq 'add_validate' ) {
## add or modify a budget period (confirmation)

    ## update budget period data
    if ( $budget_period_id ne '' ) {
        my $query = '
                UPDATE aqbudgetperiods
                SET    budget_period_startdate  = ?
                    , budget_period_enddate     = ?
                    , budget_period_description = ?
                    , budget_period_total       = ?
                    , budget_period_locked      = ?
                WHERE budget_period_id          = ?
            ';

        my $sth = $dbh->prepare($query);
        $sth->execute(
            $input->param('budget_period_startdate')   ? format_date_in_iso( $input->param('budget_period_startdate') ) : undef,
            $input->param('budget_period_enddate')     ? format_date_in_iso( $input->param('budget_period_enddate') )   : undef,
            $input->param('budget_period_description') ? $input->param('budget_period_description')                     : undef,
            $input->param('budget_period_total')       ? $input->param('budget_period_total')                           : undef,
            $input->param('budget_period_locked')      ? $input->param('budget_period_locked')                          : undef,
            $input->param('budget_period_id'),
        );

        # IF PASSED ACTIVE - THEN SET IT IN DB TOO.
        set_active($budget_period_id) if ( $budget_period_active == 1 );

    } else {    # ELSE ITS AN ADD
        my $query = "
                INSERT INTO aqbudgetperiods (
                    budget_period_id
                    , budget_period_startdate
                    , budget_period_enddate
                    , budget_period_total
                    , budget_period_description
                    , budget_period_locked )
                VALUES  (?,?,?,?,?,? );
            ";
        my $sth = $dbh->prepare($query);
        $sth->execute(
            $budget_period_id,
            $input->param('budget_period_startdate')   ? format_date_in_iso( $input->param('budget_period_startdate') ) : undef,
            $input->param('budget_period_enddate')     ? format_date_in_iso( $input->param('budget_period_enddate') )   : undef,
            $input->param('budget_period_total')       ? $input->param('budget_period_total')                           : undef,
            $input->param('budget_period_description') ? $input->param('budget_period_description')                     : undef,
            $input->param('budget_period_locked')      ? $input->param('budget_period_locked')                          : undef,
        );
        $budget_period_id = $dbh->last_insert_id( undef, undef, 'aqbudgetperiods', undef );
        set_active($budget_period_id) if ( $budget_period_active == 1 );
    }

    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=aqbudgetperiods.pl\"></html>";    #YUCK
    #    output_html_with_http_headers $input, $cookie, $template->output;   # FIXME: THIS WOULD BE NICER THAN THE PREVIOUS PRINT
    exit;
}

#--------------------------------------------------
elsif ( $op eq 'delete_confirm' ) {
## delete a budget period (preparation)
    my $dbh = C4::Context->dbh;
    ## $total = number of records linked to the record that must be deleted
    my $total = 0;
    my $data = GetBudgetPeriod( $budget_period_id);

    $template->param(
            budget_period_id            => $budget_period_id,
            budget_period_startdate     => format_date($data->{'budget_period_startdate'}),
            budget_period_enddate       => format_date($data->{'budget_period_enddate'}),
            budget_period_total         => $num->format_price(  $data->{'budget_period_total'}   )

#            budget_period_active            => $data->{'budget_period_active'},
#            budget_period_description    => $data->{'budget_period_description'},
#            template                    => C4::Context->preference('template'),  ##  ??!?
    );
}

elsif ( $op eq 'delete_confirmed' ) {
## delete the budget period record

    my $dbh              = C4::Context->dbh;
    my $budget_period_id = uc( $input->param('budget_period_id') );
    my $sth              = $dbh->prepare("DELETE FROM aqbudgetperiods WHERE budget_period_id=?");
    $sth->execute($budget_period_id);
    $sth->finish;
    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=aqbudgetperiods.pl\"></html>";
    exit;
}

else {

# DEFAULT - DISPLAY AQPERIODS TABLE
# -------------------------------------------------------------------
# display the list of budget periods
    my ( $count, $results ) = GetBudgetPeriods();
    my $page = $input->param('page') || 1;
    my $first = ( $page - 1 ) * $pagesize;

    # if we are on the last page, the number of the last word to display
    # must not exceed the length of the results array
    my $last = min( $first + $pagesize - 1, scalar @{$results} - 1, );
    my $toggle = 0;
    my @period_loop;
    foreach my $result ( @{$results}[ $first .. $last ] ) {
        my $budgetperiod = $result;
        $budgetperiod->{'budget_period_startdate'} = format_date( $budgetperiod->{'budget_period_startdate'} );
        $budgetperiod->{'budget_period_enddate'}   = format_date( $budgetperiod->{'budget_period_enddate'} );
        $budgetperiod->{'budget_period_total'}     = $num->format_price( $budgetperiod->{'budget_period_total'} );
        $budgetperiod->{toggle} = ( $toggle++ % 2 eq 0 ? 1 : 0 );
        $budgetperiod->{budget_active} = 1;
        push( @period_loop, $budgetperiod );
    }
    my $budget_period_dropbox = GetBudgetPeriodsDropbox();

    $template->param(
        budget_period_dropbox => $budget_period_dropbox,
        period_loop           => \@period_loop,
#        pagination_bar        => pagination_bar( $script_name, 
#                                                getnbpages( scalar @{$results}, 
#                                                $pagesize ), $page, 'page' )
    );
}

output_html_with_http_headers $input, $cookie, $template->output;

sub set_active {
				my $sth = $dbh->do(
					"UPDATE aqbudgetperiods
                     SET budget_period_active = 0 "
				);
				my $sth = $dbh->do(
					"UPDATE aqbudgetperiods
                     SET budget_period_active = 1
                     WHERE budget_period_id  =  $budget_period_id"
				);
}
