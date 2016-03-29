#!/usr/bin/perl

# Copyright 2014 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
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
use C4::Output;

# Example of framework plugin new style.
# It should define and return at least one and normally two anynomous
# subroutines in a hash ref.
# REQUEST: If you copy this code to construct a new plugin, please REMOVE
# all comments copied from this file.

# The first one is the builder: it returns javascript code for the plugin.
# The second one is the launcher: it runs the popup and will normally have an
# associated HTML template.

# We start with the example builder:
# It contains code for five events: Focus, MouseOver, KeyPress, Change and Click
# You could also use: Blur. Or: keydown, keyup.
# Or: mouseout, mousedown, mouseup, mousemove.
# Only define what you actually need!

# The builder receives a parameters hashref from the calling plugin object.
# Available parameters are listed in FrameworkPlugin.pm, but by far the only
# one interesting is id: it contains the html id of the field controlled by
# this plugin.
#
# The plugin returns javascript code. Note that the function names are made
# unique by appending the id. You should use the event names as listed above
# (upper or lowercase does not matter). The plugin object takes care of
# binding the function to the actual event. When doing so, it passes the id
# into the event data parameter; Focus e.g. uses that one again by looking at
# the variable event.data.id.
#
# Do not use the perl variable $id to extract the field value. Use variable
# event.data.id. This makes a difference when the field is cloned or has
# been created dynamically (as in additem.js).

my $builder= sub {
    my $params = shift;
    my $id = $params->{id};

    return qq|
<script type="text/javascript">
function Focus$id(event) {
    if( \$('#'+event.data.id).val()=='' ) {
        \$('#'+event.data.id).val('EXAMPLE:');
    }
}

function MouseOver$id(event) {
    return Focus$id(event);
    // just redirecting it to Focus for the same effect
}

function KeyPress$id(event) {
    if( event.which == 64 ) { // at character
        var f= \$('#'+event.data.id).val();
        \$('#'+event.data.id).val( f + 'AT' );
        return false; // prevents getting the @ character back too
    }
}

function Change$id(event) {
    var colors= [ 'rgb(0, 0, 255)', 'rgb(0, 128, 0)', 'rgb(255, 0, 0)' ];
    var curcol= \$('#'+event.data.id).css('color');
    var i= Math.floor( Math.random() * 3 );
    if( colors[i]==curcol ) {
        i= (i + 1)%3;
    }
    var f= \$('#'+event.data.id).css('color',colors[i]);
}

function Click$id(event) {
    var fieldvalue=\$('#'+event.data.id).val();
    window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=EXAMPLE.pl&index=\"+event.data.id+\"&result=\"+fieldvalue,\"tag_editor\",'width=700,height=700,toolbar=false,scrollbars=yes');
    return false; // prevents scrolling
}
</script>|;
};
# NOTE: Did you see the last semicolon? This was just an assignment!

# We continue now with the example launcher.
# It receives a CGI object via the parameter hashref (from plugin_launcher.pl).
# It also receives index (the html id of the input field) and result (the
# value of the input field). See also the URL in the Click function above.

# In this example we just pass those two fields to the template and call
# the output_html routine. But you could do some processing in perl before
# showing the template output.
# When you look at the template EXAMPLE.tt, you can see that the javascript
# code there puts a new value back into the input field (referenced by index).

my $launcher= sub {
    my $params = shift;
    my $cgi = $params->{cgi};
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name => "cataloguing/value_builder/EXAMPLE.tt",
        query => $cgi,
        type => "intranet",
        authnotrequired => 0,
        flagsrequired => {editcatalogue => '*'},
    });
    $template->param(
        index => scalar $cgi->param('index'),
        result => scalar $cgi->param('result'),
    );
    output_html_with_http_headers $cgi, $cookie, $template->output;
};

# Return the hashref with the builder and launcher to FrameworkPlugin object.
# NOTE: If you do not need a popup but only use e.g. Focus, Blur etc. for a
# particular plugin, you only need to define and return the builder.
return { builder => $builder, launcher => $launcher };
