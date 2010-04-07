package C4::Auth_with_cas;

# Copyright 2009 BibLibre SARL
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use C4::Debug;
use C4::Context;
use C4::Utils qw( :all );
use Authen::CAS::Client;
use CGI;


use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $debug);

BEGIN {
	require Exporter;
	$VERSION = 3.03;	# set the version for version checking
	$debug = $ENV{DEBUG};
	@ISA    = qw(Exporter);
	@EXPORT = qw(checkpw_cas login_cas logout_cas login_cas_url);
}


my $context = C4::Context->new() 	or die 'C4::Context->new failed';
my $casserver = C4::Context->preference('casServerUrl');

# Logout from CAS
sub logout_cas {
    my ($query) = @_;
    my $cas = Authen::CAS::Client->new($casserver);
    print $query->redirect($cas->logout_url(url => $ENV{'SCRIPT_URI'}));
}

# Login to CAS
sub login_cas {
    my ($query) = @_;
    my $cas = Authen::CAS::Client->new($casserver);
    print $query->redirect($cas->login_url($ENV{'SCRIPT_URI'})); 
}

# Returns CAS login URL with callback to the requesting URL
sub login_cas_url {
    my $cas = Authen::CAS::Client->new($casserver);
    return $cas->login_url($ENV{'SCRIPT_URI'});
}

# Checks for password correctness
# In our case : is there a ticket, is it valid and does it match one of our users ?
sub checkpw_cas {
    $debug and warn "checkpw_cas";
    my ($dbh, $ticket, $query) = @_;
    my $retnumber;
    my $cas = Authen::CAS::Client->new($casserver);

    # If we got a ticket
    if ($ticket) {
	$debug and warn "Got ticket : $ticket";
	
	# We try to validate it
	my $val = $cas->service_validate($ENV{'SCRIPT_URI'}, $ticket);
	
	# If it's valid
	if( $val->is_success() ) {

	    my $userid = $val->user();
	    $debug and warn "User CAS authenticated as: $userid";

	    # Does it match one of our users ?
    	    my $sth = $dbh->prepare("select cardnumber from borrowers where userid=?");
    	    $sth->execute($userid);
    	    if ( $sth->rows ) {
		$retnumber = $sth->fetchrow;
		return (1, $retnumber, $userid);
	    }
	    $sth = $dbh->prepare("select userid from borrowers where cardnumber=?");
	    $sth->execute($userid);
	    if ( $sth->rows ) {
	    	$retnumber = $sth->fetchrow;
		return (1, $retnumber, $userid);
	    }
	    
	    # If we reach this point, then the user is a valid CAS user, but not a Koha user
	    $debug and warn "User $userid is not a valid Koha user";

    	} else {
    	    $debug and warn "Invalid session ticket : $ticket";
    	    return 0;
	}
    }
    return 0;
}

1;
__END__

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use C4::Auth_with_cas;

=cut

=head1 SEE ALSO

CGI(3)

Authen::CAS::Client

=cut
