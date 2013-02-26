package Koha::SMS::Provider;

# Copyright 2012 ByWater Solutions
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

Koha::SMS::Provider - class to manage sms providers

=head1 SYNOPSIS

Object-oriented class that encapsulates sms providers in Koha.

=head1 DESCRIPTION

SMS::Provider data.

=cut

use Modern::Perl;

use C4::Context;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw( id name domain ));

=head2 new

    my $provider = Koha::SMS::Provider->new($data);

Create a new Koha::SMS::Provider object based on the provided record.

=cut

sub new {
    my $class = shift;
    my $data  = shift;

    my $self = $class->SUPER::new($data);

    bless $self, $class;
    return $self;
}

=head2 store

    Creates or updates the object in the database

=cut

sub store {
    my $self = shift;

    if ( $self->id ) {
        return C4::Context->dbh->do( "UPDATE sms_providers SET name = ?, domain = ? WHERE id = ?", undef, ( $self->name, $self->domain, $self->id ) );
    } else {
        return C4::Context->dbh->do( "INSERT INTO sms_providers ( name, domain ) VALUES ( ?, ? )", undef, ( $self->name, $self->domain ) );
    }
}

=head2 delete

=cut

sub delete {
    my $self = shift;

    return C4::Context->dbh->do( "DELETE FROM sms_providers WHERE id = ?", undef, ( $self->id ) );
}

=head2 all

    my $providers = Koha::SMS::Provider->all();

=cut

sub all {
    my $class = shift;

    my $query = "SELECT * FROM sms_providers ORDER BY name";
    my $sth   = C4::Context->dbh->prepare($query);
    $sth->execute();

    my @providers;
    while ( my $row = $sth->fetchrow_hashref() ) {
        my $p = Koha::SMS::Provider->new($row);
        push( @providers, $p );
    }

    return @providers;
}

=head2 find

  my $provider = Koha::SMS::Provider->find( $id );

=cut

sub find {
    my $class = shift;
    my $id    = shift;

    my $query = "SELECT * FROM sms_providers WHERE ID = ?";
    my $sth   = C4::Context->dbh->prepare($query);
    $sth->execute($id);

    my $row = $sth->fetchrow_hashref();
    my $p   = Koha::SMS::Provider->new($row);

    return $p;
}

=head2 search

  my @providers = Koha::SMS::Provider->search({ [name => $name], [domain => $domain] });

=cut

sub search {
    my $class  = shift;
    my $params = shift;

    my $query = "SELECT * FROM sms_providers WHERE ";

    my @params = map( $params->{$_}, keys %$params );
    $query .= join( " AND ", map( "$_ = ?", keys %$params ) );

    $query .= " ORDER BY name";

    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute(@params);

    my @providers;
    while ( my $row = $sth->fetchrow_hashref() ) {
        my $p = Koha::SMS::Provider->new($row);
        push( @providers, $p );
    }

    return @providers;
}

1;
