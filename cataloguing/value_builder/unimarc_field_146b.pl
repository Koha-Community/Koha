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

use Scalar::Util;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::I18N;
use Koha::CodeList::Unimarc::MediumOfPerformance;

my $builder = sub {
    my $params = shift;
    my $id     = $params->{id};

    return qq|
<script>
function Click$id (event) {
    event.preventDefault();
    const value = document.getElementById(event.data.id).value;
    const url = new URL('/cgi-bin/koha/cataloguing/plugin_launcher.pl', location);
    url.searchParams.set('plugin_name', 'unimarc_field_146b.pl');
    url.searchParams.set('id', event.data.id);
    url.searchParams.set('value', value);
    window.open(url.toString(), 'tag_editor', 'width=700,height=700,toolbar=false,scrollbars=yes');
}
</script>|;
};

my $launcher = sub {
    my $params = shift;
    my $cgi    = $params->{cgi};
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/unimarc_field_146b.tt",
            query         => $cgi,
            type          => 'intranet',
            flagsrequired => { editcatalogue => '*' },
        }
    );

    my @category_optgroups = (
        { label => __('Voices'),            values => Koha::CodeList::Unimarc::MediumOfPerformance->voices() },
        { label => __('Woodwinds'),         values => Koha::CodeList::Unimarc::MediumOfPerformance->woodwinds() },
        { label => __('Brass instruments'), values => Koha::CodeList::Unimarc::MediumOfPerformance->brass() },
        { label => __('Strings, bowed'),    values => Koha::CodeList::Unimarc::MediumOfPerformance->strings_bowed() },
        { label => __('Strings, plucked'),  values => Koha::CodeList::Unimarc::MediumOfPerformance->strings_plucked() },
        { label => __('Keyboard'),          values => Koha::CodeList::Unimarc::MediumOfPerformance->keyboard() },
        { label => __('Percussion'),        values => Koha::CodeList::Unimarc::MediumOfPerformance->percussion() },
        {
            label  => __('Electric / electronic instruments and devices'),
            values => Koha::CodeList::Unimarc::MediumOfPerformance->electronic()
        },
        {
            label  => __('Miscellaneous, other, unspecified instruments'),
            values => Koha::CodeList::Unimarc::MediumOfPerformance->misc()
        },
        { label => __('Other performers'), values => Koha::CodeList::Unimarc::MediumOfPerformance->other_performers() },
    );

    foreach my $optgroup (@category_optgroups) {
        my $values = delete $optgroup->{values};
        $optgroup->{options} = [ map { { value => $_, label => __( $values->{$_} ) } } sort keys %$values ];
    }

    my $tessitura_hash = Koha::CodeList::Unimarc::MediumOfPerformance->tessitura();
    my @tessitura_options =
        map { { value => $_, label => __p( 'tessitura', $tessitura_hash->{$_} ) } } sort keys %$tessitura_hash;

    my $number_of_hands_or_keys_hash = Koha::CodeList::Unimarc::MediumOfPerformance->number_of_hands_or_keys();
    my @number_of_hands_or_keys_options =
        map { { value => $_, label => __p( 'music', $number_of_hands_or_keys_hash->{$_} ) } }
        sort keys %$number_of_hands_or_keys_hash;

    my $other_hash    = Koha::CodeList::Unimarc::MediumOfPerformance->other();
    my @other_options = map { { value => $_, label => __( $other_hash->{$_} ) } } sort keys %$other_hash;

    my $other2_hash    = Koha::CodeList::Unimarc::MediumOfPerformance->other2();
    my @other2_options = map { { value => $_, label => __( $other2_hash->{$_} ) } } sort keys %$other2_hash;

    my $value  = $cgi->param('value');
    my $number = substr( $value, 0, 2 );
    unless ( Scalar::Util::looks_like_number($number) ) {
        $number = '';
    }
    my $category                = substr( $value, 2, 3 );
    my $tessitura               = substr( $value, 5, 1 );
    my $number_of_hands_or_keys = substr( $value, 6, 1 );
    my $other                   = substr( $value, 7, 1 );
    my $other2                  = substr( $value, 8, 1 );

    $template->param(
        id                              => scalar $cgi->param('id'),
        number                          => $number,
        category                        => $category,
        tessitura                       => $tessitura,
        number_of_hands_or_keys         => $number_of_hands_or_keys,
        other                           => $other,
        other2                          => $other2,
        category_optgroups              => \@category_optgroups,
        tessitura_options               => \@tessitura_options,
        number_of_hands_or_keys_options => \@number_of_hands_or_keys_options,
        other_options                   => \@other_options,
        other2_options                  => \@other2_options,
    );
    output_html_with_http_headers $cgi, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
