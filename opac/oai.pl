#!/usr/bin/perl

use strict;

use C4::Context;
use C4::Biblio;

=head1 OAI-PMH for koha

This file is an implementation of the OAI-PMH protocol for koha. Its purpose
is to share metadata in Dublin core format with harvester like PKP-Harverster.
Presently, all the bibliographic records managed by the runing koha instance
are publicly shared (as the opac is).

=head1 Package MARC::Record::KOHADC

This package is a sub-class of the MARC::File::USMARC. It add methods and functions
to map the content of a marc record (of any flavor) to Dublin core.
As soon as it is possible, mapping between marc fields and there semantic
are got from ::GetMarcFromKohaField fonction from C4::Biblio (see also the "Koha
to MARC mapping" preferences).

=cut

package MARC::Record::KOHADC;
use vars ('@ISA');
@ISA = qw(MARC::Record);

use MARC::File::USMARC;

sub new { # Get a MAR::Record as parameter and bless it as MARC::Record::KOHADC
	shift;
	my $marc = shift;
	bless $marc  if( ref( $marc ) );
}

sub subfield {
    my $self = shift;
    my ($t,$sf) = @_;

    return $self->SUPER::subfield( @_ ) unless wantarray;

    my @field = $self->field($t);
    my @list = ();
    my $f;

    foreach $f ( @field ) {
		push( @list, $f->subfield( $sf ) );
    }
    return @list;
}

sub getfields {
my $marc = shift;
my @result = ();

        foreach my $kohafield ( @_ ) {
                my ( $field, $subfield ) = ::GetMarcFromKohaField( $kohafield, '' );
                push( @result, $field < 10 ? $marc->field( $field )->as_string() : $marc->subfield( $field, $subfield ) );
        }
#        @result>1 ? \@result : $result[0];
	\@result;
}  

sub XMLescape {
my ($t) = shift;

	foreach (@$t ) {
        	s/\&/\&amp;/g; s/</&lt;/g;
	}
	$t;
} 

sub Status {
  my $self = shift;
	undef;
}

sub Title {
  my $self = shift;
	&XMLescape( $self->getfields('biblio.title') );
}

sub Creator {
  my $self = shift;
	&XMLescape( $self->getfields('biblio.author') );
}

sub Subject {
  my $self = shift;
	&XMLescape( $self->getfields('bibliosubject.subject') );
}

sub DateStamp {
  my $self = shift;
	my ($d,$h) = split( ' ', $self->{'biblio.timestamp'} );
	$d . "T" . $h . "Z";
}

sub Date {
  my $self = shift;
    my ($str) = @{$self->getfields('biblioitems.publicationyear')};
    my ($y,$m,$d) = (substr($str,0,4), substr($str,4,2), substr($str,6,2));

    $y=1970 unless($y>0); $m=1 unless($m>0); $d=1 unless($d>0);

    sprintf( "%.4d-%.2d-%.2d", $y,$m,$d);
}

sub Description {
  my $self = shift;
	undef;
}

sub Identifier {
  my $self = shift;
  my $id = $self->getfields('biblio.biblionumber')->[0];

# get url of this script and assume that OAI server is in the same place as opac-detail script
# and build a direct link to the record.
  my $uri = $ENV{'SCRIPT_URI'};
  $uri= "http://" . $ENV{'HTTP_HOST'} . $ENV{'REQUEST_URI'} unless( $uri ); # SCRIPT_URI doesn't exist on all httpd server
  $uri =~ s#[^/]+$##;	
	[
		C4::Context->preference("OAI-PMH:archiveID") .":" .$id, 
		"${uri}opac-detail.pl?bib=$id",
		@{$self->getfields('biblioitems.isbn', 'biblioitems.issn')}
	];
}

sub Language {
  my $self = shift;
	undef;
}

sub Type {
  my $self = shift;
	&XMLescape( $self->getfields('biblioitems.itemtype') );
}

sub Publisher {
  my $self = shift;
	&XMLescape( $self->getfields('biblioitems.publishercode') );
}

sub Set {
my $set = &OAI::KOHA::Set();
	[ map( $_=$_->[0], @$set) ];
}

=head1 The OAI::KOHA package

This package is a subclass of the OAI::DC data provider. It overides needed methods
and provide the links between the OAI-PMH request and the koha application.
The data used in answers are from the koha table I<bibio>.

=cut

package OAI::KOHA;

use C4::OAI::DC;
use vars ('@ISA');
@ISA = ("C4::OAI::DC");

=head2 Set

return the Set list to the I<verb=ListSets> query. Data are from the 'OAI-PMH:Set' preference.

=cut

sub Set {
#   [
#	['BRISE','Experimental unimarc set for BRISE network'],
#	['BRISE:EMSE','EMSE set in BRISE network']
#   ];
#
# A blinder correctement
	[ map( $_ = [ split(",", $_)], split( "\n",C4::Context->preference("OAI-PMH:Set") ) ) ];
}

=head2 new

The new method is the constructor for this class. It doesn't have any parameters and 
get required data from koha preferences. Koha I<LibraryName> is used to identify the
OAI-PMH repository, I<OAI-PMH:MaxCount> is used to set the maximun number of records
returned at the same time in answers to I<verb=ListRecords> or I<verb=ListIdentifiers>
queries.

The method return a blessed reference.

=cut

# constructor
sub new
{
   my $classname = shift;
   my $self = $classname->SUPER::new ();

   # set configuration
   $self->{'repositoryName'} = C4::Context->preference("LibraryName");
   $self->{'MaxCount'} = C4::Context->preference("OAI-PMH:MaxCount");
   $self->{'adminEmail'} = C4::Context->preference("KohaAdminEmailAddress");

   bless $self, $classname;
   return $self;
}

=head2 dispose

The dispose method is used as a destructor. It call just the SUPER::dispose method.

=cut

# destructor
sub dispose
{
   my ($self) = @_;
   $self->SUPER::dispose ();
}

# now date
sub now {
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime( time );

        sprintf( "%.4d-%.2d-%.2d", $year+1900, $mon+1,$mday );
}

# build the resumptionTocken fom ($metadataPrefix,$offset,$from,$until)

=head2 buildResumptionToken and parseResumptionToken

Theses two functions are used to manage resumption tokens. The choosed syntax is simple as
possible, a token is only the metadata prefix, the offset in the full answer, the from and 
the until date (in the yyyy-mm-dd format) joined by ':' caracter.

I<buildResumptionToken> get the four elements as parameters and return the ':' separated 
string.

I<parseResumptionToken> is used to set the default values to the from and until date, the 
metadata prefix using the resumption tocken if necessary. This function have four parameters
(from,until,metadata prefix and resumption tocken) which can be undefined and return every
time this list of values correctly set. The missing values are set with defaults: offset=0,
from= 1970-01-01 and until is set to current date.

=cut

sub buildResumptionToken {
        join( ':', @_ );
}

# parse the resumptionTocken
sub parseResumptionToken {
my ($from, $until, $metadataPrefix, $resumptionToken) = @_;
my $offset = 0;

        if( $resumptionToken ) {
                ($metadataPrefix,$offset,$from,$until) = split( ':', $resumptionToken );
        }

        $from  = "1970-01-01" unless( $from );
        $until = &now unless( $until );
        ($metadataPrefix, $offset, $from, $until );
}

=head2 Archive_ListSets

return the full list Set to the I<verb=ListSets> query. Data are from the 'OAI-PMH:Set' preference.

=cut

# get full list of sets from the archive
sub Archive_ListSets
{
	&Set();
}
                              
=head2 Archive_GetRecord

This method select the record specified as its first parameter from the koha I<biblio>
table and return a reference to a MARC::Record::KOHADC object. 

=cut

# get a single record from the archive
sub Archive_GetRecord
{
   my ($self, $identifier, $metadataFormat) = @_;
   my $dbh = C4::Context->dbh;
   my $sth = $dbh->prepare("SELECT biblionumber,timestamp FROM biblio WHERE biblionumber=?");
   my $prefixID = C4::Context->preference("OAI-PMH:archiveID"); $prefixID=qr{$prefixID:};

   $identifier =~ s/^$prefixID//;

   $sth->execute( $identifier );

   if( my $r = $sth->fetchrow_hashref() ) {
   	my $marc = new MARC::Record::KOHADC( ::GetMarcBiblio( $identifier ) );
	if( $marc ) {
		$marc->{'biblio.timestamp'} = $r->{'timestamp'};
   		return $marc ;
	}
	else {
		warn("Archive_GetRecord : no MARC record for " . C4::Context->preference("OAI-PMH:archiveID") . ":" . $identifier);
	}
   }

   $self->AddError ('idDoesNotExist', 'The value of the identifier argument is unknown or illegal in this repository');
   undef;
}

=head2 Archive_ListRecords

This method return a list of 'MaxCount' references to MARC::Record::KOHADC object build from the 
koha I<biblio> table according to its parameters : set, from and until date, metadata prefix 
and resumption token.

=cut

# list metadata records from the archive
sub Archive_ListRecords
{
   my ($self, $set, $from, $until, $metadataPrefix, $resumptionToken) = @_;

   my @allrows = ();
   my $marc;
   my $offset;
   my $tokenInfo;
   my $dbh = C4::Context->dbh;
   my $sth = $dbh->prepare("SELECT biblionumber,timestamp FROM biblio WHERE DATE(timestamp) >= ? and DATE(timestamp) <= ? LIMIT ? OFFSET ?");
   my $count;

        ($metadataPrefix, $offset, $from, $until ) = &parseResumptionToken($from, $until, $metadataPrefix, $resumptionToken);

#warn( "Archive_ListRecords : $set, $from, $until, $metadataPrefix, $resumptionToken\n");
   	$sth->execute( $from,$until,$self->{'MaxCount'}?$self->{'MaxCount'}:100000, $offset );

	while( my $r = $sth->fetchrow_hashref() ) { 
		my $marc = new MARC::Record::KOHADC( ::GetMarcBiblio( $r->{'biblionumber'} ) );
		unless( $marc ) { # somme time there is problems within koha, and we can't get valid marc record
			warn("Archive_ListRecords : no MARC record for " . C4::Context->preference("OAI-PMH:archiveID") .":" . $r->{'biblionumber'} );
			next;
		}
		$marc->{'biblio.timestamp'} = $r->{'timestamp'};
		push( @allrows, $marc );
	} 

	$sth = $dbh->prepare("SELECT count(*) FROM biblioitems WHERE DATE(timestamp) >= ? and DATE(timestamp) <= ?"); 
	$sth->execute($from, $until);
	( $count ) = $sth->fetchrow_array();

	unless( @allrows ) {
      		$self->AddError ('noRecordsMatch', 'The combination of the values of arguments results in an empty set');
   	}

	if( $offset + $self->{'MaxCount'} < $count ) { # Not at the end
		$offset = $offset + $self->{'MaxCount'};
		$resumptionToken = &buildResumptionToken($metadataPrefix,$offset,$from,$until);
		$tokenInfo = { 'completeListSize' => $count, 'cursor' => $offset };
	}
	else {
		$resumptionToken = '';
		$tokenInfo = {};
	}
	( \@allrows, $resumptionToken, $metadataPrefix, $tokenInfo );
}

package main;

=head1 Main package

The I<main> function is the starting point of the service. The first step is
to verify if the service is enable using the 'OAI-PMH' preference value
(See Koha systeme preferences).

If the service is enable, it create a new instance of the OAI::KOHA data
provider (see before) and run the service.

=cut

sub disable {
	print "Status:404 OAI-PMH service is disabled\n";
	print "Content-type: text/plain\n\n";

	print "OAI-PMH service is disable.\n";
}

sub main
{
   return &disable() unless( C4::Context->preference('OAI-PMH') );

   my $OAI = new OAI::KOHA();
   $OAI->Run;
   $OAI->dispose;
}

main;

1;
