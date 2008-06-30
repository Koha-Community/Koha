#  ---------------------------------------------------------------------
#   Dublin Core helper class
#    v1.0
#    January 2007
#  ------------------+--------------------------------------------------
#   Ph. Jaillon      | 
#  ------------------+----------------------+---------------------------
#   Department of Computer Science          |      
#  -----------------------------------------+-------------+-------------
#   Ecole Nationale Superieure des Mines de St-Etienne    |  www.emse.fr 
#  -------------------------------------------------------+-------------

=head1 OAI::DC Dublin Core formating helper
         
OAI::DC is an helper class for Dublin Core metadata. As Dublin Core have a well known
set of fields, OAI::DC is a subclass of the OAI::DP class and it implements a default
behavior to build correct answers. The data references returned by Archive_GetRecord
and Archive_ListRecords must be instance providing the following method (they are used
to translate your own data to Dublin Core) : Title(), Identifier(), Subject(), Creator(),
Date(), Description(), Publisher(), Language() and Type(). The semantic of these methods is
the same as the corresponding Dublin Core field.

To return correct metadata, you must provide or overide theses methods:

=over 

=over

=item B<new>: initialization step,

=item B<dispose>: clean up step,

=item B<Archive_ListSets>: return list of defined sets,

=item B<Archive_GetRecord>: return a record,

=item B<Archive_ListRecords>: return a list of records,

=item B<Archive_ListIdentifiers>: return a list of record identifiers,

=back

=back

=head2 new

=over

Object of this method is to build a new instance of your OAI data provider. At this step
you can overide somme default information about the repository, you can also initiate
connexion to a database... Parameters to the new method are user defined.

=back

=head2 dispose

=over

It's time to disconnect from database (if required). Must explicitly call SUPER::dispose().

=back

=head2 Archive_ListSets

=over

Return a reference to an array of list set. Each list set is a reference to a two element array.
The first element is the set name of the set and the second is its short description.

        sub Archive_ListSets {
                [
                        [ 'SET1', 'Description of the SET1'],
                        [ 'SET2', 'Description of the SET2'],
                ];
        }

=back

=head2 Archive_GetRecord

=over

This method take a record identifier and metadata format as parameter. It must return a reference to
the data associated to identifier. Data are reference to a hash and must provide methodes describe
at the begining of DC section.

=back

=head2 Archive_ListRecords

=over

Object of this method is to return a list of records occording to the user query. Parameters of the method
are the set, the from date, the until date, the metadata type required and a resumption token if supported.

The method must return a reference to a list of records, the metadata type of the answer and reference to
token information. Token information must be undefined or a reference to a hash with the I<completeListSize>
and the I<cursor> keys set.

=back

=cut

package C4::OAI::DC;

use C4::OAI::DP;
use vars ('@ISA');
@ISA = ("C4::OAI::DP");

# format DC record
sub FormatDC
{
   my ($self, $hashref) = @_;

   return undef if( $hashref->Status() eq 'deleted' );

   {
      title       => $hashref->Title(),
      identifier  => $hashref->Identifier(),
      subject     => $hashref->Subject(),
      creator     => $hashref->Creator(),
      date        => $hashref->Date(),
      description => $hashref->Description(),
      publisher   => $hashref->Publisher(),
      language    => $hashref->Language(),
      type        => $hashref->Type(),
      mdorder     => [ qw (title creator subject description contributor publisher date type format identifier source language relation coverage rights) ]
   };
}

# format header for ListIdentifiers
sub Archive_FormatHeader
{
   my ($self, $hashref, $metadataFormat) = @_;
   
   $self->FormatHeader ($hashref->Identifier()->[0] ,
                        $hashref->DateStamp(),
                        '',
			$hashref->Set()
                       );
}

# retrieve records from the source archive as required
sub Archive_FormatRecord
{
   my ($self, $hashref, $metadataFormat) = @_;
   
   if ($self->MetadataFormatisValid ($metadataFormat) == 0)
   {
      $self->AddError ('cannotDisseminateFormat', 'The value of metadataPrefix ('.$metadataFormat.') is not supported by the repository');
      return '';
   }

   my $dc = $self->FormatDC ($hashref);
   my $header = "<oaidc:dc xmlns=\"http://purl.org/dc/elements/1.1/\" ".
                "xmlns:oaidc=\"http://www.openarchives.org/OAI/2.0/oai_dc/\" ".
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" ".
                "xsi:schemaLocation=\"http://www.openarchives.org/OAI/2.0/oai_dc/ ".
                "http://www.openarchives.org/OAI/2.0/oai_dc.xsd\">\n";
   my $footer = "</oaidc:dc>\n";
   my $metadata = '';

   $metadata = $header . $self->{'utility'}->FormatXML($dc) . $footer if( $dc );

   $self->FormatRecord ($hashref->Identifier()->[0] ,
                        $hashref->DateStamp(),
                        $hashref->Status(),
			$hashref->Set(),
                        $metadata,
                        '',
                       );
}


# get full list of mdps or list for specific identifier
sub Archive_ListMetadataFormats
{
   my ($self, $identifier) = @_;
   
   if ((! defined $identifier) || ($identifier eq '')) {
      return ['oai_dc'];
   }
   else {
      $self->AddError ('idDoesNotExist', 'The value of the identifier argument is unknown or illegal in this repository');
   }
   return [];
}


# get full list of sets from the archive
sub Archive_ListSets
{
	[];
}
                              

# get a single record from the archive
sub Archive_GetRecord
{
   my ($self, $identifier, $metadataFormat) = @_;

   $self->AddError ('idDoesNotExist', 'The value of the identifier argument is unknown or illegal in this repository');
   undef;
}

# list metadata records from the archive
sub Archive_ListRecords
{
   my ($self, $set, $from, $until, $metadataPrefix, $resumptionToken) = @_;
   my $tokenInfo = undef;

	$self->AddError ('noRecordsMatch', 'The combination of the values of arguments results in an empty set');
	( [], $resumptionToken, $metadataPrefix, $tokenInfo );
}


# list identifiers (headers) from the archive
sub Archive_ListIdentifiers
{
   my ($self, $set, $from, $until, $metadataPrefix, $resumptionToken) = @_;

   if (($metadataPrefix ne '') && ($self->MetadataFormatisValid ($metadataPrefix) == 0))
   {
      $self->AddError ('cannotDisseminateFormat', 'The value of metadataPrefix ('.$metadataPrefix.')is not supported by the repository');
      return '';
   }
   
   $self->Archive_ListRecords ($set, $from, $until, $metadataPrefix, $resumptionToken);
}

1;

