#!/usr/bin/perl
#
#  Copyright 2020 Koha Development Team
#
#  This file is part of Koha.
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

use YAML::Syck qw( LoadFile );
use C4::Context;
use Getopt::Long qw(:config no_ignore_case);
use Data::Printer;

sub print_usage {
     ( my $basename = $0 ) =~ s|.*/||;
     print <<USAGE;

$basename
 Load file in YAML format into database

Usage:
$0 [--file=FILE]
$0 -h

 -f, --file=FILE         File to load.
 -h, --help              Show this help

USAGE
}

# Getting parameters
my $file;
my $help;

GetOptions(
 'file|f=s'     => \$file,
 'help|h'       => \$help
) or print_usage, exit 1;

if ($help or not $file) {
 print_usage;
 exit;
}

my $dbh  = C4::Context->dbh;
my $yaml;
eval {
    $yaml = LoadFile( $file );                                    # Load YAML
};
if ($@){
    die "Something went wrong loading file $file ($@)";
}

for my $table ( @{ $yaml->{'tables'} } ) {
    my $table_name   = ( keys %$table )[0];                          # table name
    my @rows         = @{ $table->{$table_name}->{rows} };           #
    my @columns      = ( sort keys %{$rows[0]} );                    # column names
    my $fields       = join ",", map{sprintf("`%s`", $_)} @columns;  # idem, joined
    my $placeholders = join ",", map { "?" } @columns;               # '?,..,?' string
    my $query        = "INSERT INTO $table_name ( $fields ) VALUES ( $placeholders )";
    my $sth          = $dbh->prepare($query);
    my @multiline    = @{ $table->{$table_name}->{'multiline'} };    # to check multiline values;
    foreach my $row ( @rows ) {
        my @values = map {
                        my $col = $_;
                        ( @multiline and grep { $_ eq $col } @multiline )
                        ? join "\r\n", @{$row->{$col}}                # join multiline values
                        : $row->{$col};
                     } @columns;
        $sth->execute( @values );
    }
}
for my $statement ( @{ $yaml->{'sql_statements'} } ) {               # extra SQL statements
    $dbh->do($statement);
}
