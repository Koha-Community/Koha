package Koha::ClassSplitRule;

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

use JSON qw( from_json to_json );

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::ClassSplitRule Koha Classfication Splitting Rule Object class

=head1 API

=head2 Class Methods

=cut

=head3 new

Accept 'regexs' as a valid attribute.
It should be an arrayref that will be serialized in JSON before stored in DB.

=cut

sub new {
    my ( $class, $attributes ) = @_;

    if ( exists $attributes->{regexs} ) {
        $attributes->{split_regex} = to_json( $attributes->{regexs} );
        delete $attributes->{regexs};
    }
    return $class->SUPER::new($attributes);
}

=head3 regexs

my $regexs = $rule->regexs

$rule->regex(\@regexs);

Getter or setter for split_regex

=cut

sub regexs {
    my ( $self, $regexs ) = @_;
    return $regexs
        ? $self->split_regex( to_json($regexs) )
        : from_json( $self->split_regex || '[]' );
}

=head3 type

=cut

sub _type {
    return 'ClassSplitRule';
}

1;
