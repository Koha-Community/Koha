package MARC::File::USMARC;

=head1 NAME

MARC::File::USMARC - USMARC-specific file handling

=cut

use 5.6.0;
use strict;
use integer;
use vars qw( $VERSION $ERROR );

=head1 VERSION

Version 0.93

    $Id$

=cut

our $VERSION = '0.93';

use MARC::File;
our @ISA = qw( MARC::File );

use MARC::Record qw( LEADER_LEN );
use constant SUBFIELD_INDICATOR	    => "\x1F";
use constant END_OF_FIELD	    => "\x1E";
use constant END_OF_RECORD	    => "\x1D";
use constant DIRECTORY_ENTRY_LEN    => 12;

=head1 SYNOPSIS

    use MARC::File::USMARC;

    my $file = MARC::File::USMARC::in( $filename );
    
    while ( my $marc = $file->next() ) {
	# Do something
    }
    $file->close();
    undef $file;

=head1 EXPORT

None.  

=head1 METHODS

=for internal

Internal function to get the next raw record out of a file.

=cut

sub _next {
    my $self = shift;

    if ($self->{fh}) {
	my $fh = $self->{fh};

	my $reclen;

	read( $fh, $reclen, 5 )
	    or return $self->_gripe( "Error reading record length: $!" );

	$reclen =~ /^\d{5}$/
	    or return $self->_gripe( "Invalid record length \"$reclen\"" );
	my $usmarc = $reclen;
	read( $fh, substr($usmarc,5), $reclen-5 )
	    or return $self->_gripe( "Error reading $reclen byte record: $!" );

	return $usmarc;
    } elsif (defined($self->{data})) {
	my $data=$self->{data};
	my $pointer=$self->{pointer};
	my $reclen;
	$reclen=substr($data,$pointer,5);
	$reclen=~/^\d{5}$/
	    or return $self->_gripe( "Invalid record length \"$reclen\"" );
	my $usmarc=substr($data,$pointer,$reclen);
	$self->{pointer}=$pointer+$reclen;
	return $usmarc;
    }
}

=head2 decode()

Constructor for handling data from a USMARC file.  This function takes care of all
the tag directory parsing & mangling.

Any warnings or coercions can be checked in the C<warnings()> function.

=cut

sub decode {
    my $text = shift;
    $text = shift if (ref($text)||$text) =~ /^MARC::File/;

    my $marc = MARC::Record->new();

    # Check for an all-numeric record length
    ($text =~ /^(\d{5})/)
	or return $marc->_gripe( "Record length \"", substr( $text, 0, 5 ), "\" is not numeric" );

    my $reclen = $1;
    ($reclen == length($text))
	or return $marc->_gripe( "Invalid record length: Leader says $reclen bytes, but it's actually ", length( $text ) );

    $marc->leader( substr( $text, 0, LEADER_LEN ) );
    my @fields = split( END_OF_FIELD, substr( $text, LEADER_LEN ) );
    my $dir = shift @fields or return _gripe( "No directory found" );

    (length($dir) % 12 == 0)
	or return $marc->_gripe( "Invalid directory length" );
    my $nfields = length($dir)/12;

    my $finalfield = pop @fields;
    # Check for the record terminator, and ignore it
    ($finalfield eq END_OF_RECORD)
    	or $marc->_warn( "Invalid record terminator: \"$finalfield\"" );

    # Walk thru the directories, and shift off the fields while we're at it
    # Shouldn't be any non-digits anywhere in any directory entry
    my @directory = unpack( "A3 A4 A5" x $nfields, $dir );
    my @bad = grep /\D/, @directory;
    if ( @bad ) { 
	return $marc->_gripe( "Non-numeric entries in the tag directory: ", join( ", ", map { "\"$_\"" } @bad ) );
    }

    my $databytesused = 0;
    while ( @directory ) {
	my $tagno = shift @directory;
	my $len = shift @directory;
	my $offset = shift @directory;
	my $tagdata = shift @fields;

	# Check directory validity
	($tagno =~ /^\d\d\d$/)
	    or return $marc->_gripe( "Invalid field number in directory: \"$tagno\"" );

	($len == length($tagdata) + 1)
	    or $marc->_warn( "Invalid length in the directory for tag $tagno" );

	($offset == $databytesused)
	    or $marc->_warn( "Directory offsets are out of whack" );
	$databytesused += $len;

	if ( $tagno < 10 ) {
	    $marc->add_fields( $tagno, $tagdata )
		or return undef; # We're relying on add_fields() having set $MARC::Record::ERROR
	} else {
	    my @subfields = split( SUBFIELD_INDICATOR, $tagdata );
	    my $indicators = shift @subfields
		or return $marc->_gripe( "No subfields found." );
	    my ($ind1,$ind2);
	    if ( $indicators =~ /^([0-9 ])([0-9 ])$/ ) {
		($ind1,$ind2) = ($1,$2);
	    } else {
		$marc->_warn( "Invalid indicators \"$indicators\" forced to blanks\n" );
		($ind1,$ind2) = (" "," ");
	    }

	    # Split the subfield data into subfield name and data pairs
	    my @subfield_data = map { (substr($_,0,1),substr($_,1)) } @subfields;
	    $marc->add_fields( $tagno, $ind1, $ind2, @subfield_data )
		or return undef;
	}
    } # while

    # Once we're done, there shouldn't be any fields left over: They should all have shifted off.
    (@fields == 0)
    	or return $marc->_gripe( "I've got leftover fields that weren't in the directory" );

    return $marc;
}

