package C4::Update::Database;

# Copyright Biblibre 2012
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use C4::Context;

use File::Basename;
use File::Find::Rule;
use Digest::MD5;
use List::MoreUtils qw/uniq/;
use YAML;

=head1 NAME

C4::Update::Database.pm

=head1 SYNOPSIS

  use C4::Update::Database;

  This package is used by admin/updatedatabase.pl, to manage DB updates

=head1 FUNCTIONS

=cut

my $VERSIONS_PATH = C4::Context->config('intranetdir') . '/installer/data/mysql/versions';

my $version;
my $list;

my $dbh = C4::Context->dbh;

=head2 get_filepath

  my $file = get_filepath($version);
  this sub will return the full path of a given DB update number

=cut

sub get_filepath {
    my ( $version ) = @_;
    my @files = File::Find::Rule->file->name( "$version.sql", "$version.pl" ) ->in( ( $VERSIONS_PATH ) );

    if ( scalar @files != 1 ) {
        die "This version ($version) returned has ".scalar @files." corresponding, need only 1";
    }

    return $files[0];
}

=head2 get_md5

  my $md5 = get_md5($filepath)
  returns the md5sum of the selected file.
  This is used to check consistency of updates

=cut

sub get_md5 {
    my ( $filepath ) = @_;
    open(FILE, $filepath);

    my $ctx = Digest::MD5->new;
    $ctx->addfile(*FILE);
    my $md5 = $ctx->hexdigest;
    close(FILE);
    return $md5;
}

=head2 execute_version

  $result = execute_version($version_number);
  Execute an update.
  This sub will detect if the number is made through a .pl or a .sql, and behave accordingly
  if there is more than 1 file with the same number, an error will be issued
  if you try to execute a version_number that has already be executed, then it will also issue an error
  the sub return an result hash, with the version number and the result

=cut

sub execute_version {
    my ( $version ) = @_;
    my $report;

    my $filepath;
    eval {
        $filepath = get_filepath $version;
    };
    if ( $@ ) {
        return { $version => $@ };
    }

    my @file_infos = fileparse( $filepath, qr/\.[^.]*/ );
    my $extension = $file_infos[2];
    my $filename = $version . $extension;

    my $md5 = get_md5 $filepath;
    my $r = md5_already_exists( $md5 );
    if ( scalar @$r ) {
        my $p = @$r[0];
        $report->{$version} = {
            error => "ALREADY_EXISTS",
            filepath => $filepath,
            old_version => @$r[0]->{version},
            md5 => @$r[0]->{md5},
        };
        return $report;
    }

    my $queries;
    given ( $extension ) {
        when ( /.sql/ ) {
            $queries = get_queries ( $filepath );
        }
        when ( /.pl/ ) {
            eval {
                $queries = get_queries ( $filepath );
            };
            if ($@) {
                $report->{$version} = {
                    error => "LOAD_FUNCTIONS_FAILED",
                    filename => $filename,
                    error_str => $@,
                };
            }
        }
        default {
            $report->{$version} = {
                error => "BAD_EXTENSION",
                extension => $extension,
            };
        }
    }

    return $report
        if ( defined $report->{$version} );

    my $errors = execute ( $queries );
    $report->{$version} = scalar( @$errors ) ? $errors : "OK";
    set_infos ( $version, $queries, $errors, $md5 );
    return $report;
}

=head2 list_versions_available

  my @versions = list_versions_available;
  return an array with all version available

=cut

sub list_versions_available {
    my @versions;

    my @files = File::Find::Rule->file->name( "*.sql", "*.pl" ) ->in( ( $VERSIONS_PATH ) );

    for my $f ( @files ) {
        my @file_infos = fileparse( $f, qr/\.[^.]*/ );
        push @versions, $file_infos[0];
    }
    @versions = uniq @versions;
    return \@versions;
}

=head2 list_versions_already_applied

  my @versions = list_versions_available;
  return an array with all version that have already been applied
  This sub check first that the updatedb tables exist and create them if needed

=cut

