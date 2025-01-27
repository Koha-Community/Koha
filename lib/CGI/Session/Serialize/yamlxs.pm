package CGI::Session::Serialize::yamlxs;

use strict;
use warnings;

use CGI::Session::ErrorHandler;
use YAML::XS;

$CGI::Session::Serialize::yamlxs::VERSION = '0.1';
@CGI::Session::Serialize::yamlxs::ISA     = ("CGI::Session::ErrorHandler");

sub freeze {
    my ( $self, $data ) = @_;
    return YAML::XS::Dump($data);
}

sub thaw {
    my ( $self, $string ) = @_;
    return ( YAML::XS::Load($string) )[0];
}

1;
