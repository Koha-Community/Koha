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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;

use C4::Debug;
use C4::Context;
use C4::Utils qw( :all );
use Authen::CAS::Client;
use CGI;


use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $debug);

BEGIN {
	require Exporter;
	$VERSION = 3.03;	# set the version for version checking
	@ISA    = qw(Exporter);
	@EXPORT = qw( checkpw_cas login_cas logout_cas );
}


my $context = C4::Context->new() 	or die 'C4::Context->new failed';
my $casserver = C4::Context->preference('casServerUrl');

sub logout_cas {
    my ($query) = @_;
    my $cas = Authen::CAS::Client->new($casserver);
    warn $cas->logout_url();
    print $query->redirect($cas->logout_url());

}

sub login_cas {
    my ($query) = @_;
    my $cas = Authen::CAS::Client->new($casserver);
    warn $cas->login_url(%ENV->{'SCRIPT_URI'});
    print $query->redirect($cas->login_url(%ENV->{'SCRIPT_URI'})); 
}

sub checkpw_cas {
    warn "checkpw_cas";
    my ($dbh, $ticket, $query) = @_;
    my $retnumber;
    my $cas = Authen::CAS::Client->new($casserver);

    if ($ticket) {
	warn "Got ticket : $ticket";
	my $val = $cas->service_validate(%ENV->{'SCRIPT_URI'}, $ticket);
	if( $val->is_success() ) {

	    my $userid = $val->user();
	    warn "User authenticated as: $userid";

    	    my $sth = $dbh->prepare("select cardnumber from borrowers where userid=?");
    	    $sth->execute($userid);
    	    if ( $sth->rows ) {
		$retnumber = $sth->fetchrow;
	    }
	    my $sth = $dbh->prepare("select userid from borrowers where cardnumber=?");
	    $sth->execute($userid);
	    if ( $sth->rows ) {
	    	$retnumber = $sth->fetchrow;
	    }
    	    return (1, $retnumber, $userid);
    	} else {
    	    warn "Invalid session ticket";
    	    return 0;
	}

    } else {
	warn ("Don't have any ticket, let's go get one from the CAS server!");
	my $url = $cas->login_url(%ENV->{'SCRIPT_URI'});
	print $query->redirect($url);    	
    }

    warn "We should not reach this point";
    return 0;
    #return(1, $retnumber);
}

1;
__END__

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use C4::Auth_with_cas;

=cut

=head1 KOHA_CONF <usecasserver>http://mycasserver/loginurl</usecasserver>

=head1 SEE ALSO

CGI(3)

Authen::CAS::Client

=cut