sub list_versions_already_applied {
    # 1st check if tables exist, otherwise create them
        $dbh->do(qq{
                CREATE TABLE IF NOT EXISTS `updatedb_error` ( `version` varchar(32) DEFAULT NULL, `error` text ) ENGINE=InnoDB CHARSET=utf8;
        });
            $dbh->do(qq{
            CREATE TABLE  IF NOT EXISTS `updatedb_query` ( `version` varchar(32) DEFAULT NULL, `query` text ) ENGINE=InnoDB CHARSET=utf8;
        });
        $dbh->do(qq{
            CREATE TABLE  IF NOT EXISTS `updatedb_report` ( `version` text, `md5` varchar(50) DEFAULT NULL, `comment` text, `status` int(1) DEFAULT NULL ) ENGINE=InnoDB CHARSET=utf8;
        });

    my $query = qq/ SELECT version, comment, status FROM updatedb_report ORDER BY version/;
    my $sth = $dbh->prepare( $query );
    $sth->execute;
    my $versions = $sth->fetchall_arrayref( {} );
    map {
        my $version = $_;
        my @comments = defined $_->{comment} ? split '\\\n', $_->{comment} : "";
        push @{ $version->{comments} }, { comment => $_ } for @comments;
        delete $version->{comment};
    } @$versions;
    $sth->finish;
    for my $version ( @$versions ) {
        $query = qq/ SELECT query FROM updatedb_query WHERE version = ? ORDER BY version/;
        $sth = $dbh->prepare( $query );
        $sth->execute( $version->{version} );
        $version->{queries} = $sth->fetchall_arrayref( {} );
        $sth->finish;
        $query = qq/ SELECT error FROM updatedb_error WHERE version = ? ORDER BY version/;
        $sth = $dbh->prepare( $query );
        $sth->execute( $version->{version} );
        $version->{errors} = $sth->fetchall_arrayref( {} );
        $sth->finish;
    }
    return $versions;
}

=head2 execute

  my @errors = $execute(\@queries);
  This sub will execute queries coming from an execute_version based on a .sql file

=cut

sub execute {
    my ( $queries ) = @_;
    my @errors;
    for my $query ( @{$queries->{queries}} ) {
        eval {
            $dbh->do( $query );
        };
        push @errors, get_error();
    }
    return \@errors;
}

=head2 get_tables_name

  my $tables = get_tables_name;
  return an array with all Koha mySQL table names

=cut

sub get_tables_name {
    my $sth = $dbh->prepare("SHOW TABLES");
    $sth->execute();
    my @tables;
    while ( my ( $table ) = $sth->fetchrow_array ) {
        push @tables, $table;
    }
    return \@tables;
}
my $tables;

=head2 check_coherency

  my $errors = check_coherency($query); UNUSED
  This sub will try to check if a SQL query is useless or no.
  for queries that are CREATE TABLE, it will check if the table already exists
  for queries that are ALTER TABLE, it will search if the modification has already been made
  for queries that are INSERT, it will search if the insert has already been made if it's a syspref or a permission

  Those test cover 90% of the updatedatabases cases. That will help finding duplicate or inconsistencies

=cut

