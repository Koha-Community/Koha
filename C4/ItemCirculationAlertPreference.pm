package C4::ItemCirculationAlertPreference;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;
use C4::Context;
use Carp qw(carp croak);

our $AUTOLOAD;

# helper function for validating \%opts
our $valid = sub {
    my $opts = shift;
    for (qw(branchcode categorycode item_type)) {
        exists($opts->{$_}) || croak("'$_' is a required parameter.");
    }
};




=head1 NAME

C4::ItemCirculationAlertPreference - manage preferences for sending alerts

=head1 SYNOPSIS

Basics:

    use C4::ItemCirculationAlertPreference;

    # a short-cut to reduce typing the long package name over and over again
    my $preferences = 'C4::ItemCirculationAlertPreference';

Creating Rules:

    my $pref = $preferences->create({
        branchcode   => 'CPL',
        categorycode => 'YA',
        item_type    => 'BK',
    });

Deleting Rules:

    $preferences->delete({
        branchcode   => 'CPL',
        categorycode => 'YA',
        item_type    => 'BK',
    });

=head1 DESCRIPTION

This class is used to manage the preferences for when an alert may be sent.  By
default, item circulation alerts are enabled for every B<branch>, B<patron
category> and B<item type>.

However, if you would like to prevent item circulation alerts from being sent
for any combination of these 3 variables, a preference can be inserted into the
C<item_circulation_alert_preferences> table to make that a policy.

=head1 API

=head2 Class Methods

=cut

=head3 C4::ItemCirculationAlertPreference->new(\%opts)

This is a constructor for an in-memory C4::ItemCirculationAlertPreference
object.  The database is not affected by this method.

=cut

sub new {
    my ($class, $opts) = @_;
    bless $opts => $class;
}




=head3 C4::ItemCirculationAlertPreference->create(\%opts)

This will find or create an item circulation alert preference.  You must pass
it a B<branchcode>, B<categorycode>, and B<item_type>.

=cut

sub create {
    my ($class, $opts) = @_;
    $valid->($opts);
    my $dbh = C4::Context->dbh;
    my $prefs = $dbh->selectall_arrayref(
        "SELECT id, branchcode, categorycode, item_type
        FROM  item_circulation_alert_preferences
        WHERE branchcode   = ?
        AND   categorycode = ?
        AND   item_type    = ?",
        { Slice => {} },
        $opts->{branchcode},
        $opts->{categorycode},
        $opts->{item_type},
    );
    if (@$prefs) {
        return $class->new($prefs->[0]);
    } else {
        my $success = $dbh->do(
            "INSERT INTO item_circulation_alert_preferences
            (branchcode, categorycode, item_type) VALUES (?, ?, ?)",
            {},
            $opts->{branchcode},
            $opts->{categorycode},
            $opts->{item_type},
        );
        if ($success) {
            my $self = {
                id           => $dbh->last_insert_id(undef, undef, undef, undef),
                branchcode   => $opts->{branchcode},
                categorycode => $opts->{categorycode},
                item_type    => $opts->{item_type},
            };
            return $class->new($self);
        } else {
            carp $dbh->errstr;
            return undef;
        }
    }
}




=head3 C4::ItemCirculationAlertPreference->delete(\%opts)

Delete an item circulation alert preference.  You can delete by either passing
in an B<id> or passing in a B<branchcode>, B<categorycode>, B<item_type>
triplet.

=cut

sub delete {
    my ($class, $opts) = @_;
    my $dbh = C4::Context->dbh;
    if ($opts->{id}) {
        $dbh->do(
            "DELETE FROM item_circulation_alert_preferences WHERE id = ?",
            {},
            $opts->{id}
        );
    } else {
        $valid->($opts);
        $dbh->do(
            "DELETE FROM item_circulation_alert_preferences
            WHERE branchcode   = ?
            AND   categorycode = ?
            AND   item_type    = ?",
            {},
            $opts->{branchcode},
            $opts->{categorycode},
            $opts->{item_type}
        );
    }
}




=head3 C4::ItemCirculationAlertPreference->is_enabled_for(\%opts)

Based on the existing preferences in the C<item_circulation_alert_preferences>
table, can an alert be sent for the given B<branchcode>, B<categorycode>, and
B<itemtype>?

B<Example>:

    my $alert = 'C4::ItemCirculationAlertPreference';
    my $conditions = {
        branchcode   => 'CPL',
        categorycode => 'IL',
        item_type    => 'MU',
    };

    if ($alert->is_enabled_for($conditions)) {
        # ...
    }

=cut

sub is_enabled_for {
    my ($class, $opts) = @_;
    $valid->($opts);
    my $dbh = C4::Context->dbh;

    # Does a preference exist to block this alert?
    my $query = qq{
        SELECT id
          FROM item_circulation_alert_preferences
         WHERE (branchcode   = ? OR branchcode   = '*')
           AND (categorycode = ? OR categorycode = '*')
           AND (item_type    = ? OR item_type    = '*')
    };

    my $preferences = $dbh->selectall_arrayref(
        $query,
        { },
        $opts->{branchcode},
        $opts->{categorycode},
        $opts->{item_type},
    );

    # If any preferences showed up, we are NOT enabled.
    if (@$preferences) {
        return undef;
    } else {
        return 1;
    }
}




=head3 C4::ItemCirculationAlertPreference->find({ branchcode => $bc })

This method returns all the item circulation alert preferences for a given
branch.

B<Example>:

    my @branch_prefs = C4::ItemCirculationAlertPreference->find({
        branchcode => 'CPL',
    });

=cut

sub find {
    my ($class, $where) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT id, branchcode, categorycode, item_type
          FROM item_circulation_alert_preferences
         WHERE branchcode = ?
         ORDER BY categorycode, item_type
    };
    return    map { $class->new($_) }    @{$dbh->selectall_arrayref(
        $query,
        { Slice => {} },
        $where->{branchcode}
    )};
}




=head2 Object Methods

These are read-only accessors for the various attributes of a preference.

=head3 $pref->id

=head3 $pref->branchcode

=head3 $pref->categorycode

=head3 $pref->item_type

=cut

sub AUTOLOAD {
    my $self = shift;
    my $attr = $AUTOLOAD;
    $attr =~ s/.*://;
    if (exists $self->{$attr}) {
        return $self->{$attr};
    } else {
        return undef;
    }
}




=head1 SEE ALSO

L<C4::Circulation>, C<admin/item_circulation_alerts.pl>

=head1 AUTHOR

John Beppu <john.beppu@liblime.com>

=cut

1;

# Local Variables: ***
# mode: cperl ***
# indent-tabs-mode: nil ***
# cperl-close-paren-offset: -4 ***
# cperl-continued-statement-offset: 4 ***
# cperl-indent-level: 4 ***
# cperl-indent-parens-as-block: t ***
# cperl-tab-always-indent: nil ***
# End: ***
# vim:tabstop=8 softtabstop=4 shiftwidth=4 shiftround expandtab
