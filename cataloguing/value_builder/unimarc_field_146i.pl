#!/usr/bin/perl

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

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::I18N;

my $builder = sub {
    my $params = shift;
    my $id = $params->{id};

    return qq|
<script>
function Click$id(event) {
    const value = document.getElementById(event.data.id).value;
    const url = new URL('/cgi-bin/koha/cataloguing/plugin_launcher.pl', location);
    url.searchParams.set('plugin_name', 'unimarc_field_146i.pl');
    url.searchParams.set('id', event.data.id);
    url.searchParams.set('value', value);
    window.open(url.toString(), 'tag_editor', 'width=700,height=700,toolbar=false,scrollbars=yes');
}
</script>|;
};

my $launcher = sub {
    my $params = shift;
    my $cgi = $params->{cgi};
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name => "cataloguing/value_builder/unimarc_field_146i.tt",
        query => $cgi,
        type => 'intranet',
        flagsrequired => { editcatalogue => '*' },
    });

    my @options = (
        { value => 'a', label => __('performers total') },
        { value => 'b', label => __('brass instruments') },
        { value => 'c', label => __('choirs') },
        { value => 'd', label => __('wind instruments') },
        { value => 'e', label => __('electro-acoustic instruments') },
        { value => 'i', label => __('instruments total') },
        { value => 'j', label => __('solo instruments') },
        { value => 'k', label => __('keyboard instruments') },
        { value => 'l', label => __('solo voices') },
        { value => 'm', label => __('miscellaneous, other instruments') },
        { value => 'o', label => __('orchestras') },
        { value => 'p', label => __('percussion instruments') },
        { value => 'q', label => __('conductors') },
        { value => 's', label => __('bowed string instruments') },
        { value => 't', label => __('plucked string instruments') },
        { value => 'v', label => __('voices total') },
        { value => 'w', label => __('woodwind instruments') },
        { value => 'x', label => __('choral voices') },
        { value => 'y', label => __('ensemble instruments') },
        { value => 'z', label => __('devices, other performers') },
    );

    my $value = $cgi->param('value');
    my $number = substr($value, 0, 3);
    my $category = substr($value, 3, 1);

    $template->param(
        id => scalar $cgi->param('id'),
        number => $number,
        category => $category,
        options => \@options,
    );
    output_html_with_http_headers $cgi, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
