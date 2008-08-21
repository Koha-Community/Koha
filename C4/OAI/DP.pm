#  ---------------------------------------------------------------------
#   OAI Data Provider template (OAI-PMH v2.0)
#    v3.05
#    June 2002
#  ------------------+--------------------+-----------------------------
#   Hussein Suleman  |   hussein@vt.edu   |    www.husseinsspace.com    
#  ------------------+--------------------+-+---------------------------
#   Department of Computer Science          |        www.cs.vt.edu       
#     Digital Library Research Laboratory   |       www.dlib.vt.edu      
#  -----------------------------------------+-------------+-------------
#   Virginia Polytechnic Institute and State University   |  www.vt.edu  
#  -------------------------------------------------------+-------------
#    January 2008
#  ------------------+--------------------------------------------------
#   Ph. Jaillon      | 
#  ------------------+----------------------+---------------------------
#   Department of Computer Science          |      
#  -----------------------------------------+-------------+-------------
#   Ecole Nationale Superieure des Mines de St-Etienne    |  www.emse.fr 
#  -------------------------------------------------------+-------------


$VERSION = '1.0.0';

package C4::OAI::DP;

=head1 OAI::DP OAI Data Provider

This module provide a full  implementation of the OAI-PMH v2 protocol
specification (http://www.openarchives.org/OAI/openarchivesprotocol.html).

It is simple to use, to answer to OAI-PMH requests you must create a new OAI::DP
instance and call its run() method.

This new instance is an instance of a subclass of the OAI::DP class and the job
of this subclass is to manage data and to format answers according to the meta data
model used (see OAI::DC for an example).

Tipical OAI service looks like:

        my $OAI = new A_OAI_SUBCLASS(some parameters);

        $OAI->run();
        $OAI->dispose();

=cut

use POSIX;

use CGI;
use C4::OAI::Utility;

# setting binmode to utf8 (any characters printed on STDOUT are utf8 encoded)
binmode(STDOUT, ":utf8");

# constructor
sub new
{
   my ($classname) = @_;

   my $self = {
      class           => $classname,
      xmlnsprefix     => 'http://www.openarchives.org/OAI/2.0/',
      protocolversion => '2.0',
      repositoryName  => 'NoName Repository',
      adminEmail      => 'someone@somewhere.org',
      granularity     => 'YYYY-MM-DD',
      deletedRecord   => 'no',
      metadatanamespace => {
         oai_dc       => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
      },
      metadataschema => {
         oai_dc       => 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
      },
      metadataroot => {
         oai_dc       => 'dc',
      },
      metadatarootparameters => {
         oai_dc       => '',
      },
      utility         => new C4::OAI::Utility,
      error           => [],
   };

   bless $self, $classname;
   return $self;
}


# destructor
sub dispose
{
   my ($self) = @_;
}


# output XML HTTP header
sub xmlheader
{
   my ($self) = @_;

   # calculate timezone automatically
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime (time);
   my $timezone = 'Z';
   my $datestring = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d%s",
                    $year+1900, $mon+1, $mday, $hour, $min, $sec,
                    $timezone);
                    
   # make error strings
   my $errors = '';
   my $fullrequest = 1;
   foreach my $error (@{$self->{'error'}})
   {
      $errors .= "<error code=\"$error->[0]\">$error->[1]</error>\n";
      if (($error->[0] eq 'badVerb') || ($error->[0] eq 'badArgument'))
      {
         $fullrequest = 0;
      }
   }
   
   # add verb container if no errors
   my $verbcontainer = '';
   if ($#{$self->{'error'}} == -1)
   {
      $verbcontainer = '<'.$self->{'verb'}.">\n";
   }
   
   # compute request element with its parameters included if necessary
   my $request = '<request';
   if ($fullrequest == 1)
   {
      foreach my $param ($self->{'cgi'}->param)
      {
         $request .= " $param=\"".$self->{'cgi'}->param ($param)."\"";
      }
   }
   $request .= '>'.$self->{'cgi'}->{'baseURL'}.'</request>';

   "Content-type: text/xml\n\n".
   "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n".
   "<OAI-PMH xmlns=\"$self->{'xmlnsprefix'}\" ".
   "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" ".
   "xsi:schemaLocation=\"$self->{'xmlnsprefix'} ".
   "$self->{'xmlnsprefix'}OAI-PMH.xsd\">\n\n".
   "<responseDate>$datestring</responseDate>\n".
   $request."\n\n".
   $errors.
   $verbcontainer;
}


# output XML HTTP footer
sub xmlfooter
{
   my ($self) = @_;
   
   # add verb container if no errors
   my $verbcontainer = '';
   if ($#{$self->{'error'}} == -1)
   {
      $verbcontainer = '</'.$self->{'verb'}.">\n";
   }
   
   $verbcontainer.
   "\n</OAI-PMH>\n";
}


# add an error to the running list of errors (if its not there already)
sub AddError
{
   my ($self, $errorcode, $errorstring) = @_;
   
   my $found = 0;
   foreach my $error (@{$self->{'error'}})
   {
      if (($error->[0] eq $errorcode) && ($error->[1] eq $errorstring))
      { $found = 1 };
   }
   
   if ($found == 0)
   {
      push (@{$self->{'error'}}, [ $errorcode, $errorstring ] );
   }
}


# create an error and output response
sub Error
{
   my ($self, $errorcode, $errorstring) = @_;

   $self->AddError ($errorcode, $errorstring);
   $self->xmlheader.$self->xmlfooter;
}


# check for the validity of the date according to the OAI spec
sub DateisValid
{
   my ($self, $date) = @_;
   
   my ($year, $month, $day, $hour, $minute, $second);
   
   if ($date =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})/)
   {
      $year = $1; 
      if ($year <= 0)
      { return 0; }

      $month = $2; 
      if (($month <= 0) || ($month > 12))
      { return 0; }

      $day = $3; 
      my $daysinmonth;
      if ((((($year % 4) == 0) && (($year % 100) != 0)) || (($year % 400) == 0))
          && ($month == 2))
      { $daysinmonth = 29; }
      elsif (($month == 4) || ($month == 6) || ($month == 9) || ($month == 11))
      { $daysinmonth = 30; }
      elsif ($month == 2)
      { $daysinmonth = 28; }
      else
      { $daysinmonth = 31; }
      if (($day <= 0) || ($day > $daysinmonth))
      { return 0; }
   }
   else 
   { return 0; }

   if ($date =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T([0-9]{2}):([0-9]{2}):([0-9]{2})Z$/)
   {
      $hour = $1; 
      $minute = $2;
      if (($hour < 0) || ($hour > 23) || ($minute < 0) || ($minute > 59))
      { return 0; }

      $second = $3;
      if (($second < 0) || ($second > 59))
      { return 0; }
   }
   elsif (length ($date) > 10)
   { return 0; }

   return 1;
}


