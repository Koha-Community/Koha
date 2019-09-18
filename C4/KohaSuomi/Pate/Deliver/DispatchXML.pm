#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use Encode;
use XML::Simple;
use HTML::Template;

sub GetDispatcherConfig {
    my %hash = @_;
    my %config;
    $config{'contact'}      = C4::Context->config('ksmessaging')->{"$hash{'interface'}"}->{'branches'}->{"$hash{'branchconfig'}"}->{'contact'};
    $config{'customerId'}   = C4::Context->config('ksmessaging')->{"$hash{'interface'}"}->{'branches'}->{"$hash{'branchconfig'}"}->{'ipostpdf'}->{'customerid'};
    $config{'customerPass'} = C4::Context->config('ksmessaging')->{"$hash{'interface'}"}->{'branches'}->{"$hash{'branchconfig'}"}->{'ipostpdf'}->{'customerpass'};
    $config{'ovtId'}        = C4::Context->config('ksmessaging')->{"$hash{'interface'}"}->{'branches'}->{"$hash{'branchconfig'}"}->{'ipostpdf'}->{'ovtid'};
    $config{'senderId'}     = C4::Context->config('ksmessaging')->{"$hash{'interface'}"}->{'branches'}->{"$hash{'branchconfig'}"}->{'ipostpdf'}->{'senderid'};
    return %config;
}

sub DispatchXML {
    my %hash = @_;
    my %sender = GetDispatcherConfig( 'interface' => $hash{'interface'}, 'branchconfig' => $hash{'branchconfig'} );
    my $borrower = GetMember( borrowernumber => $hash{'borrowernumber'} );

    my $templateDir = C4::Context->config( 'intranetdir' ) . '/C4/KohaSuomi/Pate/Templates/';
    my $xmlTemplate = HTML::Template->new( filename => $templateDir . 'DispatchXML.tmpl' );

       $xmlTemplate->param( SENDERID     => $sender{'senderId'} );
       $xmlTemplate->param( CONTACT      => $sender{'contact'} );
       $xmlTemplate->param( CUSTOMERID   => $sender{'customerId'} );
       $xmlTemplate->param( CUSTOMERPASS => $sender{'customerPass'} );
       $xmlTemplate->param( OVTID        => $sender{'ovtId'} );

       $xmlTemplate->param( SSN          => XML::Simple->new()->escape_value( $hash{'SSN'} ) );
       $xmlTemplate->param( NAME         => XML::Simple->new()->escape_value( @$borrower{'firstname'} ) );
       $xmlTemplate->param( SURNAME      => XML::Simple->new()->escape_value( @$borrower{'surname'} ) );
       $xmlTemplate->param( ADDRESS1     => XML::Simple->new()->escape_value( @$borrower{'address'} ) );
       $xmlTemplate->param( ZIPCODE      => XML::Simple->new()->escape_value( @$borrower{'zipcode'} ) );
       $xmlTemplate->param( CITY         => XML::Simple->new()->escape_value( @$borrower{'city'} ) );

       $xmlTemplate->param( LETTERID     => $hash{'letterid'} );
       $xmlTemplate->param( SUBJECT      => $hash{'subject'} );
       $xmlTemplate->param( TOTALPAGES   => $hash{'totalpages'} );

       $xmlTemplate->param( EXFILENAME   => $hash{'filename'});

    return $xmlTemplate->output;
}

1;
