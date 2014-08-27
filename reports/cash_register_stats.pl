#!/usr/bin/perl
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation;
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
use C4::Auth;
use CGI;
use C4::Context;
use C4::Reports;
use C4::Output;
use C4::Koha;
use C4::Circulation;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Budgets qw/GetCurrency GetCurrencies/;
#use Data::Dumper;
#use Smart::Comments;

my $input            = new CGI;
my $dbh              = C4::Context->dbh;
my $fullreportname   = "reports/cash_register_stats.tt";

my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => $fullreportname,
    query => $input,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired => {reports => '*'},
    debug => 1,
});

my $do_it            = $input->param('do_it');
my $output           = $input->param("output");
my $basename         = $input->param("basename");
my $transaction_type = $input->param("transaction_type") || 'ACT';
my $branchcode       = $input->param("branch") || C4::Context->userenv->{'branch'};
our $sep = ",";

$template->param(
    do_it => $do_it,
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);

#Initialize date pickers to today
my $today = C4::Dates->today('iso');
my $fromDate = $today;
my $toDate   = $today;

### fromdate today: $fromDate

my $query_manualinv = "SELECT id, authorised_value FROM authorised_values WHERE category = 'MANUAL_INV'";
my $sth_manualinv = $dbh->prepare($query_manualinv) or die "Unable to prepare query" . $dbh->errstr;
$sth_manualinv->execute() or die "Unable to execute query " . $sth_manualinv->errstr;
my $manualinv_types = $sth_manualinv->fetchall_arrayref({});

### $manualinv_types

if ($do_it) {

    $fromDate = format_date_in_iso($input->param("filter_date_begin"));
    $toDate   = format_date_in_iso($input->param("filter_date_end"));

    my $whereTType = '';

    if ($transaction_type eq 'ALL') { #All Transactons
        $whereTType = '';
    } elsif ($transaction_type eq 'ACT') { #Active
        $whereTType = " accounttype NOT IN ('F', 'FU', 'FOR', 'M', 'L') AND ";
    } else { #Single transac type
        if ($transaction_type eq 'FORW') {
            $whereTType = " accounttype = 'FOR' OR accounttype = 'W' AND ";
        } else {
            $whereTType = " accounttype = '$transaction_type' AND ";
        }
    }

    my $whereBranchCode = '';
    if ($branchcode ne 'ALL') {
        $whereBranchCode = "AND bo.branchcode = '$branchcode'";
    }

    ### $transaction_type;

    my $query = "
    SELECT round(amount,2) AS amount, description,
        bo.surname AS bsurname, bo.firstname AS bfirstname, m.surname AS msurname, m.firstname AS mfirstname,
        bo.cardnumber, br.branchname, bo.borrowernumber,
        al.borrowernumber, DATE(al.date) as date, al.accounttype, al.amountoutstanding,
        bi.title, bi.biblionumber, i.barcode, i.itype
        FROM accountlines al
        LEFT JOIN borrowers bo ON (al.borrowernumber = bo.borrowernumber)
        LEFT JOIN borrowers m ON (al.manager_id = m.borrowernumber)
        LEFT JOIN branches br ON (br.branchcode = m.branchcode )
        LEFT JOIN items i ON (i.itemnumber = al.itemnumber)
        LEFT JOIN biblio bi ON (bi.biblionumber = i.biblionumber)
        WHERE $whereTType
        CAST(al.date AS DATE) BETWEEN ? AND ?
        $whereBranchCode
        ORDER BY al.date
    ";
    my $sth_stats = $dbh->prepare($query) or die "Unable to prepare query" . $dbh->errstr;
    $sth_stats->execute($fromDate, $toDate) or die "Unable to execute query " . $sth_stats->errstr;

    my @loopresult;
    my $grantotal = 0;
    while ( my $row = $sth_stats->fetchrow_hashref()) {
        $row->{amountoutstanding} = 0 if (!$row->{amountoutstanding});
        #if ((abs($row->{amount}) - $row->{amountoutstanding}) > 0) {
            $row->{amount} = sprintf("%.2f", abs ($row->{amount}));
            $row->{date} = format_date($row->{date});
            ### date : $row->{date}

            push (@loopresult, $row);
            $grantotal += abs($row->{amount});
        #}
    }

    my @currency = GetCurrency();
    $grantotal = sprintf("%.2f", $grantotal);

    if($output eq 'screen'){
        $template->param(
            loopresult => \@loopresult,
            total => $grantotal,
        );
    } else{
        binmode STDOUT, ':encoding(UTF-8)';
        print $input->header(
            -type => 'application/vnd.sun.xml.calc',
            -encoding => 'utf-8',
            -name => "$basename.csv",
            -attachment => "$basename.csv"
        );

        print "Manager name".$sep;
        print "Borrower cardnumber".$sep;
        print "Borrower name".$sep;
        print "Branch".$sep;
        print "Transaction date".$sep;
        print "Transaction type".$sep;
        print "Amount".$sep;
        print "Biblio title".$sep;
        print "Barcode".$sep;
        print "Document type"."\n";

        foreach my $item (@loopresult){
            print $item->{mfirstname}. ' ' . $item->{msurname} . $sep;
            print $item->{cardnumber}.$sep;
            print $item->{bfirstname}. ' ' . $item->{bsurname} . $sep;
            print $item->{branchname}.$sep;
            print $item->{date}.$sep;
            print $item->{accounttype}.$sep;
            print $item->{amount}.$sep;
            print $item->{title}.$sep;
            print $item->{barcode}.$sep;
            print $item->{itype}."\n";
        }

        print $sep x 6;
        print $grantotal."\n";
        exit(1);
    }

}

### fromdate final: $fromDate
### toDate final: $toDate
$template->param(
    beginDate        => format_date($fromDate),
    endDate          => format_date($toDate),
    transaction_type => $transaction_type,
    branchloop       => C4::Branch::GetBranchesLoop($branchcode),
    manualinv_types  => $manualinv_types,
);
output_html_with_http_headers $input, $cookie, $template->output;

1;
