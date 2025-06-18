#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Parts copyright 2010 BibLibre
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use CGI        qw(-oldstyle_urls -utf8);
use C4::Auth   qw( get_template_and_user );
use Text::CSV_XS;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patron::Attribute::Types;
use DateTime;
use DateTime::Format::MySQL;

my $input               = CGI->new;
my $showall             = $input->param('showall');
my $bornamefilter       = $input->param('borname')       || '';
my $borcatfilter        = $input->param('borcat')        || '';
my $itemtypefilter      = $input->param('itemtype')      || '';
my $borflagsfilter      = $input->param('borflag')       || '';
my $branchfilter        = $input->param('branch')        || '';
my $homebranchfilter    = $input->param('homebranch')    || '';
my $holdingbranchfilter = $input->param('holdingbranch') || '';
my $dateduefrom         = $input->param('dateduefrom');
my $datedueto           = $input->param('datedueto');
my $op                  = $input->param('op') || '';

if ($dateduefrom) {
    $dateduefrom = dt_from_string($dateduefrom);
}
if ($datedueto) {
    $datedueto = dt_from_string($datedueto)->set_hour(23)->set_minute(59);
}

my $filters = {
    itemtype      => $itemtypefilter,
    borname       => $bornamefilter,
    borcat        => $borcatfilter,
    itemtype      => $itemtypefilter,
    borflag       => $borflagsfilter,
    branch        => $branchfilter,
    homebranch    => $homebranchfilter,
    holdingbranch => $holdingbranchfilter,
    dateduefrom   => $dateduefrom,
    datedueto     => $datedueto,
    showall       => $showall,
};

my $isfiltered = $op =~ /apply/i && $op =~ /filter/i;
my $noreport = C4::Context->preference('FilterBeforeOverdueReport') && !$isfiltered && $op ne "csv";

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/overdue.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => "overdues_report" },
    }
);

our $logged_in_user = Koha::Patrons->find($loggedinuser);

my $dbh = C4::Context->dbh;

my $req;
$req = $dbh->prepare("select categorycode, description from categories order by description");
$req->execute;
my @borcatloop;
while ( my ( $catcode, $description ) = $req->fetchrow ) {
    push @borcatloop, {
        value    => $catcode,
        selected => $catcode eq $borcatfilter ? 1 : 0,
        catname  => $description,
    };
}

$req = $dbh->prepare("select itemtype, description from itemtypes order by description");
$req->execute;
my @itemtypeloop;
while ( my ( $itemtype, $description ) = $req->fetchrow ) {
    push @itemtypeloop, {
        value        => $itemtype,
        selected     => $itemtype eq $itemtypefilter ? 1 : 0,
        itemtypename => $description,
    };
}

# Filtering by Patron Attributes
#  @patron_attr_filter_loop        is non empty if there are any patron attribute filters
#  %cgi_attrcode_to_attrvalues     contains the patron attribute filter values, as returned by the CGI
#  %borrowernumber_to_attributes   is populated by those borrowernumbers matching the patron attribute filters

my %cgi_attrcode_to_attrvalues;    # ( patron_attribute_code => [ zero or more attribute filter values from the CGI ] )
for my $attrcode ( grep { /^patron_attr_filter_/ } $input->multi_param ) {
    if ( my @attrvalues = grep { length($_) > 0 } $input->multi_param($attrcode) ) {
        $attrcode =~ s/^patron_attr_filter_//;
        $cgi_attrcode_to_attrvalues{$attrcode} = \@attrvalues;
    }
}
my $have_pattr_filter_data = keys(%cgi_attrcode_to_attrvalues) > 0;

my @patron_attr_filter_loop
    ; # array of [ domid cgivalue ismany isclone ordinal code description repeatable is_date authorised_value_category ]

my $patron_attrs = Koha::Patron::Attribute::Types->search_with_library_limits(
    {
        staff_searchable => 1,
    },
    {},
    C4::Context->userenv->{'branch'}
);

