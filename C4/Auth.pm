# -*- tab-width: 8 -*-
# NOTE: This file uses 8-character tabs; do not change the tab size!

package C4::Auth;

# Copyright 2000-2002 Katipo Communications
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
use Digest::MD5 qw(md5_base64);
use CGI::Session;


require Exporter;
use C4::Context;
use C4::Output;    # to get the template
use C4::Members;
use C4::Koha;
use C4::Branch; # GetBranches

# use utf8;
# use Net::LDAP;
# use Net::LDAP qw(:all);

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g;
    shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v );
};

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use CGI;
  use C4::Auth;

  my $query = new CGI;

  my ($template, $borrowernumber, $cookie) 
    = get_template_and_user(
        {
            template_name   => "opac-main.tmpl",
            query           => $query,
      type            => "opac",
      authnotrequired => 1,
      flagsrequired   => {borrow => 1},
  }
    );

  print $query->header(
    -type => 'utf-8',
    -cookie => $cookie
  ), $template->output;


=head1 DESCRIPTION

    The main function of this module is to provide
    authentification. However the get_template_and_user function has
    been provided so that a users login information is passed along
    automatically. This gets loaded into the template.

=head1 FUNCTIONS

=over 2

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(
  &checkauth
  &get_template_and_user
);

=item get_template_and_user

  my ($template, $borrowernumber, $cookie)
    = get_template_and_user(
        {
           template_name   => "opac-main.tmpl",
           query           => $query,
     type            => "opac",
     authnotrequired => 1,
     flagsrequired   => {borrow => 1},
  }
    );

    This call passes the C<query>, C<flagsrequired> and C<authnotrequired>
    to C<&checkauth> (in this module) to perform authentification.
    See C<&checkauth> for an explanation of these parameters.

    The C<template_name> is then used to find the correct template for
    the page. The authenticated users details are loaded onto the
    template in the HTML::Template LOOP variable C<USER_INFO>. Also the
    C<sessionID> is passed to the template. This can be used in templates
    if cookies are disabled. It needs to be put as and input to every
    authenticated page.

    More information on the C<gettemplate> sub can be found in the
    Output.pm module.

=cut

