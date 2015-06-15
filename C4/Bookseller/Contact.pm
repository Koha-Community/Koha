package C4::Bookseller::Contact;

# Copyright 2013 C & P Bibliography Services
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

C4::Bookseller::Contact - object class for contacts associated with vendors

=head1 SYNPOSIS

This class provides an object-oriented interface for handling vendor contacts.
It uses Class::Accessor to provide access to the following fields:

=head1 FIELDS

=over 8

=item id

ID of the contact. This is not used initially, since contacts are actually
stored in the aqbooksellers table.

=item name

Contact name.

=item position

Contact's position.

=item phone

Contact's primary phone number.

=item altphone

Contact's alternate phone number.

=item fax

Contact's fax number.

=item email

Contact's e-mail address.

=item notes

Notes about contact.

=item orderacquisition

Whether the contact should receive acquisitions orders.

=item claimacquisition

Whether the contact should receive acquisitions claims.

=item claimissues

Whether the contact should receive serials claims.

=item acqprimary

Whether the contact is the primary contact for acquisitions.

=item serialsprimary

Whether the contact is the primary contact for serials.

=item bookseller

ID of the bookseller the contact is associated with.

=back

=cut

use Modern::Perl;
use C4::Context;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(id name position phone altphone fax email notes orderacquisition claimacquisition claimissues acqprimary serialsprimary bookseller));

=head1 METHODS

=head2 get_from_bookseller

    my @contacts = @{C4::Bookseller::Contact->get_from_bookseller($booksellerid)};

Returns a reference to an array of C4::Bookseller::Contact objects for the
specified bookseller. This will always return at least one item, though that one
item may be an empty contact.

=cut

sub get_from_bookseller {
    my ($class, $bookseller) = @_;

    return unless $bookseller;

    my @contacts;
    my $query = "SELECT * FROM aqcontacts WHERE booksellerid = ?";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($bookseller);
    while (my $rec = $sth->fetchrow_hashref()) {
        push @contacts, $class->new($rec);
    }

    push @contacts, $class->new() unless @contacts;

    return \@contacts;
}


=head2 fetch

    my $contact = C4::Bookseller::Contact->fetch($contactid);

Retrieves the specified contact from the database. Currently commented out
because there is no separate table from which contacts can be fetched.

=cut

sub fetch {
    my ($class, $id) = @_;

    my $rec = { };
    if ($id) {
        my $query = "SELECT * FROM aqcontacts WHERE id = ?";
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare($query);
        $sth->execute($id);
        $rec = $sth->fetchrow_hashref();
    }
    my $self = $class->new($rec);
    bless $self, $class;
    return $self;
}

=head2 save

    $contact->save();

Save a contact to the database.

=cut

sub save {
    my ($self) = @_;

    my $query;
    my @params = (
        $self->name,  $self->position,
        $self->phone, $self->altphone,
        $self->fax,   $self->email,
        $self->notes, $self->acqprimary ? 1 : 0,
        $self->serialsprimary ? 1 : 0,
        $self->orderacquisition ? 1 : 0, $self->claimacquisition ? 1 : 0,
        $self->claimissues ? 1 : 0, $self->bookseller
    );
    if ($self->id) {
        $query = 'UPDATE aqcontacts SET name = ?, position = ?, phone = ?, altphone = ?, fax = ?, email = ?, notes = ?, acqprimary = ?, serialsprimary = ?, orderacquisition = ?, claimacquisition = ?, claimissues = ?, booksellerid = ? WHERE id = ?;';
        push @params, $self->id;
    } else {
        $query = 'INSERT INTO aqcontacts (name, position, phone, altphone, fax, email, notes, acqprimary, serialsprimary, orderacquisition, claimacquisition, claimissues, booksellerid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);';
    }
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(@params);
    $self->id($dbh->{'mysql_insertid'}) unless $self->id;
    return $self->id;
}

sub delete {
    my ($self) = @_;

    return unless $self->id;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("DELETE FROM aqcontacts WHERE id = ?;");
    $sth->execute($self->id);
    return;
}

=head1 AUTHOR

Jared Camins-Esakov <jcamins@cpbibliography.com>

=cut

1;