#sub check_coherency {
#    my ( $query ) = @_;
#    $tables = get_tables_name() if not $tables;
#
#    given ( $query ) {
#        when ( /CREATE TABLE(?:.*?)? `?(\w+)`?/ ) {
#            my $table_name = $1;
#            if ( grep { /$table_name/ } @$tables ) {
#                die "COHERENCY: Table $table_name already exists";
#            }
#        }
#
#        when ( /ALTER TABLE *`?(\w+)`? *ADD *(?:COLUMN)? `?(\w+)`?/ ) {
#            my $table_name = $1;
#            my $column_name = $2;
#            next if $column_name =~ /(UNIQUE|CONSTRAINT|INDEX|KEY|FOREIGN)/;
#            if ( not grep { /$table_name/ } @$tables ) {
#                return "COHERENCY: Table $table_name does not exist";
#            } else {
#                my $sth = $dbh->prepare( "DESC $table_name $column_name" );
#                my $rv = $sth->execute;
#                if ( $rv > 0 ) {
#                    die "COHERENCY: Field $table_name.$column_name already exists";
#                }
#            }
#        }
#
#        when ( /INSERT INTO `?(\w+)`?.*?VALUES *\((.*?)\)/ ) {
#            my $table_name = $1;
#            my @values = split /,/, $2;
#            s/^ *'// foreach @values;
#            s/' *$// foreach @values;
#            given ( $table_name ) {
#                when ( /systempreferences/ ) {
#                    my $syspref = $values[0];
#                    my $sth = $dbh->prepare( "SELECT COUNT(*) FROM systempreferences WHERE variable = ?" );
#                    $sth->execute( $syspref );
#                    if ( ( my $count = $sth->fetchrow_array ) > 0 ) {
#                        die "COHERENCY: Syspref $syspref already exists";
#                    }
#                }
#
#                when ( /permissions/){
#                    my $module_bit = $values[0];
#                    my $code = $values[1];
#                    my $sth = $dbh->prepare( "SELECT COUNT(*) FROM permissions WHERE module_bit = ? AND code = ?" );
#                    $sth->execute($module_bit, $code);
#                    if ( ( my $count = $sth->fetchrow_array ) > 0 ) {
#                        die "COHERENCY: Permission $code already exists";
#                    }
#                }
#            }
#        }
#    }
#    return 1;
#}

=head2 get_error

  my $errors = get_error()
  This sub will return any mySQL error that occured during an update

=cut

sub get_error {
    my @errors = $dbh->selectrow_array(qq{SHOW ERRORS}); # Get errors
    my @warnings = $dbh->selectrow_array(qq{SHOW WARNINGS}); # Get warnings
    if ( @errors ) { # Catch specifics errors
        return qq{$errors[0] : $errors[1] => $errors[2]};
    } elsif ( @warnings ) {
        return qq{$warnings[0] : $warnings[1] => $warnings[2]}
            if $warnings[0] ne 'Note';
    }
    return;
}

=head2 get_queries

  my $result = get_queries($filepath);
  this sub will return a hashref with 2 entries:
    $result->{queries} is an array with all queries to execute
    $result->{comments} is an array with all comments in the .sql file

=cut

sub get_queries {
    my ( $filepath ) = @_;
    open my $fh, "<", $filepath;
    my @queries;
    my @comments;
    if ( $filepath =~ /\.pl$/ ) {
        if ( do $filepath ) {
            my $infos = _get_queries();
            @queries  = @{ $infos->{queries} }  if exists $infos->{queries};
            @comments = @{ $infos->{comments} } if exists $infos->{comments};
        }
        if ( $@ ) {
            die "I can't load $filepath. Please check the execute flag and if this file is a valid perl script ($@)";
        }
    } else {
        my $old_delimiter = $/;
        while ( <$fh> ) {
            my $line = $_;
            chomp $line;
            $line =~ s/^\s*//;
            if ( $line =~ /^--/ ) {
                my @l = split $old_delimiter, $line;
                if ( @l > 1 ) {
                    my $tmp_query;
                    for my $l ( @l ) {
                        if ( $l =~ /^--/ ) {
                            $l =~ s/^--\s*//;
                            push @comments, $l;
                            next;
                        }
                        $tmp_query .= $l . $old_delimiter;
                    }
                    push @queries, $tmp_query if $tmp_query;
                    next;
                }

                $line =~ s/^--\s*//;
                push @comments, $line;
                next;
            }
            if ( $line =~ /^delimiter (.*)$/i ) {
                $/ = $1;
                next;
            }
            $line =~ s#$/##;
            push @queries, $line if not $line =~ /^\s*$/; # Push if query is not empty
        }
        $/ = $old_delimiter;
        close $fh;
    }

    return { queries => \@queries, comments => \@comments };
}

=head2 md5_already_exists

  my $result = md5_already_exists($md5);
  check if the md5 of an update has already been applied on the database.
  If yes, it will return a hash with the version related to this md5

