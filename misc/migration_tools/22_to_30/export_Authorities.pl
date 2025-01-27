#!/usr/bin/perl
use Modern::Perl;
use C4::Context;

#use MARC::File::XML(BinaryEncoding=>"utf8");
#use MARC::File::USMARC;
use C4::AuthoritiesMarc;
use POSIX;

#MARC::File::XML::default_record_format("UNIMARCAUTH");
my $dbh = C4::Context->dbh;
my $rq  = $dbh->prepare(
    qq|
  SELECT authid,authtypecode
  FROM auth_header
  |
);
my $filename = shift @ARGV;
$rq->execute;

#ATTENTION : Mettre la base en utf8 auparavant.
#BEWARE : Set database into utf8 before.
#open FILEOUTPUT,">:utf8", "$filename" or die "unable to open $filename";
while ( my ( $authid, $authtypecode ) = $rq->fetchrow ) {
    my $record = AUTHgetauthority( $dbh, $authid );
    if ( !utf8::is_utf8($record) ) {
        utf8::decode($record);
    }

    if ( C4::Context->preference('marcflavour') eq "UNIMARC" ) {
        $record->leader('     nac  22     1u 4500');
        my @time   = localtime(time);
        my $time   = sprintf( '%04d%02d%02d', $time[5] + 1900, $time[4] + 1, $time[3] );
        my $string = ( $time =~ m/([0-9\-]+)/ ) ? $1 : undef;
        $string =~ s/\-//g;
        $string = sprintf( "%-*s", 26, $string );
        substr( $string, 9, 6, "frey50" );
        unless ( $record->subfield( '100', "a" ) ) {
            $record->insert_fields_ordered( MARC::Field->new( '100', "", "", "a" => $string ) );
        }
        if ( $record->field('152') ) {
            if ( $record->subfield( '152', 'b' ) ) {
            } else {
                $record->field('152')->add_subfields( "b" => $authtypecode );
            }
        } else {
            $record->insert_fields_ordered( MARC::Field->new( '152', "", "", "b" => $authtypecode ) );
        }
        unless ( $record->field('001') ) {
            $record->insert_fields_ordered( MARC::Field->new( '001', $authid ) );
        }

        AUTHmodauthority( $dbh, $authid, $record, 1 );
    } else {
        $record->encoding('UTF-8');
    }

    #  warn $record->as_usmarc;
    # warn $record->as_formatted;
    #   warn $record->as_usmarc;

    print $record->as_usmarc();

}
close;
