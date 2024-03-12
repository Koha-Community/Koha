package Koha::Token;

# Created as wrapper for CSRF and JWT tokens, but designed for more general use

# Copyright 2016 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

Koha::Token - Tokenizer

=head1 SYNOPSIS

    use Koha::Token;
    my $tokenizer = Koha::Token->new;
    my $token = $tokenizer->generate({ length => 20 });

    # safely generate a CSRF token (nonblocking)
    my $csrf_token = $tokenizer->generate({
        type => 'CSRF', id => $id, secret => $secret,
    });

    # generate/check CSRF token with defaults and session id
    my $csrf_token = $tokenizer->generate_csrf({ session_id => $x });
    my $result = $tokenizer->check_csrf({
        session_id => $x, token => $token,
    });

=head1 DESCRIPTION

    Designed for providing general tokens.
    Created due to the need for a nonblocking call to Bytes::Random::Secure
    when generating a CSRF token.

=cut

use Modern::Perl;
use Bytes::Random::Secure;
use String::Random;
use WWW::CSRF;
use Mojo::JWT;
use Digest::MD5 qw( md5_base64 );
use Encode;
use C4::Context;
use Koha::Exceptions::Token;
use base qw(Class::Accessor);
use constant HMAC_SHA1_LENGTH => 20;
use constant CSRF_EXPIRY_HOURS => 8; # 8 hours instead of 7 days..
use constant DEFA_SESSION_ID => 0;
use constant DEFA_SESSION_USERID => 'anonymous';

=head1 METHODS

=head2 new

    Create object (via Class::Accessor).

=cut

sub new {
    my ( $class ) = @_;
    return $class->SUPER::new();
}

=head2 generate

    my $token = $tokenizer->generate({ length => 20 });
    my $csrf_token = $tokenizer->generate({
        type => 'CSRF', id => $id, secret => $secret,
    });
    my $jwt = $tokenizer->generate({
        type => 'JWT, id => $id, secret => $secret,
    });

    Generate several types of tokens. Now includes CSRF.
    For non-CSRF tokens an optional pattern parameter overrides length.
    Room for future extension.

    Pattern parameter could be write down using this subset of regular expressions:
    \w    Alphanumeric + "_".
    \d    Digits.
    \W    Printable characters other than those in \w.
    \D    Printable characters other than those in \d.
    .     Printable characters.
    []    Character classes.
    {}    Repetition.
    *     Same as {0,}.
    ?     Same as {0,1}.
    +     Same as {1,}.

=cut

sub generate {
    my ( $self, $params ) = @_;
    if( $params->{type} && $params->{type} eq 'CSRF' ) {
        $self->{lasttoken} = _gen_csrf( $params );
    } elsif( $params->{type} && $params->{type} eq 'JWT' ) {
        $self->{lasttoken} = _gen_jwt( $params );
    } else {
        $self->{lasttoken} = _gen_rand( $params );
    }
    return $self->{lasttoken};
}

=head2 generate_csrf

    Like: generate({ type => 'CSRF', ... })
    Note: id defaults to userid from context, secret to database password.
    session_id is mandatory; it is combined with id.

=cut

sub generate_csrf {
    my ( $self, $params ) = @_;
    return if !$params->{session_id};
    $params = _add_default_csrf_params( $params );
    return $self->generate({ %$params, type => 'CSRF' });
}

=head2 generate_jwt

    Like: generate({ type => 'JWT', ... })
    Note that JWT is designed to encode a structure but here we are actually only allowing a value
    that will be store in the key 'id'.

=cut

sub generate_jwt {
    my ( $self, $params ) = @_;
    return if !$params->{id};
    $params = _add_default_jwt_params( $params );
    return $self->generate({ %$params, type => 'JWT' });
}

=head2 check

    my $result = $tokenizer->check({
        type => 'CSRF', id => $id, token => $token,
    });

    Check several types of tokens. Now includes CSRF.
    Room for future extension.

=cut

sub check {
    my ( $self, $params ) = @_;
    if( $params->{type} && $params->{type} eq 'CSRF' ) {
        return _chk_csrf( $params );
    }
    elsif( $params->{type} && $params->{type} eq 'JWT' ) {
        return _chk_jwt( $params );
    }
    return;
}

