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
          shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };

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

@ISA = qw(Exporter);
@EXPORT = qw(search);
# make all your functions, whether exported or not;

sub search {
    my ($search,$type)=@_;
    my $dbh=C4::Context->dbh();
    my $q;
    my $host=C4::Context->config("zebraserver");
    my $port=C4::Context->config("zebraport");
    my $intranetdir=C4::Context->config("intranetdir");
    my $database="koha3";
    my $Zconn;
    my $raw;
    eval {
	$Zconn = new ZOOM::Connection("$host:$port/$database");
    };
    if ($@) {
	warn "Error ", $@->code(), ": ", $@->message(), "\n";                  
    }
    
    if ($type eq 'CQL'){
	my $string;
	foreach my $var (keys %$search) {
	    $string.="$var=\"$search->{$var}\" ";
	}	    
	$Zconn->option(cqlfile => "$intranetdir/zebra/pqf.properties");
	$Zconn->option(preferredRecordSyntax => "usmarc");
	$q = new ZOOM::Query::CQL2RPN( $string, $Zconn);	
	}
    eval {
	my $rs = $Zconn->search($q);
	my $n = $rs->size();
	if ($n >0){
	    $raw=$rs->record(0)->raw();
	}
#	print "here is $n";
#	$raw=$rs->record(0)->raw();
	print $raw;


    };
    if ($@) {
	print "Error ", $@->code(), ": ", $@->message(), "\n";
    }   
    my $record = MARC::Record->new_from_usmarc($raw);
    ### $record                                                                                                    
    # transform it into a meaningul hash                                                                       
    my $line = MARCmarc2koha($dbh,$record);                                                                    
    ### $line                                                                                                      
    my $biblionumber=$line->{biblionumber};                                                                    
    my $title=$line->{title};                                                                                  


}
1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