# check that the granularity is ok
sub GranularityisValid
{
   my ($self, $date1, $date2) = @_;
   
   my $granularity = $self->{'granularity'};
   
   if (($granularity ne 'YYYY-MM-DDThh:mm:ssZ') && (length ($date1) > 10))
   {
      return 0;
   }
   if (defined $date2)
   {
      if (($granularity ne 'YYYY-MM-DDThh:mm:ssZ') && (length ($date2) > 10))
      {
         return 0;
      }
      if (length ($date1) != length ($date2))
      {
         return 0;
      }
   }

   return 1;
}


# check for bad arguments
sub ArgumentisValid
{
   my ($self) = @_;
   
   my %required = ( 
      'Identify' => [],
      'ListSets' => [],
      'ListMetadataFormats' => [],
      'ListIdentifiers' => [ 'metadataPrefix' ],
      'GetRecord' => [ 'identifier', 'metadataPrefix' ],
      'ListRecords' => [ 'metadataPrefix' ]
   );
   my %optional = ( 
      'Identify' => [],
      'ListSets' => [],
      'ListMetadataFormats' => [ 'identifier' ],
      'ListIdentifiers' => [ 'set', 'from', 'until', 'resumptionToken' ],
      'GetRecord' => [],
      'ListRecords' => [ 'set', 'from', 'until', 'resumptionToken' ]
   );
 
   # get parameter lists
   my $verb = $self->{'cgi'}->param ('verb');
   my @parmsrequired = @{$required{$verb}};
   my @parmsoptional = @{$optional{$verb}};
   my @parmsall = (@parmsrequired, @parmsoptional);
   my @names = $self->{'cgi'}->param;
   my %paramhash = ();
   foreach my $name (@names)
   {
      $paramhash{$name} = 1;
   }
   
   # check for required parameters
   foreach my $name (@parmsrequired)
   {
      if ((! exists $paramhash{$name}) &&
          ((($verb ne 'ListIdentifiers') && ($verb ne 'ListRecords')) ||
           (! exists $paramhash{'resumptionToken'})))
      {
         return $self->Error ('badArgument', "missing $name parameter");
      }
   }
   
   # check for illegal parameters
   foreach my $name (@names)
   {
      my $found = 0;
      foreach my $name2 (@parmsall)
      {
         if ($name eq $name2)
         { $found = 1; }
      }
      if (($found == 0) && ($name ne 'verb'))
      {
         return $self->Error ('badArgument', "$name is an illegal parameter");
      }
   }
   
   # check for duplicate parameters
   foreach my $name (@names)
   {
      my @values = $self->{'cgi'}->param ($name);
      if ($#values != 0)
      {
         return $self->Error ('badArgument', "multiple values are not allowed for the $name parameter");
      }
   }

   # check for resumptionToken exclusivity
   if ((($verb eq 'ListIdentifiers') || ($verb eq 'ListRecords')) &&
        (exists $paramhash{'resumptionToken'}) &&
        ($#names > 1))
   {
      return $self->Error ('badArgument', 'resumptionToken cannot be combined with other parameters');
   }
   
   return '';
}


# convert date/timestamp into seconds for comparisons
sub ToSeconds
{
   my ($self, $date, $from) = @_;
   
   my ($month, $day, $hour, $minute, $second);
   
   if ((defined $from) && ($from == 1))
   {
      ($month, $day, $hour, $minute, $second) = (1, 1, 0, 0, 0);
   }
   else
   {
      ($month, $day, $hour, $minute, $second) = (12, 31, 23, 59, 59);
   }

   if ($date =~ /([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})Z/)
   {
      return mktime ($6, $5, $4, $3, $2-1, $1-1900);
   }
   elsif ($date =~ /([0-9]{4})-([0-9]{2})-([0-9]{2})/)
   {
      return mktime ($second, $minute, $hour, $3, $2-1, $1-1900);
   }
   else
   {
      return 0;
   }
}


# check if the metadata format is valid
sub MetadataFormatisValid
{
   my ($self, $metadataFormat) = @_;

   my $found = 0;
   foreach my $i (keys %{$self->{'metadatanamespace'}})
   {
      if ($metadataFormat eq $i)
      { $found = 1; }
   }

   if ($found == 1)
   { return 1; }
   else
   { return 0; }
}


# format the header for a record
sub FormatHeader
{
   my ($self, $identifier, $datestamp, $status, $setSpecs) = @_;
   
   my $statusattribute = '';
   if ((defined $status) && ($status eq 'deleted'))
   {
      $statusattribute = " status=\"deleted\"";
   }
   
   my $setstring = '';
   if (defined $setSpecs)
   {
      foreach my $setSpec (@$setSpecs)
      {
         $setstring .= '<setSpec>'.$setSpec."</setSpec>\n";
      }
   }

   "<header$statusattribute>\n".
   "<identifier>$identifier</identifier>\n".
   "<datestamp>$datestamp</datestamp>\n".
   $setstring.
   "</header>\n";
}


# format the record by encapsulating it in a "record" container
sub FormatRecord
{
   my ($self, $identifier, $datestamp, $status, $setSpecs, $metadata, $about) = @_;
   
   my $header = $self->FormatHeader ($identifier, $datestamp, $status, $setSpecs);

   my $output =
      "<record>\n".
      $header;
   
   if ((defined $metadata) && ($metadata ne ''))
   {
      $output .= "<metadata>\n$metadata</metadata>\n";
   }
   if ((defined $about) && ($about ne ''))
   {
      $output .= "<about>\n$about</about>\n";
   }
                                 
   $output."</record>\n";
}


# standard handler for Identify verb
sub Identify
{
   my ($self) = @_;

   my $identity = $self->Archive_Identify;
   if (! exists $identity->{'repositoryName'})
   {
      $identity->{'repositoryName'} = $self->{'repositoryName'};
   }
   if (! exists $identity->{'adminEmail'})
   {
      $identity->{'adminEmail'} = $self->{'adminEmail'};
   }
   $identity->{'protocolVersion'} = $self->{'protocolversion'};
   $identity->{'baseURL'} = $self->{'cgi'}->{'baseURL'};
   if (! exists $identity->{'granularity'})
   {
      $identity->{'granularity'} = $self->{'granularity'};
   }
   if (! exists $identity->{'deletedRecord'})
   {
      $identity->{'deletedRecord'} = $self->{'deletedRecord'};
   }
   if (! exists $identity->{'earliestDatestamp'})
   {
      my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime (0);
      my $timezone = 'Z';
      my $datestring = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d%s",
                       $year+1900, $mon+1, $mday, $hour, $min, $sec,
                       $timezone);
      $identity->{'earliestDatestamp'} = $datestring;
   }

   $identity->{'mdorder'} = [ qw ( repositoryName baseURL protocolVersion adminEmail earliestDatestamp deletedRecord granularity compression description ) ];

   # add in description for toolkit
   if (! exists $identity->{'description'})
   {
      $identity->{'description'} = [];
   }
   my $desc = {
      'toolkit' => [[ 
         {
            'xmlns' => 'http://oai.dlib.vt.edu/OAI/metadata/toolkit',
            'xsi:schemaLocation' => 
                       'http://oai.dlib.vt.edu/OAI/metadata/toolkit '.
                       'http://oai.dlib.vt.edu/OAI/metadata/toolkit.xsd'
         },
         {
            'title'    => 'VTOAI Perl Data Provider',
            'author'   => [
		     {
		       'name' => 'Hussein Suleman',
		       'email' => 'hussein@vt.edu',
		       'institution' => 'Virginia Tech',
		       'mdorder' => [ qw ( name email institution ) ],
		     },
		     {
		       'name' => 'Philippe Jaillon',
		       'email' => 'jaillon@emse.fr',
		       'institution' => 'École Nationale Supérieure des Mines de Saint-Étienne',
		       'mdorder' => [ qw ( name email institution ) ],
		     }
	     ],
            'version'  => '3.05',
            'URL'      => [
		'http://www.dlib.vt.edu/projects/OAI/',
            	'http://oai-pmh.emse.fr/'
	     ],
            'mdorder'  => [ qw ( title author version URL ) ]
         },
      ]]
   };
   push (@{$identity->{'description'}}, $desc);

   $self->xmlheader.
   $self->{'utility'}->FormatXML ($identity).
   $self->xmlfooter;
}


# standard handler for ListMetadataFormats verb
sub ListMetadataFormats
{
   my ($self) = @_;
   
   my $identifier = $self->{'cgi'}->param ('identifier');
   my $metadataNamespace = $self->{'metadatanamespace'};
   my $metadataSchema = $self->{'metadataschema'};

   my $lmf = $self->Archive_ListMetadataFormats ($identifier);
   if ($#$lmf > 0)
   {
      $metadataNamespace = $$lmf[0];
      $metadataSchema = $$lmf[1];
   }

   my $buffer = $self->xmlheader;
   if ($#{$self->{'error'}} == -1)
   {
      foreach my $i (keys %{$metadataNamespace})
      {
         $buffer .= "<metadataFormat>\n".
                    "<metadataPrefix>$i</metadataPrefix>\n".
                    "<schema>$metadataSchema->{$i}</schema>\n".
                    "<metadataNamespace>$metadataNamespace->{$i}</metadataNamespace>\n".
                    "</metadataFormat>\n";
      }
   }
   $buffer.$self->xmlfooter;
}


# standard handler for ListSets verb
sub ListSets
{
   my ($self) = @_;

   my $setlist = $self->Archive_ListSets;
   
   if ($#$setlist == -1)
   {
      $self->AddError ('noSetHierarchy', 'The repository does not support sets');
   }

   my $buffer = $self->xmlheader;
   if ($#{$self->{'error'}} == -1)
   {   
      foreach my $item (@$setlist)
      {
         $buffer .= "<set>\n".
                    "  <setSpec>".$self->{'utility'}->lclean ($$item[0])."</setSpec>\n".
                    "  <setName>".$self->{'utility'}->lclean ($$item[1])."</setName>\n";
         if (defined $$item[2])
         {
            $buffer .= '<setDescription>'.$$item[2].'</setDescription>';
         }
         $buffer .= "</set>\n";
      }
   }
   $buffer.$self->xmlfooter;
}


# standard handler for GetRecord verb
sub GetRecord
{
   my ($self) = @_;

   my $identifier = $self->{'cgi'}->param ('identifier');
   my $metadataPrefix = $self->{'cgi'}->param ('metadataPrefix');

   my $recref = $self->Archive_GetRecord ($identifier, $metadataPrefix);
   my $recbuffer;
   if ($recref)
   {
      $recbuffer = $self->Archive_FormatRecord ($recref, $metadataPrefix);
   }

   my $buffer = $self->xmlheader;
   if ($#{$self->{'error'}} == -1)
   {
      $buffer .= $recbuffer;
   }
   $buffer.$self->xmlfooter;
}


# create extended resumptionToken
sub createResumptionToken
{
   my ($self, $resumptionToken, $resumptionParameters) = @_;
   
   my $attrs = '';
   if (defined $resumptionParameters)
   {
      foreach my $key (keys %{$resumptionParameters})
      {
         $attrs .= " $key=\"$resumptionParameters->{$key}\"";
      }
   }
   
   if (($resumptionToken ne '') || ($attrs ne ''))
   {
      "<resumptionToken".$attrs.">$resumptionToken</resumptionToken>\n";
   }
   else
   {
      '';
   }
}


# standard handler for ListRecords verb
sub ListRecords
{
   my ($self) = @_;

   my ($set, $from, $until, $metadataPrefix);
   my ($resumptionToken, $allrows, $resumptionParameters);

   $resumptionToken = $self->{'cgi'}->param ('resumptionToken');
   if ($resumptionToken eq '')
   {
      $set = $self->{'cgi'}->param ('set');
      $from = $self->{'cgi'}->param ('from');
      $until = $self->{'cgi'}->param ('until');
      $metadataPrefix = $self->{'cgi'}->param ('metadataPrefix');

      if ($from ne '')
      {
         if (!($self->DateisValid ($from)))
         { return $self->Error ('badArgument', 'illegal from parameter'); }
         if (!($self->GranularityisValid ($from)))
         { return $self->Error ('badArgument', 'illegal granularity for from parameter'); }
      }
      if ($until ne '') 
      {
         if (!($self->DateisValid ($until)))
         { return $self->Error ('badArgument', 'illegal until parameter'); }
         if (!($self->GranularityisValid ($until)))
         { return $self->Error ('badArgument', 'illegal granularity for until parameter'); }
      }
      if (($from ne '') && ($until ne '') && (!($self->GranularityisValid ($from, $until))))
      {
         return $self->Error ('badArgument', 'mismatched granularities in from/until');
      }
   }

   ($allrows, $resumptionToken, $metadataPrefix, $resumptionParameters) =  
     $self->Archive_ListRecords ($set, $from, $until, $metadataPrefix, $resumptionToken);

   my $recbuffer;
   foreach my $recref (@$allrows)
   { 
      $recbuffer .= $self->Archive_FormatRecord ($recref, $metadataPrefix);
   }

   my $buffer = $self->xmlheader;
   if ($#{$self->{'error'}} == -1)
   {
      $buffer .= $recbuffer.$self->createResumptionToken ($resumptionToken, $resumptionParameters);
   }
   $buffer.$self->xmlfooter;
}


# standard handler for ListIdentifiers verb
sub ListIdentifiers
{
   my ($self) = @_;

   my ($set, $from, $until, $metadataPrefix);
   my ($resumptionToken, $allrows, $resumptionParameters);

   $resumptionToken = $self->{'cgi'}->param ('resumptionToken');
   if ($resumptionToken eq '')
   {
      $set = $self->{'cgi'}->param ('set');
      $from = $self->{'cgi'}->param ('from');
      $until = $self->{'cgi'}->param ('until');
      $metadataPrefix = $self->{'cgi'}->param ('metadataPrefix');

      if ($from ne '')
      {
         if (!($self->DateisValid ($from)))
         { return $self->Error ('badArgument', 'illegal from parameter'); }
         if (!($self->GranularityisValid ($from)))
         { return $self->Error ('badArgument', 'illegal granularity for from parameter'); }
      }
      if ($until ne '') 
      {
         if (!($self->DateisValid ($until)))
         { return $self->Error ('badArgument', 'illegal until parameter'); }
         if (!($self->GranularityisValid ($until)))
         { return $self->Error ('badArgument', 'illegal granularity for until parameter'); }
      }
      if (($from ne '') && ($until ne '') && (!($self->GranularityisValid ($from, $until))))
      {
         return $self->Error ('badArgument', 'mismatched granularities in from/until');
      }
   }

   ($allrows, $resumptionToken, $metadataPrefix, $resumptionParameters) = 
     $self->Archive_ListIdentifiers ($set, $from, $until, $metadataPrefix, $resumptionToken);

   my $recbuffer = '';
   foreach my $recref (@$allrows)
   {
      $recbuffer .= $self->Archive_FormatHeader ($recref, $metadataPrefix);
   }

   my $buffer = $self->xmlheader;
   if ($#{$self->{'error'}} == -1)
   {
      $buffer .= $recbuffer.$self->createResumptionToken ($resumptionToken, $resumptionParameters);
   }
   $buffer.$self->xmlfooter;
}


# stub routines to get actual data from archives


sub Archive_FormatRecord
{
   my ($self, $recref, $metadataFormat) = @_;
   
   $self->FormatRecord ('identifier',
                        '1000-01-01',
                        '',
                        '',
                        $self->{'utility'}->FormatXML ({}),
                        $self->{'utility'}->FormatXML ({})
                       );
}


sub Archive_FormatHeader
{
   my ($self, $recref, $metadataFormat) = @_;
   
   $self->FormatHeader ('identifier',
                        '1000-01-01',
                        '',
                        ''
                       );
}


sub Archive_Identify
{
   my ($self) = @_;

   {};
}


sub Archive_ListSets
{
   my ($self) = @_;
   
   [];
}


sub Archive_ListMetadataFormats
{
   my ($self, $identifier) = @_;
   
   [];
}


sub Archive_GetRecord
{
   my ($self, $identifier, $metadataPrefix) = @_;
   
   my %records = ();

   undef;
}


sub Archive_ListRecords
{
   my ($self, $set, $from, $until, $metadataPrefix, $resumptionToken) = @_;
   
   my $results = [];
   my @allrows = ();
   $resumptionToken = '';

   ( \@allrows, $resumptionToken, $metadataPrefix, {} );
}


sub Archive_ListIdentifiers
{
   my ($self, $set, $from, $until, $metadataPrefix, $resumptionToken) = @_;
   
   my $results = [];
   my @allrows = ();
   $resumptionToken = '';

   ( \@allrows, $resumptionToken, $metadataPrefix, {} );
}


# main loop to process parameters and call appropriate verb handler
sub Run
{
   my ($self) = @_;

   if (! exists $self->{'cgi'})
   {
## PJ 20071021
      ##$self->{'cgi'} = new Pure::EZCGI;
      $self->{'cgi'} = new CGI;
   }
   $self->{'verb'} = $self->{'cgi'}->param ('verb');

   # check for illegal verb
   if (($self->{'verb'} ne 'Identify') &&
       ($self->{'verb'} ne 'ListMetadataFormats') &&
       ($self->{'verb'} ne 'ListSets') &&
       ($self->{'verb'} ne 'ListIdentifiers') &&
       ($self->{'verb'} ne 'GetRecord') &&
       ($self->{'verb'} ne 'ListRecords'))
   {
      print $self->Error ('badVerb', 'illegal OAI verb');
   }
   else
   {
      # check for illegal parameters
      my $aiv = $self->ArgumentisValid;
      if ($aiv ne '')
      {
         print $aiv;
      }
      else
      {
         # run appropriate handler procedure
         if ($self->{'verb'} eq 'Identify')
         { print $self->Identify; }
         elsif ($self->{'verb'} eq 'ListMetadataFormats')
         { print $self->ListMetadataFormats; }
         elsif ($self->{'verb'} eq 'GetRecord')
         { print $self->GetRecord; }
         elsif ($self->{'verb'} eq 'ListSets')
         { print $self->ListSets; }
         elsif ($self->{'verb'} eq 'ListRecords')
         { print $self->ListRecords; }
         elsif ($self->{'verb'} eq 'ListIdentifiers')
         { print $self->ListIdentifiers; }
      }
   }
}


1;


# HISTORY
#
# 2.01
#  fixed ($identifier) error
#  added status to FormatRecord
# 2.02
#  added metadataPrefix to GetRecord hander
# 3.0
#  converted to OAI2.0 alpha1
# 3.01
#  converted to OAI2.0 alpha2
# 3.02
#  converted to OAI2.0 alpha3
# 3.03
#  converted to OAI2.0 beta1
# 3.04
#  converted to OAI2.0 beta2
#  added better argument handling
# 3.05
#  polished for OAI2.0
