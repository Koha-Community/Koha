#!/usr/bin/perl

# Copyright Rijksmuseum 2017
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

use Modern::Perl;

use Getopt::Long;
use List::MoreUtils qw/uniq/;
use Pod::Usage;

use C4::AuthoritiesMarc qw/AddAuthority DelAuthority GetAuthority merge/;

my ( @authid, $commit, $delete, $help, $merge, $reference, $renumber, $verbose );
GetOptions(
    'authid:s'    => \@authid,
    'commit'      => \$commit,
    'delete'      => \$delete,
    'help'        => \$help,
    'merge'       => \$merge,
    'reference:i' => \$reference,
    'renumber'    => \$renumber,
    'verbose'     => \$verbose,
);

@authid = map { split /[,]/, $_; } @authid;
print "No changes will be made\n" unless $commit;
if( $help ) {
    pod2usage(1);
} elsif( $delete ) {
    delete_auth( \@authid );
} elsif( $merge ) {
    merge_auth( \@authid, $reference );
} elsif( $renumber ) {
    renumber( \@authid );
} else {
    pod2usage(1);
}

sub delete_auth {
    my ( $auths ) = @_;
    foreach my $authid ( uniq(@$auths) ) {
        if( $commit ) {
            DelAuthority({ authid => $authid }); # triggers a merge (read: cleanup)
            print "Removing $authid\n" if $verbose;
        } else {
            print "Would have removed $authid\n" if $verbose;
        }
    }
}

sub merge_auth {
    my ( $auths, $reference ) = @_;
    if( !$reference ) {
        print "Reference parameter is missing\n";
        return;
    }
    my $marc_ref = GetAuthority( $reference ) || die "Reference record $reference not found\n";
    # First update all linked biblios of reference
    merge({ mergefrom => $reference, MARCfrom => $marc_ref, mergeto => $reference, MARCto => $marc_ref, override_limit => 1 }) if $commit;

    # Merge all authid's into reference
    my $marc;
    foreach my $authid ( uniq(@$auths) ) {
        next if $authid == $reference;
        $marc = GetAuthority($authid);
        if( !$marc ) {
            print "Authority id $authid ignored, does not exist.\n";
            next;
        }
        if( $commit ) {
            merge({
                mergefrom      => $authid,
                MARCfrom       => $marc,
                mergeto        => $reference,
                MARCto         => $marc_ref,
                override_limit => 1
            });
            DelAuthority({ authid => $authid, skip_merge => 1 });
            print "Record $authid merged into reference $reference.\n" if $verbose;
        } else {
            print "Would have merged record $authid into reference $reference.\n" if $verbose;
        }
    }
}

sub renumber {
    my ( $auths ) = @_;
    foreach my $authid ( uniq(@$auths) ) {
        if( my $obj = Koha::Authorities->find($authid) ) {
            my $marc = GetAuthority( $authid );
            if( $commit ) {
                AddAuthority( $marc, $authid, $obj->authtypecode );
                    # AddAuthority contains an update of 001, 005 etc.
                print "Renumbered $authid\n" if $verbose;
            } else {
                print "Would have renumbered $authid\n" if $verbose;
            }
        } else {
            print "Record $authid not found!\n"  if $verbose;
        }
    }
}

=head1 NAME

update_authorities.pl

=head1 DESCRIPTION

Script to perform various authority related maintenance tasks.
This version supports deleting an authority record and updating all linked
biblio records.
Furthermore it supports merging authority records with one reference record,
and updating all linked biblio records.
It also allows you to force a renumber, i.e. save the authid into field 001.

=head1 SYNOPSIS

update_authorities.pl -c -authid 1,2,3 -delete

update_authorities.pl -c -authid 1 -authid 2 -authid 3 -delete

update_authorities.pl -c -authid 1,2 -merge -reference 3

update_authorities.pl -c -merge -reference 4

update_authorities.pl -c -authid 1,2,3 -renumber

=head1 OPTIONS

authid: List authority numbers separated by commas or repeat the
parameter.

commit: Needed to commit changes.

delete: Delete the listed authority numbers and remove its references from
linked biblio records.

merge: Merge the passed authid's into reference and update all linked biblio
records. If you do not pass authid's, the linked biblio records of reference
will be updated only.

renumber: Save authid into field 001.

=head1 AUTHOR

Marcel de Rooy, Rijksmuseum Amsterdam, The Netherlands

=cut
