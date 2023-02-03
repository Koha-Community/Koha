#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

# Copyright 2000-2002 Katipo Communications
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

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};

    # find today's date
    my @a= (localtime) [5,4,3,2,1,0]; $a[0]+=1900; $a[1]++;
    my $date = sprintf("%4d%02d%02d%02d%02d%04.1f",@a);

    my $res  = "
<script>

function Focus$function_name(event) {
    document.getElementById(event.data.id).value='$date';
}

</script>
";
    return $res;
};

return { builder => $builder };
