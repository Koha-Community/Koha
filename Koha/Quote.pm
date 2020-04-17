package Koha::Quote;

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
use Carp;
use DateTime::Format::MySQL;
use DBI qw(:sql_types);

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);

use base qw(Koha::Object);

=head1 NAME

Koha::Quote - Koha Quote object class

=head1 API

=head2 Class methods

=cut

=head2 get_daily_quote($opts)

Takes a hashref of options

Currently supported options are:

'id'        An exact quote id
'random'    Select a random quote
noop        When no option is passed in, this sub will return the quote timestamped for the current day

The function returns an anonymous hash following this format:

        {
          'source' => 'source-of-quote',
          'timestamp' => 'timestamp-value',
          'text' => 'text-of-quote',
          'id' => 'quote-id'
        };

=cut

# This is definitely a candidate for some sort of caching once we finally settle caching/persistence issues...
# at least for default option

sub get_daily_quote {
    my ($self, %opts) = @_;
    my $dbh = C4::Context->dbh;
    my $query = '';
    my $sth = undef;
    my $quote = undef;
    if ($opts{'id'}) {
        $query = 'SELECT * FROM quotes WHERE id = ?';
        $sth = $dbh->prepare($query);
        $sth->execute($opts{'id'});
        $quote = $sth->fetchrow_hashref();
    }
    elsif ($opts{'random'}) {
        # Fall through... we also return a random quote as a catch-all if all else fails
    }
    else {
        $query = 'SELECT * FROM quotes WHERE timestamp LIKE CONCAT(CURRENT_DATE,\'%\') ORDER BY timestamp DESC LIMIT 0,1';
        $sth = $dbh->prepare($query);
        $sth->execute();
        $quote = $sth->fetchrow_hashref();
    }
    unless ($quote) {        # if there are not matches, choose a random quote
        # get a list of all available quote ids
        $sth = C4::Context->dbh->prepare('SELECT count(*) FROM quotes;');
        $sth->execute;
        my $range = ($sth->fetchrow_array)[0];
        # chose a random id within that range if there is more than one quote
        my $offset = int(rand($range));
        # grab it
        $query = 'SELECT * FROM quotes ORDER BY id LIMIT 1 OFFSET ?';
        $sth = C4::Context->dbh->prepare($query);
        # see http://www.perlmonks.org/?node_id=837422 for why
        # we're being verbose and using bind_param
        $sth->bind_param(1, $offset, SQL_INTEGER);
        $sth->execute();
        $quote = $sth->fetchrow_hashref();
        # update the timestamp for that quote
        $query = 'UPDATE quotes SET timestamp = ? WHERE id = ?';
        $sth = C4::Context->dbh->prepare($query);
        $sth->execute(
            DateTime::Format::MySQL->format_datetime( dt_from_string() ),
            $quote->{'id'}
        );
    }
    return $quote;
}

=head3 _type

=cut

sub _type {
    return 'Quote';
}

1;