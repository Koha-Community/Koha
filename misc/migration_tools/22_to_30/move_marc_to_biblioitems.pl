#!/usr/bin/perl

# script to shift marc to biblioitems
# scraped from updatedatabase for dev week by chris@katipo.co.nz

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
$dbh->do('ALTER TABLE `biblioitems` CHANGE `marc` `marc` BLOB NULL DEFAULT NULL ');
# adding marc xml, just for convenience
$dbh->do('ALTER TABLE `biblioitems` ADD `marcxml` LONGTEXT CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ');
# moving data from marc_subfield_value to biblio
$sth = $dbh->prepare('select bibid,biblionumber from marc_biblio');
$sth->execute;
my $sth_update = $dbh->prepare('update biblioitems set marc=?, marcxml=? where biblionumber=?');
my $totaldone=0;

$|=1;

while (my ($bibid,$biblionumber) = $sth->fetchrow) {
    my $record = MARCgetbiblio($dbh,$bibid);
    #Force UTF-8 in record leader
    $record->encoding('UTF-8');
    $sth_update->execute($record->as_usmarc(),$record->as_xml_record(),$biblionumber);
    $totaldone++;
    print ".";
    print "\r$totaldone / $totaltodo" unless ($totaldone % 100);
}
print "\rdone\n";


#
# those 2 subs are a copy of Biblio.pm, version 2.2.4
# they are useful only once, for moving from 2.2 to 3.0
# the MARCgetbiblio & MARCgetitem subs in Biblio.pm
# are still here, but uses other tables
# (the ones that are filled by updatedatabase !)
#

sub MARCgetbiblio {

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
    return $record;
}

sub MARCgetitem {

    # Returns MARC::Record of the biblio passed in parameter.
    my ( $dbh, $bibid, $itemnumber ) = @_;
    my $record = MARC::Record->new();

    # search MARC tagorder
    my $sth2 =
      $dbh->prepare(
"select tagorder from marc_subfield_table,marc_subfield_structure where marc_subfield_table.tag=marc_subfield_structure.tagfield and marc_subfield_table.subfieldcode=marc_subfield_structure.tagsubfield and bibid=? and kohafield='items.itemnumber' and subfieldvalue=?"
    );
    $sth2->execute( $bibid, $itemnumber );
    my ($tagorder) = $sth2->fetchrow_array();

    #---- TODO : the leader is missing
    my $sth =
      $dbh->prepare(
"select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink
                  from marc_subfield_table
                  where bibid=? and tagorder=? order by subfieldcode,subfieldorder
              "
    );
    $sth2 =
      $dbh->prepare(
        "select subfieldvalue from marc_blob_subfield where blobidlink=?");
    $sth->execute( $bibid, $tagorder );
    while ( my $row = $sth->fetchrow_hashref ) {
        if ( $row->{'valuebloblink'} ) {    #---- search blob if there is one
            $sth2->execute( $row->{'valuebloblink'} );
            my $row2 = $sth2->fetchrow_hashref;
            $sth2->finish;
            $row->{'subfieldvalue'} = $row2->{'subfieldvalue'};
        }
        if ( $record->field( $row->{'tag'} ) ) {
            my $field;

#--- this test must stay as this, because of strange behaviour of mySQL/Perl DBI with char var containing a number...
            #--- sometimes, eliminates 0 at beginning, sometimes no ;-\\\
            if ( length( $row->{'tag'} ) < 3 ) {
                $row->{'tag'} = "0" . $row->{'tag'};
            }
            $field = $record->field( $row->{'tag'} );
            if ($field) {
                my $x =
                  $field->add_subfields( $row->{'subfieldcode'},
                    $row->{'subfieldvalue'} );
                $record->delete_field($field);
                $record->add_fields($field);
            }
        }
        else {
            if ( length( $row->{'tag'} ) < 3 ) {
                $row->{'tag'} = "0" . $row->{'tag'};
            }
            my $temp =
              MARC::Field->new( $row->{'tag'}, " ", " ",
                $row->{'subfieldcode'} => $row->{'subfieldvalue'} );
            $record->add_fields($temp);
        }

    }
    return $record;
}
