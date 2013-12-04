package Koha::AdditionalField;

use Modern::Perl;

use base qw(Class::Accessor);

use C4::Context;

__PACKAGE__->mk_accessors(qw( id tablename name authorised_value_category marcfield searchable values ));

sub new {
    my ( $class, $args ) = @_;

    my $additional_field = {
        id => $args->{id} // q||,
        tablename => $args->{tablename} // q||,
        name => $args->{name} // q||,
        authorised_value_category => $args->{authorised_value_category} // q||,
        marcfield => $args->{marcfield} // q||,
        searchable => $args->{searchable} // 0,
        values => $args->{values} // {},
    };

    my $self = $class->SUPER::new( $additional_field );

    bless $self, $class;
    return $self;
}

sub fetch {
    my ( $self ) = @_;
    my $dbh = C4::Context->dbh;
    my $field_id = $self->id;
    return unless $field_id;
    my $data = $dbh->selectrow_hashref(
        q|
            SELECT id, tablename, name, authorised_value_category, marcfield, searchable
            FROM additional_fields
            WHERE id = ?
        |,
        {}, ( $field_id )
    );

    die "This additional field does not exist (id=$field_id)" unless $data;
    $self->{id} = $data->{id};
    $self->{tablename} = $data->{tablename};
    $self->{name} = $data->{name};
    $self->{authorised_value_category} = $data->{authorised_value_category};
    $self->{marcfield} = $data->{marcfield};
    $self->{searchable} = $data->{searchable};
    return $self;
}

sub update {
    my ( $self ) = @_;

    die "There is no id defined for this additional field. I cannot update it" unless $self->{id};

    my $dbh = C4::Context->dbh;
    local $dbh->{RaiseError} = 1;

    return $dbh->do(q|
        UPDATE additional_fields
        SET name = ?,
            authorised_value_category = ?,
            marcfield = ?,
            searchable = ?
        WHERE id = ?
    |, {}, ( $self->{name}, $self->{authorised_value_category}, $self->{marcfield}, $self->{searchable}, $self->{id} ) );
}

sub delete {
    my ( $self ) = @_;
    return unless $self->{id};
    my $dbh = C4::Context->dbh;
    local $dbh->{RaiseError} = 1;
    return $dbh->do(q|
        DELETE FROM additional_fields WHERE id = ?
    |, {}, ( $self->{id} ) );
}

sub insert {
    my ( $self ) = @_;
    my $dbh = C4::Context->dbh;
    local $dbh->{RaiseError} = 1;
    $dbh->do(q|
        INSERT INTO additional_fields
        ( tablename, name, authorised_value_category, marcfield, searchable )
        VALUES ( ?, ?, ?, ?, ? )
    |, {}, ( $self->{tablename}, $self->{name}, $self->{authorised_value_category}, $self->{marcfield}, $self->{searchable} ) );
    $self->{id} = $dbh->{mysql_insertid};
}

sub insert_values {
    my ( $self )  = @_;

    my $dbh = C4::Context->dbh;
    local $dbh->{RaiseError} = 1;
    while ( my ( $record_id, $value ) = each %{$self->{values}} ) {
        next unless defined $value;
        my $updated = $dbh->do(q|
            UPDATE additional_field_values
            SET value = ?
            WHERE field_id = ?
            AND record_id = ?
        |, {}, ( $value, $self->{id}, $record_id ));
        if ( $updated eq '0E0' ) {
            $dbh->do(q|
                INSERT INTO additional_field_values( field_id, record_id, value )
                VALUES( ?, ?, ?)
            |, {}, ( $self->{id}, $record_id, $value ));
        }
    }
}

sub fetch_values {
    my ( $self, $args ) = @_;
    my $record_id = $args->{record_id};
    my $dbh = C4::Context->dbh;
    my $values = $dbh->selectall_arrayref(
        q|
            SELECT *
            FROM additional_fields af, additional_field_values afv
            WHERE af.id = afv.field_id
                AND af.tablename = ?
                AND af.name = ?
        | . ( $record_id ? q|AND afv.record_id = ?| : '' ),
        {Slice => {}}, ( $self->{tablename}, $self->{name}, ($record_id ? $record_id : () ) )
    );

    $self->{values} = {};
    for my $v ( @$values ) {
        $self->{values}{$v->{record_id}} = $v->{value};
    }
}

sub all {
    my ( $class, $args ) = @_;
    die "BAD CALL: Don't use fetch_all_values as an instance method"
        if ref $class and UNIVERSAL::can($class,'can');
    my $tablename = $args->{tablename};
    my $searchable = $args->{searchable};
    my $dbh = C4::Context->dbh;
    my $query = q|
        SELECT * FROM additional_fields WHERE 1
    |;
    $query .= q| AND tablename = ?|
        if $tablename;

    $query .= q| AND searchable = ?|
        if defined $searchable;

    my $results = $dbh->selectall_arrayref(
        $query, {Slice => {}}, (
            $tablename ? $tablename : (),
            defined $searchable ? $searchable : ()
        )
    );
    my @fields;
    for my $r ( @$results ) {
        push @fields, Koha::AdditionalField->new({
            id => $r->{id},
            tablename => $r->{tablename},
            name => $r->{name},
            authorised_value_category => $r->{authorised_value_category},
            marcfield => $r->{marcfield},
            searchable => $r->{searchable},
        });
    }
    return \@fields;

}

