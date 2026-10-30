package Koha::Notice::Message;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use HTML::Entities;
use Koha::Database;
use Koha::Exceptions::Notice;
use Koha::Logger;
use Koha::I18N qw( __ );
use Koha::Notice::Template;
use Koha::Patron;
use Koha::Patron::Debarments qw( AddDebarment );

use base qw(Koha::Object);

# Notices that can carry a secret, whose content must not be displayed or printed
our @SENSITIVE_LETTER_CODES = qw( PASSWORD_RESET STAFF_PASSWORD_RESET OPAC_REG_VERIFY 2FA_OTP_TOKEN );

=head1 NAME

Koha::Notice::Message - Koha notice message Object class, related to the message_queue table

=head1 API

=head2 Class Methods

=cut

=head3 is_html

  my $bool = $message->is_html;

Returns a boolean denoting whether the message was generated using a preformatted html template.

=cut

sub is_html {
    my ($self) = @_;
    my $content_type = $self->content_type // '';
    return $content_type =~ m/html/io;
}

=head3 html_content

  my $wrapped_content = $message->html_content;

The content of messages that can carry a secret (see L</is_sensitive>) is replaced by a notice.

This method returns the message content appropriately wrapped
with HTML headers and CSS includes, and the style of the template of the notice, for HTML
formatted notices. The content of plain text notices is escaped.

=cut

