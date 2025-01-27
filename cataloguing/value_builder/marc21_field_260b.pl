#!/usr/bin/perl

# Copyright 2020 Athens County Public Libraries
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

=head1 SYNOPSIS

This plugin is used to fill 260$a with a value already existing in
biblioitems.publishercode

=cut

use Modern::Perl;
use C4::Context;

use CGI      qw ( -utf8 );
use C4::Auth qw( check_cookie_auth );
my $input = CGI->new;
my ($auth_status) =
    check_cookie_auth( $input->cookie('CGISESSID'), { catalogue => 1 } );
if ( $auth_status ne "ok" ) {
    print $input->header( -type => 'text/plain', -status => '403 Forbidden' );
    exit 0;
}

my $builder = sub {
    my ($params) = @_;
    my $function_name = $params->{id};

    my $res = "
<script>
    function Focus$function_name(event) {
        var tagfield = jQuery( this );
        tagfield.autocomplete({
            source: '/cgi-bin/koha/cataloguing/ysearch.pl?table=biblioitems&field=publishercode',
            minLength: 3,
            select: function( event, ui ) {
                tagfield.val( ui.item.fieldvalue );
                return false;
            }
        })
        .data( 'ui-autocomplete' )._renderItem = function( ul, item ) {
            return jQuery( '<li></li>' )
            .data( 'ui-autocomplete-item', item )
            .append( '<a>' + item.fieldvalue + '</a>' )
            .appendTo( ul );
        };
        return 1;
    }
</script>
";
    return $res;
};

return { builder => $builder };
