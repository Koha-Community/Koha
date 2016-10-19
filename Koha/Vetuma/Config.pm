#!/usr/bin/perl
package Koha::Vetuma::Config;
use Moose;
use C4::Context;
use XML::Simple;
use File::Basename;

my $vetumaConfigFile = "vetuma-config.xml";

sub loadConfigXml{
    my $self = shift;
    my $configs = {};
    my $xmlPath = $self->getConfigXmlPath();

    if( -e $xmlPath ){
        my $simple = XML::Simple->new;
        $configs = $simple->XMLin($xmlPath);
    }
    return $configs;
}

sub getConfigXmlPath{
    my $self = shift;
    my $kohaConfigPath = $ENV{'KOHA_CONF'};
    my $kohaPath = $ENV{KOHA_PATH};
    my($file, $path, $ext) = fileparse($kohaConfigPath);
    my $vetumaConfigPath = $path . '/' . $vetumaConfigFile; # use the same path as koha_config.xml file

    return $vetumaConfigPath;
}

1;
