package Koha::Email;

# Copyright 2014 Catalyst
#           2020 Theke Solutions
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

use Modern::Perl;

use Email::Address;
use Email::MessageID;
use Email::MIME;
use List::Util   qw( pairs );
use Scalar::Util qw( blessed );

use Koha::Exceptions;

use C4::Context;

use base qw( Email::Stuffer );

=head1 NAME

Koha::Email - A wrapper around Email::Stuffer

=head1 API

=head2 Class methods

=head3 new_from_string

    my $email = Koha::Email->new_from_string( $email_string );

Constructor for the Koha::Email class. The I<$email_string> (mandatory)
parameter will be parsed with I<Email::MIME>.

Note: I<$email_string> can be the produced by the I<as_string> method from
B<Koha::Email> or B<Email::MIME>.

=cut

sub new_from_string {
    my ( $class, $email_string ) = @_;

    Koha::Exceptions::MissingParameter->throw("Mandatory string parameter missing.")
        unless $email_string;

    my $self = $class->SUPER::new();
    my $mime = Email::MIME->new($email_string);
    $self->{email} = $mime;

    return $self;
}

=head3 create

    my $email = Koha::Email->create(
        {
          [ text_body   => $text_message,
            html_body   => $html_message,
            body_params => $body_params ]
            from        => $from,
            to          => $to,
            cc          => $cc,
            bcc         => $bcc,
            reply_to    => $reply_to,
            sender      => $sender,
            subject     => $subject,
        }
    );

This method creates a new Email::Stuffer object taking Koha specific configurations
into account.

The encoding defaults to utf-8. It can be set as part of the body_params hashref. See
I<Email::Stuffer> and I<Email::MIME> for more details on the available options.

Parameters:
 - I<from> defaults to the value of the I<KohaAdminEmailAddress> system preference
 - The I<SendAllEmailsTo> system preference overloads the I<to>, I<cc> and I<bcc> parameters
 - I<reply_to> defaults to the value of the I<ReplytoDefault> system preference
 - I<sender> defaults to the value of the I<ReturnpathDefault> system preference

Both I<text_body> and I<html_body> can be set later. I<body_params> will be passed if present
to the constructor.

=cut

sub create {
    my ( $self, $params ) = @_;

    my $args = {};
    $args->{from} = $params->{from} || C4::Context->preference('KohaAdminEmailAddress');
    Koha::Exceptions::BadParameter->throw(
        error     => "Invalid 'from' parameter: " . $args->{from},
        parameter => 'from'
    ) unless Koha::Email->is_valid( $args->{from} );    # from is mandatory

    $args->{subject} = $params->{subject} // '';

    if ( C4::Context->preference('SendAllEmailsTo') ) {
        $args->{to} = C4::Context->preference('SendAllEmailsTo');
    } else {
        $args->{to} = $params->{to};
    }

    Koha::Exceptions::BadParameter->throw(
        error     => "Invalid 'to' parameter: " . $args->{to},
        parameter => 'to'
    ) unless Koha::Email->is_valid( $args->{to} );

    my $addresses = {};
    $addresses->{reply_to} = $params->{reply_to};
    $addresses->{reply_to} ||= C4::Context->preference('ReplytoDefault')
        if C4::Context->preference('ReplytoDefault');

    $addresses->{sender} = $params->{sender};
    $addresses->{sender} ||= C4::Context->preference('ReturnpathDefault')
        if C4::Context->preference('ReturnpathDefault');

    unless ( C4::Context->preference('SendAllEmailsTo') ) {
        $addresses->{cc} = $params->{cc}
            if exists $params->{cc};
        $addresses->{bcc} = $params->{bcc}
            if exists $params->{bcc};
    }

    foreach my $address ( keys %{$addresses} ) {
        Koha::Exceptions::BadParameter->throw(
            error     => "Invalid '$address' parameter: " . $addresses->{$address},
            parameter => $address
            )
            if $addresses->{$address}
            and !Koha::Email->is_valid( $addresses->{$address} );
    }

    $args->{cc} = $addresses->{cc}
        if $addresses->{cc};
    $args->{bcc} = $addresses->{bcc}
        if $addresses->{bcc};

    my $email;

    # FIXME: This is ugly, but aids backportability
    # TODO: Remove this and move address and default headers handling
    #       to separate subs to be (re)used
    if ( blessed($self) ) {
        $email = $self;
        $email->to( $args->{to} )             if $args->{to};
        $email->from( $args->{from} )         if $args->{from};
        $email->cc( $args->{cc} )             if $args->{cc};
        $email->bcc( $args->{bcc} )           if $args->{bcc};
        $email->reply_to( $args->{reply_to} ) if $args->{reply_to};
        $email->subject( $args->{subject} )   if $args->{subject};
    } else {
        $email = $self->SUPER::new($args);
    }

    $email->header( 'Reply-To', $addresses->{reply_to} )
        if $addresses->{reply_to};

    $email->header( 'Sender'       => $addresses->{sender} )   if $addresses->{sender};
    $email->header( 'Content-Type' => $params->{contenttype} ) if $params->{contenttype};
    $email->header( 'X-Mailer'     => "Koha" );
    $email->header( 'Message-ID'   => Email::MessageID->new->in_brackets );

    # Add Koha message headers to aid later message identification
    $email->header( 'X-Koha-Template-ID' => $params->{template_id} ) if $params->{template_id};
    $email->header( 'X-Koha-Message-ID'  => $params->{message_id} )  if $params->{message_id};

    if ( $params->{text_body} ) {
        $email->text_body( $params->{text_body}, %{ $params->{body_params} } );
    } elsif ( $params->{html_body} ) {
        $email->html_body( $params->{html_body}, %{ $params->{body_params} } );
    }

    return $email;
}

=head3 send_or_die

    $email->send_or_die({ transport => $transport [, $args] });

Overloaded Email::Stuffer I<send_or_die> method, that takes care of Bcc and Return-path
handling.

Bcc is removed from the message headers, and included in the recipients list to be
passed to I<send_or_die>.

Return-path, 'MAIL FROM', is set to the 'Sender' email header unless an explicit 'from'
parameter is passed to send_or_die.  'Return-path' headers are actually set by the MTA,
usually using the 'MAIL FROM' information set at mail server connection time.

=cut

sub send_or_die {
    my ( $self, $args ) = @_;

    unless ( $args->{to} ) {    # don't do it if passed an explicit 'to' param

        my @recipients;

        my @headers = $self->email->header_str_pairs;
        foreach my $pair ( pairs @headers ) {
            my ( $header, $value ) = @$pair;
            push @recipients, split( ', ', $value )
                if grep { $_ eq $header } ( 'To', 'Cc', 'Bcc' );
        }

        # Remove the Bcc header
        $self->email->header_str_set('Bcc');

        # Tweak $args
        $args->{to} = \@recipients;
    }

    unless ( $args->{from} ) {    # don't do it if passed an explicit 'from' param
        $args->{from} = $self->email->header_str('Sender');
        $self->email->header_str_set('Sender');    # remove Sender header
    }

    $self->SUPER::send_or_die($args);
}

=head3 is_valid

    my $is_valid = Koha::Email->is_valid($email_address);

Return true is the email address passed in parameter is valid following RFC 2822.

=cut

sub is_valid {
    my ( $class, $email ) = @_;
    my @addrs = Email::Address->parse($email);
    return @addrs ? 1 : 0;
}

1;
