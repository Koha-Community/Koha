#  ---------------------------------------------------------------------
#   Utility routines for cleaning and formatting XML related to OAI
#    v1.1
#    January 2002
#  ------------------+--------------------+-----------------------------
#   Hussein Suleman  |   hussein@vt.edu   |    www.husseinsspace.com    
#  ------------------+--------------------+-+---------------------------
#   Department of Computer Science          |        www.cs.vt.edu       
#     Digital Library Research Laboratory   |       www.dlib.vt.edu      
#  -----------------------------------------+-------------+-------------
#   Virginia Polytechnic Institute and State University   |  www.vt.edu  
#  -------------------------------------------------------+-------------


package C4::OAI::Utility;


# constructor [create mapping for latin entities to Unicode]
sub new
{
   my $classname = shift;

   my $self = { XMLindent => '   ' };

   my @upperentities = qw (nbsp iexcl cent pound curren yen brvbar sect 
                           uml copy ordf laquo not 173 reg macr deg plusmn 
                           sup2 sup3 acute micro para middot cedil supl 
                           ordm raquo frac14 half frac34 iquest Agrave 
                           Aacute Acirc Atilde Auml Aring AElig Ccedil 
                           Egrave Eacute Ecirc Euml Igrave Iacute Icirc 
                           Iuml ETH Ntilde Ograve Oacute Ocirc Otilde Ouml 
                           times Oslash Ugrave Uacute Ucirc Uuml Yacute 
                           THORN szlig agrave aacute acirc atilde auml 
                           aring aelig ccedil egrave eacute ecirc euml 
                           igrave iacute icirc iuml eth ntilde ograve 
                           oacute ocirc otilde ouml divide oslash ugrave 
                           uacute ucirc uuml yacute thorn yuml);
   $upperentities[12] = '#173';

   $self->{'hashentity'} = {};
   for ( my $i=0; $i<=$#upperentities; $i++ )
   {
      my $key = '&'.$upperentities[$i].';';
      $self->{'hashentity'}->{$key}=$i+160;
   }

   $self->{'hashstr'} = (join (';|', @upperentities)).';';

   bless $self, $classname;
   return $self;
}


# clean XML version one - for paragraphs
sub pclean
{
   my ($self, $t) = @_;
   return undef if (! defined $t);
   # make ISOlat1 entities into Unicode character entities
   $t =~ s/&($self->{'hashstr'})/sprintf ("&#x%04X;", $self->{'hashentity'}->{$&})/geo;
   # escape non-XML-encoded ampersands (including from other characters sets)
   $t =~ s/&(?!((#[0-9]*)|(#x[0-9]*)|(amp)|(lt)|(gt)|(apos)|(quot));)/&amp;/go;
   # convert extended ascii into Unicode character entities
   $t =~ s/[\xa0-\xff]/'&#'.ord ($&).';'/geo;
   # remove extended ascii that doesnt translate into ISO8859/1
   $t =~ s/[\x00-\x08\x0B\x0C\x0E-\x1f\x80-\x9f]//go;
   # make tags delimiters into entities
   $t =~ s/</&lt;/go;
   $t =~ s/>/&gt;/go;
   # convert any whitespace containing lf or cr into a single cr
   $t =~ s/(\s*[\r\n]\s+)|(\s+[\r\n]\s*)/\n/go;
   # convert multiples spaces/tabs into a single space
   $t =~ s/[ \t]+/ /go;
   # kill leading and terminating spaces
   $t =~ s/^[ ]+(.+)[ ]+$/$1/;
   return $t;
}


# clean XML version two - for single-line streams
sub lclean
{
   my ($self, $t) = @_;
   return undef if (! defined $t );
   # make ISOlat1 entities into Unicode character entities
   $t =~ s/&($self->{'hashstr'})/sprintf ("&#x%04X;", $self->{'hashentity'}->{$&})/geo;
   # escape non-XML-encoded ampersands (including from other characters sets)
   $t =~ s/&(?!((#[0-9]*)|(#x[0-9]*)|(amp)|(lt)|(gt)|(apos)|(quot));)/&amp;/go;
   # convert extended ascii into Unicode character entities
   $t =~ s/[\xa0-\xff]/'&#'.ord ($&).';'/geo;
   # remove extended ascii that doesnt translate into ISO8859/1
   $t =~ s/[\x00-\x08\x0B\x0C\x0E-\x1f\x80-\x9f]//go;
   # make tags delimiters into entities
   $t =~ s/</&lt;/go;
   $t =~ s/>/&gt;/go;
   # flatten whitespace
   $t =~ s/[\s\t\r\n]+/ /go;
   # kill leading and terminating spaces
   $t =~ s/^[ ]+(.+)[ ]+$/$1/;
   return $t;
}


# remove newlines and carriage returns
sub straighten
{
   my ($self, $t) = @_;
   # eliminate all carriage returns and linefeeds
   $t =~ s/[\t\r\s\n]+/ /go;
   return $t;
}


# convert a data structure in Perl to XML
#  format of $head:
#  {
#    tag1 => [
#              [ 
#                { attr1 => val1, attr2 => val2, ... },
#                { children }
#              ],
#              [
#                { attr1 => val1, attr2 => val2, ... },
#                "text string"
#              ],
#              { children },
#              "text string"
#            ],
#    tag2 => { children },
#    tag3 => "text string",
#    mdorder => [ "tag1", "tag2", "tag3" ]
#  }
#
sub FormatXML
{
   my ($self, $head, $indent) = @_;
   $indent .= $self->{'XMLindent'};
   my ($key, $i, $j, $buffer, @orderedkeys);
   $buffer = '';
   if (exists ($head->{'mdorder'}))
   { @orderedkeys = @{$head->{'mdorder'}}; }
   else
   { @orderedkeys = keys %$head; }
   foreach $key (@orderedkeys)
   {
      if ((exists ($head->{$key})) && (ref ($head->{$key}) eq 'ARRAY'))
      {
         foreach $i (@{$head->{$key}})
         {
            if (ref ($i) eq 'ARRAY')
            {
               my $atthash = $$i[0];
               my $childhash = $$i[1];

               $buffer .= "$indent<$key";
               foreach $j (keys %$atthash)
               {
                  $buffer .= " $j=\"$atthash->{$j}\"";
               }
               $buffer .= ">\n";

               if (ref ($childhash) eq 'HASH')
               {
                  $buffer .= $self->FormatXML ($childhash, $indent);
               }
               else
               {
                  $buffer .= "$indent$childhash\n";
               }

               $buffer .= "$indent</$key>\n";
            }
            elsif (ref ($i) eq 'HASH')
            {
               my $nestedbuffer = $self->FormatXML ($i, $indent);
               if ($nestedbuffer ne '')
               {
                  $buffer .= "$indent<$key>\n$nestedbuffer$indent</$key>\n";
               }
            }
            else
            {
               $buffer .= "$indent<$key>$i</$key>\n";
            }
         }
      }
      elsif ((exists ($head->{$key})) && (ref ($head->{$key}) eq 'HASH'))
      {
         my $nestedbuffer = $self->FormatXML ($head->{$key}, $indent);
         if ($nestedbuffer ne '')
         {
            $buffer .= "$indent<$key>\n$nestedbuffer$indent</$key>\n";
         }
      }
      elsif ((exists ($head->{$key})) && ($head->{$key} ne ''))
      {
         $buffer .= "$indent<$key>$head->{$key}</$key>\n";
      }
   }
   $buffer;
}


1;
