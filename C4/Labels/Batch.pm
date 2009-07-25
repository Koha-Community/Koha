package C4::Labels::Batch;

# Copyright 2009 Foundations Bible College.
#
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

use Sys::Syslog qw(syslog);

use C4::Context;
use C4::Debug;
use C4::Biblio;
use C4::Labels::Layout 1.000000;        # use version 1.0.0 or better
use C4::Labels::Template 1.000000;
use Data::Dumper;

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');
}

sub _check_params {
    my $given_params = {};
    my $exit_code = 0;
    my @valid_template_params = (
        'layout_id',
        'template_id',
        'profile_id',
    );
    if (scalar(@_) >1) {
        $given_params = {@_};
        foreach my $key (keys %{$given_params}) {
            if (!(grep m/$key/, @valid_template_params)) {
                syslog("LOG_ERR", "C4::Labels::Batch : Unrecognized parameter type of \"%s\".", $key);
                $exit_code = 1;
            }
        }
    }
    else {
        if (!(grep m/$_/, @valid_template_params)) {
            syslog("LOG_ERR", "C4::Labels::Batch : Unrecognized parameter type of \"%s\".", $_);
            $exit_code = 1;
        }
    }
    return $exit_code;
}

=head1 NAME

C4::Labels::Batch - A class for creating and manipulating batch objects in Koha

=cut

=head1 METHODS

=head2 C4::Labels::Batch->new(layout_id => layout_id, template_id => template_id, profile_id => profile_id)

    Invoking the I<new> method constructs a new batch object with no items.

    example:
        my $batch = C4::Labels::Batch->new(layout_id => layout_id, template_id => template_id, profile_id => profile_id);
            # Creates and returns a new batch object

    B<NOTE:> This batch is I<not> written to the database untill $batch->save() is invoked. You have been warned!

=cut

sub new {
    my ($invocant, %params) = @_;
    my $type = ref($invocant) || $invocant;
    my $self = {
        batch_id        => 0,
        layout_id       => $params{layout_id},
        template_id         => $params{template_id},
        profile_id      => $params{profile_id},
        items           => [],
        batch_stat      => 0,   # False if any data has changed and the db has not been updated
    };
    bless ($self, $type);
    return $self;
}

=head2 $batch->add_item($item_number)

    Invoking the I<add_item> method will add the supplied item to the batch object.

    example:
        $batch->add_item($item_number);

=cut

sub add_item {
    my $self = shift;
    my $item_num = shift;
    push (@{$self->{items}}, $item_num);
    $self->{batch_stat} = 0;
}

=head2 $batch->get_attr()

    Invoking the I<get_attr> method will return the requested attribute.

    example:
        my @items = $batch->get_attr($attr);

=cut

sub get_attr {
    my $self = shift;
    return $self->{$_[0]};
}

=head2 $batch->delete_item()

    Invoking the I<delete_item> method will delete the supplied item from the batch object.

    example:
        $batch->delete_item();

=cut

sub delete_item {
    my $self = shift;
    my $item_num = shift;
    my $index = 0;
    ++$index until $$self->{items}[$index] == $item_num or $item_num > $#$self->{items};
    delete ($$self->{items}[$index]);
    $self->{batch_stat} = 0;
}

=head2 $batch->save()

    Invoking the I<save> method attempts to insert the batch into the database if the batch is new and
    update the existing batch record if the batch exists. The method returns the new record batch_id upon
    success and -1 upon failure (This avoids conflicting with a record batch_id of 1). Errors are
    logged to the syslog.

    example:
        my $exitstat = $batch->save(); # to save the record behind the $batch object

=cut

