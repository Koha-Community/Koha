package C4::Creators::Batch;

use strict;
use warnings;

use autouse 'Data::Dumper' => qw(Dumper);

use C4::Context;
use C4::Debug;


sub _check_params {
    my $given_params = {};
    my $exit_code = 0;
    my @valid_template_params = (
        'label_id',
        'batch_id',
        'description',
        'item_number',
        'card_number',
        'branch_code',
        'creator',
    );
    if (scalar(@_) >1) {
        $given_params = {@_};
        foreach my $key (keys %{$given_params}) {
            if (!(grep m/$key/, @valid_template_params)) {
                warn sprintf('Unrecognized parameter type of "%s".', $key);
                $exit_code = 1;
            }
        }
    }
    else {
        if (!(grep m/$_/, @valid_template_params)) {
            warn sprintf('Unrecognized parameter type of %s', $_);
            $exit_code = 1;
        }
    }
    return $exit_code;
}

sub new {
    my ($invocant) = shift;
    my $type = ref($invocant) || $invocant;
    my $self = {
        batch_id        => 0,
        description     => '',
        items           => [],
        branch_code     => 'NB',
        batch_stat      => 0,   # False if any data has changed and the db has not been updated
        @_,
    };
    bless ($self, $type);
    return $self;
}

sub add_item {
    my $self = shift;
    my $number = shift;
    ref($self) =~ m/C4::(.+)::.+$/;
    my $number_type = ($1 eq 'Patroncards' ? 'borrower_number' : 'item_number');
    if ($self->{'batch_id'} == 0){ #if this is a new batch batch_id must be created
        my $sth = C4::Context->dbh->prepare("SELECT MAX(batch_id) FROM creator_batches;");
        $sth->execute();
        my $batch_id = $sth->fetchrow_array;
        $self->{'batch_id'}= ++$batch_id;
    }
    my $query = "INSERT INTO creator_batches (batch_id, description, $number_type, branch_code, creator) VALUES (?,?,?,?,?);";
    my $sth = C4::Context->dbh->prepare($query);
#    $sth->{'TraceLevel'} = 3;
    $sth->execute($self->{'batch_id'}, $self->{'description'}, $number, $self->{'branch_code'}, $1);
    if ($sth->err) {
       warn sprintf('Database returned the following error on attempted INSERT: %s', $sth->errstr);
        return -1;
    }
    $query = "SELECT max(label_id) FROM creator_batches WHERE batch_id=? AND $number_type=? AND branch_code=?;";
    my $sth1 = C4::Context->dbh->prepare($query);
    $sth1->execute($self->{'batch_id'}, $number, $self->{'branch_code'});
    my $label_id = $sth1->fetchrow_array;
    push (@{$self->{'items'}}, {$number_type => $number, label_id => $label_id});
    $self->{'batch_stat'} = 1;
    return 0;
}

sub get_attr {
    my $self = shift;
    return $self->{$_[0]};
}

sub remove_item {
    my $self = shift;
    my $label_id = shift;
    my $query = "DELETE FROM creator_batches WHERE label_id=? AND batch_id=?;";
    my $sth = C4::Context->dbh->prepare($query);
#    $sth->{'TraceLevel'} = 3;
    $sth->execute($label_id, $self->{'batch_id'});
    if ($sth->err) {
        warn sprintf('Database returned the following error on attempted DELETE: %s', $sth->errstr);
        return -1;
    }
    @{$self->{'items'}} = grep{$_->{'label_id'} != $label_id} @{$self->{'items'}};
    $self->{'batch_stat'} = 1;
    return 0;
}

