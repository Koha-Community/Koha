package Koha::Database::Commenter;

# Copyright 2022 Rijksmuseum, Koha development team
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

use Modern::Perl;
use Data::Dumper qw(Dumper);
use File::Slurp qw(read_file);

use Koha::Exceptions;

use constant KOHA_STRUCTURE => 'installer/data/mysql/kohastructure.sql';
use constant DBI_HANDLE_CLASS => 'DBI::db';

=head1 NAME

Koha::Database::Commenter - Manage column comments in database

=head1 SYNOPSIS

    use Koha::Database::Commenter;
    $mgr = Koha::Database::Commenter->new({ dbh => $dbh });

    $mgr->reset_to_schema;
    # OR:
    $mgr->clear;

=head1 DESCRIPTION

    This object helps you to keep column comments in your database in sync
    with the Koha schema. It also allows you to clear all comments.

    The advantage of keeping in sync is that you can easily track differences
    between schema and database with the maintenance script
    update_dbix_class_files.pl.

    Tip: make a backup of your database before running this script.

=head1 METHODS

=head2 new

    $mgr = Koha::Database::Commenter->new({
        dbh => $dbh, database => $d, fh => $fh, schema_file => $s
    });

    Object constructor.
    Param dbh is mandatory. Params database, fh and schema_file are
    optional.
    Param database can be used to move away from current database of
    db handle.
    Param fh can be used to redirect output.
    Param schema_file is needed for resetting to schema. Falls back to
    the constant for Koha structure file.

=cut

sub new {
    my ( $class, $params ) = @_; # params: database, dbh, fh, schema_file
    my $self = bless $params // {}, $class;

    Koha::Exceptions::MissingParameter->throw( parameter => 'dbh' ) unless $self->{dbh};
    Koha::Exceptions::WrongParameter->throw( name => 'dbh', type => ref($self->{dbh}) )
        unless ref($self->{dbh}) eq DBI_HANDLE_CLASS;

    $self->{database} //= ( $self->{dbh}->selectrow_array('SELECT DATABASE()') )[0];
    $self->{fh} //= *STDOUT;
    $self->{schema_file} //= KOHA_STRUCTURE;
    $self->{schema_info} = {};

    return $self;
}

=head2 clear

    $object->clear({ dry_run => 0, table => $table, verbose => 0 });

    Clears all current column comments in storage.
    If table is passed, only that table is changed.
    Dry run only prints sql statements.

=cut

sub clear {
    my ( $self, $params ) = @_; # dry_run, table, verbose
    my $cols = $self->_fetch_stored_comments($params);
    foreach my $col ( @$cols ) {
        next if !$col->{column_comment};
        next if $params->{table} && $col->{table_name} ne $params->{table};
        $self->_change_column( $col->{table_name}, $col->{column_name}, undef, $params ); # undef clears
    }
}

=head2 reset_to_schema

    $object->reset_to_schema({ dry_run => 0, table => $table, verbose => 0 });

    Resets column comments in storage to schema definition.
    Other column comments are cleared.
    When you pass table, only that table is changed.
    Dry run only prints sql statements.

=cut

sub reset_to_schema {
    my ( $self, $params ) = @_; # dry_run, table, verbose
    $self->clear($params);
    my $schema_comments = $self->_fetch_schema_comments;
    foreach my $table ( sort keys %$schema_comments ) {
        next if $params->{table} && $table ne $params->{table};
        foreach my $col ( sort keys %{$schema_comments->{$table}} ) {
            $self->_change_column( $table, $col, $schema_comments->{$table}->{$col}, $params );
        }
    }
}

=head2 renumber

    $object->renumber({ dry_run => 0, table => $table, verbose => 0 });

    This is primarily meant for testing purposes (verifying results across
    whole database).
    It adds comments like Comment_1, Comment_2 etc.
    When you pass table, only that table is changed. Otherwise all tables
    are affected; note that the column counter does not reset by table.
    Dry run only prints sql statements.

=cut

sub renumber {
    my ( $self, $params ) = @_; # dry_run, table, verbose
    my $cols = $self->_fetch_stored_comments($params);
    my $i = 0;
    foreach my $col ( @$cols ) {
        next if $params->{table} && $col->{table_name} ne $params->{table};
        $i++;
        $self->_change_column( $col->{table_name}, $col->{column_name}, "Column_$i", $params );
    }
}

=head1 INTERNAL ROUTINES

=cut

=head2 _fetch_schema_comments

=cut

