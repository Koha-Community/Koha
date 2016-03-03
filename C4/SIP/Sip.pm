#
# Sip.pm: General Sip utility functions
#

package C4::SIP::Sip;

use strict;
use warnings;
use Exporter;
use Encode;
use Sys::Syslog qw(syslog);
use POSIX qw(strftime);
use Socket qw(:crlf);
use IO::Handle;

use C4::SIP::Sip::Constants qw(SIP_DATETIME FID_SCREEN_MSG);
use C4::SIP::Sip::Checksum qw(checksum);

use vars qw(@ISA @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	@ISA = qw(Exporter);

	@EXPORT_OK = qw(y_or_n timestamp add_field maybe_add add_count
		    denied sipbool boolspace write_msg read_SIP_packet
		    $error_detection $protocol_version $field_delimiter
		    $last_response);

	%EXPORT_TAGS = (
		    all => [qw(y_or_n timestamp add_field maybe_add
			       add_count denied sipbool boolspace write_msg
			       read_SIP_packet
			       $error_detection $protocol_version
			       $field_delimiter $last_response)]);
}

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
    my ($field_id, $value) = @_;
    my ($i, $ent);

    if (!defined($value)) {
	syslog("LOG_DEBUG", "add_field: Undefined value being added to '%s'",
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

    if ( $fid eq FID_SCREEN_MSG && $server->{account}->{screen_msg_regex} ) {
        foreach my $regex (
            ref $server->{account}->{screen_msg_regex} eq "ARRAY"
            ? @{ $server->{account}->{screen_msg_regex} }
            : $server->{account}->{screen_msg_regex} )
        {
            $value =~ s/$regex->{find}/$regex->{replace}/g;
        }
    }

    return (defined($value) && $value) ? add_field($fid, $value) : '';
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
		syslog("LOG_WARNING", "handle_patron_info: %s wrong size: '%s'",
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


# read_SIP_packet($file)
#
# Read a packet from $file, using the correct record separator
#
sub read_SIP_packet {
    my $record;
    my $fh = shift or syslog("LOG_ERR", "read_SIP_packet: no filehandle argument!");
    my $len1 = 999;

    # local $/ = "\r";      # don't need any of these here.  use whatever the prevailing $/ is.
    local $/ = "\015";    # proper SPEC: (octal) \015 = (hex) x0D = (dec) 13 = (ascii) carriage return
    {    # adapted from http://perldoc.perl.org/5.8.8/functions/readline.html
            undef $!;
            $record = readline($fh);
            if ( defined($record) ) {
                while ( chomp($record) ) { 1; }
                $len1 = length($record);
                syslog( "LOG_DEBUG", "read_SIP_packet, INPUT MSG: '$record'" );
                $record =~ s/^\s*[^A-z0-9]+//s; # Every line must start with a "real" character.  Not whitespace, control chars, etc. 
                $record =~ s/[^A-z0-9]+$//s;    # Same for the end.  Note this catches the problem some clients have sending empty fields at the end, like |||
                $record =~ s/\015?\012//g;      # Extra line breaks must die
                $record =~ s/\015?\012//s;      # Extra line breaks must die
                $record =~ s/\015*\012*$//s;    # treat as one line to include the extra linebreaks we are trying to remove!
                while ( chomp($record) ) { 1; }

                $record and last;    # success
            }
    }
    if ($record) {
        my $len2 = length($record);
        syslog("LOG_INFO", "read_SIP_packet, INPUT MSG: '$record'") if $record;
        ($len1 != $len2) and syslog("LOG_DEBUG", "read_SIP_packet, trimmed %s character(s) (after chomps).", $len1-$len2);
    } else {
        syslog("LOG_WARNING", "read_SIP_packet input %s, end of input.", (defined($record) ? "empty ($record)" : 'undefined'));
    }
    #
    # Cen-Tec self-check terminals transmit '\r\n' line terminators.
    # This is actually very hard to deal with in perl in a reasonable
    # since every OTHER piece of hardware out there gets the protocol
    # right.
    # 
    # The incorrect line terminator presents as a \r at the end of the
    # first record, and then a \n at the BEGINNING of the next record.
    # So, the simplest thing to do is just throw away a leading newline
    # on the input.
    #  
    # This is now handled by the vigorous cleansing above.
    # syslog("LOG_INFO", encode_utf8("INPUT MSG: '$record'")) if $record;
    syslog("LOG_INFO", "INPUT MSG: '$record'") if $record;
    return $record;
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
        syslog("LOG_INFO", "OUTPUT MSG: '$msg'");
    }

    $last_response = $msg;
}

1;
