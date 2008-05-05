#!/usr/bin/perl

# script to shift marc to biblioitems
# scraped from updatedatabase for dev week by chris@katipo.co.nz
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../../kohalib.pl" };
}
use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::XML ( BinaryEncoding => 'utf8' );

print "moving MARC record to biblioitems table\n";

my $dbh = C4::Context->dbh();

#
# moving MARC data from marc_subfield_table to biblioitems.marc
#

# changing marc field type
$dbh->do('ALTER TABLE `biblioitems` CHANGE `marc` `marc` LONGBLOB NULL DEFAULT NULL ');
# adding marc xml, just for convenience
$dbh->do('ALTER TABLE `biblioitems` ADD `marcxml` LONGTEXT CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ');
# moving data from marc_subfield_value to biblio
$sth = $dbh->prepare('select bibid,biblionumber from marc_biblio');
$sth->execute;
my $sth_update = $dbh->prepare('update biblioitems set marc=?, marcxml=? where biblionumber=?');
my $totaldone=0;

$|=1;

while (my ($bibid,$biblionumber) = $sth->fetchrow) {
    my $record = LocalMARCgetbiblio($dbh,$bibid);
    #Force UTF-8 in record leader
    $record->encoding('UTF-8');
    my $marcflavour;
    if (C4::Context->preference("marcflavour")=~/unimarc/i){
      $marcflavour="UNIMARC";
    } else {
     $marcflavour="USMARC";
    }
    $sth_update->execute($record->as_usmarc(),$record->as_xml_record($marcflavour),$biblionumber);
    $totaldone++;
    print ".";
    print "\r$totaldone / $totaltodo" unless ($totaldone % 100);
}
print "\rdone\n";


#
# this sub is a copy of Biblio.pm, version 2.2.4
# It is useful only once, for moving from 2.2 to 3.0
# the MARCgetbiblio in Biblio.pm
# is still here, but uses other tables
# (the ones that are filled by updatedatabase !)
#

sub LocalMARCgetbiblio {

    # Returns MARC::Record of the biblio passed in parameter.
    my ( $dbh, $bibid ) = @_;
    my $record = MARC::Record->new();
#    warn "". $bidid;

    my $sth =
      $dbh->prepare(
"select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink
                  from marc_subfield_table
                  where bibid=? order by tag,tagorder,subfieldorder
              "
    );
    my $sth2 =
      $dbh->prepare(
        "select subfieldvalue from marc_blob_subfield where blobidlink=?");
    $sth->execute($bibid);
    my $prevtagorder = 1;
    my $prevtag      = 'XXX';
    my $previndicator;
    my $field;        # for >=10 tags
    my $prevvalue;    # for <10 tags
    while ( my $row = $sth->fetchrow_hashref ) {

        if ( $row->{'valuebloblink'} ) {    #---- search blob if there is one
            $sth2->execute( $row->{'valuebloblink'} );
            my $row2 = $sth2->fetchrow_hashref;
            $sth2->finish;
            $row->{'subfieldvalue'} = $row2->{'subfieldvalue'};
        }
        if ( $row->{tagorder} ne $prevtagorder || $row->{tag} ne $prevtag ) {
            $previndicator .= "  ";
            if ( $prevtag < 10 ) {
                if ($prevtag ne '000') {
                    $record->add_fields( ( sprintf "%03s", $prevtag ), $prevvalue ) unless $prevtag eq "XXX";    # ignore the 1st loop
                } else {
                    $record->leader(sprintf("%24s",$prevvalue));
                }
            }
            else {
                $record->add_fields($field) unless $prevtag eq "XXX";
            }
            undef $field;
            $prevtagorder  = $row->{tagorder};
            $prevtag       = $row->{tag};
            $previndicator = $row->{tag_indicator};
            if ( $row->{tag} < 10 ) {
                $prevvalue = $row->{subfieldvalue};
            }
            else {
                $field = MARC::Field->new(
                    ( sprintf "%03s", $prevtag ),
                    substr( $row->{tag_indicator} . '  ', 0, 1 ),
                    substr( $row->{tag_indicator} . '  ', 1, 1 ),
                    $row->{'subfieldcode'},
                    $row->{'subfieldvalue'}
                );
            }
        }
        else {
            if ( $row->{tag} < 10 ) {
                $record->add_fields( ( sprintf "%03s", $row->{tag} ),
                    $row->{'subfieldvalue'} );
            }
            else {
                $field->add_subfields( $row->{'subfieldcode'},
                    $row->{'subfieldvalue'} );
            }
            $prevtag       = $row->{tag};
            $previndicator = $row->{tag_indicator};
        }
    }

    # the last has not been included inside the loop... do it now !
    if ( $prevtag ne "XXX" )
    { # check that we have found something. Otherwise, prevtag is still XXX and we
         # must return an empty record, not make MARC::Record fail because we try to
         # create a record with XXX as field :-(
        if ( $prevtag < 10 ) {
            $record->add_fields( $prevtag, $prevvalue );
        }
        else {

            #          my $field = MARC::Field->new( $prevtag, "", "", %subfieldlist);
            $record->add_fields($field);
        }
    }
    if (C4::Context->preference('marcflavour')=~/unimarc/i){
      $record->leader('     nac  22     1u 4500');
      $update=1;
      my $string;
      if ($record->field(100)) {
        $string = substr($record->subfield(100,"a")."                                   ",0,35);
        my $f100 = $record->field(100);
        $record->delete_field($f100);
      } else {
        $string = POSIX::strftime("%Y%m%d", localtime);
        $string=~s/\-//g;
        $string = sprintf("%-*s",35, $string);
      }
      substr($string,22,6,"frey50");
      unless ($record->subfield(100,"a")){
        $record->insert_fields_ordered(MARC::Field->new(100,"","","a"=>"$string"));
      }
    }

    return $record;
}
