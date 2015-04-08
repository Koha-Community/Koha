#!/usr/bin/perl

# Copyright 2013 Rijksmuseum
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

# This script imports/exports systempreferences to file.
# Two interesting features are:
# 1) It may help you to compare systempreferences between Koha instances.
# 2) You can also quickly restore subsets of preferences while testing.
#    Just leave only e.g. some circulations prefs in a file and compare with
#    the update flag.

use Modern::Perl;
use open OUT => ':encoding(UTF-8)', ':std';

use Getopt::Long;
use Pod::Usage;

use C4::Context;
my $dbh = C4::Context->dbh;

my ( $help, $cmd, $filename, $override, $compare_add, $compare_del, $compare_upd, $ignore_opt, $partial );
GetOptions(
    'help'    => \$help,
    'cmd:s'   => \$cmd,
    'file:s'  => \$filename,
    'add'     => \$compare_add,
    'del'     => \$compare_del,
    'upd'     => \$compare_upd,
    'ign-opt' => \$ignore_opt,
    'partial' => \$partial,
);

if ( $filename && !-e $filename && $cmd !~ /^b/ ) {
    die "File $filename not found";
}
if ( !$cmd || !$filename || $help ) {
    pod2usage( -verbose => 2 );
    exit;
}

#------------------------------------------------------------------------------

#backup prefs
if ( $cmd =~ /^b/i && $filename ) {
    my $dbprefs = ReadPrefsFromDb();
    open my $fh, '>:encoding(UTF-8)', $filename;
    SavePrefsToFile( $dbprefs, $fh );
    close $fh;
}

#test pref file: read and save for gaining confidence :) run a diff
if ( $cmd =~ /^t/i && $filename ) {
    my $fileprefs = ReadPrefsFromFile($filename);
    open my $fh, '>:encoding(UTF-8)', $filename . ".sav";
    SavePrefsToFile( $fileprefs, $fh );
    close $fh;
}

#compare prefs (with db)
if ( $cmd =~ /^c/i && $filename ) {
    my $dbprefs   = ReadPrefsFromDb();
    my $fileprefs = ReadPrefsFromFile($filename);

    #compare now
    my $cmp = ComparePrefs( $dbprefs, $fileprefs );
    PrintCompare( $cmp, "database", "file $filename" );
    HandleCompareChanges( $cmp, $dbprefs, $fileprefs )
      if $compare_add || $compare_del || $compare_upd;
}

#restore prefs
if ( $cmd =~ /^r/i && $filename ) {
    my $fileprefs = ReadPrefsFromFile($filename);
    CheckVersionPref($fileprefs);

    #override this check by removing Version from your file
    #if you know what you are doing of course
    SavePrefsToDb($fileprefs);
}

#------------------------------------------------------------------------------

sub PrintCompare {
    my ( $ch, $s1, $s2 ) = @_;
    foreach ( sort keys %$ch ) {
        my $v = $ch->{$_};
        next if $v eq '1' && $partial;
        print "$_: ";
        if    ( $v eq '1' ) { print "Not in $s2"; }
        elsif ( $v eq '2' ) { print "Not in $s1"; }
        else                { print "Different values: $v"; }
        print "\n";
    }
}

sub HandleCompareChanges {
    my ( $cmp_pref, $dbpref, $filepref ) = @_;
    my $t = 0;
    foreach my $k ( sort keys %$cmp_pref ) {
        my $cmp = $cmp_pref->{$k};
        if ( $cmp eq '1' ) {
            $t += DeleteOnePref($k) if $compare_del;
        } elsif ( $cmp eq '2' ) {
            my $kwc  = $filepref->{$k}->{orgkey};
            my $val  = $filepref->{$k}->{value};
            my $type = $filepref->{$k}->{type};
            $t += InsertIgnoreOnePref( $kwc, $val, $type ) if $compare_add;
        } elsif ($cmp) {    #should contain something..
            my $val = $filepref->{$k}->{value};
            $t += UpdateOnePref( $k, $val ) if $compare_upd;
        }
    }
    print "Adjusted $t prefs from this compare.\n";
}

sub ComparePrefs {
    my ( $ph1, $ph2 ) = @_;
    my $res = {};
    foreach my $k ( keys %$ph1 ) {
        if ( !exists $ph2->{$k} ) {
            $res->{$k} = 1;
        } else {
            my $v1 = $ph1->{$k}->{value} // 'NULL';
            my $v2 = $ph2->{$k}->{value} // 'NULL';
            if ( $v1 ne $v2 ) {
                $res->{$k} = "$v1 / $v2";
            }
        }
    }
    foreach my $k ( keys %$ph2 ) {
        if ( !exists $ph1->{$k} ) {
            $res->{$k} = 2;
        }
    }
    return $res;
}

sub ReadPrefsFromDb {
    my $sql = 'SELECT variable AS orgkey, LOWER(variable) AS variable, value, type FROM systempreferences ORDER BY variable';
    my $hash = $dbh->selectall_hashref( $sql, 'variable' );
    return $hash;
}

sub ReadPrefsFromFile {
    my ($file) = @_;
    open my $fh, '<:encoding(UTF-8)', $filename;
    my @lines = <$fh>;
    close $fh;
    my $hash;
    for ( my $t = 0 ; $t < @lines ; $t++ ) {
        next if $lines[$t] =~ /^\s*#|^\s*$/;    # comment line or empty line
        my @l = split ",", $lines[$t], 4;
        die "Invalid pref file; check line " . ++$t if @l < 4 || $l[0] !~ /^\d+$/ || $t + $l[0] >= @lines;
        my $key = lc $l[1];
        $hash->{$key} = { orgkey => $l[1], value => $l[3], type => $l[2] };
        for ( my $j = 0 ; $j < $l[0] ; $j++ ) { $hash->{$key}->{value} .= $lines[ $t + $j + 1 ]; }
        $t = $t + $l[0];
        $hash->{$key}->{value} =~ s/\n$//;      #only 'last' line
    }
    return $hash;
}

