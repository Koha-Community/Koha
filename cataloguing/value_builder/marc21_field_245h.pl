#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

# Copyright 2009 Kyle Hall <kyle.m.hall@gmail.com>
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
use C4::Context;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};

    my $res  = "
<script type=\"text/javascript\">
//<![CDATA[

function Blur$function_name(event) {
    var fieldValue = document.getElementById(event.data.id).value;
    if (  fieldValue.substring(0,1) != '[' 
          &&
          fieldValue.substring(fieldValue.length-1) != '[' 
        ) {
      document.getElementById(event.data.id).value = '[' + fieldValue + ']';
    }
    return 0;
}

//]]>
</script>
";
    return $res;
};

return { builder => $builder };