sub fetch_all_values {
    my ( $class, $args ) = @_;
    die "BAD CALL: Don't use fetch_all_values as an instance method"
        if ref $class and UNIVERSAL::can($class,'can');

    my $record_id = $args->{record_id};
    my $tablename = $args->{tablename};
    return unless $tablename;

    my $dbh = C4::Context->dbh;
    my $values = $dbh->selectall_arrayref(
        q|
            SELECT afv.record_id, af.name, afv.value
            FROM additional_fields af, additional_field_values afv
            WHERE af.id = afv.field_id
                AND af.tablename = ?
        | . ( $record_id ? q| AND afv.record_id = ?| : q|| ),
        {Slice => {}}, ( $tablename, ($record_id ? $record_id : ()) )
    );

    my $r;
    for my $v ( @$values ) {
        $r->{$v->{record_id}}{$v->{name}} = $v->{value};
    }
    return $r;
}

sub get_matching_record_ids {
    my ( $class, $args ) = @_;
    die "BAD CALL: Don't use fetch_all_values as an instance method"
        if ref $class and UNIVERSAL::can($class,'can');

    my $fields = $args->{fields} // [];
    my $tablename = $args->{tablename};
    my $exact_match = $args->{exact_match} // 1;
    return [] unless @$fields;

    my $dbh = C4::Context->dbh;
    my $query = q|SELECT * FROM |;
    my ( @subqueries, @args );
    my $i = 0;
    for my $field ( @$fields ) {
        $i++;
        my $subquery = qq|(
            SELECT record_id, field$i.name AS field${i}_name
            FROM additional_field_values afv
            LEFT JOIN
                (
                    SELECT afv.id, af.name, afv.value
                    FROM additional_field_values afv, additional_fields af
                    WHERE afv.field_id = af.id
                    AND af.name = ?
                    AND af.tablename = ?
                    AND value LIKE ?
                ) AS field$i USING (id)
            WHERE field$i.id IS NOT NULL
        ) AS values$i |;
        $subquery .= ' USING (record_id)' if $i > 1;
        push @subqueries, $subquery;
        push @args, $field->{name}, $tablename, ( $exact_match ? $field->{value} : "%$field->{value}%" );
    }
    $query .= join( ' LEFT JOIN ', @subqueries ) . ' WHERE 1';
    for my $j ( 1 .. $i ) {
            $query .= qq| AND field${j}_name IS NOT NULL|;
    }
    my $values = $dbh->selectall_arrayref( $query, {Slice => {}}, @args );
    return [
        map { $_->{record_id} } @$values
    ]
}

1;

__END__

=head1 NAME

Koha::AdditionalField

=head1 SYNOPSIS

    use Koha::AdditionalField;
    my $af1 = Koha::AdditionalField->new({id => $id});
    my $af2 = Koha::AuthorisedValue->new({
        tablename => 'my_table',
        name => 'a_name',
        authorised_value_category => 'LOST',
        marcfield => '200$a',
        searchable => 1,
    });
    $av1->delete;
    $av2->{name} = 'another_name';
    $av2->update;

=head1 DESCRIPTION

Class for managing additional fields into Koha.

=head1 METHODS

=head2 new

Create a new Koha::AdditionalField object. This method can be called using several ways.
Either with the id for existing field or with different values for a new one.

=over 4

=item B<id>

    The caller just knows the id of the additional field and want to retrieve all values.

=item B<tablename, name, authorised_value_category, marcfield and searchable>

    The caller wants to create a new additional field.

=back

=head2 fetch

The information will be retrieved from the database.

=head2 update

If the AdditionalField object has been modified and the values have to be modified into the database, call this method.

=head2 delete

Remove a the record in the database using the id the object.

=head2 insert

Insert a new AdditionalField object into the database.

=head2 insert_values

Insert new values for a record.

    my $af = Koha::AdditionalField({ id => $id })->fetch;
    my $af->{values} = {
        record_id1 => 'my value',
        record_id2 => 'another value',
    };
    $af->insert_values;

=head2 fetch_values

Retrieve values from the database for a given record_id.
The record_id argument is optional.

    my $af = Koha::AdditionalField({ id => $id })->fetch;
    my $values = $af->fetch_values({record_id => $record_id});

    $values will be equal to something like:
    {
        record_id => {
            field_name1 => 'value1',
            field_name2 => 'value2',
        }
    }

=head2 all

Retrieve all additional fields in the database given some parameters.
Parameters are optional.
This method returns a list of AdditionalField objects.
This is a static method.

    my $fields = Koha::AdditionalField->all;
    or
    my $fields = Koha::AdditionalField->all{(tablename => 'my_table'});
    or
    my $fields = Koha::AdditionalField->all({searchable => 1});

=head2 fetch_all_values

Retrieve all values for a table name.
This is a static method.

    my $values = Koha::AdditionalField({ tablename => 'my_table' });

    $values will be equel to something like:
    {
        record_id1 => {
            field_name1 => 'value1',
            field_name2 => 'value2',
        },
        record_id2 => {
            field_name1 => 'value3',
            field_name2 => 'value4',
        }

    }

=head2 get_matching_record_ids

Retrieve all record_ids for records matching the field values given in parameter.
This method returns a list of ids.
This is a static method.

    my $fields = [
        {
            name => 'field_name',
            value => 'field_value',
        }
    ];
    my $ids = Koha::AdditionalField->get_matching_record_ids(
        {
            tablename => 'subscription',
            fields => $fields
        }
    );

=head1 AUTHOR

Jonathan Druart <jonathan.druart at biblibre.com>

=head1 COPYRIGHT

Copyright 2013 BibLibre

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later
version.

Koha is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with Koha; if not, see <http://www.gnu.org/licenses>.
