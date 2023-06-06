#
# Sip.pm: General Sip utility functions
#

package C4::SIP::Sip;

use strict;
use warnings;
use Exporter;
use Encode;
use POSIX qw(strftime);
use Socket qw(:crlf);
use IO::Handle;
use List::Util qw(any);

use C4::SIP::Sip::Constants qw(SIP_DATETIME FID_SCREEN_MSG);
use C4::SIP::Sip::Checksum qw(checksum);
use C4::SIP::Logger qw( get_logger );

use base qw(Exporter);

our @EXPORT_OK = qw(y_or_n timestamp add_field maybe_add add_count
    denied sipbool boolspace write_msg
    $error_detection $protocol_version $field_delimiter
    $last_response siplog);

our %EXPORT_TAGS = (
    all => [qw(y_or_n timestamp add_field maybe_add
        add_count denied sipbool boolspace write_msg
        $error_detection $protocol_version
        $field_delimiter $last_response siplog)]);

our $error_detection = 0;
our $protocol_version = 1;
our $field_delimiter = '|'; # Protocol Default

# We need to keep a copy of the last message we sent to the SC,
# in case there's a transmission error and the SC sends us a
# REQUEST_ACS_RESEND.  If we receive a REQUEST_ACS_RESEND before
# we've ever sent anything, then we are to respond with a
# REQUEST_SC_RESEND (p.16)

our $last_response = '';

sub timestamp {
    my $time = $_[0] || time();
    if ( ref $time eq 'DateTime') {
        return $time->strftime(SIP_DATETIME);
    } elsif ($time=~m/^(\d{4})\-(\d{2})\-(\d{2})/) {
        # passing a db returned date as is + bogus time
        return sprintf( '%04d%02d%02d    235900', $1, $2, $3);
    }
    return strftime(SIP_DATETIME, localtime($time));
}

#
# add_field(field_id, value)
#    return constructed field value
#
sub add_field {
    my ($field_id, $value, $server) = @_;

    return q{} if should_hide( $field_id, $value, $server );

    my ($i, $ent);

    if (!defined($value)) {
    siplog("LOG_DEBUG", "add_field: Undefined value being added to '%s'",
           $field_id);
        $value = '';
    }
    $value=~s/\r/ /g; # CR terminates a sip message
                      # Protect against them in sip text fields

    # Replace any occurrences of the field delimiter in the
    # field value with the HTML character entity
    $ent = sprintf("&#%d;", ord($field_delimiter));

    while (($i = index($value, $field_delimiter)) != ($[-1)) {
        substr($value, $i, 1) = $ent;
    }

    return $field_id . $value . $field_delimiter;
}
#
# maybe_add(field_id, value):
#    If value is defined and non-empty, then return the
#    constructed field value, otherwise return the empty string.
#    NOTE: if zero is a valid value for your field, don't use maybe_add!
#
sub maybe_add {
    my ($fid, $value, $server) = @_;

    return q{} if should_hide( $fid, $value, $server );

    if ( $fid eq FID_SCREEN_MSG && $server->{account}->{screen_msg_regex} && defined($value)) {
        foreach my $regex (
            ref $server->{account}->{screen_msg_regex} eq "ARRAY"
            ? @{ $server->{account}->{screen_msg_regex} }
            : $server->{account}->{screen_msg_regex} )
        {
            $value =~ s/$regex->{find}/$regex->{replace}/g;
        }
    }

    return ( defined($value) && length($value) )
      ? add_field( $fid, $value )
      : '';
}

sub should_hide {
    my ( $field_id, $value, $server ) = @_;

    my $allow_fields = $server->{account}->{allow_fields};
    if ($allow_fields) {
        my @fields = split( ',', $allow_fields );
        return 1 unless any { $_ eq $field_id } @fields;
    }

    my $hide_fields = $server->{account}->{hide_fields};
    if ($hide_fields) {
        my @fields = split( ',', $hide_fields );
        return 1 if any { $_ eq $field_id } @fields;
    }

    return 0;
}

#
# add_count()  produce fixed four-character count field,
# or a string of four spaces if the count is invalid for some
# reason
#
sub add_count {
    my ($label, $count) = @_;

    # If the field is unsupported, it will be undef, return blanks
    # as per the spec.
    if (!defined($count)) {
        return ' ' x 4;
    }

    $count = sprintf("%04d", $count);
    if (length($count) != 4) {
        siplog("LOG_WARNING", "handle_patron_info: %s wrong size: '%s'",
           $label, $count);
        $count = ' ' x 4;
    }
    return $count;
}

#
# denied($bool)
# if $bool is false, return true.  This is because SIP statuses
# are inverted:  we report that something has been denied, not that
# it's permitted.  For example, 'renewal priv. denied' of 'Y' means
# that the user's not permitted to renew.  I assume that the ILS has
# real positive tests.
#
sub denied {
    my $bool = shift;
    return boolspace(!$bool);
}

sub sipbool {
    my $bool = shift;
    return $bool ? 'Y' : 'N';
}

#
# boolspace: ' ' is false, 'Y' is true. (don't ask)
#
sub boolspace {
    my $bool = shift;
    return $bool ? 'Y' : ' ';
}

#
# write_msg($msg, $file)
#
# Send $msg to the SC.  If error detection is active, then
# add the sequence number (if $seqno is non-zero) and checksum
# to the message, and save the whole thing as $last_response
#
# If $file is set, then it's a file handle: write to it, otherwise
# just write to the default destination.
#

sub write_msg {
    my ($self, $msg, $file, $terminator, $encoding) = @_;

    $terminator ||= q{};
    $terminator = ( $terminator eq 'CR' ) ? $CR : $CRLF;

    $msg = encode($encoding, $msg) if ( $encoding );

    my $cksum;

    # $msg = encode_utf8($msg);
    if ($error_detection) {
        if (defined($self->{seqno})) {
            $msg .= 'AY' . $self->{seqno};
        }
        $msg .= 'AZ';
        $cksum = checksum($msg);
        $msg .= sprintf('%04.4X', $cksum);
    }


    if ($file) {
        $file->autoflush(1);
        print $file $msg, $terminator;
    } else {
        STDOUT->autoflush(1);
        print $msg, $terminator;
        siplog("LOG_INFO", "OUTPUT MSG: '$msg'");
    }

    $last_response = $msg;
}

sub siplog {
    my ( $level, $mask, @args ) = @_;

    my $method =
        $level eq 'LOG_ERR'     ? 'error'
      : $level eq 'LOG_DEBUG'   ? 'debug'
      : $level eq 'LOG_INFO'    ? 'info'
      : $level eq 'LOG_WARNING' ? 'warn'
      :                           'error';

    my $message = @args ? sprintf($mask, @args) : $mask;

    my $logger = C4::SIP::Logger::get_logger();
    $logger->$method($message) if $logger;
}

1;
