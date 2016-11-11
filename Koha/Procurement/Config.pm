#!/usr/bin/perl
package Koha::Procurement::Config;

use XML::Simple;
use File::Basename;
use Data::Dumper;
use C4::Context;

my $singleton;
my $configFile = "procurement-config.xml";
my $settings;

sub new {
    my $class = shift;
    $singleton ||= bless {}, $class;
}

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
    my $procurementConfigPath = $path . $configFile; # use the same path as koha_config.xml file
    return $procurementConfigPath;
}

sub getLogDir {
    my $self = shift;
    my $config = C4::Context->config('logdir') . "/editx";
    return $config;
}

sub getSettings{
    my $self = shift;
    if(!$settings){
        my $confs = $self->loadConfigXml();
        if($confs){
            $confs->{'settings'}->{'log_directory'} = $self->getLogDir();
            $settings = $confs;
        }
    }

    return $settings;
}

sub getUseAutomatchBiblios {
    my $self = shift;
    $settings = $self->getSettings();
    my $result = 'yes';
    if(defined $settings->{'settings'}->{'automatch_biblios'}){
        $result = $settings->{'settings'}->{'automatch_biblios'};
    }
    return $result;
}

1;
