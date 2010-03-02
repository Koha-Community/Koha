#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
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

use strict;
# use warnings; # FIXME
use C4::Context;
use C4::Output;
use CGI;
use C4::Auth;
use C4::Branch;
use C4::Overdues qw/GetOverduesByBorrowers/;
use C4::Dates qw/format_date format_date_in_iso/;
use Date::Calc qw/Today/;
use Text::CSV_XS;

my $input = new CGI;
my $order   = $input->param( 'order' ) || '';
my $showall = $input->param('showall');

my  $bornamefilter = $input->param( 'borname');
my   $borcatfilter = $input->param( 'borcat' );
my $itemtypefilter = $input->param('itemtype');
my $borflagsfilter = $input->param('borflags') || "";
my   $branchfilter = $input->param( 'branch' );
my $op             = $input->param(   'op'   ) || '';

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/overdue.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => 1, circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my $dbh = C4::Context->dbh;

my $req;
$req = $dbh->prepare( "select categorycode, description from categories order by description");
$req->execute;
my @borcatloop;
while (my ($catcode, $description) =$req->fetchrow) {
    push @borcatloop, {
        value    => $catcode,
        selected => $catcode eq $borcatfilter ? 1 : 0,
        catname  => $description,
    };
}

$req = $dbh->prepare( "select itemtype, description from itemtypes order by description");
$req->execute;
my @itemtypeloop;
while (my ($itemtype, $description) =$req->fetchrow) {
    push @itemtypeloop, {
        value        => $itemtype,
        selected     => $itemtype eq $itemtypefilter ? 1 : 0,
        itemtypename => $description,
    };
}
my $onlymine=C4::Context->preference('IndependantBranches') && 
             C4::Context->userenv && 
             C4::Context->userenv->{flags}!=1 && 
             C4::Context->userenv->{branch};

$branchfilter = C4::Context->userenv->{'branch'} if ($onlymine && !$branchfilter);

$template->param(
    branchloop   => GetBranchesLoop($branchfilter, $onlymine),
    branchfilter => $branchfilter,
    borcatloop   => \@borcatloop,
    itemtypeloop => \@itemtypeloop,
    borname      => $bornamefilter,
    order        => $order,
    showall      => $showall,
    csv_param_string => $input->query_string(),
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    dateduefrom => $input->param( 'dateduefrom' ) || '',
    datedueto   => $input->param( 'datedueto' ) || '',
);

my @sort_roots = qw(borrower title barcode date_due);
push @sort_roots, map {$_ . " desc"} @sort_roots;
my @order_loop = ({selected => $order ? 0 : 1});   # initial blank row
foreach (@sort_roots) {
    my $tmpl_name = $_;
    $tmpl_name =~ s/\s/_/g;
    push @order_loop, {
        selected => $order eq $_ ? 1 : 0,
        ordervalue => $_,
        foo => $tmpl_name,
        'order_' . $tmpl_name => 1,
    };
}
$template->param(ORDER_LOOP => \@order_loop);

my $todaysdate = sprintf("%-04.4d-%-02.2d-%02.2d", Today());

$bornamefilter =~s/\*/\%/g;
$bornamefilter =~s/\?/\_/g;

my $dateduefrom = format_date_in_iso($input->param( 'dateduefrom' ));
my $datedueto   = format_date_in_iso($input->param( 'datedueto' ));

my @overduedata = @{GetOverduesByBorrowers($branchfilter, $borcatfilter, $itemtypefilter, $borflagsfilter, $bornamefilter, $order, $dateduefrom, $datedueto)};

$template->param(
    todaysdate  => format_date($todaysdate),
    overdueloop => \@overduedata 
);

# download the complete CSV
if ($op eq 'csv') {
        binmode(STDOUT, ":utf8");
        my $csv = build_csv(\@overduedata);
        print $input->header(-type => 'application/vnd.sun.xml.calc',
                             -encoding    => 'utf-8',
                             -attachment=>"overdues.csv",
                             -filename=>"overdues.csv" );
        print $csv;
        exit;
}

output_html_with_http_headers $input, $cookie, $template->output;


sub build_csv {
    my $overdues = shift;

    return "" if scalar(@$overdues) == 0;

    my @lines = ();

    # build header ...
    my @keys = (
        'borrowernumber',
        'title',
        'firstname',
        'surname',
        'address',
        'city',
        'zipcode',
        'phone',
        'email',
        'branchcode',
        'overdues'
    );

    my $csv = Text::CSV_XS->new({
        binary   => 1,
        sep_char => C4::Context->preference("delimiter") ? 
                    C4::Context->preference("delimiter") : ';' ,
    });
    $csv->combine(@keys);
    push @lines, $csv->string();

    # ... and rest of report
    foreach my $overdue ( @{ $overdues } ) {
        my $issues;
        foreach my $issue ( @{$overdue->{overdues} }){
            $issues .= "$issue->{title} / $issue->{author} / $issue->{itemcallnumber} / $issue->{barcode} / ".$issue->{issuedate}. " - " . $issue->{date_due} . " \r\n";
        }
        push @lines, $csv->string() if $csv->combine(
            $overdue->{borrowernumber},
            $overdue->{title},
            $overdue->{firstname},
            $overdue->{surname},
            $overdue->{address},
            $overdue->{city},
            $overdue->{zipcode},
            $overdue->{phone},
            $overdue->{email},
            $overdue->{branchcode},
            $issues,
        );
    }

    return join("\n", @lines) . "\n";
}