# FIXME: This method is effectively useless the way the current add_item method is written. Ideally, the items should be added to the object
#       and then the save method called. This does not work well in practice due to the inability to pass objects across cgi script calls.
#       I'm leaving it here because it should be here and for consistency's sake and once memcached support is fully implemented this should be as well. -cnighswonger
#
#=head2 $batch->save()
#
#    Invoking the I<save> method attempts to insert the batch into the database. The method returns
#    the new record batch_id upon success and -1 upon failure (This avoids conflicting with a record
#    batch_id of 1). Errors are logged to the Apache log.
#
#    example:
#        my $exitstat = $batch->save(); # to save the record behind the $batch object
#
#=cut
#
#sub save {
#    my $self = shift;
#    foreach my $item_number (@{$self->{'items'}}) {
#        my $query = "INSERT INTO creator_batches (batch_id, item_number, branch_code) VALUES (?,?,?);";
#        my $sth1 = C4::Context->dbh->prepare($query);
#        $sth1->execute($self->{'batch_id'}, $item_number->{'item_number'}, $self->{'branch_code'});
#        if ($sth1->err) {
#            warn sprintf('Database returned the following error on attempted INSERT: %s', $sth1->errstr);
#            return -1;
#        }
#        $self->{'batch_stat'} = 1;
#        return $self->{'batch_id'};
#    }
#}

sub retrieve {
    my $invocant = shift;
    my %opts = @_;
    my $type = ref($invocant) || $invocant;
    $type =~ m/C4::(.+)::.+$/;
    my $number_type = ($1 eq 'Patroncards' ? 'borrower_number' : 'item_number');
    my $record_flag = 0;
    my $query = "SELECT * FROM creator_batches WHERE batch_id = ? ORDER BY label_id";
    my $sth = C4::Context->dbh->prepare($query);
#    $sth->{'TraceLevel'} = 3;
    $sth->execute($opts{'batch_id'});
    my $self = {
        batch_id        => $opts{'batch_id'},
        items           => [],
    };
    while (my $record = $sth->fetchrow_hashref) {
        $self->{'branch_code'} = $record->{'branch_code'};
        $self->{'creator'} = $record->{'creator'};
        $self->{'description'} = $record->{'description'};
        push (@{$self->{'items'}}, {$number_type => $record->{$number_type}, label_id => $record->{'label_id'}});
        $record_flag = 1;       # true if one or more rows were retrieved
    }
    return -2 if $record_flag == 0;     # a hackish sort of way of indicating no such record exists
    if ($sth->err) {
        warn sprintf('Database returned the following error on attempted SELECT: %s', $sth->errstr);
        return -1;
    }
    $self->{'batch_stat'} = 1;
    bless ($self, $type);
    return $self;
}

sub delete {
    my $self = {};
    my %opts = ();
    my $call_type = '';
    my @query_params = ();
    if (ref($_[0])) {
        $self = shift;  # check to see if this is a method call
        $call_type = 'C4::Labels::Batch->delete'; # seems hackish
        @query_params = ($self->{'batch_id'}, $self->{'branch_code'});
    }
    else {
        shift @_;
        %opts = @_;
        $call_type = 'C4::Labels::Batch::delete';
        @query_params = ($opts{'batch_id'}, $opts{'branch_code'});
    }
    if ($query_params[0] eq '') {   # If there is no template id then we cannot delete it
        warn sprintf('%s : Cannot delete batch as the batch id is invalid or non-existent.', $call_type);
        return -1;
    }
    my $query = "DELETE FROM creator_batches WHERE batch_id = ? AND branch_code =?";
    my $sth = C4::Context->dbh->prepare($query);
#    $sth->{'TraceLevel'} = 3;
    $sth->execute(@query_params);
    if ($sth->err) {
        warn sprintf('%s : Database returned the following error on attempted INSERT: %s', $call_type, $sth->errstr);
        return -1;
    }
    return 0;
}

