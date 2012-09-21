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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
#use warnings; FIXME - Bug 2505
use Digest::MD5 qw(md5_base64);
use Storable qw(thaw freeze);
use URI::Escape;
use CGI::Session;

require Exporter;
use C4::Context;
use C4::Templates;    # to get the template
use C4::Members;
use C4::Koha;
use C4::Branch; # GetBranches
use C4::VirtualShelves;
use POSIX qw/strftime/;
use List::MoreUtils qw/ any /;

# use utf8;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $debug $ldap $cas $caslogout $servers $memcached);

BEGIN {
    sub psgi_env { any { /^psgi\./ } keys %ENV }
    sub safe_exit {
	if ( psgi_env ) { die 'psgi:exit' }
	else { exit }
    }

    $VERSION     = 3.02;                                                                                                            # set version for version checking
    $debug       = $ENV{DEBUG};
    @ISA         = qw(Exporter);
    @EXPORT      = qw(&checkauth &get_template_and_user &haspermission &get_user_subpermissions);
    @EXPORT_OK   = qw(&check_api_auth &get_session &check_cookie_auth &checkpw &get_all_subpermissions &get_user_subpermissions);
    %EXPORT_TAGS = ( EditPermissions => [qw(get_all_subpermissions get_user_subpermissions)] );
    $ldap        = C4::Context->config('useldapserver') || 0;
    $cas         = C4::Context->preference('casAuthentication');
    $caslogout   = C4::Context->preference('casLogout');
    require C4::Auth_with_cas;             # no import
    if ($ldap) {
	require C4::Auth_with_ldap;
	import C4::Auth_with_ldap qw(checkpw_ldap);
    }
    if ($cas) {
        import  C4::Auth_with_cas qw(check_api_auth_cas checkpw_cas login_cas logout_cas login_cas_url);
    }
    $servers = C4::Context->config('memcached_servers');
    if ($servers) {
	require Cache::Memcached;
        $memcached = Cache::Memcached->new({
					       servers => [ $servers ],
					       debug   => 0,
					       compress_threshold => 10_000,
					       namespace => C4::Context->config('memcached_namespace') || 'koha',
					   });
    }
}

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use CGI;
  use C4::Auth;
  use C4::Output;

  my $query = new CGI;

  my ($template, $borrowernumber, $cookie)
    = get_template_and_user(
        {
            template_name   => "opac-main.tmpl",
            query           => $query,
      type            => "opac",
      authnotrequired => 1,
      flagsrequired   => {borrow => 1, catalogue => '*', tools => 'import_patrons' },
  }
    );

  output_html_with_http_headers $query, $cookie, $template->output;

=head1 DESCRIPTION

The main function of this module is to provide
authentification. However the get_template_and_user function has
been provided so that a users login information is passed along
automatically. This gets loaded into the template.

=head1 FUNCTIONS