my $ordinal = 0;
while ( my $attr = $patron_attrs->next ) {
    my $row = {
        code                      => $attr->code,
        description               => $attr->description,
        repeatable                => $attr->repeatable,
        is_date                   => $attr->is_date,
        authorised_value_category => $attr->authorised_value_category,
    };
    $row->{ordinal} = $ordinal;
    my $code      = $row->{code};
    my $cgivalues = $cgi_attrcode_to_attrvalues{$code} || [''];
    my $isclone   = 0;
    $row->{ismany} = @$cgivalues > 1;
    my $serial = 0;
    for (@$cgivalues) {
        $row->{domid}    = $ordinal * 1000 + $serial;
        $row->{cgivalue} = $_;
        $row->{isclone}  = $isclone;
        push @patron_attr_filter_loop, {%$row};    # careful: must store a *deep copy* of the modified row
    } continue {
        $isclone = 1, ++$serial;
    }
} continue {
    ++$ordinal;
}

my %borrowernumber_to_attributes;  # hash of { borrowernumber => { attrcode => [ [val,display], [val,display], ... ] } }
                                   #   i.e. val differs from display when attr is an authorised value
if (@patron_attr_filter_loop) {

    # MAYBE FIXME: currently, *all* borrower_attributes are loaded into %borrowernumber_to_attributes
    #              then filtered and honed down to match the patron attribute filters. If this is
    #              too resource intensive, MySQL can be used to do the filtering, i.e. rewire the
    #              SQL below to select only those attribute values that match the filters.

    my $sql = q{
        SELECT b.borrowernumber AS bn, b.code AS attrcode, b.attribute AS attrval, a.lib AS avdescription
        FROM borrower_attributes b
        JOIN borrower_attribute_types bt ON (b.code = bt.code)
        LEFT JOIN authorised_values a ON (a.category = bt.authorised_value_category AND a.authorised_value = b.attribute)
    };
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while ( my $row = $sth->fetchrow_hashref ) {
        my $pattrs = $borrowernumber_to_attributes{ $row->{bn} } ||= {};
        push @{ $pattrs->{ $row->{attrcode} } }, [
            $row->{attrval},
            defined $row->{avdescription} ? $row->{avdescription} : $row->{attrval},
        ];
    }

    for my $bn ( keys %borrowernumber_to_attributes ) {
        my $pattrs = $borrowernumber_to_attributes{$bn};
        my $keep   = 1;
        for my $code ( keys %cgi_attrcode_to_attrvalues ) {

            # discard patrons that do not match (case insensitive) at least one of each attribute filter value
            my $discard = 1;
            for my $attrval ( map { lc $_ } @{ $cgi_attrcode_to_attrvalues{$code} } ) {
                if ( grep { $attrval eq lc( $_->[0] ) } @{ $pattrs->{$code} } ) {
                    $discard = 0;
                    last;
                }
            }
            if ($discard) {
                $keep = 0;
                last;
            }
        }
        delete $borrowernumber_to_attributes{$bn} if !$keep;
    }
}

$template->param(
    patron_attr_header_loop =>
        [ map { { header => $_->{description} } } grep { !$_->{isclone} } @patron_attr_filter_loop ],
    filters                 => $filters,
    borcatloop              => \@borcatloop,
    itemtypeloop            => \@itemtypeloop,
    patron_attr_filter_loop => \@patron_attr_filter_loop,
    showall                 => $showall,
);

