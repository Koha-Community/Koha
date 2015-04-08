package C4::ItemCirculationAlertPreference;

# Copyright Liblime 2009
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
use C4::Category;
use C4::ItemType;
use Carp qw(carp croak);

our $AUTOLOAD;

# helper function for validating \%opts
our $valid = sub {
    my $opts = shift;
    for (qw(branchcode categorycode item_type notification)) {
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

Creating a restriction on sending messages:

    my $pref = $preferences->create({
        branchcode   => 'CPL',
        categorycode => 'YA',
        item_type    => 'BK',
        notification => 'CHECKOUT',
    });

Removing a restriction on sending messages:

    $preferences->delete({
        branchcode   => 'CPL',
        categorycode => 'YA',
        item_type    => 'BK',
        notification => 'CHECKOUT',
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
it a B<branchcode>, B<categorycode>, B<item_type>, and B<notification>.  Valid
values for these attributes are as follows:

=over 4

=item branchcode

branches.branchcode

=item categorycode

category.categorycode

=item item_type

itemtypes.itemtype

=item notification

This can be "CHECKIN" or "CHECKOUT"

=back

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
        AND   item_type    = ?
        AND   notification = ?",
        { Slice => {} },
        $opts->{branchcode},
        $opts->{categorycode},
        $opts->{item_type},
        $opts->{notification},
    );
    if (@$prefs) {
        return $class->new($prefs->[0]);
    } else {
        my $success = $dbh->do(
            "INSERT INTO item_circulation_alert_preferences
            (branchcode, categorycode, item_type, notification) VALUES (?, ?, ?, ?)",
            {},
            $opts->{branchcode},
            $opts->{categorycode},
            $opts->{item_type},
            $opts->{notification},
        );
        if ($success) {
            my $self = {
                id           => $dbh->last_insert_id(undef, undef, undef, undef),
                branchcode   => $opts->{branchcode},
                categorycode => $opts->{categorycode},
                item_type    => $opts->{item_type},
                notification => $opts->{notification},
            };
            return $class->new($self);
        } else {
            carp $dbh->errstr;
            return;
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
        my $sql =
            "DELETE FROM item_circulation_alert_preferences
            WHERE branchcode   = ?
            AND   categorycode = ?
            AND   item_type    = ?
            AND   notification = ?";
        $dbh->do(
            $sql,
            {},
            $opts->{branchcode},
            $opts->{categorycode},
            $opts->{item_type},
            $opts->{notification},
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

sub is_disabled_for {
    my ($class, $opts) = @_;
    $valid->($opts);
    my $dbh = C4::Context->dbh;

    # Does a preference exist to block this alert?
    my $query = qq{
        SELECT id, branchcode, categorycode, item_type, notification
          FROM item_circulation_alert_preferences
         WHERE (branchcode   = ? OR branchcode   = '*')
           AND (categorycode = ? OR categorycode = '*')
           AND (item_type    = ? OR item_type    = '*')
           AND (notification = ? OR notification = '*')
    };

    my $preferences = $dbh->selectall_arrayref(
        $query,
        { Slice => {} },
        $opts->{branchcode},
        $opts->{categorycode},
        $opts->{item_type},
        $opts->{notification},
    );

    # If any preferences showed up, we are NOT enabled.
    return @$preferences;
}

sub is_enabled_for {
    my ($class, $opts) = @_;
    return not $class->is_disabled_for($opts);
}




=head3 C4::ItemCirculationAlertPreference->find({ branchcode => $bc, notification => $type })

This method returns all the item circulation alert preferences for a given
branch and notification.

B<Example>:

    my @branch_prefs = C4::ItemCirculationAlertPreference->find({
        branchcode   => 'CPL',
        notification => 'CHECKIN',
    });

=cut

sub find {
    my ($class, $where) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT id, branchcode, categorycode, item_type, notification
          FROM item_circulation_alert_preferences
         WHERE branchcode = ? AND notification = ?
         ORDER BY categorycode, item_type
    };
    return    map { $class->new($_) }    @{$dbh->selectall_arrayref(
        $query,
        { Slice => {} },
        $where->{branchcode},
        $where->{notification},
    )};
}




=head3 C4::ItemCirculationAlertPreference->grid({ branchcode => $c, notification => $type })

Return a 2D arrayref for the grid view in F<admin/item_circulation_alert_preferences.pl>.
Each row represents a category (like 'Patron' or 'Young Adult') and
each column represents an itemtype (like 'Book' or 'Music').

Each cell contains...

B<Example>:

    use Data::Dump 'pp';
    my $grid = C4::ItemCirculationAlertPreference->grid({
        branchcode   => 'CPL',
        notification => 'CHECKOUT',
    });
    warn pp($grid);

See F<admin/item_circulation_alerts.pl> to see how this method is used.

=cut

sub grid {
    my ($class, $where) = @_;
    my @branch_prefs = $class->find($where);
    my @default_prefs = $class->find({ branchcode => '*', notification => $where->{notification} });
    my @cc = C4::Category->all;
    my @it = C4::ItemType->all;
    my $notification = $where->{notification};
    my %disabled = map {
        my $key = $_->categorycode . "-" . $_->item_type . "-" . $notification;
        $key =~ s/\*/_/g;
        ($key => 1);
    } @branch_prefs;
    my %default = map {
        my $key = $_->categorycode . "-" . $_->item_type . "-" . $notification;
        $key =~ s/\*/_/g;
        ($key => 1);
    } @default_prefs;
    my @grid;
    for my $c (@cc) {
        my $row = { description => $c->description, items => [] };
        push @grid, $row;
        for my $i (@it) {
            my $key = $c->categorycode . "-" . $i->itemtype . "-" . $notification;
            $key =~ s/\*/_/g;
            my @classes;
            my $text = " ";
            if ($disabled{$key}) {
                push @classes, 'disabled';
                $text = "Disabled for $where->{branchcode}";
            }
            if ($default{$key}) {
                push @classes, 'default';
                $text = "Disabled for all";
            }
            push @{$row->{items}}, {
                class => join(' ', @classes),
                id    => $key,
                text  => $text,
            };
        }
    }
    return \@grid;
}




=head2 Object Methods

These are read-only accessors for the various attributes of a preference.

=head3 $pref->id

=cut

=head3 $pref->branchcode

=cut

=head3 $pref->categorycode

=cut

=head3 $pref->item_type

=cut

=head3 $pref->notification

=cut

sub AUTOLOAD {
    my $self = shift;
    my $attr = $AUTOLOAD;
    $attr =~ s/.*://;
    if (exists $self->{$attr}) {
        return $self->{$attr};
    } else {
        return;
    }
}

sub DESTROY { }



=head1 SEE ALSO

L<C4::Circulation>, F<admin/item_circulation_alerts.pl>

=head1 AUTHOR

John Beppu <john.beppu@liblime.com>

=cut

1;
