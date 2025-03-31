#!/usr/bin/perl
use Modern::Perl;

use C4::Record;
use C4::Auth qw( get_template_and_user );
use C4::Output;
use CGI     qw ( -utf8 );
use C4::Ris qw( marc2ris );

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "tools/export.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

my $op     = $query->param("op");
my $format = $query->param("format");
my $error  = '';
if ( $op eq "export" ) {
    my $biblionumber = $query->param("bib");
    if ($biblionumber) {
        my $file_id  = $biblionumber;
        my $file_pre = "bib-";

        my $biblio = Koha::Biblios->find($biblionumber);
        my $marc   = $biblio->metadata_record( { embed_items => 1 } );

        my $metadata_extractor = $biblio->metadata_extractor;

        if ( C4::Context->preference('DefaultSaveRecordFileID') eq 'controlnumber' ) {
            my $control_num = $metadata_extractor->get_control_number();
            if ($control_num) {
                $file_id  = $control_num;
                $file_pre = "record-";
            }
        }

        if ( $format =~ /endnote/ ) {
            $marc   = marc2endnote($marc);
            $format = 'endnote';
        } elsif ( $format =~ /marcxml/ ) {
            $marc   = marc2marcxml($marc);
            $format = "marcxml";
        } elsif ( $format =~ /mods/ ) {
            $marc   = marc2modsxml($marc);
            $format = "mods";
        } elsif ( $format =~ /ris/ ) {
            $marc   = marc2ris($marc);
            $format = "ris";
        } elsif ( $format =~ /bibtex/ ) {
            $marc   = marc2bibtex($marc);
            $format = "bibtex";
        } elsif ( $format =~ /dc$/ ) {
            $marc   = marc2dcxml( undef, undef, $biblionumber, $format );
            $format = "dublin-core.xml";
        } elsif ( $format =~ /marc8/ ) {
            $marc   = changeEncoding( $marc, "MARC", "MARC21", "MARC-8" );
            $marc   = $marc->as_usmarc();
            $format = "marc8";
        } elsif ( $format =~ /utf8/ ) {
            C4::Charset::SetUTF8Flag( $marc, 1 );
            $marc   = $marc->as_usmarc();
            $format = "utf8";
        } elsif ( $format =~ /marcstd/ ) {
            C4::Charset::SetUTF8Flag( $marc, 1 );
            ( $error, $marc ) = marc2marc( $marc, 'marcstd', C4::Context->preference('marcflavour') );
            $format = "marcstd";
        }
        if ( $format ne 'marc8' ) {
            binmode STDOUT, ':encoding(UTF-8)';
        }
        print $query->header(
            -type       => 'application/octet-stream',
            -attachment => "$file_pre$file_id.$format"
        );
        print $marc;
    }
}
