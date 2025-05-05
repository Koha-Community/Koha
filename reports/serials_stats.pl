#!/usr/bin/perl

# Copyright 2009 SARL Biblibre
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
use CGI      qw ( -utf8 );
use C4::Context;
use C4::Output  qw( output_html_with_http_headers );
use C4::Reports qw( GetDelimiterChoices );
use C4::Serials qw( GetExpirationDate HasSubscriptionExpired );

=head1 serials_out

plugin that shows a stats on serials

=head1 DESCRIPTION

=cut

my $input        = CGI->new;
my $templatename = "reports/serials_stats.tt";
my $do_it        = $input->param("do_it");
my $bookseller   = $input->param("bookseller");
my $branchcode   = $input->param("branchcode");
my $expired      = $input->param("expired");
my $order        = $input->param("order");
my $output       = $input->param("output");
my $basename     = $input->param("basename");
our $sep = C4::Context->csv_delimiter( scalar $input->param("sep") );

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => $templatename,
        query         => $input,
        type          => "intranet",
        flagsrequired => { reports => '*' },
    }
);

my $dbh = C4::Context->dbh;

if ($do_it) {
    my $where = "WHERE 1 ";
    my @args;

    # if a specific branchcode was selected
    if ( $branchcode ne '' ) {
        $where .= "AND branchcode = ? ";
        push @args, $branchcode;
    }

    # if a specific bookseller was selected
    if ( $bookseller ne '' ) {
        $where .= "AND aqbooksellerid = ? ";
        push @args, $bookseller;
    }

    my $sth = $dbh->prepare(
        "SELECT * 
                             FROM subscription 
                               LEFT JOIN aqbooksellers 
                               ON (aqbooksellers.id=subscription.aqbooksellerid)
                               LEFT JOIN biblio
                               ON (biblio.biblionumber=subscription.biblionumber)
                               $where
                            "
    );

    $sth->execute(@args);

    ## hash generation of items by branchcode
    my @datas;

    while ( my $row = $sth->fetchrow_hashref ) {
        $row->{'enddate'} = GetExpirationDate( $row->{'subscriptionid'} );
        $row->{expired}   = HasSubscriptionExpired( $row->{subscriptionid} );
        push @datas,
            $row if (
            $expired
            or (
                not $expired
                and (   not $row->{expired}
                    and not $row->{closed} )
            )
            );
    }

    if ( $output eq 'screen' ) {
        $template->param(
            datas => \@datas,
            do_it => 1
        );
    } else {
        binmode STDOUT, ':encoding(UTF-8)';
        print $input->header(
            -type       => 'application/vnd.sun.xml.calc',
            -encoding   => 'utf-8',
            -name       => "$basename.csv",
            -attachment => "$basename.csv"
        );
        print "Vendor" . $sep;
        print "Title" . $sep;
        print "Subscription id" . $sep;
        print "Branch" . $sep;
        print "Callnumber" . $sep;
        print "Subscription Begin" . $sep;
        print "Subscription End\n";

        foreach my $item (@datas) {
            print $item->{name} . $sep;
            print $item->{title} . $sep;
            print $item->{subscriptionid} . $sep;
            print $item->{branchcode} . $sep;
            print $item->{callnumber} . $sep;
            print $item->{startdate} . $sep;
            print $item->{enddate} . "\n";
        }
        exit;
    }
} else {
    ## We generate booksellers list
    my @booksellers;

    my $sth = $dbh->prepare(
        "SELECT aqbooksellerid, aqbooksellers.name 
                                FROM subscription 
                                  LEFT JOIN aqbooksellers ON (subscription.aqbooksellerid=aqbooksellers.id ) 
                                GROUP BY aqbooksellerid, aqbooksellers.name
                                ORDER BY aqbooksellers.name ASC
        "
    );
    $sth->execute();

    while ( my $row = $sth->fetchrow_hashref ) {
        push( @booksellers, $row );
    }

    my $CGIextChoice = ('CSV');               # FIXME translation
    my $CGIsepChoice = GetDelimiterChoices;
    $template->param(
        CGIextChoice => $CGIextChoice,
        CGIsepChoice => $CGIsepChoice,
        booksellers  => \@booksellers,
    );
}

output_html_with_http_headers $input, $cookie, $template->output;
