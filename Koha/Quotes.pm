package Koha::Quotes;

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

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Quote;

use base qw(Koha::Objects);

=head1 NAME

Koha::Quotes - Koha Quote object class

=head1 API

=head2 Class methods

=cut

=head2 get_daily_quote($opts)

Takes a hashref of options

Currently supported options are:

'id'        An exact quote id
'random'    Select a random quote
noop        When no option is passed in, this sub will return the quote timestamped for the current day

=cut

# This is definitely a candidate for some sort of caching once we finally settle caching/persistence issues...
# at least for default option

sub get_daily_quote {
    my ( $self, %opts ) = @_;

    my $qotdPref  = C4::Context->preference('QuoteOfTheDay');
    my $interface = C4::Context->interface();

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;

    unless ( $qotdPref =~ /$interface/ ) {
        return;
    }

    my $quote = undef;

    if ( $opts{'id'} ) {
        $quote = $self->find( { id => $opts{'id'} } );
    } elsif ( $opts{'random'} ) {

        # Fall through... we also return a random quote as a catch-all if all else fails
    } else {
        my $dt = $dtf->format_date(dt_from_string);
        $quote = $self->search(
            {
                timestamp => { -between => [ "$dt 00:00:00", "$dt 23:59:59" ] },
            },
            {
                order_by => { -desc => 'timestamp' },
                rows     => 1,
            }
        )->single;
    }
    unless ($quote) {    # if there are not matches, choose a random quote
        my $range  = $self->search->count;
        my $offset = int( rand($range) );
        $quote = $self->search(
            {},
            {
                order_by => 'id',
                rows     => 1,
                offset   => $offset,
            }
        )->single;
    }

    return unless $quote;

    # update the timestamp for that quote
    $quote->update( { timestamp => dt_from_string } )->discard_changes;

    return $quote;
}

=head3 type

=cut

sub _type {
    return 'Quote';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Quote';
}

1;
