package C4::Search;

# Copyright 2000-2006 Katipo Communications
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use ZOOM;
use Smart::Comments;
use C4::Context;
use MARC::Record;
use MARC::File::XML;
use C4::Biblio;

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g;
    shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v );
};

=head1 NAME

C4::Search - Functions for searching the Koha catalog and other databases

=head1 SYNOPSIS

  use C4::Search;

=head1 DESCRIPTION

This module provides the searching facilities for the Koha catalog and
other databases.

=head1 FUNCTIONS

=over 2

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(search get_record get_xml_record);

# make all your functions, whether exported or not;

sub search {
    my ( $search, $type, $number ) = @_;
    my $dbh = C4::Context->dbh();
    my $q;
    my $Zconn = C4::Context->Zconn;
    my $raw;

    if ( $type eq 'CQL' ) {
        my $string;
        if ( $search->{'cql'} ) {
            $string = $search->{'cql'};
        }
        else {
            foreach my $var ( keys %$search ) {
                $string .= "$var=\"$search->{$var}\" ";
            }
        }
        $q = new ZOOM::Query::CQL2RPN( $string, $Zconn );
    }
    my $rs;
    my $n;
    eval {
        $rs = $Zconn->search($q);
        $n  = $rs->size();
    };
    if ($@) {
        print "Error ", $@->code(), ": ", $@->message(), "\n";
    }
    my $i = 0;
    my @results;
    while ( $i < $n && $i < $number ) {
        $raw = $rs->record($i)->raw();
        my $record = MARC::Record->new_from_xml($raw, 'UTF-8');
        my $line = MARCmarc2koha( $dbh, $record );
        push @results, $line;
#	 push @results,$raw;
	$i++;
    }
    return ( \@results );

}

sub get_record {

    # pass in an id (biblionumber at this stage) and get back a MARC record
    my ($id) = @_;
    my $q;
    my $Zconn = C4::Context->Zconn;
    my $raw;
    my $string = "identifier=$id";
#    my $string = "title=delete";
#    warn $string;

        $q = new ZOOM::Query::CQL2RPN( $string, $Zconn);
    eval {
#        my $rs = $Zconn->search_pqf("\@attr 1=12 $id");
	my $rs = $Zconn->search($q);
        my $n  = $rs->size();
        if ( $n > 0 ) {
            $raw = $rs->record(0)->raw();
        }
    };
    if ($@) {

        warn "Error ", $@->code(), ": ", $@->message(), "\n";
    }
    ###$raw
    my $record = MARC::Record->new_from_xml($raw, 'UTF-8');
    ###$record
    return ($record);
}


sub get_xml_record {
    # pass in an id (biblionumber at this stage) and get back a MARC record
    my ($id) = @_;
    my $q;
    my $Zconn = C4::Context->Zconn;
    my $raw;
    my $string = "identifier=$id";
#    my $string = "title=delete";
#    warn $string;

        $q = new ZOOM::Query::CQL2RPN( $string, $Zconn);
    eval {
#        my $rs = $Zconn->search_pqf("\@attr 1=12 $id");
	my $rs = $Zconn->search($q);
        my $n  = $rs->size();
        if ( $n > 0 ) {
            $raw = $rs->record(0)->raw();
        }
    };
    if ($@) {

        warn "Error ", $@->code(), ": ", $@->message(), "\n";
    }
    ###$raw
    my $record = $raw;
    ###$record
    return ($record);
}    

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
 
