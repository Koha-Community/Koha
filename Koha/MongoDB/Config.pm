package Koha::MongoDB::Config;

use Moose;
use MongoDB;
use File::Basename;
use XML::Simple;
use Data::Dumper;
use C4::Context;

my $singleton;
my $configFile = "mongodb-config.xml";
my $settings;

sub new {
    my $class = shift;
    $singleton ||= bless {}, $class;
}

sub mongoClient {
    my $self = shift;
    $settings = $self->getSettings();

    my $connection = MongoDB::MongoClient->new(
        host => $settings->{host},
        username => $settings->{username},
        password => $settings->{password},
        db_name => $settings->{database}
    );

    return $connection;
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

sub getSettings{
    my $self = shift;
    if(!$settings){
        my $confs = $self->loadConfigXml();
        if($confs){
            $settings = $confs;
        }
    }

    return $settings;
}

1;