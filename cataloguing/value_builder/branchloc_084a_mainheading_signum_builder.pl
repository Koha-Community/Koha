#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2016 Koha-Suomi Oy
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
use C4::Context;

=head1 plugin_javascript

The javascript function called when the user enters the subfield.
contain 3 javascript functions :
* one called when the field is entered (OnFocus). Named FocusXXX
* one called when the field is leaved (onBlur). Named BlurXXX
* one called when the ... link is clicked (<a href="javascript:function">) named ClicXXX

returns :
* a variable containing the 3 scripts.
the 3 scripts are inserted after the <input> in the html code

=cut

sub plugin_javascript {
	my $function_name= "signum".(int(rand(100000))+1);

    # Inject this javascript to the page
    my $js  = <<END_OF_JS;
<script type="text/javascript">
//<![CDATA[

function Blur$function_name(index) {
    // No action
}

function Focus$function_name(subfield_managed, id, force) {
    // Uncomment the below line to have the signum updated when the field gets focus
    // return Clic$function_name(id);
}

function Clic$function_name(id) {
// Do shelving location
var shelvingLoc = \$("select[id^='tag_952_subfield_c']").val() ? \$("select[id^='tag_952_subfield_c']").val() : \$("div[id^='subfieldc']").find("select").val();
if (!shelvingLoc) {
    shelvingLoc = "";
}
var branch = \$("select[id^='tag_952_subfield_a']").val() ? \$("select[id^='tag_952_subfield_a']").val() : \$("div[id^='subfielda']").find("select").val();
if (!branch) {
    branch = "";
}


// Do classification
var marc084a = \$("input[name^='marcfield084a']").val();

// Do main heading
// Actually we should also follow the bypass indicators here

var marc100a = \$("input[name^='marcfield100a']").val();
var marc110a = \$("input[name^='marcfield110a']").val();
var marc111a = \$("input[name^='marcfield111a']").val();

// First indicator is 'bypass'
var marc130a = \$("input[name^='marcfield130a']").val();

// Second indicator is 'bypass'
var marc245a = \$("input[name^='marcfield245a']").val();

if (marc100a) {
    var mainHeading = marc100a;
} else if (marc110a) {
    var mainHeading = marc110a;
} else if (marc111a) {
    var mainHeading = marc111a;
} else if (marc130a) {
    var mainHeading = marc130a;
} else if (marc245a) {
    var mainHeading = marc245a;
}

mainHeading = mainHeading.substring(0, 3).toUpperCase();
var splitted = branch.split('_')[1];
if (splitted) {
    branch = splitted;
}

// This will determine the order of the signum elements
\$('#' + id).val(branch + shelvingLoc + " " + marc084a + " " + mainHeading);
return 0;
}

// We don't want signums to change without explicit user action (clicking the ...)
// So these are commented out:

//\$("select[id^='tag_952_subfield_c']").change(function(){
//    \$("a[id^='buttonDot_tag_952_subfield_o']").click();
//});

//\$("div[id^='subfieldc']").find("select").change(function(){
//    \$("a[id^='buttonDot_tag_952_subfield_o']").click();
//});

//\$("select[id^='tag_952_subfield_a']").change(function(){
//    \$("a[id^='buttonDot_tag_952_subfield_o']").click();
//});

//]]>
</script>
END_OF_JS

    return ($function_name, $js);
}

1;
