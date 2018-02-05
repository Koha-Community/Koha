package C4::Serials::Numberpattern;

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

    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
        &GetSubscriptionNumberpatterns
        &GetSubscriptionNumberpattern
        &GetSubscriptionNumberpatternByName
        &AddSubscriptionNumberpattern
        &ModSubscriptionNumberpattern
        &DelSubscriptionNumberpattern

        &GetSubscriptionsWithNumberpattern
    );
}


=head1 NAME

C4::Serials::Numberpattern - Serials numbering pattern module

=head1 FUNCTIONS

=head2 GetSubscriptionNumberpatterns

@results = GetSubscriptionNumberpatterns;
this function get all subscription number patterns entered in table

=cut

sub GetSubscriptionNumberpatterns {
    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM subscription_numberpatterns
        ORDER by displayorder
    };
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $results = $sth->fetchall_arrayref({});

    return @$results;
}

=head2 GetSubscriptionNumberpattern

$result = GetSubscriptionNumberpattern($numberpatternid);
this function get the data of the subscription numberpatterns which id is $numberpatternid

=cut

sub GetSubscriptionNumberpattern {
    my $numberpatternid = shift;
    my $dbh = C4::Context->dbh;
    my $query = qq(
        SELECT *
        FROM subscription_numberpatterns
        WHERE id = ?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($numberpatternid);

    return $sth->fetchrow_hashref;
}

=head2 GetSubscriptionNumberpatternByName

$result = GetSubscriptionNumberpatternByName($name);
this function get the data of the subscription numberpatterns which name is $name

=cut

sub GetSubscriptionNumberpatternByName {
    my $name = shift;
    my $dbh = C4::Context->dbh;
    my $query = qq(
        SELECT *
        FROM subscription_numberpatterns
        WHERE label = ?
    );
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute($name);

    return $sth->fetchrow_hashref;
}

=head2 AddSubscriptionNumberpattern

=over 4

=item C<$numberpatternid> = &AddSubscriptionNumberpattern($numberpattern)

Add a new numberpattern

=item C<$frequency> is a hashref that contains values of the number pattern

=item Only label and numberingmethod are mandatory

=back

=cut

sub AddSubscriptionNumberpattern {
    my $numberpattern = shift;

    unless(
      ref($numberpattern) eq 'HASH'
      && defined $numberpattern->{'label'}
      && $numberpattern->{'label'} ne ''
      && defined $numberpattern->{'numberingmethod'}
      && $numberpattern->{'numberingmethod'} ne ''
    ) {
        return;
    }

    # FIXME label, description and numberingmethod must be mandatory
    my @keys;
    my @values;
    foreach (qw/ label description numberingmethod displayorder
      label1 label2 label3 add1 add2 add3 every1 every2 every3
      setto1 setto2 setto3 whenmorethan1 whenmorethan2 whenmorethan3
      numbering1 numbering2 numbering3 /) {
        if(exists $numberpattern->{$_}) {
            push @keys, $_;
            push @values, $numberpattern->{$_};
        }
    }

    my $dbh = C4::Context->dbh;
    my $query = "INSERT INTO subscription_numberpatterns";
    $query .= '(' . join(',', @keys) . ')';
    $query .= ' VALUES (' . ('?,' x (scalar(@keys)-1)) . '?)';
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute(@values);

    if(defined $rv) {
        return $dbh->last_insert_id(undef, undef, "subscription_numberpatterns", undef);
    }

    return $rv;
}

=head2 ModSubscriptionNumberpattern

=over 4

=item &ModSubscriptionNumberpattern($numberpattern)

Modifies a numberpattern

=item C<$frequency> is a hashref that contains values of the number pattern

=item Only id is mandatory

=back

=cut

sub ModSubscriptionNumberpattern {
    my $numberpattern = shift;

    unless(
      ref($numberpattern) eq 'HASH'
      && defined $numberpattern->{'id'}
      && $numberpattern->{'id'} > 0
      && (
        (defined $numberpattern->{'label'}
        && $numberpattern->{'label'} ne '')
        || !defined $numberpattern->{'label'}
      )
      && (
        (defined $numberpattern->{'numberingmethod'}
        && $numberpattern->{'numberingmethod'} ne '')
        || !defined $numberpattern->{'numberingmethod'}
      )
    ) {
        return;
    }

    my @keys;
    my @values;
    foreach (qw/ label description numberingmethod displayorder
      label1 label2 label3 add1 add2 add3 every1 every2 every3
      setto1 setto2 setto3 whenmorethan1 whenmorethan2 whenmorethan3
      numbering1 numbering2 numbering3 /) {
        if(exists $numberpattern->{$_}) {
            push @keys, $_;
            push @values, $numberpattern->{$_};
        }
    }

    my $dbh = C4::Context->dbh;
    my $query = "UPDATE subscription_numberpatterns";
    $query .= ' SET ' . join(' = ?,', @keys) . ' = ?';
    $query .= ' WHERE id = ?';
    my $sth = $dbh->prepare($query);

    return $sth->execute(@values, $numberpattern->{'id'});
}

=head2 DelSubscriptionNumberpattern

=over 4

=item &DelSubscriptionNumberpattern($numberpatternid)

Delete a number pattern

=back

=cut

sub DelSubscriptionNumberpattern {
    my $numberpatternid = shift;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        DELETE FROM subscription_numberpatterns
        WHERE id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($numberpatternid);
}

=head2 GetSubscriptionsWithNumberpattern

    my @subs = GetSubscriptionsWithNumberpattern($numberpatternid);

Returns all subscriptions that are using a particular numbering pattern

=cut

sub GetSubscriptionsWithNumberpattern {
    my ($numberpatternid) = @_;

    return unless $numberpatternid;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM subscription
          LEFT JOIN biblio ON subscription.biblionumber = biblio.biblionumber
        WHERE numberpattern = ?
    };
    my $sth = $dbh->prepare($query);
    my @results;
    if ($sth->execute($numberpatternid)) {
        @results = @{ $sth->fetchall_arrayref({}) };
    }
    return @results;
}


1;

__END__

=head1 AUTHOR

Koha Development team <info@koha.org>

=cut
