package Koha::Auth::Token;

use Moose;
use MongoDB;
use File::Basename;
use XML::Simple;
use Data::Dumper;
use C4::Context;
use Session::Token;


sub new {
    my $class = shift;
    return $class->SUPER::new();
}

sub setToken {
	my $self = shift;
	my ($resultSet, $tokenColumn, $params) = @_;

	return if $self->getToken($resultSet, $params);
	Koha::Exception::BadParameter->throw(error => "missing token's column name") unless $tokenColumn;


	if (defined $params && ref($params) eq 'HASH') {
		$params->{$tokenColumn} = $self->create();
		$resultSet->create($params);
	} else {
		Koha::Exception::BadParameter->throw(error => "$params are not in hashref format");
	}

}

sub getToken {
	my $self = shift;
	my ($resultSet, $params) = @_;
	my $result;
	if (defined $params && ref($params) eq 'HASH') {
		$result = $resultSet->find($params);
	} else {
		Koha::Exception::BadParameter->throw(error => "$params are not in hashref format");
	}

	return $result;
}

sub create {
	my $self = shift;
    my $token = Session::Token->new(entropy => 256)->get;
    return $token;
}


sub delete {
	my $self = shift;
	my ($resultSet, $params) = @_;
	my $result = $resultSet->find($params);
	$result->delete();
}

1;