if ($noreport) {

    # la de dah ... page comes up presto-quicko
    $template->param( noreport => $noreport );
} else {

    # FIXME : the left joins + where clauses make the following SQL query really slow with large datasets :(
    #
    #  FIX 1: use the table with the least rows as first in the join, second least second, etc
    #         ref: http://www.fiftyfoureleven.com/weblog/web-development/programming-and-scripts/mysql-optimization-tip
    #
    #  FIX 2: ensure there are indexes for columns participating in the WHERE clauses, where feasible/reasonable

    my $today_dt = dt_from_string();
    $today_dt->truncate( to => 'minute' );
    my $todaysdate = $today_dt->strftime('%Y-%m-%d %H:%M');

    $bornamefilter =~ s/\*/\%/g;
    $bornamefilter =~ s/\?/\_/g;

    my $strsth = "SELECT date_due,
        borrowers.title as borrowertitle,
        borrowers.surname,
        borrowers.firstname,
        borrowers.streetnumber,
        borrowers.streettype,
        borrowers.address,
        borrowers.address2,
        borrowers.city,
        borrowers.zipcode,
        borrowers.country,
        borrowers.phone,
        borrowers.email,
        borrowers.cardnumber,
        borrowers.borrowernumber,
        borrowers.branchcode,
        issues.itemnumber,
        issues.issuedate,
        items.datelastborrowed,
        items.barcode,
        items.homebranch,
        items.holdingbranch,
        items.location,
        biblio.title,
        biblio.subtitle,
        biblio.part_number,
        biblio.part_name,
        biblio.author,
        biblio.biblionumber,
        items.itemcallnumber,
        items.replacementprice,
        items.enumchron,
        items.itemnotes_nonpublic,
        items.itype,
        return_claims.created_on AS return_claim_created_on,
        return_claims.id AS return_claim_id
      FROM issues
    LEFT JOIN borrowers   ON (issues.borrowernumber=borrowers.borrowernumber )
    LEFT JOIN items       ON (issues.itemnumber=items.itemnumber)
    LEFT JOIN biblioitems ON (biblioitems.biblioitemnumber=items.biblioitemnumber)
    LEFT JOIN biblio      ON (biblio.biblionumber=items.biblionumber )
    LEFT JOIN return_claims ON (return_claims.borrowernumber=borrowers.borrowernumber AND return_claims.itemnumber=items.itemnumber)
    WHERE 1=1 ";    # placeholder, since it is possible that none of the additional
                    # conditions will be selected by user
    $strsth .= " AND date_due               < '" . $todaysdate . "' " unless ( $showall or $datedueto );

    my @bind_values;
    if ($bornamefilter) {
        $strsth .= " AND (borrowers.firstname like ? or borrowers.surname like ? or borrowers.cardnumber like ?)";
        push @bind_values, "$bornamefilter%", "$bornamefilter%", "$bornamefilter%";
    }
    if ($borcatfilter) {
        $strsth .= " AND borrowers.categorycode = ? ";
        push @bind_values, $borcatfilter;
    }
    if ($itemtypefilter) {
        if ( C4::Context->preference('item-level_itypes') ) {
            $strsth .= " AND items.itype   = ? ";
        } else {
            $strsth .= " AND biblioitems.itemtype   = ? ";
        }
        push @bind_values, $itemtypefilter;
    }
    if ( $borflagsfilter eq 'gonenoaddress' ) {
        $strsth .= " AND borrowers.gonenoaddress <> 0";
    } elsif ( $borflagsfilter eq 'debarred' ) {
        $strsth .= " AND borrowers.debarred >=  CURDATE()";
    } elsif ( $borflagsfilter eq 'lost' ) {
        $strsth .= " AND borrowers.lost <> 0";
    }
    if ($branchfilter) {
        $strsth .= " AND borrowers.branchcode   = ? ";
        push @bind_values, $branchfilter;
    }
    if ($homebranchfilter) {
        $strsth .= " AND items.homebranch       = ? ";
        push @bind_values, $homebranchfilter;
    }
    if ($holdingbranchfilter) {
        $strsth .= " AND items.holdingbranch    = ? ";
        push @bind_values, $holdingbranchfilter;
    }
    if ($dateduefrom) {
        $strsth .= " AND date_due >= ?";
        push @bind_values, DateTime::Format::MySQL->format_datetime($dateduefrom);
    }
    if ($datedueto) {
        $strsth .= " AND date_due <= ?";
        push @bind_values, DateTime::Format::MySQL->format_datetime($datedueto);
    }

    # restrict patrons (borrowers) to those matching the patron attribute filter(s), if any
    my $bnlist = $have_pattr_filter_data ? join( ',', keys %borrowernumber_to_attributes ) : '';
    $strsth =~ s/WHERE 1=1/WHERE 1=1 AND borrowers.borrowernumber IN ($bnlist)/ if $bnlist;
    $strsth =~ s/WHERE 1=1/WHERE 0=1/
        if $have_pattr_filter_data && !$bnlist;    # no match if no borrowers matched patron attrs
    $strsth .= " ORDER BY date_due, surname, firstname";
    $template->param( sql => $strsth );
    my $sth = $dbh->prepare($strsth);
    $sth->execute(@bind_values);

    my @overduedata;
    while ( my $data = $sth->fetchrow_hashref ) {

        # most of the overdue report data is linked to the database schema, i.e. things like borrowernumber and phone
        # but the patron attributes (patron_attr_value_loop) are unnormalised and varies dynamically from one db to the next

        my $pattrs = $borrowernumber_to_attributes{ $data->{borrowernumber} } || {};    # patron attrs for this borrower
            # $pattrs is a hash { attrcode => [  [value,displayvalue], [value,displayvalue]... ] }

        my @patron_attr_value_loop;    # template array [ {value=>v1}, {value=>v2} ... } ]
        for my $pattr_filter ( grep { !$_->{isclone} } @patron_attr_filter_loop ) {
            my @displayvalues =
                map { $_->[1] } @{ $pattrs->{ $pattr_filter->{code} } };    # grab second value from each subarray
            push @patron_attr_value_loop, { value => join( ', ', sort { lc $a cmp lc $b } @displayvalues ) };
        }

        push @overduedata, {
            patron                  => Koha::Patrons->find( $data->{borrowernumber} ),
            duedate                 => $data->{date_due},
            borrowernumber          => $data->{borrowernumber},
            cardnumber              => $data->{cardnumber},
            borrowertitle           => $data->{borrowertitle},
            surname                 => $data->{surname},
            firstname               => $data->{firstname},
            streetnumber            => $data->{streetnumber},
            streettype              => $data->{streettype},
            address                 => $data->{address},
            address2                => $data->{address2},
            city                    => $data->{city},
            zipcode                 => $data->{zipcode},
            country                 => $data->{country},
            phone                   => $data->{phone},
            email                   => $data->{email},
            branchcode              => $data->{branchcode},
            barcode                 => $data->{barcode},
            datelastborrowed        => $data->{datelastborrowed},
            itemnum                 => $data->{itemnumber},
            issuedate               => $data->{issuedate},
            biblionumber            => $data->{biblionumber},
            title                   => $data->{title},
            subtitle                => $data->{subtitle},
            part_number             => $data->{part_number},
            part_name               => $data->{part_name},
            author                  => $data->{author},
            homebranchcode          => $data->{homebranch},
            holdingbranchcode       => $data->{holdingbranch},
            location                => $data->{location},
            itemcallnumber          => $data->{itemcallnumber},
            replacementprice        => $data->{replacementprice},
            itemnotes_nonpublic     => $data->{itemnotes_nonpublic},
            return_claim_created_on => $data->{return_claim_created_on},
            return_claim_id         => $data->{return_claim_id},
            enumchron               => $data->{enumchron},
            itemtype                => $data->{itype},
            overdue                => DateTime->compare( dt_from_string( $data->{date_due} ), $today_dt ) == -1 ? 1 : 0,
            patron_attr_value_loop => \@patron_attr_value_loop,
        };
    }

    if ( $op eq 'csv' ) {
        binmode( STDOUT, ":encoding(UTF-8)" );
        my $csv = build_csv( \@overduedata );
        print $input->header(
            -type       => 'application/vnd.sun.xml.calc',
            -encoding   => 'utf-8',
            -attachment => "overdues.csv",
            -filename   => "overdues.csv"
        );
        print $csv;
        exit;
    }

    # generate parameter list for CSV download link
    my $new_cgi = CGI->new($input);
    $new_cgi->delete('op');

    $template->param(
        todaysdate            => $today_dt,
        overdueloop           => \@overduedata,
        nnoverdue             => scalar(@overduedata),
        noverdue_is_plural    => scalar(@overduedata) != 1,
        noreport              => $noreport,
        isfiltered            => $isfiltered,
        borflag_gonenoaddress => $borflagsfilter eq 'gonenoaddress',
        borflag_debarred      => $borflagsfilter eq 'debarred',
        borflag_lost          => $borflagsfilter eq 'lost',
    );

}

output_html_with_http_headers $input, $cookie, $template->output;

sub build_csv {
    my $overdues = shift;

    return "" if scalar(@$overdues) == 0;

    my @lines = ();

    # build header ...
    my @keys =
        qw ( duedate title author borrowertitle firstname surname phone barcode email address address2 zipcode city country
        branchcode datelastissued itemcallnumber biblionumber borrowernumber itemnum issuedate replacementprice itemnotes_nonpublic streetnumber streettype);
    my $csv = Text::CSV_XS->new( { formula => "empty" } );
    $csv->combine(@keys);
    push @lines, $csv->string();

    my @private_keys =
        qw( borrowertitle firstname surname phone email address address2 zipcode city country streetnumber streettype );

    # ... and rest of report
    foreach my $overdue ( @{$overdues} ) {
        unless ( $logged_in_user->can_see_patron_infos( $overdue->{patron} ) ) {
            $overdue->{$_} = undef for @private_keys;
        }
        push @lines, $csv->string() if $csv->combine( map { $overdue->{$_} } @keys );
    }

    return join( "\n", @lines ) . "\n";
}
