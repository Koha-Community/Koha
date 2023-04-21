package Koha::ERM::Agreements;

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
use DateTime;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use Koha::ERM::Agreement;
use Koha::ERM::Agreement::Periods;

use base qw(Koha::Objects);

=head1 NAME

Koha::ERM::Agreements- Koha ErmAgreement Object set class

=head1 API

=head2 Class Methods

=cut

=head3 filter_by_expired

=cut

sub filter_by_expired {
    my ($self, $max_expiration_date) = @_;

    $max_expiration_date =
      $max_expiration_date
      ? dt_from_string( $max_expiration_date, 'iso' )
      : dt_from_string;

    my $periods = Koha::ERM::Agreement::Periods->search(
        { agreement_id => [ $self->get_column('agreement_id') ] },
        {
            select => [
                'agreement_id',
                \do {"CASE WHEN MAX(me.ended_on IS NULL) = 0 THEN max(me.ended_on) END"}
            ],
            as       => [ 'agreement_id', 'max_ended_on' ],
            group_by => ['agreement_id'],
        }
    );

    my @expired_agreement_ids;
    while ( my $p = $periods->next ) {
        # FIXME Can this be moved in the HAVING clause of the previous query?
        my $max_ended_on = $p->get_column('max_ended_on');
        next unless $max_ended_on;
        my $max_ended_on_dt = dt_from_string($max_ended_on);
        next if DateTime->compare( $max_ended_on_dt, $max_expiration_date ) == 1;
        push @expired_agreement_ids, $p->agreement_id;
    }

    return $self->search( { "me.agreement_id" => \@expired_agreement_ids } );
}

=head3 type

=cut

sub _type {
    return 'ErmAgreement';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::ERM::Agreement';
}

1;