sub get_template_and_user {
    my $in       = shift;
    my $template =
      gettemplate( $in->{'template_name'}, $in->{'type'}, $in->{'query'} );
    my ( $user, $cookie, $sessionID, $flags ) = checkauth(
        $in->{'query'},
        $in->{'authnotrequired'},
        $in->{'flagsrequired'},
        $in->{'type'}
    ) unless ($in->{'template_name'}=~/maintenance/);

    my $borrowernumber;
    my $insecure = C4::Context->preference('insecure');
    if ($user or $insecure) {

		# load the template variables for stylesheets and JavaScript
		$template->param( css_libs => $in->{'css_libs'} );
		$template->param( css_module => $in->{'css_module'} );
		$template->param( css_page => $in->{'css_page'} );
		$template->param( css_widgets => $in->{'css_widgets'} );

        $template->param( js_libs => $in->{'js_libs'} );
        $template->param( js_module => $in->{'js_module'} );
        $template->param( js_page => $in->{'js_page'} );
        $template->param( js_widgets => $in->{'js_widgets'} );

		# user info
        $template->param( loggedinusername => $user );
        $template->param( sessionID        => $sessionID );

        $borrowernumber = getborrowernumber($user);
        my ( $borr, $alternativeflags ) =
          GetMemberDetails( $borrowernumber );
        my @bordat;
        $bordat[0] = $borr;
        $template->param( "USER_INFO" => \@bordat );

        # We are going to use the $flags returned by checkauth
        # to create the template's parameters that will indicate
        # which menus the user can access.
        if (( $flags && $flags->{superlibrarian}==1) or $insecure==1) {
            $template->param( CAN_user_circulate        => 1 );
            $template->param( CAN_user_catalogue        => 1 );
            $template->param( CAN_user_parameters       => 1 );
            $template->param( CAN_user_borrowers        => 1 );
            $template->param( CAN_user_permission       => 1 );
            $template->param( CAN_user_reserveforothers => 1 );
            $template->param( CAN_user_borrow           => 1 );
            $template->param( CAN_user_editcatalogue    => 1 );
            $template->param( CAN_user_updatecharge     => 1 );
            $template->param( CAN_user_acquisition      => 1 );
            $template->param( CAN_user_management       => 1 );
            $template->param( CAN_user_tools            => 1 ); 
            $template->param( CAN_user_editauthorities  => 1 );
            $template->param( CAN_user_serials          => 1 );
            $template->param( CAN_user_reports          => 1 );
        }

        if ( $flags && $flags->{circulate} == 1 ) {
            $template->param( CAN_user_circulate => 1 );
        }

        if ( $flags && $flags->{catalogue} == 1 ) {
            $template->param( CAN_user_catalogue => 1 );
        }

        if ( $flags && $flags->{parameters} == 1 ) {
            $template->param( CAN_user_parameters => 1 );
            $template->param( CAN_user_management => 1 );
        }

        if ( $flags && $flags->{borrowers} == 1 ) {
            $template->param( CAN_user_borrowers => 1 );
        }

        if ( $flags && $flags->{permissions} == 1 ) {
            $template->param( CAN_user_permission => 1 );
        }

        if ( $flags && $flags->{reserveforothers} == 1 ) {
            $template->param( CAN_user_reserveforothers => 1 );
        }

        if ( $flags && $flags->{borrow} == 1 ) {
            $template->param( CAN_user_borrow => 1 );
        }

        if ( $flags && $flags->{editcatalogue} == 1 ) {
            $template->param( CAN_user_editcatalogue => 1 );
        }

        if ( $flags && $flags->{updatecharges} == 1 ) {
            $template->param( CAN_user_updatecharge => 1 );
        }

        if ( $flags && $flags->{acquisition} == 1 ) {
            $template->param( CAN_user_acquisition => 1 );
        }

        if ( $flags && $flags->{tools} == 1 ) {
            $template->param( CAN_user_tools => 1 );
        }
  
        if ( $flags && $flags->{editauthorities} == 1 ) {
            $template->param( CAN_user_editauthorities => 1 );
        }
    
        if ( $flags && $flags->{serials} == 1 ) {
            $template->param( CAN_user_serials => 1 );
        }

        if ( $flags && $flags->{reports} == 1 ) {
            $template->param( CAN_user_reports => 1 );
        }
    }
    if ( $in->{'type'} eq "intranet" ) {
        $template->param(
            intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
            intranetstylesheet => C4::Context->preference("intranetstylesheet"),
            IntranetNav        => C4::Context->preference("IntranetNav"),
            intranetuserjs     => C4::Context->preference("intranetuserjs"),
            TemplateEncoding   => C4::Context->preference("TemplateEncoding"),
            AmazonContent      => C4::Context->preference("AmazonContent"),
            LibraryName        => C4::Context->preference("LibraryName"),
            LoginBranchcode    => (C4::Context->userenv?C4::Context->userenv->{"branch"}:"insecure"),
            LoginBranchname    => (C4::Context->userenv?C4::Context->userenv->{"branchname"}:"insecure"),
            LoginFirstname     => (C4::Context->userenv?C4::Context->userenv->{"firstname"}:"Bel"),
            LoginSurname       => C4::Context->userenv?C4::Context->userenv->{"surname"}:"Inconnu", 
            AutoLocation       => C4::Context->preference("AutoLocation"),
            hide_marc          => C4::Context->preference("hide_marc"),
            patronimages       => C4::Context->preference("patronimages"),
            "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
            advancedMARCEditor      => C4::Context->preference("advancedMARCEditor"),
            suggestion              => C4::Context->preference("suggestion"),
            virtualshelves          => C4::Context->preference("virtualshelves"),
            LibraryName             => C4::Context->preference("LibraryName"),
            KohaAdminEmailAddress   => "" . C4::Context->preference("KohaAdminEmailAddress"),
			IntranetmainUserblock 	=> C4::Context->preference("IntranetmainUserblock"),
        );
    }
    else {
        warn "template type should be OPAC, here it is=[" . $in->{'type'} . "]" unless ( $in->{'type'} eq 'opac' );
        my $LibraryNameTitle = C4::Context->preference("LibraryName");
        $LibraryNameTitle =~ s/<(?:\/?)(?:br|p)\s*(?:\/?)>/ /sgi;
        $LibraryNameTitle =~ s/<(?:[^<>'"]|'(?:[^']*)'|"(?:[^"]*)")*>//sg;
  $template->param(
            KohaAdminEmailAddress  => "" . C4::Context->preference("KohaAdminEmailAddress"),
            suggestion             => "" . C4::Context->preference("suggestion"),
            virtualshelves         => "" . C4::Context->preference("virtualshelves"),
            OpacNav                => "" . C4::Context->preference("OpacNav"),
            opacheader             => "" . C4::Context->preference("opacheader"),
            opaccredits            => "" . C4::Context->preference("opaccredits"),
            opacsmallimage         => "" . C4::Context->preference("opacsmallimage"),
            opaclargeimage         => "" . C4::Context->preference("opaclargeimage"),
            opaclayoutstylesheet   => "". C4::Context->preference("opaclayoutstylesheet"),
            opaccolorstylesheet    => "". C4::Context->preference("opaccolorstylesheet"),
            opaclanguagesdisplay   => "". C4::Context->preference("opaclanguagesdisplay"),
            opacuserlogin          => "" . C4::Context->preference("opacuserlogin"),
            opacbookbag            => "" . C4::Context->preference("opacbookbag"),
            TemplateEncoding       => "". C4::Context->preference("TemplateEncoding"),
            AmazonContent          => "" . C4::Context->preference("AmazonContent"),
            LibraryName            => "" . C4::Context->preference("LibraryName"),
            LibraryNameTitle       => "" . $LibraryNameTitle,
            LoginBranchcode        => (C4::Context->userenv?C4::Context->userenv->{"branch"}:"insecure"),
            LoginBranchname        => C4::Context->userenv?C4::Context->userenv->{"branchname"}:"", 
            LoginFirstname        => (C4::Context->userenv?C4::Context->userenv->{"firstname"}:"Bel"),
            LoginSurname        => C4::Context->userenv?C4::Context->userenv->{"surname"}:"Inconnu", 
            OpacPasswordChange     => C4::Context->preference("OpacPasswordChange"),
            opacreadinghistory     => C4::Context->preference("opacreadinghistory"),
            opacuserjs             => C4::Context->preference("opacuserjs"),
            OpacCloud              => C4::Context->preference("OpacCloud"),
            OpacTopissue           => C4::Context->preference("OpacTopissue"),
            OpacAuthorities        => C4::Context->preference("OpacAuthorities"),
            OpacBrowser            => C4::Context->preference("OpacBrowser"),
            RequestOnOpac          => C4::Context->preference("RequestOnOpac"),
            reviewson              => C4::Context->preference("reviewson"),
            hide_marc              => C4::Context->preference("hide_marc"),
            patronimages           => C4::Context->preference("patronimages"),
            mylibraryfirst   => C4::Context->preference("SearchMyLibraryFirst"),
            "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
        );
    }
    return ( $template, $borrowernumber, $cookie );
}

=item checkauth

  ($userid, $cookie, $sessionID) = &checkauth($query, $noauth, $flagsrequired, $type);

Verifies that the user is authorized to run this script.  If
the user is authorized, a (userid, cookie, session-id, flags)
quadruple is returned.  If the user is not authorized but does
not have the required privilege (see $flagsrequired below), it
displays an error page and exits.  Otherwise, it displays the
login page and exits.

Note that C<&checkauth> will return if and only if the user
is authorized, so it should be called early on, before any
unfinished operations (e.g., if you've opened a file, then
C<&checkauth> won't close it for you).

C<$query> is the CGI object for the script calling C<&checkauth>.

The C<$noauth> argument is optional. If it is set, then no
authorization is required for the script.

C<&checkauth> fetches user and session information from C<$query> and
ensures that the user is authorized to run scripts that require
authorization.

The C<$flagsrequired> argument specifies the required privileges
the user must have if the username and password are correct.
It should be specified as a reference-to-hash; keys in the hash
should be the "flags" for the user, as specified in the Members
intranet module. Any key specified must correspond to a "flag"
in the userflags table. E.g., { circulate => 1 } would specify
that the user must have the "circulate" privilege in order to
proceed. To make sure that access control is correct, the
C<$flagsrequired> parameter must be specified correctly.

The C<$type> argument specifies whether the template should be
retrieved from the opac or intranet directory tree.  "opac" is
assumed if it is not specified; however, if C<$type> is specified,
"intranet" is assumed if it is not "opac".

If C<$query> does not have a valid session ID associated with it
(i.e., the user has not logged in) or if the session has expired,
C<&checkauth> presents the user with a login page (from the point of
view of the original script, C<&checkauth> does not return). Once the
user has authenticated, C<&checkauth> restarts the original script
(this time, C<&checkauth> returns).

The login page is provided using a HTML::Template, which is set in the
systempreferences table or at the top of this file. The variable C<$type>
selects which template to use, either the opac or the intranet 
authentification template.

C<&checkauth> returns a user ID, a cookie, and a session ID. The
cookie should be sent back to the browser; it verifies that the user
has authenticated.

=cut

sub checkauth {
    my $query = shift;
  # warn "Checking Auth";
    # $authnotrequired will be set for scripts which will run without authentication
    my $authnotrequired = shift;
    my $flagsrequired   = shift;
    my $type            = shift;
    $type = 'opac' unless $type;

    my $dbh     = C4::Context->dbh;
    my $timeout = C4::Context->preference('timeout');
    $timeout = 600 unless $timeout;


    # If Version syspref is unavailable, it means Koha is beeing installed,
    # and so we must redirect to OPAC maintenance page or to the WebInstaller
    unless (C4::Context->preference('Version')) {
      if ($type ne 'opac') {
        warn "Install required, redirecting to Installer";
        print $query->redirect("/cgi-bin/koha/installer/install.pl");
      } 
      else {
        warn "OPAC Install required, redirecting to maintenance";
        print $query->redirect("/cgi-bin/koha/maintenance.pl");
      }
      exit;
    }


    # state variables
    my $loggedin = 0;
    my %info;
    my ( $userid, $cookie, $sessionID, $flags );
    my $logout = $query->param('logout.x');
    if ( $userid = $ENV{'REMOTE_USER'} ) {
        # Using Basic Authentication, no cookies required
        $cookie = $query->cookie(
            -name    => 'CGISESSID',
            -value   => '',
            -expires => ''
        );
        $loggedin = 1;
    }
    elsif ( $sessionID = $query->cookie("CGISESSID")) {
		my $storage_method = C4::Context->preference('SessionStorage');
		my $session;
		if ($storage_method eq 'mysql'){
		    $session = new CGI::Session("driver:MySQL", $sessionID, {Handle=>$dbh});
		}
		else {
			# catch all defaults to tmp should work on all systems
			$session = new CGI::Session("driver:File", $sessionID, {Directory=>'/tmp'});			
		}
        C4::Context->_new_userenv($sessionID);
        if ($session){
            C4::Context::set_userenv(
                $session->param('number'),       $session->param('id'),
                $session->param('cardnumber'),   $session->param('firstname'),
                $session->param('surname'),      $session->param('branch'),
                $session->param('branchname'),   $session->param('flags'),
                $session->param('emailaddress'), $session->param('branchprinter')
            );
#             warn       "".$session->param('cardnumber').",   ".$session->param('firstname').",
#                 ".$session->param('surname').",      ".$session->param('branch');
        }
        my $ip;
        my $lasttime;
        if ($session) {
          $ip = $session->param('ip');
          $lasttime = $session->param('lasttime');
                $userid = $session->param('id');
        }
        
    
        if ($logout) {

            # voluntary logout the user

            $session->flush;      
			$session->delete();
            C4::Context->_unset_userenv($sessionID);
            $sessionID = undef;
            $userid    = undef;
            open L, ">>/tmp/sessionlog";
            my $time = localtime( time() );
            printf L "%20s from %16s logged out at %30s (manually).\n", $userid,
              $ip, $time;
            close L;
        }
        if ($userid) {
            if ( $lasttime < time() - $timeout ) {
                # timed logout
                $info{'timed_out'} = 1;
                $session->delete();
                C4::Context->_unset_userenv($sessionID);
                $userid    = undef;
                $sessionID = undef;
                open L, ">>/tmp/sessionlog";
                my $time = localtime( time() );
                printf L "%20s from %16s logged out at %30s (inactivity).\n",
                  $userid, $ip, $time;
                close L;
            }
            elsif ( $ip ne $ENV{'REMOTE_ADDR'} ) {
                # Different ip than originally logged in from
                $info{'oldip'}        = $ip;
                $info{'newip'}        = $ENV{'REMOTE_ADDR'};
                $info{'different_ip'} = 1;
        $session->delete();
                C4::Context->_unset_userenv($sessionID);
                $sessionID = undef;
                $userid    = undef;
                open L, ">>/tmp/sessionlog";
                my $time = localtime( time() );
                printf L
"%20s from logged out at %30s (ip changed from %16s to %16s).\n",
                  $userid, $time, $ip, $info{'newip'};
                close L;
            }
            else {
                $cookie = $query->cookie( CGISESSID => $session->id );
                $session->param('lasttime',time());
                $flags = haspermission( $dbh, $userid, $flagsrequired );
                if ($flags) {
                    $loggedin = 1;
                }
                else {
                    $info{'nopermission'} = 1;
                }
            }
        }
    }
    unless ($userid) {
		my $storage_method = C4::Context->preference('SessionStorage');
		my $session;
		if ($storage_method eq 'mysql'){
		    $session = new CGI::Session("driver:MySQL", $sessionID, {Handle=>$dbh});
		}
		else {
			# catch all defaults to tmp should work on all systems
			$session = new CGI::Session("driver:File", $sessionID, {Directory=>'/tmp'});			
		}

        my $sessionID;
		if ($session) {
			$sessionID = $session->id;
		}
        $userid    = $query->param('userid');
        C4::Context->_new_userenv($sessionID);
        my $password = $query->param('password');
        C4::Context->_new_userenv($sessionID);
        my ( $return, $cardnumber ) = checkpw( $dbh, $userid, $password );
        if ($return) {
            open L, ">>/tmp/sessionlog";
            my $time = localtime( time() );
            printf L "%20s from %16s logged in  at %30s.\n", $userid,
              $ENV{'REMOTE_ADDR'}, $time;
            close L;
            $cookie = $query->cookie(CGISESSID => $sessionID);
            if ( $flags = haspermission( $dbh, $userid, $flagsrequired ) ) {
                $loggedin = 1;
            }
            else {
                $info{'nopermission'} = 1;
                C4::Context->_unset_userenv($sessionID);
            }
            if ( $return == 1 ) {
                my (
                    $borrowernumber, $firstname,  $surname,
                    $userflags,      $branchcode, $branchname,
                    $branchprinter,  $emailaddress
                );
                my $sth =
                  $dbh->prepare(
"select borrowernumber, firstname, surname, flags, borrowers.branchcode, branches.branchname as branchname,branches.branchprinter as branchprinter, email from borrowers left join branches on borrowers.branchcode=branches.branchcode where userid=?"
                  );
                $sth->execute($userid);
                (
                    $borrowernumber, $firstname,  $surname,
                    $userflags,      $branchcode, $branchname,
                    $branchprinter,  $emailaddress
                  )
                  = $sth->fetchrow
                  if ( $sth->rows );

#         warn "$cardnumber,$borrowernumber,$userid,$firstname,$surname,$userflags,$branchcode,$emailaddress";
                unless ( $sth->rows ) {
                    my $sth =
                      $dbh->prepare(
"select borrowernumber, firstname, surname, flags, borrowers.branchcode, branches.branchname as branchname, branches.branchprinter as branchprinter, email from borrowers left join branches on borrowers.branchcode=branches.branchcode where cardnumber=?"
                      );
                    $sth->execute($cardnumber);
                    (
                        $borrowernumber, $firstname,  $surname,
                        $userflags,      $branchcode, $branchname,
                        $branchprinter,  $emailaddress
                      )
                      = $sth->fetchrow
                      if ( $sth->rows );

#           warn "$cardnumber,$borrowernumber,$userid,$firstname,$surname,$userflags,$branchcode,$emailaddress";
                    unless ( $sth->rows ) {
                        $sth->execute($userid);
                        (
                            $borrowernumber, $firstname, $surname, $userflags,
                            $branchcode, $branchname, $branchprinter, $emailaddress
                          )
                          = $sth->fetchrow
                          if ( $sth->rows );
                    }
                }

# launch a sequence to check if we have a ip for the branch, if we have one we replace the branchcode of the userenv by the branch bound in the ip.
                my $ip       = $ENV{'REMOTE_ADDR'};
                # if they specify at login, use that
                if ($query->param('branch')) {
                    $branchcode  = $query->param('branch');
                    $branchname = GetBranchName($branchcode);
                }
                my $branches = GetBranches();
                my @branchesloop;
                foreach my $br ( keys %$branches ) {
                    #     now we work with the treatment of ip
                    my $domain = $branches->{$br}->{'branchip'};
                    if ( $domain && $ip =~ /^$domain/ ) {
                        $branchcode = $branches->{$br}->{'branchcode'};

                        # new op dev : add the branchprinter and branchname in the cookie
                        $branchprinter = $branches->{$br}->{'branchprinter'};
                        $branchname    = $branches->{$br}->{'branchname'};
                    }
                }
                $session->param('number',$borrowernumber);
                $session->param('id',$userid);
                $session->param('cardnumber',$cardnumber);
                $session->param('firstname',$firstname);
                $session->param('surname',$surname);
                $session->param('branch',$branchcode);
                $session->param('branchname',$branchname);
                $session->param('flags',$userflags);
                $session->param('emailaddress',$emailaddress);
                $session->param('ip',$session->remote_addr());
                $session->param('lasttime',time());
#            warn       "".$session->param('cardnumber').",   ".$session->param('firstname').",
#                 ".$session->param('surname').",      ".$session->param('branch');
            }
            elsif ( $return == 2 ) {
                #We suppose the user is the superlibrarian
                        $session->param('number',0);
                        $session->param('id',C4::Context->config('user'));
                        $session->param('cardnumber',C4::Context->config('user'));
                        $session->param('firstname',C4::Context->config('user'));
                        $session->param('surname',C4::Context->config('user'));
                        $session->param('branch','NO_LIBRARY_SET');
                        $session->param('branchname','NO_LIBRARY_SET');
                        $session->param('flags',1);
                        $session->param('emailaddress', C4::Context->preference('KohaAdminEmailAddress'));
                        $session->param('ip',$session->remote_addr());
                        $session->param('lasttime',time());
                }
                if ($session){
                    C4::Context::set_userenv(
                        $session->param('number'),       $session->param('id'),
                        $session->param('cardnumber'),   $session->param('firstname'),
                        $session->param('surname'),      $session->param('branch'),
                        $session->param('branchname'),   $session->param('flags'),
                        $session->param('emailaddress'), $session->param('branchprinter')
                    );
                }
        }

        else {
            if ($userid) {
                $info{'invalid_username_or_password'} = 1;
                C4::Context->_unset_userenv($sessionID);
            }
        }
    }
    my $insecure = C4::Context->boolean_preference('insecure');

    # finished authentification, now respond
    if ( $loggedin || $authnotrequired || ( defined($insecure) && $insecure ) )
    {
        # successful login
        unless ($cookie) {
            $cookie = $query->cookie( CGISESSID => ''
            );
        }
    return ( $userid, $cookie, $sessionID, $flags );

    }

#
#
# AUTH rejected, show the login/password template, after checking the DB.
#
#
    
    # get the inputs from the incoming query
    my @inputs = ();
    foreach my $name ( param $query) {
        (next) if ( $name eq 'userid' || $name eq 'password' );
        my $value = $query->param($name);
        push @inputs, { name => $name, value => $value };
    }
    # get the branchloop, which we need for authentication
    my $branches = GetBranches();
    my @branch_loop;
    for my $branch_hash (keys %$branches) {
                push @branch_loop, {branchcode => "$branch_hash", branchname => $branches->{$branch_hash}->{'branchname'}, };
    }

    # check that database and koha version are the same
    # there is no DB version, it's a fresh install,
    # go to web installer
    # there is a DB version, compare it to the code version
    my $kohaversion=C4::Context::KOHAVERSION;
    # remove the 3 last . to have a Perl number
    $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
#     warn "kohaversion : $kohaversion";
    if (C4::Context->preference('Version') < $kohaversion){
      if ($type ne 'opac'){
      warn "Database update needed, redirecting to Installer. Database is ".C4::Context->preference('Version')." and Koha is : ".C4::Context->config("kohaversion");
        print $query->redirect("/cgi-bin/koha/installer/install.pl?step=3");
      } else {
      warn "OPAC :Database update needed, redirecting to maintenance. Database is ".C4::Context->preference('Version')." and Koha is : ".C4::Context->config("kohaversion");
        print $query->redirect("/cgi-bin/koha/maintenance.pl");
      }       
      exit;
    }
    my $template_name;
    if ( $type eq 'opac' ) {
        $template_name = "opac-auth.tmpl";
    }
    else {
        $template_name = "auth.tmpl";
    }
    my $template = gettemplate( $template_name, $type, $query );
    $template->param(branchloop => \@branch_loop,);
    $template->param(
    login        => 1,
        INPUTS               => \@inputs,
        suggestion           => C4::Context->preference("suggestion"),
        virtualshelves       => C4::Context->preference("virtualshelves"),
        opaclargeimage       => C4::Context->preference("opaclargeimage"),
        LibraryName          => C4::Context->preference("LibraryName"),
        OpacNav              => C4::Context->preference("OpacNav"),
        opaccredits          => C4::Context->preference("opaccredits"),
        opacreadinghistory   => C4::Context->preference("opacreadinghistory"),
        opacsmallimage       => C4::Context->preference("opacsmallimage"),
        opaclayoutstylesheet => C4::Context->preference("opaclayoutstylesheet"),
        opaccolorstylesheet  => C4::Context->preference("opaccolorstylesheet"),
        opaclanguagesdisplay => C4::Context->preference("opaclanguagesdisplay"),
        opacuserjs           => C4::Context->preference("opacuserjs"),

        intranetcolorstylesheet =>
          C4::Context->preference("intranetcolorstylesheet"),
        intranetstylesheet => C4::Context->preference("intranetstylesheet"),
        IntranetNav        => C4::Context->preference("IntranetNav"),
        intranetuserjs     => C4::Context->preference("intranetuserjs"),
        TemplateEncoding   => C4::Context->preference("TemplateEncoding"),

    );
    $template->param( loginprompt => 1 ) unless $info{'nopermission'};

    my $self_url = $query->url( -absolute => 1 );
    $template->param(
        url         => $self_url,
        LibraryName => => C4::Context->preference("LibraryName"),
    );
    $template->param( \%info );
#    $cookie = $query->cookie(CGISESSID => $session->id
#   );
    print $query->header(
 		-type   => 'text/html',
        -charset => 'utf-8',
        -cookie => $cookie
      ),
      $template->output;
    exit;
}

sub checkpw {

    my ( $dbh, $userid, $password ) = @_;

    # INTERNAL AUTH
    my $sth =
      $dbh->prepare(
"select password,cardnumber,borrowernumber,userid,firstname,surname,branchcode,flags from borrowers where userid=?"
      );
    $sth->execute($userid);
    if ( $sth->rows ) {
        my ( $md5password, $cardnumber, $borrowernumber, $userid, $firstname,
            $surname, $branchcode, $flags )
          = $sth->fetchrow;
        if ( md5_base64($password) eq $md5password ) {

            C4::Context->set_userenv( "$borrowernumber", $userid, $cardnumber,
                $firstname, $surname, $branchcode, $flags );
            return 1, $cardnumber;
        }
    }
    $sth =
      $dbh->prepare(
"select password,cardnumber,borrowernumber,userid, firstname,surname,branchcode,flags from borrowers where cardnumber=?"
      );
    $sth->execute($userid);
    if ( $sth->rows ) {
        my ( $md5password, $cardnumber, $borrowernumber, $userid, $firstname,
            $surname, $branchcode, $flags )
          = $sth->fetchrow;
        if ( md5_base64($password) eq $md5password ) {

            C4::Context->set_userenv( $borrowernumber, $userid, $cardnumber,
                $firstname, $surname, $branchcode, $flags );
            return 1, $userid;
        }
    }
    if (   $userid && $userid eq C4::Context->config('user')
        && "$password" eq C4::Context->config('pass') )
    {

# Koha superuser account
#     C4::Context->set_userenv(0,0,C4::Context->config('user'),C4::Context->config('user'),C4::Context->config('user'),"",1);
        return 2;
    }
    if (   $userid && $userid eq 'demo'
        && "$password" eq 'demo'
        && C4::Context->config('demo') )
    {

# DEMO => the demo user is allowed to do everything (if demo set to 1 in koha.conf
# some features won't be effective : modify systempref, modify MARC structure,
        return 2;
    }
    return 0;
}

sub getuserflags {
    my $cardnumber = shift;
    my $dbh        = shift;
    my $userflags;
    my $sth = $dbh->prepare("SELECT flags FROM borrowers WHERE cardnumber=?");
    $sth->execute($cardnumber);
    my ($flags) = $sth->fetchrow;
    $flags = 0 unless $flags;
    $sth = $dbh->prepare("SELECT bit, flag, defaulton FROM userflags");
    $sth->execute;

    while ( my ( $bit, $flag, $defaulton ) = $sth->fetchrow ) {
        if ( ( $flags & ( 2**$bit ) ) || $defaulton ) {
            $userflags->{$flag} = 1;
        }
        else {
            $userflags->{$flag} = 0;
        }
    }
    return $userflags;
}

sub haspermission {
    my ( $dbh, $userid, $flagsrequired ) = @_;
    my $sth = $dbh->prepare("SELECT cardnumber FROM borrowers WHERE userid=?");
    $sth->execute($userid);
    my ($cardnumber) = $sth->fetchrow;
    ($cardnumber) || ( $cardnumber = $userid );
    my $flags = getuserflags( $cardnumber, $dbh );
    my $configfile;
    if ( $userid eq C4::Context->config('user') ) {

        # Super User Account from /etc/koha.conf
        $flags->{'superlibrarian'} = 1;
    }
    if ( $userid eq 'demo' && C4::Context->config('demo') ) {

        # Demo user that can do "anything" (demo=1 in /etc/koha.conf)
        $flags->{'superlibrarian'} = 1;
    }
    return $flags if $flags->{superlibrarian};
    foreach ( keys %$flagsrequired ) {
        return $flags if $flags->{$_};
    }
    return 0;
}

sub getborrowernumber {
    my ($userid) = @_;
    my $dbh = C4::Context->dbh;
    for my $field ( 'userid', 'cardnumber' ) {
        my $sth =
          $dbh->prepare("select borrowernumber from borrowers where $field=?");
        $sth->execute($userid);
        if ( $sth->rows ) {
            my ($bnumber) = $sth->fetchrow;
            return $bnumber;
        }
    }
    return 0;
}

END { }    # module clean-up code here (global destructor)
1;
__END__

=back

=head1 SEE ALSO

CGI(3)

C4::Output(3)

Digest::MD5(3)

=cut
