package Koha::Notice::Templates;

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

use Koha::Database;

use Koha::Notice::Template;

use base qw(Koha::Objects);

=head1 NAME

Koha::Notice::Templates - Koha notice template Object set class, related to the letter table

=head1 API

=head2 Class Methods

=cut

=head3 find_effective_template

my $template = Koha::Notice::Templates->find_effective_template(
    {
        module     => $module,
        code       => $code,
        branchcode => $branchcode,
        lang       => $lang,
    }
);

Return the notice template that must be used for a given primary key (module, code, branchcode, lang).

For instance if lang="es-ES" but there is no "es-ES" template defined for this language,
the default template will be returned.

lang will default to "default" if not passed.

=cut

sub find_effective_template {
    my ( $self, $params ) = @_;

    $params = {%$params};    # don't modify original

    $params->{lang} = 'default'
        unless C4::Context->preference('TranslateNotices') && $params->{lang};

    my $only_my_library = C4::Context->only_my_library;
    if ( $only_my_library and $params->{branchcode} ) {
        $params->{branchcode} = C4::Context::mybranch();
    }
    $params->{branchcode} //= '';
    $params->{branchcode} = [ $params->{branchcode}, '' ];

    my $template = $self->SUPER::search( $params, { order_by => { -desc => 'branchcode' } } );

    if (   !$template->count
        && C4::Context->preference('TranslateNotices')
        && $params->{lang} ne 'default' )
    {
        $params->{lang} = 'default';
        $template = $self->SUPER::search( $params, { order_by => { -desc => 'branchcode' } } );
    }

    return $template->next if $template->count;
}

=head3 type

=cut

sub _type {
    return 'Letter';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Notice::Template';
}

1;