=cut

sub md5_already_exists {
    my ( $md5 ) = @_;
    my $query = qq/SELECT version, md5 FROM updatedb_report WHERE md5 = ?/;
    my $sth = $dbh->prepare( $query );
    $sth->execute( $md5 );
    my @r;
    while ( my ( $version, $md5 ) = $sth->fetchrow ) {
        push @r, { version => $version, md5 => $md5 };
    }
    $sth->finish;
    return \@r;
}

=head2 set_infos

  set_info($version,$queries, $error, $md5);
  this sub will insert into the updatedb tables what has been made on the database (queries, errors, result)

=cut

sub set_infos {
    my ( $version, $queries, $errors, $md5 ) = @_;
    SetVersion($version) if not -s $errors;
    for my $query ( @{ $queries->{queries} } ) {
        my $sth = $dbh->prepare("INSERT INTO updatedb_query(version, query) VALUES (?, ?)");
        $sth->execute( $version, $query );
        $sth->finish;
    }
    for my $error ( @$errors ) {
        my $sth = $dbh->prepare("INSERT INTO updatedb_error(version, error) VALUES (?, ?)");
        $sth->execute( $version, $error );
    }
    my $sth = $dbh->prepare("INSERT INTO updatedb_report(version, md5, comment, status) VALUES (?, ?, ?, ?)");
    $sth->execute(
        $version,
        $md5,
        join ('\n', @{ $queries->{comments} }),
        ( @$errors > 0 ) ? 0 : 1
    );
}

=head2 mark_as_ok

  mark_as_ok($version);
  this sub will force to mark as "OK" an update that has failed
  once this has been made, the status will look as "forced OK", and appear in green like versions that have been applied without any problem

=cut

sub mark_as_ok {
    my ( $version ) = @_;
    my $sth = $dbh->prepare( "UPDATE updatedb_report SET status = 2 WHERE version=?" );
    my $affected = $sth->execute( $version );
    if ( $affected < 1 ) {
        my $filepath = get_filepath $version;
        my $queries  = get_queries $filepath;
        my $md5      = get_md5 $filepath;
        set_infos $version, $queries, undef, $md5;

        $sth->execute( $version );
    }
    $sth->finish;
}

=head2 is_uptodate
  is_uptodate();
  return 1 if the database is up to date else 0.
  The database is up to date if all versions are excecuted.

=cut

sub is_uptodate {
    my $versions_available = C4::Update::Database::list_versions_available;
    my $versions = C4::Update::Database::list_versions_already_applied;
    for my $v ( @$versions_available ) {
        if ( not grep { $v eq $$_{version} } @$versions ) {
            return 0;
        }
    }
    return 1;
}

=head2 TransformToNum

  Transform the Koha version from a 4 parts string
  to a number, with just 1 . (ie: it's a number)

=cut

sub TransformToNum {
    my $version = shift;

    # remove the 3 last . to have a Perl number
    $version =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    $version =~ s/Bug(\d+)/$1/;
    return $version;
}

sub SetVersion {
    my $new_version = TransformToNum(shift);
    return unless $new_version =~ /\d\.\d+/;
    my $current_version = TransformToNum( C4::Context->preference('Version') );
    unless ( C4::Context->preference('Version') ) {
        my $finish = $dbh->prepare(qq{
            INSERT IGNORE INTO systempreferences (variable,value,explanation)
            VALUES ('Version',?,'The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller')
        });
        $finish->execute($new_version);
        return;
    }
    if ( $new_version > $current_version ) {
        my $finish = $dbh->prepare("UPDATE systempreferences SET value=? WHERE variable='Version'");
        $finish->execute($new_version);
    }
}

=head2 TableExists($table)

=cut

sub TableExists {
    my $table = shift;
    eval {
        local $dbh->{PrintError} = 0;
        local $dbh->{RaiseError} = 0;
        $dbh->do(qq{SELECT * FROM $table WHERE 1 = 0 });
    };
    return 1 unless $@;
    return 0;
}
1;
