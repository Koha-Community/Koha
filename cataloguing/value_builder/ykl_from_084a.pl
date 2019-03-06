#!/usr/bin/perl

# Copyright 2019 Koha-Suomi Oy
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

# Get value from the first 084a with ind1 != 9 and trim the value

my $builder= sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};

    my $js = qq|
<script type="text/javascript">
//<![CDATA[

 function Click$function_name(event) {
   \$("div[id^='tag_084_']").each(function() {
      var ind1 = \$( this ).find("input[name^='tag_084_indicator1_']").val();
      var inp = \$( this ).find("input[id^='tag_084_subfield_a_']");
      if (ind1 != "9" && inp) {
         var v = inp.val() ? inp.val().trim() : "";
         if (v !== "") {
            \$('#' + event.data.id).val(v);
            return false;
         }
      }
   });
   return false;
 }

//]]>
</script>

|;
    return $js;
};

return { builder => $builder };