=head2 get_template_and_user

 my ($template, $borrowernumber, $cookie)
     = get_template_and_user(
       {
         template_name   => "opac-main.tmpl",
         query           => $query,
         type            => "opac",
         authnotrequired => 1,
         flagsrequired   => {borrow => 1, catalogue => '*', tools => 'import_patrons' },
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

my $SEARCH_HISTORY_INSERT_SQL =<<EOQ;
INSERT INTO search_history(userid, sessionid, query_desc, query_cgi, total, time            )
VALUES                    (     ?,         ?,          ?,         ?,          ?, FROM_UNIXTIME(?))
EOQ
sub get_template_and_user {
    my $in       = shift;
    my $template =
      C4::Templates::gettemplate( $in->{'template_name'}, $in->{'type'}, $in->{'query'} );
    my ( $user, $cookie, $sessionID, $flags );
    if ( $in->{'template_name'} !~m/maintenance/ ) {
        ( $user, $cookie, $sessionID, $flags ) = checkauth(
            $in->{'query'},
            $in->{'authnotrequired'},
            $in->{'flagsrequired'},
            $in->{'type'}
        );
    }

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

        my ($total, $pubshelves, $barshelves) = C4::Context->get_shelves_userenv();
        if (defined($pubshelves)) {
            $template->param( pubshelves     => scalar @{$pubshelves},
                              pubshelvesloop => $pubshelves,
            );
            $template->param( pubtotal   => $total->{'pubtotal'}, ) if ($total->{'pubtotal'} > scalar @{$pubshelves});
        }
        if (defined($barshelves)) {
            $template->param( barshelves      => scalar @{$barshelves},
                              barshelvesloop  => $barshelves,
            );
            $template->param( bartotal  => $total->{'bartotal'}, ) if ($total->{'bartotal'} > scalar @{$barshelves});
        }

        $borrowernumber = getborrowernumber($user) if defined($user);

        my ( $borr ) = GetMemberDetails( $borrowernumber );
        my @bordat;
        $bordat[0] = $borr;
        $template->param( "USER_INFO" => \@bordat );

        my $all_perms = get_all_subpermissions();

        my @flagroots = qw(circulate catalogue parameters borrowers permissions reserveforothers borrow
                            editcatalogue updatecharges management tools editauthorities serials reports acquisition);
        # We are going to use the $flags returned by checkauth
        # to create the template's parameters that will indicate
        # which menus the user can access.
        if (( $flags && $flags->{superlibrarian}==1) or $insecure==1) {
            $template->param( CAN_user_circulate        => 1 );
            $template->param( CAN_user_catalogue        => 1 );
            $template->param( CAN_user_parameters       => 1 );
            $template->param( CAN_user_borrowers        => 1 );
            $template->param( CAN_user_permissions      => 1 );
            $template->param( CAN_user_reserveforothers => 1 );
            $template->param( CAN_user_borrow           => 1 );
            $template->param( CAN_user_editcatalogue    => 1 );
            $template->param( CAN_user_updatecharges     => 1 );
            $template->param( CAN_user_acquisition      => 1 );
            $template->param( CAN_user_management       => 1 );
            $template->param( CAN_user_tools            => 1 );
            $template->param( CAN_user_editauthorities  => 1 );
            $template->param( CAN_user_serials          => 1 );
            $template->param( CAN_user_reports          => 1 );
            $template->param( CAN_user_staffaccess      => 1 );
            foreach my $module (keys %$all_perms) {
                foreach my $subperm (keys %{ $all_perms->{$module} }) {
                    $template->param( "CAN_user_${module}_${subperm}" => 1 );
                }
            }
        }

        if ( $flags ) {
            foreach my $module (keys %$all_perms) {
                if ( $flags->{$module} == 1) {
                    foreach my $subperm (keys %{ $all_perms->{$module} }) {
                        $template->param( "CAN_user_${module}_${subperm}" => 1 );
                    }
                } elsif ( ref($flags->{$module}) ) {
                    foreach my $subperm (keys %{ $flags->{$module} } ) {
                        $template->param( "CAN_user_${module}_${subperm}" => 1 );
                    }
                }
            }
        }

        if ($flags) {
            foreach my $module (keys %$flags) {
                if ( $flags->{$module} == 1 or ref($flags->{$module}) ) {
                    $template->param( "CAN_user_$module" => 1 );
                    if ($module eq "parameters") {
                        $template->param( CAN_user_management => 1 );
                    }
                }
            }
        }
		# Logged-in opac search history
		# If the requested template is an opac one and opac search history is enabled
		if ($in->{type} eq 'opac' && C4::Context->preference('EnableOpacSearchHistory')) {
			my $dbh = C4::Context->dbh;
			my $query = "SELECT COUNT(*) FROM search_history WHERE userid=?";
			my $sth = $dbh->prepare($query);
			$sth->execute($borrowernumber);
			
			# If at least one search has already been performed
			if ($sth->fetchrow_array > 0) { 
			# We show the link in opac
			$template->param(ShowOpacRecentSearchLink => 1);
			}

			# And if there's a cookie with searches performed when the user was not logged in, 
			# we add them to the logged-in search history
			my $searchcookie = $in->{'query'}->cookie('KohaOpacRecentSearches');
			if ($searchcookie){
				$searchcookie = uri_unescape($searchcookie);
			        my @recentSearches = @{thaw($searchcookie) || []};
				if (@recentSearches) {
					my $sth = $dbh->prepare($SEARCH_HISTORY_INSERT_SQL);
					$sth->execute( $borrowernumber,
						       $in->{'query'}->cookie("CGISESSID"),
						       $_->{'query_desc'},
						       $_->{'query_cgi'},
						       $_->{'total'},
						       $_->{'time'},
                            ) foreach @recentSearches;

					# And then, delete the cookie's content
					my $newsearchcookie = $in->{'query'}->cookie(
												-name => 'KohaOpacRecentSearches',
												-value => freeze([]),
												-expires => ''
											 );
					$cookie = [$cookie, $newsearchcookie];
				}
			}
		}
    }
	else {	# if this is an anonymous session, setup to display public lists...

        # load the template variables for stylesheets and JavaScript
        $template->param( css_libs => $in->{'css_libs'} );
        $template->param( css_module => $in->{'css_module'} );
        $template->param( css_page => $in->{'css_page'} );
        $template->param( css_widgets => $in->{'css_widgets'} );

        $template->param( js_libs => $in->{'js_libs'} );
        $template->param( js_module => $in->{'js_module'} );
        $template->param( js_page => $in->{'js_page'} );
        $template->param( js_widgets => $in->{'js_widgets'} );

        $template->param( sessionID        => $sessionID );
        
        my ($total, $pubshelves) = C4::Context->get_shelves_userenv();  # an anonymous user has no 'barshelves'...
        if (defined $pubshelves) {
            $template->param(   pubshelves      => scalar @{$pubshelves},
                                pubshelvesloop  => $pubshelves,
                            );
            $template->param(   pubtotal        => $total->{'pubtotal'}, ) if ($total->{'pubtotal'} > scalar @{$pubshelves});
        }

    }
 	# Anonymous opac search history
 	# If opac search history is enabled and at least one search has already been performed
 	if (C4::Context->preference('EnableOpacSearchHistory')) {
		my $searchcookie = $in->{'query'}->cookie('KohaOpacRecentSearches');
		if ($searchcookie){
			$searchcookie = uri_unescape($searchcookie);
		        my @recentSearches = @{thaw($searchcookie) || []};
 	    # We show the link in opac
			if (@recentSearches) {
				$template->param(ShowOpacRecentSearchLink => 1);
			}
	    }
 	}

    if(C4::Context->preference('dateformat')){
        if(C4::Context->preference('dateformat') eq "metric"){
            $template->param(dateformat_metric => 1);
        } elsif(C4::Context->preference('dateformat') eq "us"){
            $template->param(dateformat_us => 1);
        } else {
            $template->param(dateformat_iso => 1);
        }
    } else {
        $template->param(dateformat_iso => 1);
    }

    # these template parameters are set the same regardless of $in->{'type'}
    $template->param(
            "BiblioDefaultView".C4::Context->preference("BiblioDefaultView")         => 1,
            EnhancedMessagingPreferences => C4::Context->preference('EnhancedMessagingPreferences'),
            GoogleJackets                => C4::Context->preference("GoogleJackets"),
	    OpenLibraryCovers            => C4::Context->preference("OpenLibraryCovers"),
            KohaAdminEmailAddress        => "" . C4::Context->preference("KohaAdminEmailAddress"),
            LoginBranchcode              => (C4::Context->userenv?C4::Context->userenv->{"branch"}:"insecure"),
            LoginFirstname               => (C4::Context->userenv?C4::Context->userenv->{"firstname"}:"Bel"),
            LoginSurname                 => C4::Context->userenv?C4::Context->userenv->{"surname"}:"Inconnu",
            TagsEnabled                  => C4::Context->preference("TagsEnabled"),
            hide_marc                    => C4::Context->preference("hide_marc"),
            item_level_itypes            => C4::Context->preference('item-level_itypes'),
            patronimages                 => C4::Context->preference("patronimages"),
            singleBranchMode             => C4::Context->preference("singleBranchMode"),
            XSLTDetailsDisplay           => C4::Context->preference("XSLTDetailsDisplay"),
            XSLTResultsDisplay           => C4::Context->preference("XSLTResultsDisplay"),
            using_https                  => $in->{'query'}->https() ? 1 : 0,
            noItemTypeImages            => C4::Context->preference("noItemTypeImages"),
    );

    if ( $in->{'type'} eq "intranet" ) {
        $template->param(
            AmazonContent               => C4::Context->preference("AmazonContent"),
            AmazonCoverImages           => C4::Context->preference("AmazonCoverImages"),
            AmazonEnabled               => C4::Context->preference("AmazonEnabled"),
            AmazonSimilarItems          => C4::Context->preference("AmazonSimilarItems"),
            AutoLocation                => C4::Context->preference("AutoLocation"),
            "BiblioDefaultView".C4::Context->preference("IntranetBiblioDefaultView") => 1,
            CircAutocompl               => C4::Context->preference("CircAutocompl"),
            FRBRizeEditions             => C4::Context->preference("FRBRizeEditions"),
            IndependantBranches         => C4::Context->preference("IndependantBranches"),
            IntranetNav                 => C4::Context->preference("IntranetNav"),
            IntranetmainUserblock       => C4::Context->preference("IntranetmainUserblock"),
            LibraryName                 => C4::Context->preference("LibraryName"),
            LoginBranchname             => (C4::Context->userenv?C4::Context->userenv->{"branchname"}:"insecure"),
            advancedMARCEditor          => C4::Context->preference("advancedMARCEditor"),
            canreservefromotherbranches => C4::Context->preference('canreservefromotherbranches'),
            intranetcolorstylesheet     => C4::Context->preference("intranetcolorstylesheet"),
            IntranetFavicon             => C4::Context->preference("IntranetFavicon"),
            intranetreadinghistory      => C4::Context->preference("intranetreadinghistory"),
            intranetstylesheet          => C4::Context->preference("intranetstylesheet"),
            IntranetUserCSS             => C4::Context->preference("IntranetUserCSS"),
            intranetuserjs              => C4::Context->preference("intranetuserjs"),
            intranetbookbag             => C4::Context->preference("intranetbookbag"),
            suggestion                  => C4::Context->preference("suggestion"),
            virtualshelves              => C4::Context->preference("virtualshelves"),
            StaffSerialIssueDisplayCount => C4::Context->preference("StaffSerialIssueDisplayCount"),
            NoZebra                     => C4::Context->preference('NoZebra'),
		EasyAnalyticalRecords => C4::Context->preference('EasyAnalyticalRecords'),
        );
    }
    else {
        warn "template type should be OPAC, here it is=[" . $in->{'type'} . "]" unless ( $in->{'type'} eq 'opac' );
        #TODO : replace LibraryName syspref with 'system name', and remove this html processing
        my $LibraryNameTitle = C4::Context->preference("LibraryName");
        $LibraryNameTitle =~ s/<(?:\/?)(?:br|p)\s*(?:\/?)>/ /sgi;
        $LibraryNameTitle =~ s/<(?:[^<>'"]|'(?:[^']*)'|"(?:[^"]*)")*>//sg;
        # clean up the busc param in the session if the page is not opac-detail
        if (C4::Context->preference("OpacBrowseResults") && $in->{'template_name'} =~ /opac-(.+)\.(?:tt|tmpl)$/ && $1 !~ /^(?:MARC|ISBD)?detail$/) {
            my $sessionSearch = get_session($sessionID || $in->{'query'}->cookie("CGISESSID"));
            $sessionSearch->clear(["busc"]) if ($sessionSearch->param("busc"));
        }
        # variables passed from CGI: opac_css_override and opac_search_limits.
        my $opac_search_limit = $ENV{'OPAC_SEARCH_LIMIT'};
        my $opac_limit_override = $ENV{'OPAC_LIMIT_OVERRIDE'};
        my $opac_name = '';
        if (($opac_search_limit && $opac_search_limit =~ /branch:(\w+)/ && $opac_limit_override) || ($in->{'query'}->param('limit') && $in->{'query'}->param('limit') =~ /branch:(\w+)/)){
            $opac_name = $1;   # opac_search_limit is a branch, so we use it.
        } elsif (C4::Context->preference("SearchMyLibraryFirst") && C4::Context->userenv && C4::Context->userenv->{'branch'}) {
            $opac_name = C4::Context->userenv->{'branch'};
        }
	my $checkstyle = C4::Context->preference("opaccolorstylesheet");
	if ($checkstyle =~ /http/)
	{
            	$template->param( opacexternalsheet => $checkstyle);
	} else
	{
		my $opaccolorstylesheet = C4::Context->preference("opaccolorstylesheet");  
            $template->param( opaccolorstylesheet => $opaccolorstylesheet);
	}
        $template->param(
            AmazonContent             => "" . C4::Context->preference("AmazonContent"),
            AnonSuggestions           => "" . C4::Context->preference("AnonSuggestions"),
            AuthorisedValueImages     => C4::Context->preference("AuthorisedValueImages"),
            BranchesLoop              => GetBranchesLoop($opac_name),
            LibraryName               => "" . C4::Context->preference("LibraryName"),
            LibraryNameTitle          => "" . $LibraryNameTitle,
            LoginBranchname           => C4::Context->userenv?C4::Context->userenv->{"branchname"}:"",
            OPACAmazonEnabled         => C4::Context->preference("OPACAmazonEnabled"),
            OPACAmazonSimilarItems    => C4::Context->preference("OPACAmazonSimilarItems"),
            OPACAmazonCoverImages     => C4::Context->preference("OPACAmazonCoverImages"),
            OPACAmazonReviews         => C4::Context->preference("OPACAmazonReviews"),
            OPACFRBRizeEditions       => C4::Context->preference("OPACFRBRizeEditions"),
            OpacHighlightedWords       => C4::Context->preference("OpacHighlightedWords"),
            OPACItemHolds             => C4::Context->preference("OPACItemHolds"),
            OPACShelfBrowser          => "". C4::Context->preference("OPACShelfBrowser"),
            OpacShowRecentComments    => C4::Context->preference("OpacShowRecentComments"),
            OPACURLOpenInNewWindow    => "" . C4::Context->preference("OPACURLOpenInNewWindow"),
            OPACUserCSS               => "". C4::Context->preference("OPACUserCSS"),
            OPACViewOthersSuggestions => "" . C4::Context->preference("OPACViewOthersSuggestions"),
            OpacAuthorities           => C4::Context->preference("OpacAuthorities"),
            OPACBaseURL               => ($in->{'query'}->https() ? "https://" : "http://") . $ENV{'SERVER_NAME'} .
                   ($ENV{'SERVER_PORT'} eq ($in->{'query'}->https() ? "443" : "80") ? '' : ":$ENV{'SERVER_PORT'}"),
            opac_css_override           => $ENV{'OPAC_CSS_OVERRIDE'},
            opac_search_limit         => $opac_search_limit,
            opac_limit_override       => $opac_limit_override,
            OpacBrowser               => C4::Context->preference("OpacBrowser"),
            OpacCloud                 => C4::Context->preference("OpacCloud"),
            OpacKohaUrl               => C4::Context->preference("OpacKohaUrl"),
            OpacMainUserBlock         => "" . C4::Context->preference("OpacMainUserBlock"),
            OpacNav                   => "" . C4::Context->preference("OpacNav"),
            OpacNavBottom             => "" . C4::Context->preference("OpacNavBottom"),
            OpacPasswordChange        => C4::Context->preference("OpacPasswordChange"),
            OPACPatronDetails        => C4::Context->preference("OPACPatronDetails"),
            OPACPrivacy               => C4::Context->preference("OPACPrivacy"),
            OPACFinesTab              => C4::Context->preference("OPACFinesTab"),
            OpacTopissue              => C4::Context->preference("OpacTopissue"),
            RequestOnOpac             => C4::Context->preference("RequestOnOpac"),
            'Version'                 => C4::Context->preference('Version'),
            hidelostitems             => C4::Context->preference("hidelostitems"),
            mylibraryfirst            => (C4::Context->preference("SearchMyLibraryFirst") && C4::Context->userenv) ? C4::Context->userenv->{'branch'} : '',
            opaclayoutstylesheet      => "" . C4::Context->preference("opaclayoutstylesheet"),
            opacstylesheet            => "" . C4::Context->preference("opacstylesheet"),
            opacbookbag               => "" . C4::Context->preference("opacbookbag"),
            opaccredits               => "" . C4::Context->preference("opaccredits"),
            OpacFavicon               => C4::Context->preference("OpacFavicon"),
            opacheader                => "" . C4::Context->preference("opacheader"),
            opaclanguagesdisplay      => "" . C4::Context->preference("opaclanguagesdisplay"),
            opacreadinghistory        => C4::Context->preference("opacreadinghistory"),
            opacsmallimage            => "" . C4::Context->preference("opacsmallimage"),
            opacuserjs                => C4::Context->preference("opacuserjs"),
            opacuserlogin             => "" . C4::Context->preference("opacuserlogin"),
            reviewson                 => C4::Context->preference("reviewson"),
            ShowReviewer              => C4::Context->preference("ShowReviewer"),
            ShowReviewerPhoto         => C4::Context->preference("ShowReviewerPhoto"),
            suggestion                => "" . C4::Context->preference("suggestion"),
            virtualshelves            => "" . C4::Context->preference("virtualshelves"),
            OPACSerialIssueDisplayCount => C4::Context->preference("OPACSerialIssueDisplayCount"),
            OpacAddMastheadLibraryPulldown => C4::Context->preference("OpacAddMastheadLibraryPulldown"),
            OPACXSLTDetailsDisplay           => C4::Context->preference("OPACXSLTDetailsDisplay"),
            OPACXSLTResultsDisplay           => C4::Context->preference("OPACXSLTResultsDisplay"),
            SyndeticsClientCode          => C4::Context->preference("SyndeticsClientCode"),
            SyndeticsEnabled             => C4::Context->preference("SyndeticsEnabled"),
            SyndeticsCoverImages         => C4::Context->preference("SyndeticsCoverImages"),
            SyndeticsTOC                 => C4::Context->preference("SyndeticsTOC"),
            SyndeticsSummary             => C4::Context->preference("SyndeticsSummary"),
            SyndeticsEditions            => C4::Context->preference("SyndeticsEditions"),
            SyndeticsExcerpt             => C4::Context->preference("SyndeticsExcerpt"),
            SyndeticsReviews             => C4::Context->preference("SyndeticsReviews"),
            SyndeticsAuthorNotes         => C4::Context->preference("SyndeticsAuthorNotes"),
            SyndeticsAwards              => C4::Context->preference("SyndeticsAwards"),
            SyndeticsSeries              => C4::Context->preference("SyndeticsSeries"),
            SyndeticsCoverImageSize      => C4::Context->preference("SyndeticsCoverImageSize"),
        );

        $template->param(OpacPublic => '1') if ($user || C4::Context->preference("OpacPublic"));
    }
    return ( $template, $borrowernumber, $cookie, $flags);
}

=head2 checkauth

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

Koha also has a concept of sub-permissions, also known as
granular permissions.  This makes the value of each key
in the C<flagsrequired> hash take on an additional
meaning, i.e.,

 1

The user must have access to all subfunctions of the module
specified by the hash key.

 *

The user must have access to at least one subfunction of the module
specified by the hash key.

 specific permission, e.g., 'export_catalog'

The user must have access to the specific subfunction list, which
must correspond to a row in the permissions table.

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

sub _version_check ($$) {
    my $type = shift;
    my $query = shift;
    my $version;
    # If Version syspref is unavailable, it means Koha is beeing installed,
    # and so we must redirect to OPAC maintenance page or to the WebInstaller
	# also, if OpacMaintenance is ON, OPAC should redirect to maintenance
	if (C4::Context->preference('OpacMaintenance') && $type eq 'opac') {
        warn "OPAC Install required, redirecting to maintenance";
        print $query->redirect("/cgi-bin/koha/maintenance.pl");
        safe_exit;
    }
    unless ( $version = C4::Context->preference('Version') ) {    # assignment, not comparison
        if ( $type ne 'opac' ) {
            warn "Install required, redirecting to Installer";
            print $query->redirect("/cgi-bin/koha/installer/install.pl");
        } else {
            warn "OPAC Install required, redirecting to maintenance";
            print $query->redirect("/cgi-bin/koha/maintenance.pl");
        }
        safe_exit;
    }

    # check that database and koha version are the same
    # there is no DB version, it's a fresh install,
    # go to web installer
    # there is a DB version, compare it to the code version
    my $kohaversion=C4::Context::KOHAVERSION;
    # remove the 3 last . to have a Perl number
    $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    $debug and print STDERR "kohaversion : $kohaversion\n";
    if ($version < $kohaversion){
        my $warning = "Database update needed, redirecting to %s. Database is $version and Koha is $kohaversion";
        if ($type ne 'opac'){
            warn sprintf($warning, 'Installer');
            print $query->redirect("/cgi-bin/koha/installer/install.pl?step=3");
        } else {
            warn sprintf("OPAC: " . $warning, 'maintenance');
            print $query->redirect("/cgi-bin/koha/maintenance.pl");
        }
        safe_exit;
    }
}

sub _session_log {
    (@_) or return 0;
    open L, ">>/tmp/sessionlog" or warn "ERROR: Cannot append to /tmp/sessionlog";
    printf L join("\n",@_);
    close L;
}

sub _timeout_syspref {
    my $timeout = C4::Context->preference('timeout') || 600;
    # value in days, convert in seconds
    if ($timeout =~ /(\d+)[dD]/) {
        $timeout = $1 * 86400;
    };
    return $timeout;
}

sub checkauth {
    my $query = shift;
	$debug and warn "Checking Auth";
    # $authnotrequired will be set for scripts which will run without authentication
    my $authnotrequired = shift;
    my $flagsrequired   = shift;
    my $type            = shift;
    $type = 'opac' unless $type;

    my $dbh     = C4::Context->dbh;
    my $timeout = _timeout_syspref();

    _version_check($type,$query);
    # state variables
    my $loggedin = 0;
    my %info;
    my ( $userid, $cookie, $sessionID, $flags, $barshelves, $pubshelves );
    my $logout = $query->param('logout.x');

    # This parameter is the name of the CAS server we want to authenticate against,
    # when using authentication against multiple CAS servers, as configured in Auth_cas_servers.yaml
    my $casparam = $query->param('cas');

    if ( $userid = $ENV{'REMOTE_USER'} ) {
        # Using Basic Authentication, no cookies required
        $cookie = $query->cookie(
            -name    => 'CGISESSID',
            -value   => '',
            -expires => ''
        );
        $loggedin = 1;
    }
    elsif ( $sessionID = $query->cookie("CGISESSID")) {     # assignment, not comparison
        my $session = get_session($sessionID);
        C4::Context->_new_userenv($sessionID);
        my ($ip, $lasttime, $sessiontype);
        if ($session){
            C4::Context::set_userenv(
                $session->param('number'),       $session->param('id'),
                $session->param('cardnumber'),   $session->param('firstname'),
                $session->param('surname'),      $session->param('branch'),
                $session->param('branchname'),   $session->param('flags'),
                $session->param('emailaddress'), $session->param('branchprinter')
            );
            C4::Context::set_shelves_userenv('bar',$session->param('barshelves'));
            C4::Context::set_shelves_userenv('pub',$session->param('pubshelves'));
            C4::Context::set_shelves_userenv('tot',$session->param('totshelves'));
            $debug and printf STDERR "AUTH_SESSION: (%s)\t%s %s - %s\n", map {$session->param($_)} qw(cardnumber firstname surname branch) ;
            $ip       = $session->param('ip');
            $lasttime = $session->param('lasttime');
            $userid   = $session->param('id');
			$sessiontype = $session->param('sessiontype');
        }
        if ( ( ($query->param('koha_login_context')) && ($query->param('userid') ne $session->param('id')) )
          || ( $cas && $query->param('ticket') ) ) {
            #if a user enters an id ne to the id in the current session, we need to log them in...
            #first we need to clear the anonymous session...
            $debug and warn "query id = " . $query->param('userid') . " but session id = " . $session->param('id');
            $session->flush;      
            $session->delete();
            C4::Context->_unset_userenv($sessionID);
			$sessionID = undef;
			$userid = undef;
		}
        elsif ($logout) {
            # voluntary logout the user
            $session->flush;
            $session->delete();
            C4::Context->_unset_userenv($sessionID);
            #_session_log(sprintf "%20s from %16s logged out at %30s (manually).\n", $userid,$ip,(strftime "%c",localtime));
            $sessionID = undef;
            $userid    = undef;

	    if ($cas and $caslogout) {
		logout_cas($query);
	    }
        }
        elsif ( $lasttime < time() - $timeout ) {
            # timed logout
            $info{'timed_out'} = 1;
            $session->delete();
            C4::Context->_unset_userenv($sessionID);
            #_session_log(sprintf "%20s from %16s logged out at %30s (inactivity).\n", $userid,$ip,(strftime "%c",localtime));
            $userid    = undef;
            $sessionID = undef;
        }
        elsif ( $ip ne $ENV{'REMOTE_ADDR'} ) {
            # Different ip than originally logged in from
            $info{'oldip'}        = $ip;
            $info{'newip'}        = $ENV{'REMOTE_ADDR'};
            $info{'different_ip'} = 1;
            $session->delete();
            C4::Context->_unset_userenv($sessionID);
            #_session_log(sprintf "%20s from %16s logged out at %30s (ip changed to %16s).\n", $userid,$ip,(strftime "%c",localtime), $info{'newip'});
            $sessionID = undef;
            $userid    = undef;
        }
        else {
            $cookie = $query->cookie( CGISESSID => $session->id );
            $session->param('lasttime',time());
            unless ( $sessiontype && $sessiontype eq 'anon' ) { #if this is an anonymous session, we want to update the session, but not behave as if they are logged in...
                $flags = haspermission($userid, $flagsrequired);
                if ($flags) {
                    $loggedin = 1;
                } else {
                    $info{'nopermission'} = 1;
                }
            }
        }
    }
    unless ($userid || $sessionID) {
        #we initiate a session prior to checking for a username to allow for anonymous sessions...
		my $session = get_session("") or die "Auth ERROR: Cannot get_session()";
        my $sessionID = $session->id;
       	C4::Context->_new_userenv($sessionID);
        $cookie = $query->cookie(CGISESSID => $sessionID);
	    $userid    = $query->param('userid');
            if (($cas && $query->param('ticket')) || $userid) {
        	my $password = $query->param('password');
		my ($return, $cardnumber);
		if ($cas && $query->param('ticket')) {
		    my $retuserid;
		    ( $return, $cardnumber, $retuserid ) = checkpw( $dbh, $userid, $password, $query );
		    $userid = $retuserid;
		    $info{'invalidCasLogin'} = 1 unless ($return);
        	} else {
		    my $retuserid;
		    ( $return, $cardnumber, $retuserid ) = checkpw( $dbh, $userid, $password, $query );
		    $userid = $retuserid if ($retuserid ne '');
		}
		if ($return) {
               #_session_log(sprintf "%20s from %16s logged in  at %30s.\n", $userid,$ENV{'REMOTE_ADDR'},(strftime '%c', localtime));
            	if ( $flags = haspermission(  $userid, $flagsrequired ) ) {
					$loggedin = 1;
            	}
           		else {
                	$info{'nopermission'} = 1;
                	C4::Context->_unset_userenv($sessionID);
            	}

				my ($borrowernumber, $firstname, $surname, $userflags,
					$branchcode, $branchname, $branchprinter, $emailaddress);

            	if ( $return == 1 ) {
                	my $select = "
                	SELECT borrowernumber, firstname, surname, flags, borrowers.branchcode, 
                    	    branches.branchname    as branchname, 
                        	branches.branchprinter as branchprinter, 
                        	email 
                	FROM borrowers 
                	LEFT JOIN branches on borrowers.branchcode=branches.branchcode
                	";
                	my $sth = $dbh->prepare("$select where userid=?");
                	$sth->execute($userid);
			unless ($sth->rows) {
		    	    $debug and print STDERR "AUTH_1: no rows for userid='$userid'\n";
		    	    $sth = $dbh->prepare("$select where cardnumber=?");
		       	    $sth->execute($cardnumber);

		    	    unless ($sth->rows) {
				$debug and print STDERR "AUTH_2a: no rows for cardnumber='$cardnumber'\n";
				$sth->execute($userid);
				unless ($sth->rows) {
				    $debug and print STDERR "AUTH_2b: no rows for userid='$userid' AS cardnumber\n";
				}
			    }
			}
                	if ($sth->rows) {
			    ($borrowernumber, $firstname, $surname, $userflags,
                    		$branchcode, $branchname, $branchprinter, $emailaddress) = $sth->fetchrow;
						$debug and print STDERR "AUTH_3 results: " .
							"$cardnumber,$borrowernumber,$userid,$firstname,$surname,$userflags,$branchcode,$emailaddress\n";
					} else {
						print STDERR "AUTH_3: no results for userid='$userid', cardnumber='$cardnumber'.\n";
					}

# launch a sequence to check if we have a ip for the branch, i
# if we have one we replace the branchcode of the userenv by the branch bound in the ip.

					my $ip       = $ENV{'REMOTE_ADDR'};
					# if they specify at login, use that
					if ($query->param('branch')) {
						$branchcode  = $query->param('branch');
						$branchname = GetBranchName($branchcode);
					}
					my $branches = GetBranches();
					if (C4::Context->boolean_preference('IndependantBranches') && C4::Context->boolean_preference('Autolocation')){
						# we have to check they are coming from the right ip range
						my $domain = $branches->{$branchcode}->{'branchip'};
						if ($ip !~ /^$domain/){
							$loggedin=0;
							$info{'wrongip'} = 1;
						}
					}

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
					$debug and printf STDERR "AUTH_4: (%s)\t%s %s - %s\n", map {$session->param($_)} qw(cardnumber firstname surname branch) ;
				}
				elsif ( $return == 2 ) {
					#We suppose the user is the superlibrarian
					$borrowernumber = 0;
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
				C4::Context::set_userenv(
					$session->param('number'),       $session->param('id'),
					$session->param('cardnumber'),   $session->param('firstname'),
					$session->param('surname'),      $session->param('branch'),
					$session->param('branchname'),   $session->param('flags'),
					$session->param('emailaddress'), $session->param('branchprinter')
				);

				# Grab borrower's shelves and public shelves and add them to the session
				# $row_count determines how many records are returned from the db query
				# and the number of lists to be displayed of each type in the 'Lists' button drop down
				my $row_count = 10; # FIXME:This probably should be a syspref
				my ($total, $totshelves, $barshelves, $pubshelves);
				($barshelves, $totshelves) = C4::VirtualShelves::GetRecentShelves(1, $row_count, $borrowernumber);
				$total->{'bartotal'} = $totshelves;
				($pubshelves, $totshelves) = C4::VirtualShelves::GetRecentShelves(2, $row_count, undef);
				$total->{'pubtotal'} = $totshelves;
				$session->param('barshelves', $barshelves);
				$session->param('pubshelves', $pubshelves);
				$session->param('totshelves', $total);

				C4::Context::set_shelves_userenv('bar',$barshelves);
				C4::Context::set_shelves_userenv('pub',$pubshelves);
				C4::Context::set_shelves_userenv('tot',$total);
			}
        	else {
            	if ($userid) {
                	$info{'invalid_username_or_password'} = 1;
                	C4::Context->_unset_userenv($sessionID);
            	}
			}
        }	# END if ( $userid    = $query->param('userid') )
		elsif ($type eq "opac") {
            # if we are here this is an anonymous session; add public lists to it and a few other items...
            # anonymous sessions are created only for the OPAC
			$debug and warn "Initiating an anonymous session...";

			# Grab the public shelves and add to the session...
			my $row_count = 20; # FIXME:This probably should be a syspref
			my ($total, $totshelves, $pubshelves);
			($pubshelves, $totshelves) = C4::VirtualShelves::GetRecentShelves(2, $row_count, undef);
			$total->{'pubtotal'} = $totshelves;
			$session->param('pubshelves', $pubshelves);
			$session->param('totshelves', $total);
			C4::Context::set_shelves_userenv('pub',$pubshelves);
			C4::Context::set_shelves_userenv('tot',$total);

			# setting a couple of other session vars...
			$session->param('ip',$session->remote_addr());
			$session->param('lasttime',time());
			$session->param('sessiontype','anon');
		}
    }	# END unless ($userid)
    my $insecure = C4::Context->boolean_preference('insecure');

    # finished authentification, now respond
    if ( $loggedin || $authnotrequired || ( defined($insecure) && $insecure ) )
    {
        # successful login
        unless ($cookie) {
            $cookie = $query->cookie( CGISESSID => '' );
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
        (next) if ( $name eq 'userid' || $name eq 'password' || $name eq 'ticket' );
        my $value = $query->param($name);
        push @inputs, { name => $name, value => $value };
    }
    # get the branchloop, which we need for authentication
    my $branches = GetBranches();
    my @branch_loop;
    for my $branch_hash (sort keys %$branches) {
		push @branch_loop, {branchcode => "$branch_hash", branchname => $branches->{$branch_hash}->{'branchname'}, };
    }

    my $template_name = ( $type eq 'opac' ) ? 'opac-auth.tmpl' : 'auth.tmpl';
    my $template = C4::Templates::gettemplate( $template_name, $type, $query );
    $template->param(branchloop => \@branch_loop,);
    my $checkstyle = C4::Context->preference("opaccolorstylesheet");
    if ($checkstyle =~ /\//)
	{
            	$template->param( opacexternalsheet => $checkstyle);
	} else
	{
		my $opaccolorstylesheet = C4::Context->preference("opaccolorstylesheet");  
            $template->param( opaccolorstylesheet => $opaccolorstylesheet);
	}
    $template->param(
    login        => 1,
        INPUTS               => \@inputs,
        casAuthentication    => C4::Context->preference("casAuthentication"),
        suggestion           => C4::Context->preference("suggestion"),
        virtualshelves       => C4::Context->preference("virtualshelves"),
        LibraryName          => C4::Context->preference("LibraryName"),
        opacuserlogin        => C4::Context->preference("opacuserlogin"),
        OpacNav              => C4::Context->preference("OpacNav"),
        OpacNavBottom        => C4::Context->preference("OpacNavBottom"),
        opaccredits          => C4::Context->preference("opaccredits"),
        OpacFavicon          => C4::Context->preference("OpacFavicon"),
        opacreadinghistory   => C4::Context->preference("opacreadinghistory"),
        opacsmallimage       => C4::Context->preference("opacsmallimage"),
        opaclayoutstylesheet => C4::Context->preference("opaclayoutstylesheet"),
        opaclanguagesdisplay => C4::Context->preference("opaclanguagesdisplay"),
        opacuserjs           => C4::Context->preference("opacuserjs"),
        opacbookbag          => "" . C4::Context->preference("opacbookbag"),
        OpacCloud            => C4::Context->preference("OpacCloud"),
        OpacTopissue         => C4::Context->preference("OpacTopissue"),
        OpacAuthorities      => C4::Context->preference("OpacAuthorities"),
        OpacBrowser          => C4::Context->preference("OpacBrowser"),
        opacheader           => C4::Context->preference("opacheader"),
        TagsEnabled                  => C4::Context->preference("TagsEnabled"),
        OPACUserCSS           => C4::Context->preference("OPACUserCSS"),
        opacstylesheet       => C4::Context->preference("opacstylesheet"),
        intranetcolorstylesheet =>
								C4::Context->preference("intranetcolorstylesheet"),
        intranetstylesheet => C4::Context->preference("intranetstylesheet"),
        intranetbookbag    => C4::Context->preference("intranetbookbag"),
        IntranetNav        => C4::Context->preference("IntranetNav"),
        intranetuserjs     => C4::Context->preference("intranetuserjs"),
        IndependantBranches=> C4::Context->preference("IndependantBranches"),
        AutoLocation       => C4::Context->preference("AutoLocation"),
		wrongip            => $info{'wrongip'},
    );

    $template->param( OpacPublic => C4::Context->preference("OpacPublic"));
    $template->param( loginprompt => 1 ) unless $info{'nopermission'};

    if ($cas) {

	# Is authentication against multiple CAS servers enabled?
        if (C4::Auth_with_cas::multipleAuth && !$casparam) {
	    my $casservers = C4::Auth_with_cas::getMultipleAuth();		    
	    my @tmplservers;
	    foreach my $key (keys %$casservers) {
		push @tmplservers, {name => $key, value => login_cas_url($query, $key) . "?cas=$key" };
	    }
	    #warn Data::Dumper::Dumper(\@tmplservers);
	    $template->param(
		casServersLoop => \@tmplservers
	    );
	} else {
        $template->param(
            casServerUrl    => login_cas_url($query),
	    );
	}

	$template->param(
            invalidCasLogin => $info{'invalidCasLogin'}
        );
    }

    my $self_url = $query->url( -absolute => 1 );
    $template->param(
        url         => $self_url,
        LibraryName => C4::Context->preference("LibraryName"),
    );
    $template->param( %info );
#    $cookie = $query->cookie(CGISESSID => $session->id
#   );
    print $query->header(
        -type   => 'text/html',
        -charset => 'utf-8',
        -cookie => $cookie
      ),
      $template->output;
    safe_exit;
}

=head2 check_api_auth

  ($status, $cookie, $sessionId) = check_api_auth($query, $userflags);

Given a CGI query containing the parameters 'userid' and 'password' and/or a session
cookie, determine if the user has the privileges specified by C<$userflags>.

C<check_api_auth> is is meant for authenticating users of web services, and
consequently will always return and will not attempt to redirect the user
agent.

If a valid session cookie is already present, check_api_auth will return a status
of "ok", the cookie, and the Koha session ID.

If no session cookie is present, check_api_auth will check the 'userid' and 'password
parameters and create a session cookie and Koha session if the supplied credentials
are OK.

Possible return values in C<$status> are:

=over

=item "ok" -- user authenticated; C<$cookie> and C<$sessionid> have valid values.

=item "failed" -- credentials are not correct; C<$cookie> and C<$sessionid> are undef

=item "maintenance" -- DB is in maintenance mode; no login possible at the moment

=item "expired -- session cookie has expired; API user should resubmit userid and password

=back

=cut

sub check_api_auth {
    my $query = shift;
    my $flagsrequired = shift;

    my $dbh     = C4::Context->dbh;
    my $timeout = _timeout_syspref();

    unless (C4::Context->preference('Version')) {
        # database has not been installed yet
        return ("maintenance", undef, undef);
    }
    my $kohaversion=C4::Context::KOHAVERSION;
    $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    if (C4::Context->preference('Version') < $kohaversion) {
        # database in need of version update; assume that
        # no API should be called while databsae is in
        # this condition.
        return ("maintenance", undef, undef);
    }

    # FIXME -- most of what follows is a copy-and-paste
    # of code from checkauth.  There is an obvious need
    # for refactoring to separate the various parts of
    # the authentication code, but as of 2007-11-19 this
    # is deferred so as to not introduce bugs into the
    # regular authentication code for Koha 3.0.

    # see if we have a valid session cookie already
    # however, if a userid parameter is present (i.e., from
    # a form submission, assume that any current cookie
    # is to be ignored
    my $sessionID = undef;
    unless ($query->param('userid')) {
        $sessionID = $query->cookie("CGISESSID");
    }
    if ($sessionID && not ($cas && $query->param('PT')) ) {
        my $session = get_session($sessionID);
        C4::Context->_new_userenv($sessionID);
        if ($session) {
            C4::Context::set_userenv(
                $session->param('number'),       $session->param('id'),
                $session->param('cardnumber'),   $session->param('firstname'),
                $session->param('surname'),      $session->param('branch'),
                $session->param('branchname'),   $session->param('flags'),
                $session->param('emailaddress'), $session->param('branchprinter')
            );

            my $ip = $session->param('ip');
            my $lasttime = $session->param('lasttime');
            my $userid = $session->param('id');
            if ( $lasttime < time() - $timeout ) {
                # time out
                $session->delete();
                C4::Context->_unset_userenv($sessionID);
                $userid    = undef;
                $sessionID = undef;
                return ("expired", undef, undef);
            } elsif ( $ip ne $ENV{'REMOTE_ADDR'} ) {
                # IP address changed
                $session->delete();
                C4::Context->_unset_userenv($sessionID);
                $userid    = undef;
                $sessionID = undef;
                return ("expired", undef, undef);
            } else {
                my $cookie = $query->cookie( CGISESSID => $session->id );
                $session->param('lasttime',time());
                my $flags = haspermission($userid, $flagsrequired);
                if ($flags) {
                    return ("ok", $cookie, $sessionID);
                } else {
                    $session->delete();
                    C4::Context->_unset_userenv($sessionID);
                    $userid    = undef;
                    $sessionID = undef;
                    return ("failed", undef, undef);
                }
            }
        } else {
            return ("expired", undef, undef);
        }
    } else {
        # new login
        my $userid = $query->param('userid');
        my $password = $query->param('password');
       	my ($return, $cardnumber);

	# Proxy CAS auth
	if ($cas && $query->param('PT')) {
	    my $retuserid;
	    $debug and print STDERR "## check_api_auth - checking CAS\n";
	    # In case of a CAS authentication, we use the ticket instead of the password
	    my $PT = $query->param('PT');
	    ($return,$cardnumber,$userid) = check_api_auth_cas($dbh, $PT, $query);    # EXTERNAL AUTH
	} else {
	    # User / password auth
	    unless ($userid and $password) {
		# caller did something wrong, fail the authenticateion
		return ("failed", undef, undef);
	    }
	    ( $return, $cardnumber ) = checkpw( $dbh, $userid, $password, $query );
	}

        if ($return and haspermission(  $userid, $flagsrequired)) {
            my $session = get_session("");
            return ("failed", undef, undef) unless $session;

            my $sessionID = $session->id;
            C4::Context->_new_userenv($sessionID);
            my $cookie = $query->cookie(CGISESSID => $sessionID);
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
                ) = $sth->fetchrow if ( $sth->rows );

                unless ($sth->rows ) {
                    my $sth = $dbh->prepare(
"select borrowernumber, firstname, surname, flags, borrowers.branchcode, branches.branchname as branchname, branches.branchprinter as branchprinter, email from borrowers left join branches on borrowers.branchcode=branches.branchcode where cardnumber=?"
                      );
                    $sth->execute($cardnumber);
                    (
                        $borrowernumber, $firstname,  $surname,
                        $userflags,      $branchcode, $branchname,
                        $branchprinter,  $emailaddress
                    ) = $sth->fetchrow if ( $sth->rows );

                    unless ( $sth->rows ) {
                        $sth->execute($userid);
                        (
                            $borrowernumber, $firstname, $surname, $userflags,
                            $branchcode, $branchname, $branchprinter, $emailaddress
                        ) = $sth->fetchrow if ( $sth->rows );
                    }
                }

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
            } elsif ( $return == 2 ) {
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
            C4::Context::set_userenv(
                $session->param('number'),       $session->param('id'),
                $session->param('cardnumber'),   $session->param('firstname'),
                $session->param('surname'),      $session->param('branch'),
                $session->param('branchname'),   $session->param('flags'),
                $session->param('emailaddress'), $session->param('branchprinter')
            );
            return ("ok", $cookie, $sessionID);
        } else {
            return ("failed", undef, undef);
        }
    }
}

=head2 check_cookie_auth

  ($status, $sessionId) = check_api_auth($cookie, $userflags);

Given a CGISESSID cookie set during a previous login to Koha, determine
if the user has the privileges specified by C<$userflags>.

C<check_cookie_auth> is meant for authenticating special services
such as tools/upload-file.pl that are invoked by other pages that
have been authenticated in the usual way.

Possible return values in C<$status> are:

=over

=item "ok" -- user authenticated; C<$sessionID> have valid values.

=item "failed" -- credentials are not correct; C<$sessionid> are undef

=item "maintenance" -- DB is in maintenance mode; no login possible at the moment

=item "expired -- session cookie has expired; API user should resubmit userid and password

=back

=cut

sub check_cookie_auth {
    my $cookie = shift;
    my $flagsrequired = shift;

    my $dbh     = C4::Context->dbh;
    my $timeout = _timeout_syspref();

    unless (C4::Context->preference('Version')) {
        # database has not been installed yet
        return ("maintenance", undef);
    }
    my $kohaversion=C4::Context::KOHAVERSION;
    $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    if (C4::Context->preference('Version') < $kohaversion) {
        # database in need of version update; assume that
        # no API should be called while databsae is in
        # this condition.
        return ("maintenance", undef);
    }

    # FIXME -- most of what follows is a copy-and-paste
    # of code from checkauth.  There is an obvious need
    # for refactoring to separate the various parts of
    # the authentication code, but as of 2007-11-23 this
    # is deferred so as to not introduce bugs into the
    # regular authentication code for Koha 3.0.

    # see if we have a valid session cookie already
    # however, if a userid parameter is present (i.e., from
    # a form submission, assume that any current cookie
    # is to be ignored
    unless (defined $cookie and $cookie) {
        return ("failed", undef);
    }
    my $sessionID = $cookie;
    my $session = get_session($sessionID);
    C4::Context->_new_userenv($sessionID);
    if ($session) {
        C4::Context::set_userenv(
            $session->param('number'),       $session->param('id'),
            $session->param('cardnumber'),   $session->param('firstname'),
            $session->param('surname'),      $session->param('branch'),
            $session->param('branchname'),   $session->param('flags'),
            $session->param('emailaddress'), $session->param('branchprinter')
        );

        my $ip = $session->param('ip');
        my $lasttime = $session->param('lasttime');
        my $userid = $session->param('id');
        if ( $lasttime < time() - $timeout ) {
            # time out
            $session->delete();
            C4::Context->_unset_userenv($sessionID);
            $userid    = undef;
            $sessionID = undef;
            return ("expired", undef);
        } elsif ( $ip ne $ENV{'REMOTE_ADDR'} ) {
            # IP address changed
            $session->delete();
            C4::Context->_unset_userenv($sessionID);
            $userid    = undef;
            $sessionID = undef;
            return ("expired", undef);
        } else {
            $session->param('lasttime',time());
            my $flags = haspermission($userid, $flagsrequired);
            if ($flags) {
                return ("ok", $sessionID);
            } else {
                $session->delete();
                C4::Context->_unset_userenv($sessionID);
                $userid    = undef;
                $sessionID = undef;
                return ("failed", undef);
            }
        }
    } else {
        return ("expired", undef);
    }
}

=head2 get_session

  use CGI::Session;
  my $session = get_session($sessionID);

Given a session ID, retrieve the CGI::Session object used to store
the session's state.  The session object can be used to store
data that needs to be accessed by different scripts during a
user's session.

If the C<$sessionID> parameter is an empty string, a new session
will be created.

=cut

sub get_session {
    my $sessionID = shift;
    my $storage_method = C4::Context->preference('SessionStorage');
    my $dbh = C4::Context->dbh;
    my $session;
    if ($storage_method eq 'mysql'){
        $session = new CGI::Session("driver:MySQL;serializer:yaml;id:md5", $sessionID, {Handle=>$dbh});
    }
    elsif ($storage_method eq 'Pg') {
        $session = new CGI::Session("driver:PostgreSQL;serializer:yaml;id:md5", $sessionID, {Handle=>$dbh});
    }
    elsif ($storage_method eq 'memcached' && $servers){
	$session = new CGI::Session("driver:memcached;serializer:yaml;id:md5", $sessionID, { Memcached => $memcached } );
    }
    else {
        # catch all defaults to tmp should work on all systems
        $session = new CGI::Session("driver:File;serializer:yaml;id:md5", $sessionID, {Directory=>'/tmp'});
    }
    return $session;
}

sub checkpw {

    my ( $dbh, $userid, $password, $query ) = @_;
    if ($ldap) {
        $debug and print STDERR "## checkpw - checking LDAP\n";
        my ($retval,$retcard,$retuserid) = checkpw_ldap(@_);    # EXTERNAL AUTH
        ($retval) and return ($retval,$retcard,$retuserid);
    }

    if ($cas && $query && $query->param('ticket')) {
        $debug and print STDERR "## checkpw - checking CAS\n";
	# In case of a CAS authentication, we use the ticket instead of the password
	my $ticket = $query->param('ticket');
        my ($retval,$retcard,$retuserid) = checkpw_cas($dbh, $ticket, $query);    # EXTERNAL AUTH
        ($retval) and return ($retval,$retcard,$retuserid);
	return 0;
    }

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
        if ( md5_base64($password) eq $md5password and $md5password ne "!") {

            C4::Context->set_userenv( "$borrowernumber", $userid, $cardnumber,
                $firstname, $surname, $branchcode, $flags );
            return 1, $cardnumber, $userid;
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
            return 1, $cardnumber, $userid;
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

=head2 getuserflags

    my $authflags = getuserflags($flags, $userid, [$dbh]);

Translates integer flags into permissions strings hash.

C<$flags> is the integer userflags value ( borrowers.userflags )
C<$userid> is the members.userid, used for building subpermissions
C<$authflags> is a hashref of permissions

=cut

sub getuserflags {
    my $flags   = shift;
    my $userid  = shift;
    my $dbh     = @_ ? shift : C4::Context->dbh;
    my $userflags;
    $flags = 0 unless $flags;
    my $sth = $dbh->prepare("SELECT bit, flag, defaulton FROM userflags");
    $sth->execute;

    while ( my ( $bit, $flag, $defaulton ) = $sth->fetchrow ) {
        if ( ( $flags & ( 2**$bit ) ) || $defaulton ) {
            $userflags->{$flag} = 1;
        }
        else {
            $userflags->{$flag} = 0;
        }
    }

    # get subpermissions and merge with top-level permissions
    my $user_subperms = get_user_subpermissions($userid);
    foreach my $module (keys %$user_subperms) {
        next if $userflags->{$module} == 1; # user already has permission for everything in this module
        $userflags->{$module} = $user_subperms->{$module};
    }

    return $userflags;
}

=head2 get_user_subpermissions

  $user_perm_hashref = get_user_subpermissions($userid);

Given the userid (note, not the borrowernumber) of a staff user,
return a hashref of hashrefs of the specific subpermissions
accorded to the user.  An example return is

 {
    tools => {
        export_catalog => 1,
        import_patrons => 1,
    }
 }

The top-level hash-key is a module or function code from
userflags.flag, while the second-level key is a code
from permissions.

The results of this function do not give a complete picture
of the functions that a staff user can access; it is also
necessary to check borrowers.flags.

=cut

sub get_user_subpermissions {
    my $userid = shift;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT flag, user_permissions.code
                             FROM user_permissions
                             JOIN permissions USING (module_bit, code)
                             JOIN userflags ON (module_bit = bit)
                             JOIN borrowers USING (borrowernumber)
                             WHERE userid = ?");
    $sth->execute($userid);

    my $user_perms = {};
    while (my $perm = $sth->fetchrow_hashref) {
        $user_perms->{$perm->{'flag'}}->{$perm->{'code'}} = 1;
    }
    return $user_perms;
}

=head2 get_all_subpermissions

  my $perm_hashref = get_all_subpermissions();

Returns a hashref of hashrefs defining all specific
permissions currently defined.  The return value
has the same structure as that of C<get_user_subpermissions>,
except that the innermost hash value is the description
of the subpermission.

=cut

sub get_all_subpermissions {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT flag, code, description
                             FROM permissions
                             JOIN userflags ON (module_bit = bit)");
    $sth->execute();

    my $all_perms = {};
    while (my $perm = $sth->fetchrow_hashref) {
        $all_perms->{$perm->{'flag'}}->{$perm->{'code'}} = $perm->{'description'};
    }
    return $all_perms;
}

=head2 haspermission

  $flags = ($userid, $flagsrequired);

C<$userid> the userid of the member
C<$flags> is a hashref of required flags like C<$borrower-&lt;{authflags}> 

Returns member's flags or 0 if a permission is not met.

=cut

sub haspermission {
    my ($userid, $flagsrequired) = @_;
    my $sth = C4::Context->dbh->prepare("SELECT flags FROM borrowers WHERE userid=?");
    $sth->execute($userid);
    my $flags = getuserflags($sth->fetchrow(), $userid);
    if ( $userid eq C4::Context->config('user') ) {
        # Super User Account from /etc/koha.conf
        $flags->{'superlibrarian'} = 1;
    }
    elsif ( $userid eq 'demo' && C4::Context->config('demo') ) {
        # Demo user that can do "anything" (demo=1 in /etc/koha.conf)
        $flags->{'superlibrarian'} = 1;
    }

    return $flags if $flags->{superlibrarian};

    foreach my $module ( keys %$flagsrequired ) {
        my $subperm = $flagsrequired->{$module};
        if ($subperm eq '*') {
            return 0 unless ( $flags->{$module} == 1 or ref($flags->{$module}) );
        } else {
            return 0 unless ( $flags->{$module} == 1 or
                                ( ref($flags->{$module}) and
                                  exists $flags->{$module}->{$subperm} and
                                  $flags->{$module}->{$subperm} == 1
                                )
                            );
        }
    }
    return $flags;
    #FIXME - This fcn should return the failed permission so a suitable error msg can be delivered.
}


sub getborrowernumber {
    my ($userid) = @_;
    my $userenv = C4::Context->userenv;
    if ( defined( $userenv ) && ref( $userenv ) eq 'HASH' && $userenv->{number} ) {
        return $userenv->{number};
    }
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

=head1 SEE ALSO

CGI(3)

C4::Output(3)

Digest::MD5(3)

=cut
