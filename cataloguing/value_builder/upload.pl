#!/usr/bin/perl

# Converted to new plugin style (Bug 6874/See also 13437)

# This file is part of Koha.
#
# Copyright (C) 2015 Rijksmuseum
# Copyright (C) 2011-2012 BibLibre
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

# This plugin does not use the plugin launcher. It refers to tools/upload.pl.
# That script and template support using it as a plugin.

# If the plugin is called with the pattern [id=some_hashvalue] in the
# corresponding field, it starts the upload script as a search, providing
# the possibility to delete the uploaded file. If the field is empty, you
# can upload a new file.

my $builder = sub {
    my ( $params ) = @_;
    return <<"SCRIPT";
<script type=\"text/javascript\">
        function Click$params->{id}(event) {
            var index = event.data.id;
            var str = document.getElementById(index).value;
            var myurl, term;
            if( str && str.match(/id=([0-9a-f]+)/) ) {
                term = RegExp.\$1;
                myurl = '../tools/upload.pl?op=search&index='+index+'&term='+term+'&plugin=1';
            } else {
                myurl = '../tools/upload.pl?op=new&index='+index+'&plugin=1';
            }
            window.open( myurl, 'tag_editor', 'width=800,height=400,toolbar=false,scrollbars=yes' );
        }
</script>
SCRIPT
};

return { builder => $builder };
