#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)
# This plugin adds the MARC organization code in fields like 003, 040cd

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Context;

use Koha::Libraries;
use CGI      qw ( -utf8 );
use C4::Auth qw( check_cookie_auth );

my $input = CGI->new;
my ($auth_status) =
    check_cookie_auth( C4::Context->userenv->{session_id}, { catalogue => 1 } );
if ( $auth_status ne "ok" ) {
    print $input->header( -type => 'text/plain', -status => '403 Forbidden' );
    exit 0;
}

my $builder = sub {
    my ($params) = @_;
    my $library  = Koha::Libraries->find( C4::Context->userenv->{'branch'} );
    my $org      = $library->get_effective_marcorgcode;
    return <<"HERE";
<script>

function Focus$params->{id}(event) {
    if( ! \$('#'+event.data.id).val() ) {
        \$('#'+event.data.id).val('$org');
    }
}

</script>
HERE
};

return { builder => $builder };
