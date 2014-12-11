#!/usr/bin/perl


# Copyright 2009 Kyle Hall <kyle.m.hall@gmail.com>
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
#use warnings; FIXME - Bug 2505
use C4::Context;

sub plugin_javascript {
    my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
    my $function_name = $field_number;

    my $res  = "
<script type=\"text/javascript\">
//<![CDATA[

function Blur$function_name(index) {
    var fieldValue = document.getElementById(\"$field_number\").value;
    if (  fieldValue.substring(0,1) != '[' 
          &&
          fieldValue.substring(fieldValue.length-1) != '[' 
        ) {
      document.getElementById(\"$field_number\").value = '[' + fieldValue + ']';
    }
    return 0;
}

//]]>
</script>
";
return ($function_name,$res);
}
