package t::lib::Page::PageUtils;

# Copyright 2015 Open Source Freedom Fighters
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

use Koha::Exception::UnknownObject;

=head NAME t::lib::Page::PageUtils

=head SYNOPSIS

Contains all kinds of helper functions used all over the PageObject testing framework.

=cut

sub getSelectElementsOptionByName {
    my ($d, $selectElement, $optionName) = @_;

    my $options = $d->find_child_elements($selectElement, "option", 'css');
    my $correctOption;
    foreach my $option (@$options) {
        if ($option->get_text() eq $optionName) {
            $correctOption = $option;
            last();
        }
    }

    return $correctOption if $correctOption;

    ##Throw Exception because we didn't find the option element.
    my @availableOptions;
    foreach my $option (@$options) {
        push @availableOptions, $option->get_tag_name() .', value: '. $option->get_value() .', text: '. $option->get_text();
    }
    Koha::Exception::UnknownObject->throw(error =>
        "getSelectElementsOptionByName():> Couldn't find the given option-element using '$optionName'. Available options:\n".
        join("\n", @availableOptions));
}

sub displaySelectsOptions {
    my ($d, $selectElement) = @_;

    my $options = $d->find_child_elements($selectElement, "option", 'css');
    if (scalar(@$options)) {
        $selectElement->click() if $options->[0]->is_hidden();
    }
    else {
        Koha::Exception::UnknownObject->throw(error =>
            "_displaySelectsOptions():> element: ".$selectElement->get_tag_name()-', class: '.$selectElement->get_attribute("class").", doesn't have any option-elements?");
    }
}

1;