sub _fetch_schema_comments {
# Wish we had a DBIC function for this, showing comments too ;) Now using kohastructure as source of truth.
    my ( $self ) = @_;
    my $file = $self->{schema_file};
    Koha::Exceptions::FileNotFound->throw( filename => $file ) unless -e $file;

    return $self->{schema_info} if keys %{$self->{schema_info}};

    my @schema_lines = read_file( $file );
    my $info = {};
    my $current_table = q{};
    foreach my $line ( @schema_lines ) {
        if( $line =~ /^CREATE TABLE `?(\w+)`?/ ) {
            $current_table = $1;
        } elsif( $line =~ /^\s+`?(\w+)`?.*COMMENT ['"](.+)['"][,)]?$/ ) {
            my ( $col, $comment ) = ( $1, $2 );
            $comment =~ s/''/'/g; # we call quote later on
            $info->{$current_table}->{$col} = $comment;
        }
    }
    return $self->{schema_info} = $info;
}

=head2 _fetch_stored_comments

=cut

sub _fetch_stored_comments {
    my ( $self, $params ) = @_; # params: table
    my $sql = q|
SELECT table_name, column_name, column_comment FROM information_schema.columns
WHERE table_schema=? AND table_name=?
ORDER BY table_name, column_name|;
    $sql =~ s/AND table_name=\?// unless $params->{table};
    return $self->{dbh}->selectall_arrayref( $sql, { Slice => {} }, $self->{database}, $params->{table} || () );
}

=head2 _change_column

=cut

sub _change_column {
# NOTE: We do not want to use DBIx schema here, but we use stored structure,
# since we only want to change comment not actual table structure.
    my ( $self, $table_name, $column_name, $comment, $params ) = @_; # params: dry_run, verbose
    $params //= {};

    my $dbh = $self->{dbh};
    my $info = $self->_columns_info( $table_name )->{$column_name};

    # datatype; nullable, collation
    my $rv = qq|ALTER TABLE $self->{database}.$table_name MODIFY COLUMN `$column_name` $info->{Type} |;
    $rv .= 'NOT NULL ' if $info->{Null} eq 'NO';
    $rv .= "COLLATE $info->{Collation} " if $info->{Collation};

    # Default - needs a bit of tweaking
    if( !defined $info->{Default} && $info->{Null} eq 'NO' ) {
        # Do not provide a default
    } elsif( $info->{Type} =~ /char|text|enum/i ) {
        if( !defined $info->{Default} ) {
            $rv .= "DEFAULT NULL ";
        } else {      #includes: $info->{Default} eq '' || $info->{Default} eq '0'
            $rv .= "DEFAULT ". $dbh->quote($info->{Default}). " ";
        }
    } elsif( !$info->{Default} && $info->{Type} =~ /timestamp/ ) { # Peculiar correction for nullable timestamps
        $rv .= 'NULL DEFAULT NULL ' if $info->{Null} eq 'YES';
    } else {
        $rv .= "DEFAULT ". ( $info->{Default} // 'NULL' ). " ";
    }

    # Extra (like autoincrement)
    $rv .= $info->{Extra}. ' ' if $info->{Extra};

    # Comment if passed; not passing means clearing actually.
    if( $comment ) {
        $comment = $dbh->quote($comment) unless $comment =~ /\\'/; # Prevent quoting twice
        $rv .= "COMMENT ". $comment;
    }
    $rv =~ s/\s+$//; # remove trailing spaces

    # Print
    if( $params->{dry_run} ) {
        print { $self->{fh} } "$rv;\n";
        return;
    }
    # Deploy
    eval { $dbh->do($rv) };
    if( $@ ) {
        warn "Failure for $table_name:$column_name";
        print { $self->{fh} } "-- FAILED: $rv;\n";
    } elsif( $params->{verbose} ) {
        print { $self->{fh} } "$rv;\n";
    }
}

sub _columns_info {
    my ( $self, $table ) = @_;
    return $self->{dbh}->selectall_hashref( 'SHOW FULL COLUMNS FROM '. $self->{database}. '.'. $table, 'Field' );
}

1;
__END__

=head1 ADDITIONAL COMMENTS

    The module contains the core code for the options of the maintenance
    script sync_db_comments.pl.

    It can be tested additionally with Commenter.t, but note that since
    SQL DDL statements - as generated by this module - implicitly commit,
    we are not modifying actual Koha tables in that test.

=head1 AUTHOR

    Marcel de Rooy, Rijksmuseum Amsterdam, The Netherlands

=cut
