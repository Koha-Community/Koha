#!/usr/bin/perl


# Copyright 2008 Biblibre SARL
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
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );


sub plugin_javascript {
    my ($dbh,$record,$tagslib,$field_number) = @_;
    my $res="
    <script>
        function Blur$field_number(ev) {
                var isbn = document.getElementById(ev.data.id);
                var url = '../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_010.pl&isbn=' + isbn.value;
                var req = \$.get(url);
                req.done(function(resp){
                        var elems = document.getElementsByTagName('input');
                        for( i = 0 ; elems[i] ; i++ )
                        {
                            if(elems[i].id.match(/^tag_210_subfield_c/)) {
                                elems[i].value = resp;
                                return 1;
                            }
                        }
                });
                return 1;
        }

    </script>
    ";

    return ($field_number,$res);
}

sub plugin {
    my ($input) = @_;
    my $isbn = $input->param('isbn');

    my ($template, $loggedinuser, $cookie)
            = get_template_and_user({template_name => "cataloguing/value_builder/ajax.tt",
                                    query => $input,
                                    type => "intranet",
                                    flagsrequired => {editcatalogue => '*'},
                                    });


    my $dbh = C4::Context->dbh;
    my $len = 0;
    my $sth = $dbh->prepare('SELECT publishercode FROM biblioitems WHERE REPLACE(isbn, "-", "") LIKE ? OR isbn LIKE ? LIMIT 1');
    
    $isbn =~ s/-//g;
    if (length ($isbn) == 13){
        $isbn = substr($isbn, 3, length($isbn)-3);
    }
    
    if(length($isbn) <= 10){

        $len = 5;
        if ( substr( $isbn, 0, 1 ) <= 7 ){
            $len = 1;
        }elsif ( substr( $isbn, 0, 2 ) <= 94 ){
            $len = 2;
        }elsif ( substr( $isbn, 0, 3 ) <= 995 ){
            $len = 3;
        }elsif ( substr( $isbn, 0, 4 ) <= 9989 ){
            $len = 4 ;
        }

        my $x = substr( $isbn, $len );
        my $seg2 = "";
        
        if ( substr( $x, 0, 2 ) <= 19 ) {    
            $seg2 = substr( $x, 0, 2 );
        }
        elsif ( substr( $x, 0, 3 ) <= 699 ) {
            $seg2 = substr( $x, 0, 3 );
        }
        elsif ( substr( $x, 0, 4 ) <= 8399 ) {
            $seg2 = substr( $x, 0, 4 );
        }
        elsif ( substr( $x, 0, 5 ) <= 89999 ) {
            $seg2 = substr( $x, 0, 5 );
        }
        elsif ( substr( $x, 0, 6 ) <= 9499999 ) {
            $seg2 = substr( $x, 0, 6 );
        }
        else {
            $seg2 = substr( $x, 0, 7 );
        }

        while($len--){
            $seg2 = "_".$seg2;
        }
        
        $len = 10 -length($seg2);
        
        while($len--){
            $seg2 .= "_";
        }

        $sth->execute($seg2, "978$seg2");
    }
    
    if( (my $publishercode) = $sth->fetchrow )
    {
        $template->param(return => $publishercode);
    }
    output_html_with_http_headers $input, $cookie, $template->output;
}
