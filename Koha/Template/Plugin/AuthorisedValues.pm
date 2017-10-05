package Koha::Template::Plugin::AuthorisedValues;

# Copyright 2012 ByWater Solutions
# Copyright 2013-2014 BibLibre
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

use Template::Plugin;
use base qw( Template::Plugin );

use C4::Koha;
use Koha::AuthorisedValues;

sub GetByCode {
    my ( $self, $category, $code, $opac ) = @_;
    my $av = Koha::AuthorisedValues->search({ category => $category, authorised_value => $code });
    return $av->count
            ? $opac
                ? $av->next->opac_description
                : $av->next->lib
            : $code;
}

sub Get {
    my ( $self, $category, $selected, $opac ) = @_;
    return GetAuthorisedValues( $category, $selected, $opac );
}

sub GetAuthValueDropbox {
    my ( $self, $category ) = @_;
    my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
    return Koha::AuthorisedValues->search(
        {
            branchcode => $branch_limit,
            category => $category,
        },
        {
            group_by => 'lib',
            order_by => [ 'category', 'lib', 'lib_opac' ],
        }
    );
}

sub GetCategories {
    my ( $self, $params ) = @_;
    my $selected = $params->{selected};
    my @categories = Koha::AuthorisedValues->new->categories;
    return [
        map {
            {
                category => $_,
                ( ( $selected and $selected eq $_ ) ? ( selected => 1 ) : () ),
            }
        } @categories
    ];
}

sub GetDescriptionsByKohaField {
    my ( $self, $params ) = @_;
    return Koha::AuthorisedValues->get_descriptions_by_koha_field(
        { kohafield => $params->{kohafield} } );
}

sub GetDescriptionByKohaField {
    my ( $self, $params ) = @_;
    my $av = Koha::AuthorisedValues->get_description_by_koha_field(
        {
            kohafield        => $params->{kohafield},
            authorised_value => $params->{authorised_value},
        }
    );
    return %$av
            ? $params->{opac}
                ? $av->{opac_description}
                : $av->{lib}
            : ''; # Maybe we should return $params->{authorised_value}?

}

1;

=head1 NAME

Koha::Template::Plugin::AuthorisedValues - TT Plugin for authorised values

=head1 SYNOPSIS

[% USE AuthorisedValues %]

[% AuthorisedValues.GetByCode( 'CATEGORY', 'AUTHORISED_VALUE_CODE', 'IS_OPAC' ) %]

[% AuthorisedValues.GetAuthValueDropbox( $category, $default ) %]

=head1 ROUTINES

=head2 GetByCode

In a template, you can get the description for an authorised value with
the following TT code: [% AuthorisedValues.GetByCode( 'CATEGORY', 'AUTHORISED_VALUE_CODE', 'IS_OPAC' ) %]

=head2 GetAuthValueDropbox

The parameters are identical to those used by the subroutine C4::Koha::GetAuthValueDropbox

=head2 GetDescriptionsByKohaField

The parameters are identical to those used by the subroutine Koha::AuthorisedValues->get_descriptions_by_koha_field

=head2 GetDescriptionByKohaField

The parameters are identical to those used by the subroutine Koha::AuthorisedValues->get_description_by_koha_field

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

Jonathan Druart <jonathan.druart@biblibre.com>

=cut
