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

use Modern::Perl;
use C4::Auth;
use CGI;
use C4::Context;
use C4::Reports;
use C4::Output;
use C4::Koha;
use C4::Circulation;
use DateTime;
use Koha::DateUtils;
use Text::CSV::Encoded;

my $input            = new CGI;
my $dbh              = C4::Context->dbh;

my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => "reports/cash_register_stats.tt",
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
my $manager_branchcode       = $input->param("branch") || C4::Context->userenv->{'branch'};

$template->param(
    do_it => $do_it,
    CGIsepChoice => GetDelimiterChoices,
);

#Initialize date pickers to today
my $fromDate = dt_from_string;
my $toDate   = dt_from_string;

my $query_manualinv = "SELECT id, authorised_value FROM authorised_values WHERE category = 'MANUAL_INV'";
my $sth_manualinv = $dbh->prepare($query_manualinv) or die "Unable to prepare query" . $dbh->errstr;
$sth_manualinv->execute() or die "Unable to execute query " . $sth_manualinv->errstr;
my $manualinv_types = $sth_manualinv->fetchall_arrayref({});


if ($do_it) {

    $fromDate = output_pref({ dt => eval { dt_from_string($input->param("from")) } || dt_from_string,
            dateformat => 'sql', dateonly => 1 }); #for sql query
    $toDate   = output_pref({ dt => eval { dt_from_string($input->param("to")) } || dt_from_string,
            dateformat => 'sql', dateonly => 1 }); #for sql query

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
    if ($manager_branchcode ne 'ALL') {
        $whereBranchCode = "AND m.branchcode = '$manager_branchcode'";
    }


    my $query = "
    SELECT round(amount,2) AS amount, description,
        bo.surname AS bsurname, bo.firstname AS bfirstname, m.surname AS msurname, m.firstname AS mfirstname,
        bo.cardnumber, br.branchname, bo.borrowernumber,
        al.borrowernumber, DATE(al.date) as date, al.accounttype, al.amountoutstanding, al.note,
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
            $row->{date} = dt_from_string($row->{date}, 'sql');

            push (@loopresult, $row);
            if($transaction_type eq 'ACT' && ($row->{accounttype} !~ /^C$|^CR$|^LR$|^Pay$/)){
                pop @loopresult;
                next;
            }
            if($row->{accounttype} =~ /^C$|^CR$|^LR$/){
                $grantotal -= abs($row->{amount});
                $row->{amount} = '-' . $row->{amount};
            }elsif($row->{accounttype} eq 'FORW' || $row->{accounttype} eq 'W'){
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
        binmode STDOUT, ':encoding(UTF-8)';
        my $q_errors;
        my $format = 'csv';
        my $reportname = $input->param('basename');
        my $reportfilename = $reportname ? "$reportname.$format" : "reportresults.$format" ;
        #my $reportfilename = "$reportname.html" ;
        my $delimiter = C4::Context->preference('delimiter') || ',';
        my ( $type, $content );
        if ( $format eq 'csv' ) {
            my $type = 'application/csv';
            my $csv = Text::CSV::Encoded->new({ encoding_out => 'UTF-8', sep_char => $delimiter});
            $csv or die "Text::CSV::Encoded->new({binary => 1}) FAILED: " . Text::CSV::Encoded->error_diag();
            my @headers = ();
            push @headers, "mfirstname",
                        "cardnumber",
                        "bfirstname",
                        "branchname",
                        "date",
                        "accounttype",
                        "amount",
                        "title",
                        "barcode",
                        "itype";
            if ($csv->combine(@headers)) {
                $content .= Encode::decode('UTF-8', $csv->string()) . "\n";
            } else {
                push @$q_errors, { combine => 'HEADER ROW: ' . $csv->error_diag() } ;
            }
            foreach my $row (@loopresult) {
                my @rowValues = ();
                push @rowValues, $row->{mfirstname},
                        $row->{cardnumber},
                        $row->{bfirstname},
                        $row->{branchname},
                        $row->{date},
                        $row->{accounttype},
                        $row->{amount},
                        $row->{title},
                        $row->{barcode};
                        $row->{itype};
                if ($csv->combine(@rowValues)) {
                    $content .= Encode::decode('UTF-8',$csv->string()) . "\n";
                } else {
                    push @$q_errors, { combine => $csv->error_diag() } ;
                }
            }
        }
        print $input->header(
            -type => $type,
            -attachment=> $reportfilename
        );
        print $content;

        print $delimiter x 6;
        print $grantotal."\n";
        foreach my $err (@$q_errors) {
            print "# ERROR: " . (map {$_ . ": " . $err->{$_}} keys %$err) . "\n";
        }   # here we print all the non-fatal errors at the end.  Not super smooth, but better than nothing.
        exit(1);
    }

}

$template->param(
    beginDate        => $fromDate,
    endDate          => $toDate,
    transaction_type => $transaction_type,
    branchloop       => C4::Branch::GetBranchesLoop($manager_branchcode),
    manualinv_types  => $manualinv_types,
    CGIsepChoice => GetDelimiterChoices,
);

output_html_with_http_headers $input, $cookie, $template->output;

1;
