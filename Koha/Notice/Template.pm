package Koha::Notice::Template;

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

use YAML::XS qw(LoadFile);

use C4::Context;
use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Notice::Template - Koha notice template Object class, related to the letter table

=head1 API

=head2 Class Methods

=head3 get_default

    my $default = $template->get_default;

Returns the default notice template content.

=cut

sub get_default {
    my $self = shift;
    my $lang = $self->lang;
    if ( $lang eq 'default' ) {
        my $translated_languages =
            C4::Languages::getTranslatedLanguages( 'opac', C4::Context->preference('opacthemes') );
        $lang = @{ @{$translated_languages}[0]->{sublanguages_loop} }[0]->{rfc4646_subtag};
    }

    my $defaulted_to_en = 0;

    my $file = C4::Context->config('intranetdir') . "/installer/data/mysql/$lang/mandatory/sample_notices.yml";
    if ( !-e $file ) {
        if ( $lang eq 'en' ) {
            warn "cannot open sample data $file";
        } else {

            # if no localised sample data is available,
            # default to English
            $file = C4::Context->config('intranetdir') . "/installer/data/mysql/en/mandatory/sample_notices.yml";
            die "cannot open English sample data directory $file" unless ( -e $file );
            $defaulted_to_en = 1;
        }
    }

    my $data = YAML::XS::LoadFile("$file");

    my $module = $self->module;
    my $code   = $self->code;
    my $mtt    = $self->message_transport_type;

    my $content;
    for my $table ( @{ $data->{tables} } ) {
        if ( $table->{letter}->{rows} ) {
            for my $template ( @{ $table->{letter}->{rows} } ) {
                if (   $template->{module} eq $module
                    && $template->{code} eq $code
                    && $template->{message_transport_type} eq $mtt )
                {
                    $content = join "\r\n", @{ $template->{content} };
                    last;
                }
            }
        }
    }

    return $content;
}

=head3 type

=cut

sub _type {
    return 'Letter';
}

1;