=head2 update_leader()

If any changes get made to the MARC record, the first 5 bytes of the
leader (the length) will be invalid.  This function updates the 
leader with the correct length of the record as it would be if
written out to a file.

=cut

sub update_leader() {
	my $self = shift;

	my (undef,undef,$reclen,$baseaddress) = $self->_build_tag_directory();

	$self->_set_leader_lengths( $reclen, $baseaddress );
}

=head2 _build_tag_directory()

Function for internal use only: Builds the tag directory that gets
put in front of the data in a MARC record.

Returns two array references, and two lengths: The tag directory, and the data fields themselves,
the length of all data (including the Leader that we expect will be added),
and the size of the Leader and tag directory.

=cut

sub _build_tag_directory {
	my $marc = shift;
	$marc = shift if (ref($marc)||$marc) =~ /^MARC::File/;
	die "Wanted a MARC::Record but got a ", ref($marc) unless ref($marc) eq "MARC::Record";

	my @fields;
	my @directory;

	my $dataend = 0;
	for my $field ( $marc->fields() ) {
		# Dump data into proper format
		my $str = $field->as_usmarc;
		push( @fields, $str );

		# Create directory entry
		my $len = length $str;
		my $direntry = sprintf( "%03d%04d%05d", $field->tag, $len, $dataend );
		push( @directory, $direntry );
		$dataend += $len;
	}

	my $baseaddress = 
		LEADER_LEN +    # better be 24
		( @directory * DIRECTORY_ENTRY_LEN ) +
				# all the directory entries
		1;           	# end-of-field marker


	my $total = 
		$baseaddress +	# stuff before first field
		$dataend + 	# Length of the fields
		1;		# End-of-record marker



	return (\@fields, \@directory, $total, $baseaddress);
}

=head2 encode()

Returns a string of characters suitable for writing out to a USMARC file,
including the leader, directory and all the fields.

=cut

sub encode() {
    my $marc = shift;
    $marc = shift if (ref($marc)||$marc) =~ /^MARC::File/;

    my ($fields,$directory,$reclen,$baseaddress) = _build_tag_directory($marc);
    $marc->set_leader_lengths( $reclen, $baseaddress );

    # Glomp it all together
    return join("",$marc->leader, @$directory, END_OF_FIELD, @$fields, END_OF_RECORD);
}

1;

__END__

=head1 RELATED MODULES

L<MARC::Record>

=head1 TODO

Make some sort of autodispatch so that you don't have to explicitly
specify the MARC::File::X subclass, sort of like how DBI knows to
use DBD::Oracle or DBD::Mysql.

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>marc@petdance.comE<gt> or E<lt>alester@flr.follett.comE<gt>

=cut

