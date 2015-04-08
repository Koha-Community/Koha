package C4::Print;

# Copyright 2000-2002 Katipo Communications
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

use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA    = qw(Exporter);
    @EXPORT = qw(&NetworkPrint);
}

=head1 NAME

C4::Print - Koha module dealing with printing

=head1 SYNOPSIS

  use C4::Print;

=head1 DESCRIPTION

The functions in this module handle sending text to a printer.

=head1 FUNCTIONS

=head2 NetworkPrint

  &NetworkPrint($text)

Queue some text for printing on the selected branch printer

=cut

sub NetworkPrint {
    my ($text) = @_;

# FIXME - It'd be nifty if this could generate pretty PostScript.

    my $queue = '';

    # FIXME - If 'queue' is undefined or empty, then presumably it should
    # mean "use the default queue", whatever the default is. Presumably
    # the default depends on the physical location of the machine.
    # FIXME - Perhaps "print to file" should be a supported option. Just
    # set the queue to "file" (or " file", if real queues aren't allowed
    # to have spaces in them). Or perhaps if $queue eq "" and
    # $env->{file} ne "", then that should mean "print to $env->{file}".

    my $fh;
    if ( $queue eq "" || $queue eq 'nulllp' ) {
        return;
	#open( $fh, ">/tmp/kohaiss" );
    }
    else {

        # FIXME - This assumes that 'lpr' exists, and works as expected.
        # This is a reasonable assumption, but only because every other
        # printing package has a wrapper script called 'lpr'. It'd still
        # be better to be able to customize this.
        open( $fh, "-|", "lpr -P $queue > /dev/null" )
          or die "Couldn't write to queue:$queue!\n";
    }

    #  print $queue;
    #open (FILE,">/tmp/$file");
    print $fh $text;
    print $fh "\r\n" x 7 ;
    close $fh;

    #system("lpr /tmp/$file");
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut
