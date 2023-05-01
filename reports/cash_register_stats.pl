#!/usr/bin/perl
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
use C4::Auth qw( get_template_and_user );
use CGI;
use C4::Context;
use C4::Reports qw( GetDelimiterChoices );
use C4::Output qw( output_html_with_http_headers );
use DateTime;
use Koha::DateUtils qw( dt_from_string );
use Text::CSV::Encoded;
use List::Util qw( any );

use Koha::Account::CreditTypes;
use Koha::Account::DebitTypes;

my $input            = CGI->new;
my $dbh              = C4::Context->dbh;

my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => "reports/cash_register_stats.tt",
    query => $input,
    type => "intranet",
    flagsrequired => {reports => '*'},
});

my $do_it            = $input->param('do_it');
my $output           = $input->param("output");
my $basename         = $input->param("basename");
my $transaction_type = $input->param("transaction_type") || 'ACT';
my $manager_branchcode       = $input->param("branch") || C4::Context->userenv->{'branch'};

$template->param(
    do_it => $do_it,
    CGIsepChoice => GetDelimiterChoices,
);

#Initialize date pickers to today
my $fromDate = $input->param("from") || dt_from_string;
my $toDate   = $input->param("to")   || dt_from_string;

my @debit_types =
  Koha::Account::DebitTypes->search()->as_list;
my @credit_types =
  Koha::Account::CreditTypes->search()->as_list;
my $registerid;

if ($do_it) {


    my $whereTType = q{};
    my @extra_params; # if we add conditions to the select we need extra params

    if ($transaction_type eq 'ALL') { #All Transactons
        $whereTType = q{};
    } elsif ($transaction_type eq 'ACT') { #Active
        $whereTType = q{ AND credit_type_code IN ('PAYMENT','CREDIT') };
    } elsif ($transaction_type eq 'FORW') {
        $whereTType = q{ AND credit_type_code IN ('FORGIVEN','WRITEOFF') };
    } else {
        if ( any { $transaction_type eq $_->code } @debit_types ) {
            $whereTType = q{ AND debit_type_code = ? };
            push @extra_params, $transaction_type;
        } else {
            $whereTType = q{ AND credit_type_code = ? };
            push @extra_params, $transaction_type;
        }
    }

    if ( $transaction_type eq 'PAYMENT' || $transaction_type eq 'ACT' ) {
        $whereTType .= q{ AND status != 'VOID' };
    }

    my $whereBranchCode = q{};
    if ($manager_branchcode ne 'ALL') {
        $whereBranchCode = q{ AND m.branchcode = ?};
        push @extra_params, $manager_branchcode;
    }

    my $whereRegister = q{};
    $registerid = $input->param("registerid");
    if ($registerid) {
        $whereRegister = q{ AND al.register_id = ?};
        push @extra_params, $registerid;
    }

    my $query = "
    SELECT round(amount,2) AS amount, al.description,
        bo.surname AS bsurname, bo.firstname AS bfirstname, m.surname AS msurname, m.firstname AS mfirstname,
        bo.cardnumber, br.branchname, bo.borrowernumber,
        al.borrowernumber, DATE(al.date) as date, al.credit_type_code, al.debit_type_code, COALESCE(act.description,al.credit_type_code,adt.description,al.debit_type_code) AS type_description, al.amountoutstanding, al.note, al.timestamp,
        bi.title, bi.biblionumber, i.barcode, i.itype
        FROM accountlines al
        LEFT JOIN borrowers bo ON (al.borrowernumber = bo.borrowernumber)
        LEFT JOIN borrowers m ON (al.manager_id = m.borrowernumber)
        LEFT JOIN cash_registers cr ON (al.register_id = cr.id)
        LEFT JOIN branches br ON (br.branchcode = cr.branch)
        LEFT JOIN items i ON (i.itemnumber = al.itemnumber)
        LEFT JOIN biblio bi ON (bi.biblionumber = i.biblionumber)
        LEFT JOIN account_credit_types act ON (al.credit_type_code = act.code)
        LEFT JOIN account_debit_types adt ON (al.debit_type_code = adt.code)
        WHERE CAST(al.date AS DATE) BETWEEN ? AND ?
        $whereTType
        $whereBranchCode
        $whereRegister
        ORDER BY al.date
    ";
    my $sth_stats = $dbh->prepare($query) or die "Unable to prepare query " . $dbh->errstr;
    $sth_stats->execute($fromDate, $toDate, @extra_params) or die "Unable to execute query " . $sth_stats->errstr;

    my @loopresult;
    my $grantotal = 0;
    while ( my $row = $sth_stats->fetchrow_hashref()) {
        $row->{amountoutstanding} = 0 if (!$row->{amountoutstanding});
        #if ((abs($row->{amount}) - $row->{amountoutstanding}) > 0) {
            $row->{amount} = sprintf("%.2f", abs ($row->{amount}));
            $row->{date} = dt_from_string($row->{date}, 'sql');

            push (@loopresult, $row);
            if($transaction_type eq 'ACT' && ($row->{credit_type_code} !~ /^CREDIT$|^PAYMENT$/)){
                pop @loopresult;
                next;
            }
            if($row->{credit_type_code} =~ /^CREDIT$/){
                $grantotal -= abs($row->{amount});
                $row->{amount} = '-' . $row->{amount};
            }elsif($row->{credit_type_code} eq 'FORGIVEN' || $row->{credit_type_code} eq 'WRITEOFF'){
            }else{
                $grantotal += abs($row->{amount});
            }
        #}
    }

    $grantotal = sprintf("%.2f", $grantotal);

    if($output eq 'screen'){
        $template->param(
            loopresult => \@loopresult,
            total => $grantotal,
        );
    } else{
        my $format = 'csv';
        my $reportname = $input->param('basename');
        my $reportfilename = $reportname ? "$reportname.$format" : "reportresults.$format" ;
        my $delimiter = C4::Context->csv_delimiter;
            my @rows;
            foreach my $row (@loopresult) {
                my @rowValues;
                push @rowValues, $row->{mfirstname}. ' ' . $row->{msurname},
                        $row->{cardnumber},
                        $row->{bfirstname} . ' ' . $row->{bsurname},
                        $row->{branchname},
                        $row->{date},
                        $row->{timestamp},
                        $row->{type_description},
                        $row->{note},
                        $row->{amount},
                        $row->{title},
                        $row->{barcode},
                        $row->{itype};
                    push (@rows, \@rowValues) ;
                }
                my @total;
                for (1..7){push(@total,"")};
                push(@total, $grantotal);
        print $input->header(
            -type       => 'text/csv',
            -encoding    => 'utf-8',
            -attachment => $reportfilename,
            -name       => $reportfilename
         );
        my $csvTemplate = C4::Templates::gettemplate('reports/csv/cash_register_stats.tt', 'intranet', $input);
            $csvTemplate->param(sep => $delimiter, rows => \@rows, total => \@total );
        print $csvTemplate->output;
        exit;
    }

}

$template->param(
    beginDate        => $fromDate,
    endDate          => $toDate,
    transaction_type => $transaction_type,
    branchloop       => Koha::Libraries->search({}, { order_by => ['branchname'] })->unblessed,
    debit_types      => \@debit_types,
    credit_types     => \@credit_types,
    registerid       => $registerid,
    CGIsepChoice => GetDelimiterChoices,
);

output_html_with_http_headers $input, $cookie, $template->output;

1;