sub SavePrefsToFile {
    my ( $hash, $fh ) = @_;
    print $fh '#cmp_sysprefs.pl: ' . C4::Context->config('database') . ', ' . localtime . "\n";
    foreach my $k ( sort keys %$hash ) {

        #sort handles underscore differently than mysql?
        my $c   = CountLines( $hash->{$k}->{value} );
        my $kwc = $hash->{$k}->{orgkey};                # key-with-case
        print $fh "$c,$kwc," . ( $hash->{$k}->{type} // 'Free' ) . ',' . ( $hash->{$k}->{value} // 'NULL' ) . "\n";
    }
}

sub SavePrefsToDb {
    my ($hash) = @_;
    my $t = 0;

    #will not erase everything! you can do that in mysql :)
    foreach my $k ( keys %$hash ) {
        my $v = $hash->{$k}->{value} eq 'NULL' ? undef : $hash->{$k}->{value};
        my $kwc  = $hash->{$k}->{orgkey} // $k;
        my $type = $hash->{$k}->{type}   // 'Free';

        #insert and update seem overkill, but better than delete and insert
        #you cannot assume that the pref IS or IS NOT there
        InsertIgnoreOnePref( $kwc, $v, $type );
        UpdateOnePref( $k, $v );
        $t++;
    }
    print "Updated $t prefs\n";
}

sub InsertIgnoreOnePref {
    my ( $kwc, $v, $t ) = @_;
    my $i = $dbh->do(
        'INSERT IGNORE INTO systempreferences (variable, value, type)
        VALUES (?,?,?)', undef, ( $kwc, $v, $t )
    );
    return !defined($i) || $i eq '0E0'? 0: $i;
}

sub UpdateOnePref {
    my ( $k, $v ) = @_;
    return if lc $k eq 'version';
    my $i = $dbh->do( 'UPDATE systempreferences SET value=? WHERE variable=?', undef, ( $v, $k ) );
    return !defined($i) || $i eq '0E0'? 0: $i;
}

sub DeleteOnePref {
    my ($k) = @_;
    return if lc $k eq 'version';
    my $sql = 'DELETE FROM systempreferences WHERE variable=?';
    unless ($ignore_opt) {
        $sql .= " AND COALESCE(explanation,'')='' AND COALESCE(options,'')=''";
    }
    my $i = $dbh->do( $sql, undef, ($k) );
    return !defined($i) || $i eq '0E0'? 0: $i;
}

sub CheckVersionPref {    #additional precaution
                          #if there are versions, compare them
    my ($hash) = @_;
    my $hv = exists $hash->{version}? $hash->{version}->{value}: undef;
    return if !defined $hv;
    my ($dv) = $dbh->selectrow_array(
        'SELECT value FROM systempreferences
        WHERE variable LIKE ?', undef, ('version')
    );
    return if !defined $dv;
    die "Versions do not match ($dv, $hv)" if $dv ne $hv;
}

sub CountLines {
    my @ma;
    return ( $_[0] && ( @ma = $_[0] =~ /\r?\n|\r\n?/g ) ) ? scalar @ma : 0;
}

=head1 NAME

cmp_sysprefs.pl

=head1 SYNOPSIS

cmp_sysprefs.pl -help

cmp_sysprefs.pl -cmd backup -file prefbackup

cmp_sysprefs.pl -cmd compare -file prefbackup -upd

cmp_sysprefs.pl -cmd compare -file prefbackup -del -ign-opt

cmp_sysprefs.pl -cmd restore -file prefbackup

=head1 DESCRIPTION

This script may backup, compare and restore system preferences from file.

Precaution: only the last command or file name will be used. The add, del and
upd parameters are extensions for the compare command. They allow you to act
immediately on the compare results.

When restoring a preferences file containing a version pref to a database having
another version, the restore will not be made. Similarly, a version pref will
never be overwritten. A restore will overwrite prefs but not delete them.

It is possible to edit the preference backup files. But be careful. The first
parameter for each preference is a line count. Some preference values use more
than one line. If you edit a file, make sure that the line counts are still
valid.

You can compare/restore using edited/partial preference files. Take special
care when using the del parameter in comparing such a partial file. It will
delete all prefs in the database not found in your partial file. Partial pref
files can however be very useful when testing or monitoring a limited set of
prefs.

The ign-opt flag allows you to delete preferences that have explanation or
options in the database. If you do not set this flag, a compare with delete
will by default only delete preferences without explanation/options. Use this
option only if you understand the risk. Note that a restore will recover value,
not explanation or options. (See also BZ 10199.)

=over 8

=item B<-help>

Print this usage statement.

=item B<-cmd>

Command: backup, compare, restore or test.

=item B<-file>

Name of the file used in command.

=item B<-partial>

Only for partial compares: skip 'not present in file'-messages.

=item B<-add>

Only for compares: restore preferences not present in database.

=item B<-del>

Only for compares: delete preferences not present in file.

=item B<-upd>

Only for compares: update preferences when values differ.

=item B<-ign-opt>

Ignore options/explanation when comparing with delete flag. Use this flag with care.

=back

=cut
