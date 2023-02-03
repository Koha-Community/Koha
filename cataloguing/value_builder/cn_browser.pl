#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

# Copyright 2015 Koha Development Team
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
use C4::ClassSource qw( GetClassSort );
use C4::Output qw( output_html_with_http_headers );

use Koha::ClassSources;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};
    my $res = "
<script>

function Click$function_name(ev) {
    ev.preventDefault();
    q = document.getElementById(ev.data.id);
    window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=cn_browser.pl&popup&q=\"+encodeURIComponent(q.value),\"cnbrowser\",\"width=500,height=400,toolbar=false,scrollbars=yes\");
}

</script>
";
    return $res;
};

my $launcher = sub {
    my ( $params ) = @_;
    my $cgi = $params->{cgi};
    my $results_per_page = 30;
    my $current_page = $cgi->param('page') || 1;

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/cn_browser.tt",
            query           => $cgi,
            type            => "intranet",
            flagsrequired   => { catalogue => 1 },
        }
    );

    my $dbh = C4::Context->dbh;
    my $sth;
    my @cn;
    my $query;
    my $real_limit = $results_per_page / 2;
    my $rows_lt    = 999;
    my $rows_gt    = 999;
    my $search;
    my $globalGreen = 0;
    my $lt          = '';
    my $gt          = '';
    my $q;

    if ( $q = $cgi->param('q') ) {
        $search = $q;
    }
    if ( $cgi->param('lt') ) {
        $lt     = $cgi->param('lt');
        $search = $lt;
    }
    if ( $cgi->param('gt') ) {
        $gt     = $cgi->param('gt');
        $search = $gt;
    }

    my $cn_source = $cgi->param('cn_source') || C4::Context->preference("DefaultClassificationSource");
    my @class_sources = Koha::ClassSources->search({ used => 1});

    #Don't show half the results of show lt or gt
    $real_limit = $results_per_page if $search ne $q;
    my $cn_sort = GetClassSort( $cn_source, undef, $search );

    my $red = 0;
    if ( $search ne $gt ) {
        my $green = 0;

        #Results before the cn_sort
        $query = "SELECT b.title, b.subtitle, itemcallnumber, biblionumber, barcode, cn_sort, branchname, author, ccode
        FROM items AS i
        JOIN biblio AS b USING (biblionumber)
        LEFT OUTER JOIN branches ON (branches.branchcode = homebranch)
        WHERE cn_sort < ?
        AND itemcallnumber != ''
        ORDER BY cn_sort DESC, itemnumber
        LIMIT $real_limit;";
        $sth = $dbh->prepare($query);
        $sth->execute($cn_sort);
        while ( my $data = $sth->fetchrow_hashref ) {
            if ( $data->{itemcallnumber} eq $q ) {
                $data->{background} = 'red';
                $red = 1;
            } elsif ( $data->{cn_sort} lt $cn_sort && !$green && !$red ) {
                if ( $#cn != -1 ) {
                    unshift @cn, { 'background' => 'green' };
                    $globalGreen = 1;
                }
                $green = 1;
            }
            unshift @cn, $data;
        }
        $rows_lt = $sth->rows;
    }

    if ( $search ne $lt ) {
        my $green = 0;

        #Results after the cn_sort
        $query = "SELECT b.title, b.subtitle, itemcallnumber, biblionumber, barcode, cn_sort, branchname, author, ccode
        FROM items AS i
        JOIN biblio AS b USING (biblionumber)
        LEFT OUTER JOIN branches ON (branches.branchcode = homebranch)
        WHERE i.cn_sort >= '$cn_sort'
        AND itemcallnumber != ''
        ORDER BY cn_sort, itemnumber
        LIMIT $real_limit";
        $sth = $dbh->prepare($query);
        $sth->execute();

        while ( my $data = $sth->fetchrow_hashref ) {
            if ( $data->{itemcallnumber} eq $q ) {
                $data->{background} = 'red';
                $red = 1;
            } elsif ( $data->{cn_sort} gt $cn_sort && !$green && !$red && !$globalGreen ) {
                push @cn, { 'background' => 'green' };
                $green = 1;
            }
            push @cn, $data;
        }
        $rows_gt = $sth->rows;

        if ( !$green && !$red && !$globalGreen ) {
            push @cn, { 'background' => 'green' };
        }

        $sth->finish;
    }

    $template->param( 'q'       => $q );
    $template->param( 'cn_loop' => \@cn ) if $#cn != -1;
    $template->param( 'popup'   => defined( $cgi->param('popup') ) );
    $template->param( 'cn_source' => $cn_source ) if $cn_source;
    $template->param( 'class_sources' => \@class_sources );


    output_html_with_http_headers $cgi, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