sub remove_duplicates {
    my $self = shift;
    my %seen=();
    my $query = "DELETE FROM creator_batches WHERE label_id = ?;"; # ORDER BY timestamp ASC LIMIT ?;";
    my $sth = C4::Context->dbh->prepare($query);
    my @duplicate_items = grep{
        $_->{'item_number'}
            ? $seen{$_->{'item_number'}}++
            : $seen{$_->{'borrower_number'}}++
    } @{$self->{'items'}};
    foreach my $item (@duplicate_items) {
        $sth->execute($item->{'label_id'});
        if ($sth->err) {
            warn sprintf('Database returned the following error on attempted DELETE for label_id %s: %s', $item->{'label_id'}, $sth->errstr);
            return -1;
        }
        $sth->finish(); # Per DBI.pm docs: "If execute() is called on a statement handle that's still active ($sth->{Active} is true) then it should effectively call finish() to tidy up the previous execution results before starting this new execution."
        @{$self->{'items'}} = grep{$_->{'label_id'} != $item->{'label_id'}} @{$self->{'items'}};  # the correct label/item must be removed from the current batch object as well; this should be done *after* each sql DELETE in case the DELETE fails
    }
    return scalar(@duplicate_items);
}

1;
__END__

=head1 NAME

C4::Labels::Batch - A class for creating and manipulating batch objects in Koha

=head1 ABSTRACT

This module provides methods for creating, and otherwise manipulating batch objects used by Koha to create and export labels.

=head1 METHODS

=head2 new()

    Invoking the I<new> method constructs a new batch object with no items. It is possible to pre-populate the batch with items and a branch code by passing them
    as in the second example below.

    B<NOTE:> The items list must be an arrayref pointing to an array of hashes containing a key/data pair after this fashion: {item_number => item_number}. The order of
    the array elements determines the order of the items in the batch.

    example:
        C<my $batch = C4::Labels::Batch->new(); # Creates and returns a new batch object>

        C<my $batch = C4::Labels::Batch->new(items => $arrayref, branch_code => branch_code) #    Creates and returns a new batch object containing the items passed in
            with the branch code passed in.>

    B<NOTE:> This batch is I<not> written to the database until C<$batch->save()> is invoked. You have been warned!

=head2 $batch->add_item(item_number => $item_number, branch_code => $branch_code)

    Invoking the I<add_item> method will add the supplied item to the batch object.

    example:
        $batch->add_item(item_number => $item_number, branch_code => $branch_code);

=head2 $batch->get_attr($attribute)

    Invoking the I<get_attr> method will return the requested attribute.

    example:
        my @items = $batch->get_attr('items');

=head2 $batch->remove_item($item_number)

    Invoking the I<remove_item> method will remove the supplied item number from the batch object.

    example:
        $batch->remove_item($item_number);

=head2 C4::Labels::Batch->retrieve(batch_id => $batch_id)

    Invoking the I<retrieve> method constructs a new batch object containing the current values for batch_id. The method returns a new object upon success and 1 upon failure.
    Errors are logged to the Apache log.

    examples:

        my $batch = C4::Labels::Batch->retrieve(batch_id => 1); # Retrieves batch 1 and returns an object containing the record

=head2 delete()

    Invoking the delete method attempts to delete the template from the database. The method returns -1 upon failure. Errors are logged to the Apache log.
    NOTE: This method may also be called as a function and passed a key/value pair simply deleteing that batch from the database. See the example below.

    examples:
        my $exitstat = $batch->delete(); # to delete the record behind the $batch object
        my $exitstat = C4::Labels::Batch->delete(batch_id => 1); # to delete batch 1

=head2 remove_duplicates()

    Invoking the remove_duplicates method attempts to remove duplicate items in the batch from the database. The method returns the count of duplicate records removed upon
    success and -1 upon failure. Errors are logged to the Apache log.
    NOTE: This method may also be called as a function and passed a key/value pair removing duplicates in the batch passed in. See the example below.

    examples:
        my $remove_count = $batch->remove_duplicates(); # to remove duplicates the record behind the $batch object
        my $remove_count = C4::Labels::Batch->remove_duplicates(batch_id => 1); # to remove duplicates in batch 1

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2009 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with Koha; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
Fifth Floor, Boston, MA 02110-1301 USA.

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut

