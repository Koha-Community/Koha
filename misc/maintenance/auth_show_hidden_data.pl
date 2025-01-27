#!/usr/bin/perl

# Copyright 2017 Rijksmuseum
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

# This script walks through your authority marc records and tells you
# which hidden fields in the framework still contain data.

use Modern::Perl;
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use Koha::Script;
use Koha::Authorities;
use Koha::Authority::Subfields;
use Koha::MetadataRecord::Authority;

my ( $max, $help, $confirm );
GetOptions( 'confirm' => \$confirm, 'help' => \$help, 'max' => \$max );
if ( !$confirm || $help ) {
    pod2usage( -verbose => 2 );
    exit;
}

our $hidden_fields = Koha::Authority::Subfields->search(
    { hidden => { '!=' => 0 } },
);
our $results = {};

my $auths = Koha::Authorities->search( {}, { order_by => 'authid' } );
my $count = 0;
while ( my $record = $auths->next ) {
    last if $max && $count >= $max;
    scan_record($record);
    $count++;
}
report_results();

sub scan_record {
    my ($record) = @_;
    my $id       = $record->authid;
    my $type     = $record->authtypecode;
    my $marc     = Koha::MetadataRecord::Authority->get_from_authid($id)->record;
    foreach my $fld ( $marc->fields ) {    # does not include leader
        my @subfields =
            $fld->is_control_field
            ? '@'
            : map { $_->[0] } $fld->subfields;
        foreach my $sub (@subfields) {
            next if $results->{$type} && $results->{$type}->{ $fld->tag } && $results->{$type}->{ $fld->tag }->{$sub};
            if ( $hidden_fields->find( $type, $fld->tag, $sub ) ) {
                $results->{$type}->{ $fld->tag }->{$sub} = 1;
            }
        }
    }

    # To be overcomplete, check the leader too :)
    if ( $marc->leader ) {
        if ( $hidden_fields->find( $type, '000', '@' ) ) {
            $results->{$type}->{'000'}->{'@'} = 1;
        }
    }
}

sub report_results {
    my $cnt = 0;
    foreach my $fw ( sort keys %$results ) {
        foreach my $tag ( sort keys %{ $results->{$fw} } ) {
            foreach my $sub ( sort keys %{ $results->{$fw}->{$tag} } ) {
                print "\nFramework " . ( $fw || 'Default' ) . ", $tag, $sub contains data but is hidden";
                $cnt++;
            }
        }
    }
    if ($cnt) {
        print
            "\n\nNOTE: You should consider removing the hidden attribute of these framework fields in order to not lose data in those fields when editing authority records.\n";
    } else {
        print "\nNo hidden (sub)fields containing data were found!\n";
    }
}

=head1 NAME

auth_show_hidden_data.pl

=head1 SYNOPSIS

auth_show_hidden_data.pl -c -max 1000

=head1 DESCRIPTION

This script tells you if you have authority data in hidden (sub)fields. That
data will be lost when editing such authority records.

=over 8

=item B<-confirm>

Confirm flag. Required to start checking authority records.

=item B<-help>

Usage statement

=item B<-max>

This optional parameter tells the script to stop after the specified number of
records.

=back

=cut