sub save {
    my $self = shift;
    if ($self->{batch_id} > 0) {
        foreach my $item_number (@$self->{items}) {
            my $query = "UPDATE labels_batches SET item_number=?, layout_id=?, template_id=?, profile_id=? WHERE batch_id=?;";
            warn "DEBUG: Updating: $query\n" if $debug;
            my $sth->C4::Context->dbh->prepare($query);
            $sth->execute($item_number, $self->{layout_id}, $self->{template_id}, $self->{profile_id}, $self->{batch_id});
            if ($sth->err) {
                syslog("LOG_ERR", "Database returned the following error: %s", $sth->errstr);
                return -1;
            }
        }
    }
    else {
        foreach my $item_number (@$self->{items}) {
            my $query = "INSERT INTO labels_batches (item_number, layout_id, template_id, profile_id) VALUES (?,?,?,?);";
            warn "DEBUG: Inserting: $query\n" if $debug;
            my $sth->C4::Context->dbh->prepare($query);
            $sth->execute($item_number, $self->{layout_id}, $self->{template_id}, $self->{profile_id});
            if ($sth->err) {
                syslog("LOG_ERR", "Database returned the following error: %s", $sth->errstr);
                return -1;
            }
            my $sth1 = C4::Context->dbh->prepare("SELECT MAX(batch_id) FROM labels_batches;");
            $sth1->execute();
            my $batch_id = $sth1->fetchrow_array;
            $self->{batch_id} = $batch_id;
            return $batch_id;
        }
    }
    $self->{batch_stat} = 1;
}

=head2 C4::Labels::Template->retrieve(template_id)

    Invoking the I<retrieve> method constructs a new template object containing the current values for template_id. The method returns
    a new object upon success and 1 upon failure. Errors are logged to the syslog. Two further options may be accessed. See the example
    below for further description.

    examples:

        my $template = C4::Labels::Template->retrieve(template_id => 1); # Retrieves template record 1 and returns an object containing the record

        my $template = C4::Labels::Template->retrieve(template_id => 1, convert => 1); # Retrieves template record 1, converts the units to points,
            and returns an object containing the record

        my $template = C4::Labels::Template->retrieve(template_id => 1, profile_id => profile_id); # Retrieves template record 1, converts the units
            to points, applies the given profile id, and returns an object containing the record

=cut

sub retrieve {
    my $invocant = shift;
    my %opts = @_;
    my $type = ref($invocant) || $invocant;
    my $query = "SELECT * FROM labels_batches WHERE batch_id = ? ORDER BY label_id";  
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($opts{batch_id});
    if ($sth->err) {
        syslog("LOG_ERR", "Database returned the following error: %s", $sth->errstr);
        return 1;
    }
    my $self = {
        items   => [],
    };
    while (my $record = $sth->fetchrow_hashref) {
        $self->{batch_id} = $record->{batch_id};        # FIXME: seems a bit wasteful to re-initialize these every trip: is there a better way?
        $self->{layout_id} = $record->{layout_id};
        $self->{template_id} = $record->{template_id};
        $self->{profile_id} = $record->{profile_id};
        push (@{$self->{items}}, $record->{item_number});
    }
    $self->{batch_stat} = 1;
    bless ($self, $type);
    return $self;
}

=head2 C4::Labels::Batch->delete(batch_id => batch_id) |  $batch->delete()

    Invoking the delete method attempts to delete the batch from the database. The method returns 0 upon success
    and 1 upon failure. Errors are logged to the syslog.

    examples:
        my $exitstat = $batch->delete(); # to delete the record behind the $batch object
        my $exitstat = C4::Labels::Batch->delete(batch_id => 1); # to delete batch record 1

=cut

sub delete {
    my $self = shift;
    my %opts = @_;
    if ((ref $self) && !$self->{'batch_id'}) {   # If there is no batch batch_id then we cannot delete it from the db
        syslog("LOG_ERR", "Cannot delete batch: Batch has not been saved.");
        return 1;
    }
    elsif (!$opts{batch_id}) {
        syslog("LOG_ERR", "Cannot delete batch: Missing batch_id.");
        return 1;
    }
    my $query = "DELETE FROM labels_batches WHERE batch_id = ?";
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($self->{'batch_id'});
    return 0;
}


1;
__END__

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=cut