=head2 check_csrf

    Like: check({ type => 'CSRF', ... })
    Note: id defaults to userid from context, secret to database password.
    session_id is mandatory; it is combined with id.

=cut

sub check_csrf {
    my ( $self, $params ) = @_;
    return if !$params->{session_id};
    $params = _add_default_csrf_params( $params );
    return $self->check({ %$params, type => 'CSRF' });
}

=head2 check_jwt

    Like: check({ type => 'JWT', id => $id, token => $token })

    Will return true if the token contains the passed id

=cut

sub check_jwt {
    my ( $self, $params ) = @_;
    $params = _add_default_jwt_params( $params );
    return $self->check({ %$params, type => 'JWT' });
}

=head2 decode_jwt

    $tokenizer->decode_jwt({ type => 'JWT', token => $token })

    Will return the value of the id stored in the token.

=cut
sub decode_jwt {
    my ( $self, $params ) = @_;
    $params = _add_default_jwt_params( $params );
    return _decode_jwt( $params );
}

# --- Internal routines ---

sub _add_default_csrf_params {
    my ( $params ) = @_;
    $params->{session_id} //= DEFA_SESSION_ID;
    my $userenv = C4::Context->userenv;
    if ( ( !$userenv ) || !$userenv->{id} ) {
        $userenv = { id => DEFA_SESSION_USERID };
    }
    $params->{id} //= Encode::encode( 'UTF-8', $userenv->{id} );
    $params->{id} .= '_' . $params->{session_id};

    my $pw = C4::Context->config('pass');
    $params->{secret} //= md5_base64( Encode::encode( 'UTF-8', $pw ) ),
    return $params;
}

sub _gen_csrf {

# Since WWW::CSRF::generate_csrf_token does not use the NonBlocking
# parameter of Bytes::Random::Secure, we are passing random bytes from
# a non blocking source to WWW::CSRF via its Random parameter.

    my ( $params ) = @_;
    return if !$params->{id} || !$params->{secret};


    my $randomizer = Bytes::Random::Secure->new( NonBlocking => 1 );
        # this is most fundamental: do not use /dev/random since it is
        # blocking, but use /dev/urandom !
    my $random = $randomizer->bytes( HMAC_SHA1_LENGTH );
    my $token = WWW::CSRF::generate_csrf_token(
        $params->{id}, $params->{secret}, { Random => $random },
    );

    return $token;
}

sub _chk_csrf {
    my ( $params ) = @_;
    return if !$params->{id} || !$params->{secret} || !$params->{token};

    my $csrf_status = WWW::CSRF::check_csrf_token(
        $params->{id},
        $params->{secret},
        $params->{token},
        { MaxAge => $params->{MaxAge} // ( CSRF_EXPIRY_HOURS * 3600 ) },
    );
    return $csrf_status == WWW::CSRF::CSRF_OK();
}

sub _gen_rand {
    my ( $params ) = @_;
    my $length = $params->{length} || 1;
    $length = 1 unless $length > 0;
    my $pattern = $params->{pattern} // '.{'.$length.'}'; # pattern overrides length parameter

    my $token;
    eval {
        $token = String::Random::random_regex( $pattern );
    };
    Koha::Exceptions::Token::BadPattern->throw($@) if $@;
    return $token;
}

sub _add_default_jwt_params {
    my ( $params ) = @_;
    my $pw = C4::Context->config('pass');
    $params->{secret} //= md5_base64( Encode::encode( 'UTF-8', $pw ) ),
    return $params;
}

sub _gen_jwt {
    my ( $params ) = @_;
    return if !$params->{id} || !$params->{secret};

    return Mojo::JWT->new(
        claims => { id => $params->{id} },
        secret => $params->{secret}
    )->encode;
}

sub _chk_jwt {
    my ( $params ) = @_;
    return if !$params->{id} || !$params->{secret} || !$params->{token};

    my $claims = Mojo::JWT->new(secret => $params->{secret})->decode($params->{token});

    return 1 if exists $claims->{id} && $claims->{id} eq $params->{id};
}

sub _decode_jwt {
    my ( $params ) = @_;
    return if !$params->{token} || !$params->{secret};

    my $claims = Mojo::JWT->new(secret => $params->{secret})->decode($params->{token});

    return $claims->{id};
}

=head1 AUTHOR

    Marcel de Rooy, Rijksmuseum Amsterdam, The Netherlands

=cut

1;
