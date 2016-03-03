package C4::Serials::Frequency;

# Copyright 2011-2013 Biblibre SARL
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

use strict;
use warnings;

use C4::Context;

use vars qw(@ISA @EXPORT);

BEGIN {
    # set the version for version checking
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
      &GetSubscriptionFrequencies
      &GetSubscriptionFrequency
      &AddSubscriptionFrequency
      &ModSubscriptionFrequency
      &DelSubscriptionFrequency

      &GetSubscriptionsWithFrequency
    );
}


=head1 NAME

C4::Serials::Frequency - Serials Frequency module

=head1 FUNCTIONS

=head2 GetSubscriptionFrequencies

=over 4

=item C<@frequencies> = &GetSubscriptionFrequencies();

gets frequencies restricted on filters

=back

=cut

sub GetSubscriptionFrequencies {
    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM subscription_frequencies
        ORDER BY displayorder
    };
    my $sth = $dbh->prepare($query);
    $sth->execute();

    my $results = $sth->fetchall_arrayref( {} );
    return @$results;
}

=head2 GetSubscriptionFrequency

=over 4

=item $frequency = &GetSubscriptionFrequency($frequencyid);

gets frequency where $frequencyid is the identifier

=back

=cut

sub GetSubscriptionFrequency {
    my ($frequencyid) = @_;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM subscription_frequencies
        WHERE id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($frequencyid);

    return $sth->fetchrow_hashref;
}

=head2 AddSubscriptionFrequency

=over 4

=item C<$frequencyid> = &AddSubscriptionFrequency($frequency);

Add a new frequency

=item C<$frequency> is a hashref that can contains the following keys

=over 2

=item * description

=item * unit

=item * issuesperunit

=item * unitsperissue

=item * expectedissuesayear

=item * displayorder

=back

Only description is mandatory.

=back

=cut

sub AddSubscriptionFrequency {
    my $frequency = shift;

    unless(ref($frequency) eq 'HASH' && defined $frequency->{'description'} && $frequency->{'description'} ne '') {
        return;
    }

    my @keys;
    my @values;
    foreach (qw/ description unit issuesperunit unitsperissue expectedissuesayear displayorder /) {
        if(exists $frequency->{$_}) {
            push @keys, $_;
            push @values, $frequency->{$_};
        }
    }

    my $dbh = C4::Context->dbh;
    my $query = "INSERT INTO subscription_frequencies";
    $query .= '(' . join(',', @keys) . ')';
    $query .= ' VALUES (' . ('?,' x (scalar(@keys)-1)) . '?)';
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute(@values);

    if(defined $rv) {
        return $dbh->last_insert_id(undef, undef, "subscription_frequencies", undef);
    }

    return $rv;
}

=head2 ModSubscriptionFrequency

=over 4

=item &ModSubscriptionFrequency($frequency);

Modifies a frequency

=item C<$frequency> is a hashref that can contains the following keys

=over 2

=item * id

=item * description

=item * unit

=item * issuesperunit

=item * unitsperissue

=item * expectedissuesayear

=item * displayorder

=back

Only id is mandatory.

=back

=cut

sub ModSubscriptionFrequency {
    my $frequency = shift;

    unless(
      ref($frequency) eq 'HASH'
      && defined $frequency->{'id'} && $frequency->{'id'} > 0
      && (
        (defined $frequency->{'description'}
        && $frequency->{'description'} ne '')
        || !defined $frequency->{'description'}
      )
    ) {
        return;
    }

    my @keys;
    my @values;
    foreach (qw/ description unit issuesperunit unitsperissue expectedissuesayear displayorder /) {
        if(exists $frequency->{$_}) {
            push @keys, $_;
            push @values, $frequency->{$_};
        }
    }

    my $dbh = C4::Context->dbh;
    my $query = "UPDATE subscription_frequencies";
    $query .= ' SET ' . join(' = ?,', @keys) . ' = ?';
    $query .= ' WHERE id = ?';
    my $sth = $dbh->prepare($query);

    return $sth->execute(@values, $frequency->{'id'});
}

=head2 DelSubscriptionFrequency

=over 4

=item &DelSubscriptionFrequency($frequencyid);

Delete a frequency

=back

=cut

sub DelSubscriptionFrequency {
    my $frequencyid = shift;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        DELETE FROM subscription_frequencies
        WHERE id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($frequencyid);
}

=head2 GetSubscriptionsWithFrequency

    my @subs = GetSubscriptionsWithFrequency($frequencyid);

Returns all subscriptions that are using a particular frequency

=cut

sub GetSubscriptionsWithFrequency {
    my ($frequencyid) = @_;

    return unless $frequencyid;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM subscription
          LEFT JOIN biblio ON subscription.biblionumber = biblio.biblionumber
        WHERE periodicity = ?
    };
    my $sth = $dbh->prepare($query);
    my @results;
    if ($sth->execute($frequencyid)) {
        @results = @{ $sth->fetchall_arrayref({}) };
    }
    return @results;
}

1;

__END__

=head1 AUTHOR

Koha Development team <info@koha.org>

=cut