sub html_content {
    my ($self) = @_;

    my $title   = $self->subject;
    my $content = $self->content;

    # The style of the template belongs to the notice, which is shown on its own
    my $template    = $self->template;
    my $stylesheets = join(
        "\n    ", grep { length } $self->stylesheets,
        $template && length( $template->style // '' )
        ? qq{<style type="text/css">} . $template->style . qq{</style>}
        : ()
    );

    my $is_html = $self->is_html;
    if ( $self->is_sensitive ) {
        $content =
            '<p><em>'
            . __(
            'The content of this notice is not displayed because it can contain a password reset link or a security code.'
            ) . '</em></p>';
        $is_html = 1;
    }

    my $wrapped;
    if ($is_html) {
        $wrapped = <<EOS;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>$title</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    $stylesheets
  </head>
  <body>
  $content
  </body>
</html>
EOS
    } else {
        $wrapped = "<div style=\"white-space: pre-wrap;\">";
        $wrapped .= HTML::Entities::encode_entities( $content, '<>&"' );
        $wrapped .= "</div>";
    }
    return $wrapped;
}

=head3 is_sensitive

    if ( $message->is_sensitive ) { ... }

Returns true if the content of the message must not be displayed or printed, as it can
contain a secret: a password reset link, an account verification link or a security code.
The message itself is still recorded, with its status.

=cut

sub is_sensitive {
    my ($self) = @_;

    my $letter_code = $self->letter_code;
    return 0 unless defined $letter_code;
    return ( grep { $_ eq $letter_code } @SENSITIVE_LETTER_CODES ) ? 1 : 0;
}

=head3 can_be_printed

    if ( $message->can_be_printed ) { ... }

Returns true if the message can be printed from the notices pages: its content must not be
sensitive, and it must not be pending (waiting to be sent), unless it is a print notice that
is waiting to be printed. A message that has been converted to a print notice is not printed,
its print notice is.

=cut

sub can_be_printed {
    my ($self) = @_;

    return 0 if $self->is_sensitive;
    return 0 if $self->status eq 'converted';
    return 1 if $self->status ne 'pending';
    return $self->message_transport_type eq 'print' ? 1 : 0;
}

=head3 content_as_html

    my $html = $message->content_as_html;

Returns the content of the message as a fragment of HTML: the content of an HTML
message, and the text of the others, escaped and with its line breaks kept.

=cut

sub content_as_html {
    my ($self) = @_;

    return $self->content if $self->is_html;

    my $text = $self->content // q{};
    $text =~ s/&/&amp;/g;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;
    return '<div style="white-space: pre-wrap;">' . $text . '</div>';
}

=head3 can_be_converted_to_print

    if ( $message->can_be_converted_to_print ) { ... }

Returns true if the message can be converted to a print notice: it is for a patron, it is
not already a print notice, its content must not be sensitive, and it has been sent, has
failed or has been deleted.

=cut

sub can_be_converted_to_print {
    my ($self) = @_;

    return 0 if $self->is_sensitive;
    return 0 unless $self->borrowernumber;
    return 0 if $self->message_transport_type eq 'print';
    return ( grep { $_ eq $self->status } qw( sent failed deleted ) ) ? 1 : 0;
}

=head3 conversion_template_exists

    if ( Koha::Notice::Message->conversion_template_exists ) { ... }

Class method, returns true if there is a CONVERTED_TO_PRINT notice, which is needed to convert
a notice to a print notice (see L</convert_to_print>).

=cut

sub conversion_template_exists {
    require Koha::Notice::Templates;

    return Koha::Notice::Templates->search(
        { module => 'members', code => 'CONVERTED_TO_PRINT', message_transport_type => 'print' } )->count ? 1 : 0;
}

=head3 convert_to_print

    my $print_notice = $message->convert_to_print;

Queue a print notice for the patron with the notice CONVERTED_TO_PRINT, which adds the address of
the patron and a note to the content of this message, and set the status of this message to
'converted'. Returns the print notice, which is pending.

Throws a L<Koha::Exceptions::Notice::CannotConvertToPrint> if the message cannot be converted
(see L</can_be_converted_to_print>), a L<Koha::Exceptions::Notice::NoConversionTemplate> if
there is no CONVERTED_TO_PRINT notice, and a L<Koha::Exceptions::Notice::ConversionTemplateError>
if it cannot be processed, for example because of an error in its template, which is also logged
as an error. Nothing is changed when an exception is thrown.

The two messages are linked in their delivery note (C<failure_code>): the original has
C<CONVERTED_TO_PRINT:$message_id> with the id of the print notice, and the print notice has
C<CONVERTED_FROM:$message_id> with the id of the original.

=cut

sub convert_to_print {
    my ($self) = @_;

    Koha::Exceptions::Notice::CannotConvertToPrint->throw unless $self->can_be_converted_to_print;
    Koha::Exceptions::Notice::NoConversionTemplate->throw unless $self->conversion_template_exists;

    require C4::Letters;
    require Koha::Notice::Messages;

    my $patron = $self->patron;
    my $letter = eval {
        C4::Letters::GetPreparedLetter(
            module                 => 'members',
            letter_code            => 'CONVERTED_TO_PRINT',
            branchcode             => $patron->branchcode,
            lang                   => $patron->lang || 'default',
            message_transport_type => 'print',
            tables                 => {
                borrowers => $patron->borrowernumber,
                branches  => $patron->branchcode,
            },
            objects => { original_message => $self },
        );
    };
    if ( my $error = $@ ) {
        $error = "$error";
        Koha::Logger->get->error( "The CONVERTED_TO_PRINT notice could not be processed to convert notice "
                . $self->message_id
                . ": $error" );
        Koha::Exceptions::Notice::ConversionTemplateError->throw( error => $error );
    }
    $letter or Koha::Exceptions::Notice::NoConversionTemplate->throw;

    my $print_notice;
    $self->_result->result_source->schema->txn_do(
        sub {
            my $message_id = C4::Letters::EnqueueLetter(
                {
                    letter                 => $letter,
                    borrowernumber         => $patron->borrowernumber,
                    message_transport_type => 'print',
                }
            ) or Koha::Exceptions::Notice::CannotConvertToPrint->throw( error => 'The print notice is empty' );

            $print_notice = Koha::Notice::Messages->find($message_id);
            $print_notice->update( { failure_code => 'CONVERTED_FROM:' . $self->message_id } );
            $self->update( { status => 'converted', failure_code => 'CONVERTED_TO_PRINT:' . $message_id } );
        }
    );

    return $print_notice;
}

=head3 mark_as_printed

    $message->mark_as_printed;

Set the status of the message to 'printed'.

=cut

sub mark_as_printed {
    my ($self) = @_;

    $self->update( { status => 'printed' } );

    return $self;
}

=head3 restrict_patron_when_notice_fails

    $failed_notice->restrict_patron_when_notice_fails;

Places a restriction (debarment) on patrons with failed SMS and email notices.

=cut

sub restrict_patron_when_notice_fails {
    my ($self) = @_;

    # Set the appropriate restriction (debarment) comment depending if the failed
    # message is a SMS or email notice. If the failed notice is neither then
    # return without placing a restriction
    my $comment;
    if ( $self->message_transport_type eq 'email' ) {
        $comment = 'Email address invalid';
    } elsif ( $self->message_transport_type eq 'sms' ) {
        $comment = 'SMS number invalid';
    } else {
        return;
    }

    AddDebarment(
        {
            borrowernumber => $self->borrowernumber,
            type           => 'NOTICE_FAILURE_SUSPENSION',
            comment        => $comment,
            expiration     => undef,
        }
    );

    return $self;
}

=head3 stylesheets

  my $stylesheets = $message->stylesheets;

Returns a string of all the stylesheet links for the message

=cut

sub stylesheets {
    my ($self) = @_;
    my $stylesheets = '';

    my $all_stylesheets = C4::Context->preference("AllNoticeStylesheet") || '';
    $stylesheets .= qq{<link rel="stylesheet" type="text/css" href="$all_stylesheets">\n} if $all_stylesheets;
    my $all_style_pref = C4::Context->preference("AllNoticeCSS");
    $stylesheets .= qq{<style type="text/css">$all_style_pref</style>} if $all_style_pref;
    if ( $self->message_transport_type eq 'email' ) {
        my $email_stylesheet = C4::Context->preference("EmailNoticeStylesheet") || '';
        $stylesheets .= qq{<link rel="stylesheet" type="text/css" href="$email_stylesheet">\n} if $email_stylesheet;
        my $email_style_pref = C4::Context->preference("EmailNoticeCSS");
        $stylesheets .= qq{<style type="text/css">$email_style_pref</style>} if $email_style_pref;
    }
    if ( $self->message_transport_type eq 'print' ) {
        my $print_stylesheet = C4::Context->preference("PrintNoticeStylesheet") || '';
        $stylesheets .= qq{<link rel="stylesheet" type="text/css" href="$print_stylesheet">\n} if $print_stylesheet;
        my $print_style_pref = C4::Context->preference("PrintNoticeCSS");
        $stylesheets .= qq{<style type="text/css">$print_style_pref</style>\n} if $print_style_pref;
    }
    $stylesheets =~ s/\n+\z//;

    return $stylesheets;
}

=head3 patron

    my $patron = $message->patron

Return the patron by whom this message is for

=cut

sub patron {
    my ($self) = @_;
    my $patron_rs = $self->_result->borrowernumber;
    return unless $patron_rs;
    return Koha::Patron->_new_from_dbic($patron_rs);
}

=head3 template

    my $template = $message->template

Return the template from which this message may have been generated

=cut

sub template {
    my ($self) = @_;
    my $template_rs = $self->_result->letter;
    return unless $template_rs;
    return Koha::Notice::Template->_new_from_dbic($template_rs);
}

=head3 _type

Return the name of the DBIC result class this object wraps

=cut

sub _type {
    return 'MessageQueue';
}

1;
