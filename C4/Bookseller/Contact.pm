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

=item primary

Flag to indicate whether a contact is "primary" or not. Initially unused since
each bookseller can have only one contact.

=item bookseller

ID of the bookseller the contact is associated with.

=back

=cut

use Modern::Perl;
use C4::Context;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(id name position phone altphone fax email notes primary bookseller));

=head1 METHODS

=head2 get_from_bookseller

    my @contacts = @{C4::Bookseller::Contact->get_from_bookseller($booksellerid)};

Returns a reference to an array of C4::Bookseller::Contact objects for the
specified bookseller.

=cut

sub get_from_bookseller {
    my ($class, $bookseller) = @_;

    return unless $bookseller;

    my @contacts;
    my $query = "SELECT contact AS name, contpos AS position, contphone AS phone, contaltphone AS altphone, contfax AS fax, contemail AS email, contnotes AS notes, id AS bookseller FROM aqbooksellers WHERE id = ?";
    # When we have our own table, we can use: my $query = "SELECT * FROM aqcontacts WHERE bookseller = ?";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($bookseller);
    while (my $rec = $sth->fetchrow_hashref()) {
        $rec->{'primary'} = 1;
        push @contacts, $class->new($rec);
    }

    return \@contacts;
}


=head2 fetch

    my $contact = C4::Bookseller::Contact->fetch($contactid);

Retrieves the specified contact from the database. Currently commented out
because there is no separate table from which contacts can be fetched.

=cut

#sub fetch {
#    my ($class, $id) = @_;
#
#    my $rec = { };
#    if ($id) {
#        my $query = "SELECT * FROM aqcontacts WHERE id = ?";
#        my $dbh = C4::Context->dbh;
#        my $sth = $dbh->prepare($query);
#        $sth->execute($id);
#        $rec = $sth->fetchrow_hashref();
#    }
#    my $self = $class->SUPER::new($rec);
#    bless $self, $class;
#    return $self;
#}

=head2 save

    $contact->save();

Save a contact to the database.

=cut

sub save {
    my ($self) = @_;

    my $query;
#    if ($self->id) {
#        $query = 'UPDATE aqcontacts SET name = ?, position = ?, phone = ?, altphone = ?, fax = ?, email = ?, notes = ?, primary = ? WHERE id = ?;';
#    } else {
#        $query = 'INSERT INTO aqcontacts (name, position, phone, altphone, fax, email, notes, primary) VALUES (?, ?, ?, ?, ? ,? ,?, ?);';
#    }
    if ($self->bookseller) {
        $query = 'UPDATE aqbooksellers SET contact = ?, contpos = ?, contphone = ?, contaltphone = ?, contfax = ?, contemail = ?, contnotes = ? WHERE id = ?;';
    } else {
        return;
    }
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($self->name, $self->position, $self->phone, $self->altphone, $self->fax, $self->email, $self->notes, $self->bookseller);
    #$self->id = $dbh->last_insert_id(undef, undef, 'aqcontacts', undef);
    return $self->bookseller;
}

=head1 AUTHOR

Jared Camins-Esakov <jcamins@cpbibliography.com>

=cut

1;
