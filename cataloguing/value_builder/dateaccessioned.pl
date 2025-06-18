#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

# Copyright 2000-2002 Katipo Communications
# Parts copyright Athens County Public Libraries 2019
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

    my $res = <<END_OF_JS;
<script>
/* from: cataloguing/value_builder/dateaccessioned.pl */

\$(document).ready(function(){
    \$("#$function_name").flatpickr({
        onReady: function(selectedDates, dateStr, instance) {
            let options = maskitoDateOptionsGenerator({
                mode: altinput_dateformat,
                separator: delimiter,
                overwriteMode: 'replace',
            });

            new Maskito( instance.altInput, options );
        },
        onOpen: function(selectedDates, dateStr, instance) {
            if (dateStr == '') {
                instance.setDate(new Date());
            }
        }
    });
});

function Click$function_name(event) {
    set_to_today(event.data.id, 1);
    return false;
}

function set_to_today( id, force ) {
    /* The force parameter is used in Click but not in Focus ! */
    if (! id) { alert(_("Bad id ") + id + _(" sent to set_to_today()")); return 0; }
    var elt = document.querySelector("#" + id);
    if ( elt.value == '' || force ) {
        const fp = document.querySelector("#" + id)._flatpickr;
        fp.setDate(new Date());
    }
}
</script>
END_OF_JS
    return $res;
};

return { builder => $builder };
