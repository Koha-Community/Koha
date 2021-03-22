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

use Email::Valid;
use Email::MessageID;
use List::Util qw(pairs);

use Koha::Exceptions;

use C4::Context;

use base qw( Email::Stuffer );

=head1 NAME

Koha::Email - A wrapper around Email::Stuffer

=head1 API

=head2 Class methods

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
    Koha::Exceptions::BadParameter->throw("Invalid 'from' parameter: ".$args->{from})
        unless Email::Valid->address( -address => $args->{from}, -fqdn => 0 ); # from is mandatory

    $args->{subject} = $params->{subject} // '';

    if ( C4::Context->preference('SendAllEmailsTo') ) {
        $args->{to} = C4::Context->preference('SendAllEmailsTo');
    }
    else {
        $args->{to} = $params->{to};
    }

    Koha::Exceptions::BadParameter->throw("Invalid 'to' parameter: ".$args->{to})
        unless Email::Valid->address( -address => $args->{to}, -fqdn => 0 ); # to is mandatory

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
            "Invalid '$address' parameter: " . $addresses->{$address} )
          if $addresses->{$address} and !Email::Valid->address(
            -address => $addresses->{$address},
            -fqdn    => 0
          );
    }

    $args->{cc} = $addresses->{cc}
        if $addresses->{cc};
    $args->{bcc} = $addresses->{bcc}
        if $addresses->{bcc};

    my $email = $self->SUPER::new( $args );

    $email->header( 'Reply-To', $addresses->{reply_to} )
        if $addresses->{reply_to};

    $email->header( 'Sender'       => $addresses->{sender} ) if $addresses->{sender};
    $email->header( 'Content-Type' => $params->{contenttype} ) if $params->{contenttype};
    $email->header( 'X-Mailer'     => "Koha" );
    $email->header( 'Message-ID'   => Email::MessageID->new->in_brackets );

    if ( $params->{text_body} ) {
        $email->text_body( $params->{text_body}, %{ $params->{body_params} } );
    }
    elsif ( $params->{html_body} ) {
        $email->html_body( $params->{html_body}, %{ $params->{body_params} } );
    }

    return $email;
}

=head3 send_or_die

    $email->send_or_die({ transport => $transport [, $args] });

Overloaded Email::Stuffer I<send_or_die> method, that takes care of Bcc handling.
Bcc is removed from the message headers, and included in the recipients list to be
passed to I<send_or_die>.

=cut

sub send_or_die {
    my ( $self, $args ) = @_;

    unless ( $args->{to} ) {    # don't do it if passed an explicit 'to' param

        my @recipients;

        my @headers = $self->email->header_str_pairs;
        foreach my $pair ( pairs @headers ) {
            my ( $header, $value ) = @$pair;
            push @recipients, split (', ', $value)
                if grep { $_ eq $header } ('To', 'Cc', 'Bcc');
        }

        # Remove the Bcc header
        $self->email->header_str_set('Bcc');

        # Tweak $args
        $args->{to} = \@recipients;
    }

    $self->SUPER::send_or_die($args);
}

1;
