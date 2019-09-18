#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use DateTime;
use C4::Context;
use XML::Simple;
use HTML::Template;
use MIME::Base64;

use C4::Members qw(GetMember);

use C4::KohaSuomi::SSN::Access;
use C4::KohaSuomi::Pate::Format::PDF;

sub FormatDescription {
    my $description =  shift;
       $description =~ s/\r\n/\n/g;
       $description =~ s/</&lt;/g;
       $description =~ s/>/&gt;/g;

    return $description;
}

sub SOAPEnvelope {
    my %hash = @_;

    my $templateDir = C4::Context->config( 'intranetdir' ) . '/C4/KohaSuomi/Pate/Templates/';
    my $xmlTemplate = HTML::Template->new( filename => $templateDir . 'SOAPEnvelope.tmpl' );

    my $borrower = GetMember ( borrowernumber => $hash{'borrowernumber'} );
    my $id = GetSSNByBorrowerNumber ( $hash{'borrowernumber'} );

    return undef unless $id;

    my $base64data = encode_base64 ( toPDF ( %hash ) );
    my $description = FormatDescription ( $hash{'content'} );

    my $issue_id = $hash{'branchcode'} . '/' . $hash{'message_id'};
    my $filename = $hash{'branchcode'} . '_' . $hash{'message_id'} . '.pdf';

    $xmlTemplate->param( SANOMAVERSIO       => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'sanomaversio'} );
    $xmlTemplate->param( VARMENNENIMI       => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'varmennenimi'} );

    $xmlTemplate->param( VIRANOMAISTUNNUS   => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'viranomaistunnus'} );
    $xmlTemplate->param( PALVELUTUNNUS      => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'palvelutunnus'} );
    $xmlTemplate->param( KAYTTAJATUNNUS     => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'kayttajatunnus'} );

    $xmlTemplate->param( YHTEYSNIMI         => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'yhteyshenkilo'}->{'nimi'} );
    $xmlTemplate->param( YHTEYSEMAIL        => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'yhteyshenkilo'}->{'email'} );
    $xmlTemplate->param( YHTEYSPUHELIN      => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'yhteyshenkilo'}->{'puhelin'} );

    $xmlTemplate->param( VONIMI             => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'osoite'}->{'nimi'} );
    $xmlTemplate->param( VOOSOITE           => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'osoite'}->{'lahiosoite'} );
    $xmlTemplate->param( VOPOSTINUMERO      => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'osoite'}->{'postinumero'} );
    $xmlTemplate->param( VOPOSTITOIMIPAIKKA => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'osoite'}->{'postitoimipaikka'} );
    $xmlTemplate->param( VOMAA              => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'viranomainen'}->{'osoite'}->{'maa'} );

    $xmlTemplate->param( TOIMITTAJA         => C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'tulostus'}->{'toimittaja'} );

    $xmlTemplate->param( LAHETYSPVM         => DateTime->now );

    $xmlTemplate->param( OTSIKKO            => $hash{'subject'}); # Suomi.fi "nimeke" = otsikko
    $xmlTemplate->param( SANOMATUNNISTE     => $hash{'message_id'});
    $xmlTemplate->param( VIRANOMAISTUNNISTE => $hash{'issue_id'});

    $xmlTemplate->param( ASNIMI             => @$borrower{'firstname'} . ' ' . @$borrower{'surname'} );
    $xmlTemplate->param( ASOSOITE           => @$borrower{'address'} );
    $xmlTemplate->param( ASPOSTINUMERO      => @$borrower{'zipcode'} );
    $xmlTemplate->param( ASPOSTITOIMIPAIKKA => @$borrower{'city'} );
    $xmlTemplate->param( ASMAA              => @$borrower{'country'} );

    $xmlTemplate->param( ASID               => $id );
    $xmlTemplate->param( ASID_TYYPPI        => 'SSN' ); # CRN for companies, but not supported atm

    $xmlTemplate->param( TIEDOSTONIMI       => $filename );
    $xmlTemplate->param( BASE64DATA         => $base64data );
    $xmlTemplate->param( KUVAUSTEKSTI       => $description );

    return $xmlTemplate->output;
}
1;
