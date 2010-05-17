#!/usr/bin/perl

# script to shift marc to biblioitems
# scraped from updatedatabase for dev week by chris@katipo.co.nz
use strict;
#use warnings; FIXME - Bug 2505
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../../kohalib.pl" };
}
use C4::Context;
use C4::AuthoritiesMarc;
use MARC::Record;
use MARC::File::XML ( BinaryEncoding => 'utf8' );

print "moving MARC record to marc_header table\n";

my $dbh = C4::Context->dbh();
# changing marc field type
$dbh->do('ALTER TABLE auth_header CHANGE marc marc BLOB NULL DEFAULT NULL ');

# adding marc xml, just for convenience
$dbh->do(
'ALTER TABLE auth_header ADD marcxml LONGTEXT CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL '
);

$|=1; # flushes output

# moving data from marc_subfield_value to biblio
my $sth = $dbh->prepare('select authid,authtypecode from auth_header');
$sth->execute;
my $sth_update =
  $dbh->prepare(
    'update auth_header set marc=?,marcxml=? where authid=?');
my $totaldone = 0;
while ( my ( $authid,$authtypecode ) = $sth->fetchrow ) {
#     my $authtypecode = AUTHfind_authtypecode($dbh,$authid);
    my $record = old_AUTHgetauthority( $dbh, $authid );
    $record->leader('     nac  22     1u 4500');
    my $string;
    $string=~s/\-//g;
    $string = sprintf("%-*s",26, $string);
    substr($string,9,6,"frey50");
    unless ($record->subfield(100,"a") and length($record->subfield(100,"a")) == 26 ){
      $record->insert_fields_ordered(MARC::Field->new(100,"","","a"=>$string));
    }
    if ($record->field(152)){
      if ($record->subfield('152','b')){
      } else {
        $record->field('152')->add_subfields("b"=>$authtypecode);
      }
    } else {
      $record->insert_fields_ordered(MARC::Field->new(152,"","","b"=>$authtypecode));
    }
    unless ($record->field('001')){
      $record->insert_fields_ordered(MARC::Field->new('001',$authid));
    }
																						

    #Force UTF-8 in record leaded
    $record->encoding('UTF-8');
#     warn "REC : ".$record->as_formatted;
    $sth_update->execute( $record->as_usmarc(),$record->as_xml("UNIMARCAUTH"),
        $authid );
    $totaldone++;
    print "\r$totaldone" unless ( $totaldone % 100 );
}
print "\rdone\n";

#
# copying the 2.2 getauthority function, to retrieve authority correctly
# before moving it to marcxml field.
#
sub old_AUTHgetauthority {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$authid)=@_;
    my $record = MARC::Record->new();
#---- TODO : the leader is missing
	$record->leader('                        ');
    my $sth=$dbh->prepare("select authid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue
		 		 from auth_subfield_table
		 		 where authid=? order by tag,tagorder,subfieldorder
		 	 ");
	$sth->execute($authid);
	my $prevtagorder=1;
	my $prevtag='XXX';
	my $previndicator;
	my $field; # for >=10 tags
	my $prevvalue; # for <10 tags
	while (my $row=$sth->fetchrow_hashref) {
		if ($row->{tagorder} ne $prevtagorder || $row->{tag} ne $prevtag) {
			$previndicator.="  ";
			if ($prevtag <10) {
 			$record->add_fields((sprintf "%03s",$prevtag),$prevvalue) unless $prevtag eq "XXX"; # ignore the 1st loop
			} else {
				$record->add_fields($field) unless $prevtag eq "XXX";
			}
			undef $field;
			$prevtagorder=$row->{tagorder};
			$prevtag = $row->{tag};
			$previndicator=$row->{tag_indicator};
			if ($row->{tag}<10) {
				$prevvalue = $row->{subfieldvalue};
			} else {
				$field = MARC::Field->new((sprintf "%03s",$prevtag), substr($row->{tag_indicator}.'  ',0,1), substr($row->{tag_indicator}.'  ',1,1), $row->{'subfieldcode'}, $row->{'subfieldvalue'} );
			}
		} else {
			if ($row->{tag} <10) {
 				$record->add_fields((sprintf "%03s",$row->{tag}), $row->{'subfieldvalue'});
 			} else {
				$field->add_subfields($row->{'subfieldcode'}, $row->{'subfieldvalue'} );
 			}
 			$prevtag= $row->{tag};
			$previndicator=$row->{tag_indicator};
		}
	}
	# the last has not been included inside the loop... do it now !
	if ($prevtag ne "XXX") { # check that we have found something. Otherwise, prevtag is still XXX and we
						# must return an empty record, not make MARC::Record fail because we try to
						# create a record with XXX as field :-(
		if ($prevtag <10) {
			$record->add_fields($prevtag,$prevvalue);
		} else {
	#  		my $field = MARC::Field->new( $prevtag, "", "", %subfieldlist);
			$record->add_fields($field);
		}
	}
	return $record;
}

