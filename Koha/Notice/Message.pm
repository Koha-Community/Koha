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
use C4::Log qw( logaction );
use Koha::Database;
use Koha::Notice::Template;
use Koha::Patron;
use Koha::Patron::Debarments qw( AddDebarment );

use base qw(Koha::Object);

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

This method returns the message content appropriately wrapped
with HTML headers and CSS includes for HTML formatted notices.

=cut

sub html_content {
    my ($self) = @_;

    my $title       = $self->subject;
    my $content     = $self->content;
    my $stylesheets = $self->stylesheets;

    my $wrapped;
    if ( $self->is_html ) {
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
        $wrapped .= $content;
        $wrapped .= "</div>";
    }
    return $wrapped;
}

=head3 can_be_printed

    if ( $message->can_be_printed ) { ... }

Returns true if the message can be printed from the notices pages: it must not be pending
(waiting to be sent), unless it is a print notice that is waiting to be printed.

=cut

sub can_be_printed {
    my ($self) = @_;

    return 1 if $self->status ne 'pending';
    return $self->message_transport_type eq 'print' ? 1 : 0;
}

=head3 mark_as_printed

    $message->mark_as_printed;

Set the status of the message to 'printed', and log it if the notices are logged.

=cut

sub mark_as_printed {
    my ($self) = @_;

    $self->update( { status => 'printed' } );
    logaction( 'NOTICES', 'PRINT', $self->message_id, 'message_queue' )
        if C4::Context->preference('NoticesLog');

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

=head3 scoped_style

  my $scoped_style = $message->scoped_style;

Returns a string of all the scoped styles for the message: the styles defined for its
transport type, with every selector prefixed by a class for the transport type so they
only apply to notices of that type.

=cut

sub scoped_style {
    my ($self) = @_;
    my $type = $self->message_transport_type;
    my $css_content;

    if ( $type eq 'email' ) {
        $css_content = C4::Context->preference("EmailNoticeCSS");
    } elsif ( $type eq 'print' ) {
        $css_content = C4::Context->preference("PrintNoticeCSS");
    }

    # No styles are defined for other transport types, or for an empty preference
    return q{} unless $css_content;

    return _scope_css( $css_content, ".type_$type" );
}

=head3 scoped_template_style

  my $style = $message->scoped_template_style('#notice_123');

Returns the styles of the notice template the message was generated from, with every selector
prefixed by the given scope, or an empty string if the message has no template or the template
has no styles.

=cut

sub scoped_template_style {
    my ( $self, $scope ) = @_;

    my $template = $self->template;
    return q{} unless $template && $template->style;

    return _scope_css( $template->style, $scope );
}

=head3 _split_selectors

  my @selectors = _split_selectors('a, :is(b, c), [data-x="1,2"]');

Split a selector list on its top level commas, commas in parentheses, brackets and strings are kept.

=cut

sub _split_selectors {
    my ($list) = @_;

    my @selectors;
    my ( $current, $depth, $quote ) = ( q{}, 0, undef );
    for my $char ( split //, $list ) {
        if ($quote) {
            $quote = undef if $char eq $quote;
        } elsif ( $char eq '"' or $char eq "'" ) {
            $quote = $char;
        } elsif ( $char eq '(' or $char eq '[' ) {
            $depth++;
        } elsif ( $char eq ')' or $char eq ']' ) {
            $depth-- if $depth;
        } elsif ( $char eq ',' and !$depth ) {
            push @selectors, $current;
            $current = q{};
            next;
        }
        $current .= $char;
    }
    push @selectors, $current;

    return @selectors;
}

=head3 _scope_css

  my $scoped_css = _scope_css( $css, '.scope' );

Prefix every selector of the given CSS with the given scope. Rules nested in conditional
group at-rules (@media, @supports, @document, @layer, @container) are scoped too, other at-rules
(@font-face, @keyframes, @import...) and comments are left alone.

=cut

sub _scope_css {
    my ( $css, $scope ) = @_;

    my $scoped = q{};
    while (
        $css =~ m{
            \G
            (?: (?<comment> /\*.*?\*/ )
              | (?<space> \s+ )
              | (?<atrule> \@(?<name>[\w-]+) (?<prelude>[^{};]*)
                    (?: ; | (?<block> \{ (?: [^{}]++ | (?&block) )* \} ) ) )
              | (?<selector> [^{}\@;]+? ) (?<declarations> \{ [^{}]* \} )
            )
        }gcsx
        )
    {
        # Copy what we need, the recursive call below resets the match variables
        my %match = ( %+, all => $& );

        if ( defined $match{comment} or defined $match{space} ) {
            $scoped .= $match{all};
        } elsif ( defined $match{atrule} ) {
            if ( defined $match{block}
                and $match{name} =~ m/^(?:media|supports|-moz-document|document|layer|container)$/ )
            {
                my $inner = substr( $match{block}, 1, -1 );
                $scoped .= '@' . $match{name} . $match{prelude} . '{' . _scope_css( $inner, $scope ) . '}';
            } else {
                $scoped .= $match{all};
            }
        } else {
            my ($leading) = $match{selector} =~ m/^(\s*)/;
            my @selectors = grep { length } map { s/^\s+|\s+$//gr } _split_selectors( $match{selector} );

            # The notice replaces the document, so the document selectors apply to its container
            my @scoped_selectors;
            for my $selector (@selectors) {
                if ( $selector =~ s/^(?:html|body|:root)(?=$|[\s>+~])/$scope/ ) {
                    push @scoped_selectors, $selector;
                } else {
                    push @scoped_selectors, "$scope $selector";
                }
            }
            $scoped .= $leading . join( ', ', @scoped_selectors ) . ' ' . $match{declarations};
        }
    }

    # Anything we could not make sense of is kept as it was
    $scoped .= substr( $css, pos($css) // 0 );

    return $scoped;
}

=head3 _type

Return the name of the DBIC result class this object wraps

=cut

sub _type {
    return 'MessageQueue';
}

1;
