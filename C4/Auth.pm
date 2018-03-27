package C4::Auth;

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
use warnings;
use Digest::MD5 qw(md5_base64);
use File::Spec;
use JSON qw/encode_json/;
use URI::Escape;
use CGI::Session;

require Exporter;
use C4::Context;
use C4::Templates;    # to get the template
use C4::Languages;
use C4::Search::History;
use Koha;
use Koha::Caches;
use Koha::AuthUtils qw(get_script_name hash_password);
use Koha::Library::Groups;
use Koha::Libraries;
use Koha::Patrons;
use POSIX qw/strftime/;
use List::MoreUtils qw/ any /;
use Encode qw( encode is_utf8);

# use utf8;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $debug $ldap $cas $caslogout $shib $shib_login);

BEGIN {
    sub psgi_env { any { /^psgi\./ } keys %ENV }

    sub safe_exit {
        if   (psgi_env) { die 'psgi:exit' }
        else            { exit }
    }

    $debug     = $ENV{DEBUG};
    @ISA       = qw(Exporter);
    @EXPORT    = qw(&checkauth &get_template_and_user &haspermission &get_user_subpermissions);
    @EXPORT_OK = qw(&check_api_auth &get_session &check_cookie_auth &checkpw &checkpw_internal &checkpw_hash
      &get_all_subpermissions &get_user_subpermissions
    );
    %EXPORT_TAGS = ( EditPermissions => [qw(get_all_subpermissions get_user_subpermissions)] );
    $ldap      = C4::Context->config('useldapserver') || 0;
    $cas       = C4::Context->preference('casAuthentication');
    $shib      = C4::Context->config('useshibboleth') || 0;
    $caslogout = C4::Context->preference('casLogout');
    require C4::Auth_with_cas;    # no import

    if ($ldap) {
        require C4::Auth_with_ldap;
        import C4::Auth_with_ldap qw(checkpw_ldap);
    }
    if ($shib) {
        require C4::Auth_with_shibboleth;
        import C4::Auth_with_shibboleth
          qw(shib_ok checkpw_shib logout_shib login_shib_url get_login_shib);

        # Check for good config
        if ( shib_ok() ) {

            # Get shibboleth login attribute
            $shib_login = get_login_shib();
        }

        # Bad config, disable shibboleth
        else {
            $shib = 0;
        }
    }
    if ($cas) {
        import C4::Auth_with_cas qw(check_api_auth_cas checkpw_cas login_cas logout_cas login_cas_url logout_if_required);
    }

}

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use CGI qw ( -utf8 );
  use C4::Auth;
  use C4::Output;

  my $query = new CGI;

  my ($template, $borrowernumber, $cookie)
    = get_template_and_user(
        {
            template_name   => "opac-main.tt",
            query           => $query,
      type            => "opac",
      authnotrequired => 0,
      flagsrequired   => { catalogue => '*', tools => 'import_patrons' },
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
         template_name   => "opac-main.tt",
         query           => $query,
         type            => "opac",
         authnotrequired => 0,
         flagsrequired   => { catalogue => '*', tools => 'import_patrons' },
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

    my $in = shift;
    my ( $user, $cookie, $sessionID, $flags );

    C4::Context->interface( $in->{type} );

    $in->{'authnotrequired'} ||= 0;

    # the following call includes a bad template check; might croak
    my $template = C4::Templates::gettemplate(
        $in->{'template_name'},
        $in->{'type'},
        $in->{'query'},
    );

    if ( $in->{'template_name'} !~ m/maintenance/ ) {
        ( $user, $cookie, $sessionID, $flags ) = checkauth(
            $in->{'query'},
            $in->{'authnotrequired'},
            $in->{'flagsrequired'},
            $in->{'type'}
        );
    }

    if ( $in->{type} eq 'opac' && $user ) {
        my $kick_out;

        if (
# If the user logged in is the SCO user and they try to go out of the SCO module,
# log the user out removing the CGISESSID cookie
               $in->{template_name} !~ m|sco/|
            && C4::Context->preference('AutoSelfCheckID')
            && $user eq C4::Context->preference('AutoSelfCheckID')
          )
        {
            $kick_out = 1;
        }
        elsif (
# If the user logged in is the SCI user and they try to go out of the SCI module,
# kick them out unless it is SCO with a valid permission
# or they are a superlibrarian
               $in->{template_name} !~ m|sci/|
            && haspermission( $user, { self_check => 'self_checkin_module' } )
            && !(
                $in->{template_name} =~ m|sco/| && haspermission(
                    $user, { self_check => 'self_checkout_module' }
                )
            )
            && $flags && $flags->{superlibrarian} != 1
          )
        {
            $kick_out = 1;
        }

        if ($kick_out) {
            $template = C4::Templates::gettemplate( 'opac-auth.tt', 'opac',
                $in->{query} );
            $cookie = $in->{query}->cookie(
                -name     => 'CGISESSID',
                -value    => '',
                -expires  => '',
                -HttpOnly => 1,
            );

            $template->param(
                loginprompt => 1,
                script_name => get_script_name(),
            );

            print $in->{query}->header(
                {
                    type              => 'text/html',
                    charset           => 'utf-8',
                    cookie            => $cookie,
                    'X-Frame-Options' => 'SAMEORIGIN'
                }
              ),
              $template->output;
            safe_exit;
        }
    }

    my $borrowernumber;
    if ($user) {

        # It's possible for $user to be the borrowernumber if they don't have a
        # userid defined (and are logging in through some other method, such
        # as SSL certs against an email address)
        my $patron;
        $borrowernumber = getborrowernumber($user) if defined($user);
        if ( !defined($borrowernumber) && defined($user) ) {
            $patron = Koha::Patrons->find( $user );
            if ($patron) {
                $borrowernumber = $user;

                # A bit of a hack, but I don't know there's a nicer way
                # to do it.
                $user = $patron->firstname . ' ' . $patron->surname;
            }
        } else {
            $patron = Koha::Patrons->find( $borrowernumber );
            # FIXME What to do if $patron does not exist?
        }

        # user info
        $template->param( loggedinusername   => $user ); # FIXME Should be replaced with something like patron-title.inc
        $template->param( loggedinusernumber => $borrowernumber ); # FIXME Should be replaced with logged_in_user.borrowernumber
        $template->param( logged_in_user     => $patron );
        $template->param( sessionID          => $sessionID );

        if ( $in->{'type'} eq 'opac' ) {
            require Koha::Virtualshelves;
            my $some_private_shelves = Koha::Virtualshelves->get_some_shelves(
                {
                    borrowernumber => $borrowernumber,
                    category       => 1,
                }
            );
            my $some_public_shelves = Koha::Virtualshelves->get_some_shelves(
                {
                    category       => 2,
                }
            );
            $template->param(
                some_private_shelves => $some_private_shelves,
                some_public_shelves  => $some_public_shelves,
            );
        }

        $template->param( "USER_INFO" => $patron->unblessed ) if $borrowernumber != 0;

        my $all_perms = get_all_subpermissions();

        my @flagroots = qw(circulate catalogue parameters borrowers permissions reserveforothers borrow
          editcatalogue updatecharges management tools editauthorities serials reports acquisition clubs);

        # We are going to use the $flags returned by checkauth
        # to create the template's parameters that will indicate
        # which menus the user can access.
        if ( $flags && $flags->{superlibrarian} == 1 ) {
            $template->param( CAN_user_circulate        => 1 );
            $template->param( CAN_user_catalogue        => 1 );
            $template->param( CAN_user_parameters       => 1 );
            $template->param( CAN_user_borrowers        => 1 );
            $template->param( CAN_user_permissions      => 1 );
            $template->param( CAN_user_reserveforothers => 1 );
            $template->param( CAN_user_editcatalogue    => 1 );
            $template->param( CAN_user_updatecharges    => 1 );
            $template->param( CAN_user_acquisition      => 1 );
            $template->param( CAN_user_management       => 1 );
            $template->param( CAN_user_tools            => 1 );
            $template->param( CAN_user_editauthorities  => 1 );
            $template->param( CAN_user_serials          => 1 );
            $template->param( CAN_user_reports          => 1 );
            $template->param( CAN_user_staffaccess      => 1 );
            $template->param( CAN_user_plugins          => 1 );
            $template->param( CAN_user_coursereserves   => 1 );
            $template->param( CAN_user_clubs            => 1 );

            foreach my $module ( keys %$all_perms ) {
                foreach my $subperm ( keys %{ $all_perms->{$module} } ) {
                    $template->param( "CAN_user_${module}_${subperm}" => 1 );
                }
            }
        }

        if ($flags) {
            foreach my $module ( keys %$all_perms ) {
                if ( defined($flags->{$module}) && $flags->{$module} == 1 ) {
                    foreach my $subperm ( keys %{ $all_perms->{$module} } ) {
                        $template->param( "CAN_user_${module}_${subperm}" => 1 );
                    }
                } elsif ( ref( $flags->{$module} ) ) {
                    foreach my $subperm ( keys %{ $flags->{$module} } ) {
                        $template->param( "CAN_user_${module}_${subperm}" => 1 );
                    }
                }
            }
        }

        if ($flags) {
            foreach my $module ( keys %$flags ) {
                if ( $flags->{$module} == 1 or ref( $flags->{$module} ) ) {
                    $template->param( "CAN_user_$module" => 1 );
                    if ( $module eq "parameters" ) {
                        $template->param( CAN_user_management => 1 );
                    }
                }
            }
        }

        # Logged-in opac search history
        # If the requested template is an opac one and opac search history is enabled
        if ( $in->{type} eq 'opac' && C4::Context->preference('EnableOpacSearchHistory') ) {
            my $dbh   = C4::Context->dbh;
            my $query = "SELECT COUNT(*) FROM search_history WHERE userid=?";
            my $sth   = $dbh->prepare($query);
            $sth->execute($borrowernumber);

            # If at least one search has already been performed
            if ( $sth->fetchrow_array > 0 ) {

                # We show the link in opac
                $template->param( EnableOpacSearchHistory => 1 );
            }
            if (C4::Context->preference('LoadSearchHistoryToTheFirstLoggedUser'))
            {
                # And if there are searches performed when the user was not logged in,
                # we add them to the logged-in search history
                my @recentSearches = C4::Search::History::get_from_session( { cgi => $in->{'query'} } );
                if (@recentSearches) {
                    my $dbh   = C4::Context->dbh;
                    my $query = q{
                        INSERT INTO search_history(userid, sessionid, query_desc, query_cgi, type,  total, time )
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    };
                    my $sth = $dbh->prepare($query);
                    $sth->execute( $borrowernumber,
                        $in->{query}->cookie("CGISESSID"),
                        $_->{query_desc},
                        $_->{query_cgi},
                        $_->{type} || 'biblio',
                        $_->{total},
                        $_->{time},
                    ) foreach @recentSearches;

                    # clear out the search history from the session now that
                    # we've saved it to the database
                 }
              }
              C4::Search::History::set_to_session( { cgi => $in->{'query'}, search_history => [] } );

        } elsif ( $in->{type} eq 'intranet' and C4::Context->preference('EnableSearchHistory') ) {
            $template->param( EnableSearchHistory => 1 );
        }
    }
    else {    # if this is an anonymous session, setup to display public lists...

        # If shibboleth is enabled, and we're in an anonymous session, we should allow
        # the user to attempt login via shibboleth.
        if ($shib) {
            $template->param( shibbolethAuthentication => $shib,
                shibbolethLoginUrl => login_shib_url( $in->{'query'} ),
            );

            # If shibboleth is enabled and we have a shibboleth login attribute,
            # but we are in an anonymous session, then we clearly have an invalid
            # shibboleth koha account.
            if ($shib_login) {
                $template->param( invalidShibLogin => '1' );
            }
        }

        $template->param( sessionID => $sessionID );

        if ( $in->{'type'} eq 'opac' ){
            require Koha::Virtualshelves;
            my $some_public_shelves = Koha::Virtualshelves->get_some_shelves(
                {
                    category       => 2,
                }
            );
            $template->param(
                some_public_shelves  => $some_public_shelves,
            );
        }
    }

    # Anonymous opac search history
    # If opac search history is enabled and at least one search has already been performed
    if ( C4::Context->preference('EnableOpacSearchHistory') ) {
        my @recentSearches = C4::Search::History::get_from_session( { cgi => $in->{'query'} } );
        if (@recentSearches) {
            $template->param( EnableOpacSearchHistory => 1 );
        }
    }

    if ( C4::Context->preference('dateformat') ) {
        $template->param( dateformat => C4::Context->preference('dateformat') );
    }

    $template->param(auth_forwarded_hash => scalar $in->{'query'}->param('auth_forwarded_hash'));

    # these template parameters are set the same regardless of $in->{'type'}

    # Set the using_https variable for templates
    # FIXME Under Plack the CGI->https method always returns 'OFF'
    my $https = $in->{query}->https();
    my $using_https = ( defined $https and $https ne 'OFF' ) ? 1 : 0;

    my $minPasswordLength = C4::Context->preference('minPasswordLength');
    $minPasswordLength = 3 if not $minPasswordLength or $minPasswordLength < 3;
    $template->param(
        "BiblioDefaultView" . C4::Context->preference("BiblioDefaultView") => 1,
        EnhancedMessagingPreferences                                       => C4::Context->preference('EnhancedMessagingPreferences'),
        GoogleJackets                                                      => C4::Context->preference("GoogleJackets"),
        OpenLibraryCovers                                                  => C4::Context->preference("OpenLibraryCovers"),
        KohaAdminEmailAddress                                              => "" . C4::Context->preference("KohaAdminEmailAddress"),
        LoginBranchcode => ( C4::Context->userenv ? C4::Context->userenv->{"branch"}    : undef ),
        LoginFirstname  => ( C4::Context->userenv ? C4::Context->userenv->{"firstname"} : "Bel" ),
        LoginSurname    => C4::Context->userenv ? C4::Context->userenv->{"surname"}      : "Inconnu",
        emailaddress    => C4::Context->userenv ? C4::Context->userenv->{"emailaddress"} : undef,
        TagsEnabled     => C4::Context->preference("TagsEnabled"),
        hide_marc       => C4::Context->preference("hide_marc"),
        item_level_itypes  => C4::Context->preference('item-level_itypes'),
        patronimages       => C4::Context->preference("patronimages"),
        singleBranchMode   => ( Koha::Libraries->search->count == 1 ),
        XSLTDetailsDisplay => C4::Context->preference("XSLTDetailsDisplay"),
        XSLTResultsDisplay => C4::Context->preference("XSLTResultsDisplay"),
        using_https        => $using_https,
        noItemTypeImages   => C4::Context->preference("noItemTypeImages"),
        marcflavour        => C4::Context->preference("marcflavour"),
        OPACBaseURL        => C4::Context->preference('OPACBaseURL'),
        minPasswordLength  => $minPasswordLength,
    );
    if ( $in->{'type'} eq "intranet" ) {
        $template->param(
            AmazonCoverImages                                                          => C4::Context->preference("AmazonCoverImages"),
            AutoLocation                                                               => C4::Context->preference("AutoLocation"),
            "BiblioDefaultView" . C4::Context->preference("IntranetBiblioDefaultView") => 1,
            CircAutocompl                                                              => C4::Context->preference("CircAutocompl"),
            FRBRizeEditions                                                            => C4::Context->preference("FRBRizeEditions"),
            IndependentBranches                                                        => C4::Context->preference("IndependentBranches"),
            IntranetNav                                                                => C4::Context->preference("IntranetNav"),
            IntranetmainUserblock                                                      => C4::Context->preference("IntranetmainUserblock"),
            LibraryName                                                                => C4::Context->preference("LibraryName"),
            LoginBranchname                                                            => ( C4::Context->userenv ? C4::Context->userenv->{"branchname"} : undef ),
            advancedMARCEditor                                                         => C4::Context->preference("advancedMARCEditor"),
            canreservefromotherbranches                                                => C4::Context->preference('canreservefromotherbranches'),
            intranetcolorstylesheet                                                    => C4::Context->preference("intranetcolorstylesheet"),
            IntranetFavicon                                                            => C4::Context->preference("IntranetFavicon"),
            intranetreadinghistory                                                     => C4::Context->preference("intranetreadinghistory"),
            intranetstylesheet                                                         => C4::Context->preference("intranetstylesheet"),
            IntranetUserCSS                                                            => C4::Context->preference("IntranetUserCSS"),
            IntranetUserJS                                                             => C4::Context->preference("IntranetUserJS"),
            intranetbookbag                                                            => C4::Context->preference("intranetbookbag"),
            suggestion                                                                 => C4::Context->preference("suggestion"),
            virtualshelves                                                             => C4::Context->preference("virtualshelves"),
            StaffSerialIssueDisplayCount                                               => C4::Context->preference("StaffSerialIssueDisplayCount"),
            EasyAnalyticalRecords                                                      => C4::Context->preference('EasyAnalyticalRecords'),
            LocalCoverImages                                                           => C4::Context->preference('LocalCoverImages'),
            OPACLocalCoverImages                                                       => C4::Context->preference('OPACLocalCoverImages'),
            AllowMultipleCovers                                                        => C4::Context->preference('AllowMultipleCovers'),
            EnableBorrowerFiles                                                        => C4::Context->preference('EnableBorrowerFiles'),
            UseKohaPlugins                                                             => C4::Context->preference('UseKohaPlugins'),
            UseCourseReserves                                                          => C4::Context->preference("UseCourseReserves"),
            useDischarge                                                               => C4::Context->preference('useDischarge')
        );
    }
    else {
        warn "template type should be OPAC, here it is=[" . $in->{'type'} . "]" unless ( $in->{'type'} eq 'opac' );

        #TODO : replace LibraryName syspref with 'system name', and remove this html processing
        my $LibraryNameTitle = C4::Context->preference("LibraryName");
        $LibraryNameTitle =~ s/<(?:\/?)(?:br|p)\s*(?:\/?)>/ /sgi;
        $LibraryNameTitle =~ s/<(?:[^<>'"]|'(?:[^']*)'|"(?:[^"]*)")*>//sg;

        # clean up the busc param in the session
        # if the page is not opac-detail and not the "add to list" page
        # and not the "edit comments" page
        if ( C4::Context->preference("OpacBrowseResults")
            && $in->{'template_name'} =~ /opac-(.+)\.(?:tt|tmpl)$/ ) {
            my $pagename = $1;
            unless ( $pagename =~ /^(?:MARC|ISBD)?detail$/
                or $pagename =~ /^addbybiblionumber$/
                or $pagename =~ /^review$/ ) {
                my $sessionSearch = get_session( $sessionID || $in->{'query'}->cookie("CGISESSID") );
                $sessionSearch->clear( ["busc"] ) if ( $sessionSearch->param("busc") );
            }
        }

        # variables passed from CGI: opac_css_override and opac_search_limits.
        my $opac_search_limit   = $ENV{'OPAC_SEARCH_LIMIT'};
        my $opac_limit_override = $ENV{'OPAC_LIMIT_OVERRIDE'};
        my $opac_name           = '';
        if (
            ( $opac_limit_override && $opac_search_limit && $opac_search_limit =~ /branch:(\w+)/ ) ||
            ( $in->{'query'}->param('limit') && $in->{'query'}->param('limit') =~ /branch:(\w+)/ ) ||
            ( $in->{'query'}->param('multibranchlimit') && $in->{'query'}->param('multibranchlimit') =~ /multibranchlimit-(\w+)/ )
          ) {
            $opac_name = $1;    # opac_search_limit is a branch, so we use it.
        } elsif ( $in->{'query'}->param('multibranchlimit') ) {
            $opac_name = $in->{'query'}->param('multibranchlimit');
        } elsif ( C4::Context->preference("SearchMyLibraryFirst") && C4::Context->userenv && C4::Context->userenv->{'branch'} ) {
            $opac_name = C4::Context->userenv->{'branch'};
        }

        my @search_groups = Koha::Library::Groups->get_search_groups({ interface => 'opac' });
        $template->param(
            OpacAdditionalStylesheet                   => C4::Context->preference("OpacAdditionalStylesheet"),
            AnonSuggestions                       => "" . C4::Context->preference("AnonSuggestions"),
            LibrarySearchGroups                   => \@search_groups,
            opac_name                             => $opac_name,
            LibraryName                           => "" . C4::Context->preference("LibraryName"),
            LibraryNameTitle                      => "" . $LibraryNameTitle,
            LoginBranchname                       => C4::Context->userenv ? C4::Context->userenv->{"branchname"} : "",
            OPACAmazonCoverImages                 => C4::Context->preference("OPACAmazonCoverImages"),
            OPACFRBRizeEditions                   => C4::Context->preference("OPACFRBRizeEditions"),
            OpacHighlightedWords                  => C4::Context->preference("OpacHighlightedWords"),
            OPACShelfBrowser                      => "" . C4::Context->preference("OPACShelfBrowser"),
            OPACURLOpenInNewWindow                => "" . C4::Context->preference("OPACURLOpenInNewWindow"),
            OPACUserCSS                           => "" . C4::Context->preference("OPACUserCSS"),
            OpacAuthorities                       => C4::Context->preference("OpacAuthorities"),
            opac_css_override                     => $ENV{'OPAC_CSS_OVERRIDE'},
            opac_search_limit                     => $opac_search_limit,
            opac_limit_override                   => $opac_limit_override,
            OpacBrowser                           => C4::Context->preference("OpacBrowser"),
            OpacCloud                             => C4::Context->preference("OpacCloud"),
            OpacKohaUrl                           => C4::Context->preference("OpacKohaUrl"),
            OpacMainUserBlock                     => "" . C4::Context->preference("OpacMainUserBlock"),
            OpacNav                               => "" . C4::Context->preference("OpacNav"),
            OpacNavRight                          => "" . C4::Context->preference("OpacNavRight"),
            OpacNavBottom                         => "" . C4::Context->preference("OpacNavBottom"),
            OpacPasswordChange                    => C4::Context->preference("OpacPasswordChange"),
            OPACPatronDetails                     => C4::Context->preference("OPACPatronDetails"),
            OPACPrivacy                           => C4::Context->preference("OPACPrivacy"),
            OPACFinesTab                          => C4::Context->preference("OPACFinesTab"),
            OpacTopissue                          => C4::Context->preference("OpacTopissue"),
            RequestOnOpac                         => C4::Context->preference("RequestOnOpac"),
            'Version'                             => C4::Context->preference('Version'),
            hidelostitems                         => C4::Context->preference("hidelostitems"),
            mylibraryfirst                        => ( C4::Context->preference("SearchMyLibraryFirst") && C4::Context->userenv ) ? C4::Context->userenv->{'branch'} : '',
            opaclayoutstylesheet                  => "" . C4::Context->preference("opaclayoutstylesheet"),
            opacbookbag                           => "" . C4::Context->preference("opacbookbag"),
            opaccredits                           => "" . C4::Context->preference("opaccredits"),
            OpacFavicon                           => C4::Context->preference("OpacFavicon"),
            opacheader                            => "" . C4::Context->preference("opacheader"),
            opaclanguagesdisplay                  => "" . C4::Context->preference("opaclanguagesdisplay"),
            opacreadinghistory                    => C4::Context->preference("opacreadinghistory"),
            OPACUserJS                            => C4::Context->preference("OPACUserJS"),
            opacuserlogin                         => "" . C4::Context->preference("opacuserlogin"),
            OpenLibrarySearch                     => C4::Context->preference("OpenLibrarySearch"),
            ShowReviewer                          => C4::Context->preference("ShowReviewer"),
            ShowReviewerPhoto                     => C4::Context->preference("ShowReviewerPhoto"),
            suggestion                            => "" . C4::Context->preference("suggestion"),
            virtualshelves                        => "" . C4::Context->preference("virtualshelves"),
            OPACSerialIssueDisplayCount           => C4::Context->preference("OPACSerialIssueDisplayCount"),
            OPACXSLTDetailsDisplay                => C4::Context->preference("OPACXSLTDetailsDisplay"),
            OPACXSLTResultsDisplay                => C4::Context->preference("OPACXSLTResultsDisplay"),
            SyndeticsClientCode                   => C4::Context->preference("SyndeticsClientCode"),
            SyndeticsEnabled                      => C4::Context->preference("SyndeticsEnabled"),
            SyndeticsCoverImages                  => C4::Context->preference("SyndeticsCoverImages"),
            SyndeticsTOC                          => C4::Context->preference("SyndeticsTOC"),
            SyndeticsSummary                      => C4::Context->preference("SyndeticsSummary"),
            SyndeticsEditions                     => C4::Context->preference("SyndeticsEditions"),
            SyndeticsExcerpt                      => C4::Context->preference("SyndeticsExcerpt"),
            SyndeticsReviews                      => C4::Context->preference("SyndeticsReviews"),
            SyndeticsAuthorNotes                  => C4::Context->preference("SyndeticsAuthorNotes"),
            SyndeticsAwards                       => C4::Context->preference("SyndeticsAwards"),
            SyndeticsSeries                       => C4::Context->preference("SyndeticsSeries"),
            SyndeticsCoverImageSize               => C4::Context->preference("SyndeticsCoverImageSize"),
            OPACLocalCoverImages                  => C4::Context->preference("OPACLocalCoverImages"),
            PatronSelfRegistration                => C4::Context->preference("PatronSelfRegistration"),
            PatronSelfRegistrationDefaultCategory => C4::Context->preference("PatronSelfRegistrationDefaultCategory"),
            useDischarge                 => C4::Context->preference('useDischarge'),
        );

        $template->param( OpacPublic => '1' ) if ( $user || C4::Context->preference("OpacPublic") );
    }

    # Check if we were asked using parameters to force a specific language
    if ( defined $in->{'query'}->param('language') ) {

        # Extract the language, let C4::Languages::getlanguage choose
        # what to do
        my $language = C4::Languages::getlanguage( $in->{'query'} );
        my $languagecookie = C4::Templates::getlanguagecookie( $in->{'query'}, $language );
        if ( ref $cookie eq 'ARRAY' ) {
            push @{$cookie}, $languagecookie;
        } else {
            $cookie = [ $cookie, $languagecookie ];
        }
    }

    return ( $template, $borrowernumber, $cookie, $flags );
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

sub _version_check {
    my $type  = shift;
    my $query = shift;
    my $version;

    # If version syspref is unavailable, it means Koha is being installed,
    # and so we must redirect to OPAC maintenance page or to the WebInstaller
    # also, if OpacMaintenance is ON, OPAC should redirect to maintenance
    if ( C4::Context->preference('OpacMaintenance') && $type eq 'opac' ) {
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
    my $kohaversion = Koha::version();

    # remove the 3 last . to have a Perl number
    $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    $debug and print STDERR "kohaversion : $kohaversion\n";
    if ( $version < $kohaversion ) {
        my $warning = "Database update needed, redirecting to %s. Database is $version and Koha is $kohaversion";
        if ( $type ne 'opac' ) {
            warn sprintf( $warning, 'Installer' );
            print $query->redirect("/cgi-bin/koha/installer/install.pl?step=1&op=updatestructure");
        } else {
            warn sprintf( "OPAC: " . $warning, 'maintenance' );
            print $query->redirect("/cgi-bin/koha/maintenance.pl");
        }
        safe_exit;
    }
}

sub _session_log {
    (@_) or return 0;
    open my $fh, '>>', "/tmp/sessionlog" or warn "ERROR: Cannot append to /tmp/sessionlog";
    printf $fh join( "\n", @_ );
    close $fh;
}

sub _timeout_syspref {
    my $timeout = C4::Context->preference('timeout') || 600;

    # value in days, convert in seconds
    if ( $timeout =~ /(\d+)[dD]/ ) {
        $timeout = $1 * 86400;
    }
    return $timeout;
}

sub checkauth {
    my $query = shift;
    $debug and warn "Checking Auth";
    # $authnotrequired will be set for scripts which will run without authentication
    my $authnotrequired = shift;
    my $flagsrequired   = shift;
    my $type            = shift;
    my $emailaddress    = shift;
    $type = 'opac' unless $type;

    my $dbh     = C4::Context->dbh;
    my $timeout = _timeout_syspref();

    _version_check( $type, $query );

    # state variables
    my $loggedin = 0;
    my %info;
    my ( $userid, $cookie, $sessionID, $flags );
    my $logout = $query->param('logout.x');

    my $anon_search_history;
    my $cas_ticket = '';
    # This parameter is the name of the CAS server we want to authenticate against,
    # when using authentication against multiple CAS servers, as configured in Auth_cas_servers.yaml
    my $casparam = $query->param('cas');
    my $q_userid = $query->param('userid') // '';

    # Basic authentication is incompatible with the use of Shibboleth,
    # as Shibboleth may return REMOTE_USER as a Shibboleth attribute,
    # and it may not be the attribute we want to use to match the koha login.
    #
    # Also, do not consider an empty REMOTE_USER.
    #
    # Finally, after those tests, we can assume (although if it would be better with
    # a syspref) that if we get a REMOTE_USER, that's from basic authentication,
    # and we can affect it to $userid.
    if ( !$shib and defined( $ENV{'REMOTE_USER'} ) and $ENV{'REMOTE_USER'} ne '' and $userid = $ENV{'REMOTE_USER'} ) {

        # Using Basic Authentication, no cookies required
        $cookie = $query->cookie(
            -name     => 'CGISESSID',
            -value    => '',
            -expires  => '',
            -HttpOnly => 1,
        );
        $loggedin = 1;
    }
    elsif ( $emailaddress) {
        # the Google OpenID Connect passes an email address
    }
    elsif ( $sessionID = $query->cookie("CGISESSID") )
    {    # assignment, not comparison
        my $session = get_session($sessionID);
        C4::Context->_new_userenv($sessionID);
        my ( $ip, $lasttime, $sessiontype );
        my $s_userid = '';
        if ($session) {
            $s_userid = $session->param('id') // '';
            C4::Context->set_userenv(
                $session->param('number'),       $s_userid,
                $session->param('cardnumber'),   $session->param('firstname'),
                $session->param('surname'),      $session->param('branch'),
                $session->param('branchname'),   $session->param('flags'),
                $session->param('emailaddress'), $session->param('branchprinter'),
                $session->param('shibboleth')
            );
            C4::Context::set_shelves_userenv( 'bar', $session->param('barshelves') );
            C4::Context::set_shelves_userenv( 'pub', $session->param('pubshelves') );
            C4::Context::set_shelves_userenv( 'tot', $session->param('totshelves') );
            $debug and printf STDERR "AUTH_SESSION: (%s)\t%s %s - %s\n", map { $session->param($_) } qw(cardnumber firstname surname branch);
            $ip          = $session->param('ip');
            $lasttime    = $session->param('lasttime');
            $userid      = $s_userid;
            $sessiontype = $session->param('sessiontype') || '';
        }
        if ( ( $query->param('koha_login_context') && ( $q_userid ne $s_userid ) )
            || ( $cas && $query->param('ticket') && !C4::Context->userenv->{'id'} )
            || ( $shib && $shib_login && !$logout && !C4::Context->userenv->{'id'} )
        ) {

            #if a user enters an id ne to the id in the current session, we need to log them in...
            #first we need to clear the anonymous session...
            $debug and warn "query id = $q_userid but session id = $s_userid";
            $anon_search_history = $session->param('search_history');
            $session->delete();
            $session->flush;
            C4::Context->_unset_userenv($sessionID);
            $sessionID = undef;
            $userid    = undef;
        }
        elsif ($logout) {

            # voluntary logout the user
            # check wether the user was using their shibboleth session or a local one
            my $shibSuccess = C4::Context->userenv->{'shibboleth'};
            $session->delete();
            $session->flush;
            C4::Context->_unset_userenv($sessionID);

            #_session_log(sprintf "%20s from %16s logged out at %30s (manually).\n", $userid,$ip,(strftime "%c",localtime));
            $sessionID = undef;
            $userid    = undef;

            if ($cas and $caslogout) {
                logout_cas($query, $type);
            }

            # If we are in a shibboleth session (shibboleth is enabled, a shibboleth match attribute is set and matches koha matchpoint)
            if ( $shib and $shib_login and $shibSuccess and $type eq 'opac' ) {

                # (Note: $type eq 'opac' condition should be removed when shibboleth authentication for intranet will be implemented)
                logout_shib($query);
            }
        }
        elsif ( !$lasttime || ( $lasttime < time() - $timeout ) ) {

            # timed logout
            $info{'timed_out'} = 1;
            if ($session) {
                $session->delete();
                $session->flush;
            }
            C4::Context->_unset_userenv($sessionID);

            #_session_log(sprintf "%20s from %16s logged out at %30s (inactivity).\n", $userid,$ip,(strftime "%c",localtime));
            $userid    = undef;
            $sessionID = undef;
        }
        elsif ( C4::Context->preference('SessionRestrictionByIP') && $ip ne $ENV{'REMOTE_ADDR'} ) {

            # Different ip than originally logged in from
            $info{'oldip'}        = $ip;
            $info{'newip'}        = $ENV{'REMOTE_ADDR'};
            $info{'different_ip'} = 1;
            $session->delete();
            $session->flush;
            C4::Context->_unset_userenv($sessionID);

            #_session_log(sprintf "%20s from %16s logged out at %30s (ip changed to %16s).\n", $userid,$ip,(strftime "%c",localtime), $info{'newip'});
            $sessionID = undef;
            $userid    = undef;
        }
        else {
            $cookie = $query->cookie(
                -name     => 'CGISESSID',
                -value    => $session->id,
                -HttpOnly => 1
            );
            $session->param( 'lasttime', time() );
            unless ( $sessiontype && $sessiontype eq 'anon' ) {    #if this is an anonymous session, we want to update the session, but not behave as if they are logged in...
                $flags = haspermission( $userid, $flagsrequired );
                if ($flags) {
                    $loggedin = 1;
                } else {
                    $info{'nopermission'} = 1;
                }
            }
        }
    }
    unless ( $userid || $sessionID ) {
        #we initiate a session prior to checking for a username to allow for anonymous sessions...
        my $session = get_session("") or die "Auth ERROR: Cannot get_session()";

        # Save anonymous search history in new session so it can be retrieved
        # by get_template_and_user to store it in user's search history after
        # a successful login.
        if ($anon_search_history) {
            $session->param( 'search_history', $anon_search_history );
        }

        my $sessionID = $session->id;
        C4::Context->_new_userenv($sessionID);
        $cookie = $query->cookie(
            -name     => 'CGISESSID',
            -value    => $session->id,
            -HttpOnly => 1
        );
        my $pki_field = C4::Context->preference('AllowPKIAuth');
        if ( !defined($pki_field) ) {
            print STDERR "ERROR: Missing system preference AllowPKIAuth.\n";
            $pki_field = 'None';
        }
        if ( ( $cas && $query->param('ticket') )
            || $q_userid
            || ( $shib && $shib_login )
            || $pki_field ne 'None'
            || $emailaddress )
        {
            my $password    = $query->param('password');
            my $shibSuccess = 0;
            my ( $return, $cardnumber );

            # If shib is enabled and we have a shib login, does the login match a valid koha user
            if ( $shib && $shib_login && $type eq 'opac' ) {
                my $retuserid;

                # Do not pass password here, else shib will not be checked in checkpw.
                ( $return, $cardnumber, $retuserid ) = checkpw( $dbh, $q_userid, undef, $query );
                $userid      = $retuserid;
                $shibSuccess = $return;
                $info{'invalidShibLogin'} = 1 unless ($return);
            }

            # If shib login and match were successful, skip further login methods
            unless ($shibSuccess) {
                if ( $cas && $query->param('ticket') ) {
                    my $retuserid;
                    ( $return, $cardnumber, $retuserid, $cas_ticket ) =
                      checkpw( $dbh, $userid, $password, $query, $type );
                    $userid = $retuserid;
                    $info{'invalidCasLogin'} = 1 unless ($return);
                }

                elsif ( $emailaddress ) {
                    my $value = $emailaddress;

                    # If we're looking up the email, there's a chance that the person
                    # doesn't have a userid. So if there is none, we pass along the
                    # borrower number, and the bits of code that need to know the user
                    # ID will have to be smart enough to handle that.
                    my $patrons = Koha::Patrons->search({ email => $value });
                    if ($patrons->count) {

                        # First the userid, then the borrowernum
                        my $patron = $patrons->next;
                        $value = $patron->userid || $patron->borrowernumber;
                    } else {
                        undef $value;
                    }
                    $return = $value ? 1 : 0;
                    $userid = $value;
                }

                elsif (
                    ( $pki_field eq 'Common Name' && $ENV{'SSL_CLIENT_S_DN_CN'} )
                    || ( $pki_field eq 'emailAddress'
                        && $ENV{'SSL_CLIENT_S_DN_Email'} )
                  )
                {
                    my $value;
                    if ( $pki_field eq 'Common Name' ) {
                        $value = $ENV{'SSL_CLIENT_S_DN_CN'};
                    }
                    elsif ( $pki_field eq 'emailAddress' ) {
                        $value = $ENV{'SSL_CLIENT_S_DN_Email'};

                        # If we're looking up the email, there's a chance that the person
                        # doesn't have a userid. So if there is none, we pass along the
                        # borrower number, and the bits of code that need to know the user
                        # ID will have to be smart enough to handle that.
                        my $patrons = Koha::Patrons->search({ email => $value });
                        if ($patrons->count) {

                            # First the userid, then the borrowernum
                            my $patron = $patrons->next;
                            $value = $patron->userid || $patron->borrowernumber;
                        } else {
                            undef $value;
                        }
                    }

                    $return = $value ? 1 : 0;
                    $userid = $value;

                }
                else {
                    my $retuserid;
                    ( $return, $cardnumber, $retuserid, $cas_ticket ) =
                      checkpw( $dbh, $q_userid, $password, $query, $type );
                    $userid = $retuserid if ($retuserid);
                    $info{'invalid_username_or_password'} = 1 unless ($return);
                }
            }

            # $return: 1 = valid user, 2 = superlibrarian
            if ($return) {
                # If DB user is logged in
                $userid ||= $q_userid if $return == 2;

                #_session_log(sprintf "%20s from %16s logged in  at %30s.\n", $userid,$ENV{'REMOTE_ADDR'},(strftime '%c', localtime));
                if ( $flags = haspermission( $userid, $flagsrequired ) ) {
                    $loggedin = 1;
                }
                else {
                    $info{'nopermission'} = 1;
                    C4::Context->_unset_userenv($sessionID);
                }
                my ( $borrowernumber, $firstname, $surname, $userflags,
                    $branchcode, $branchname, $branchprinter, $emailaddress );

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
                    unless ( $sth->rows ) {
                        $debug and print STDERR "AUTH_1: no rows for userid='$userid'\n";
                        $sth = $dbh->prepare("$select where cardnumber=?");
                        $sth->execute($cardnumber);

                        unless ( $sth->rows ) {
                            $debug and print STDERR "AUTH_2a: no rows for cardnumber='$cardnumber'\n";
                            $sth->execute($userid);
                            unless ( $sth->rows ) {
                                $debug and print STDERR "AUTH_2b: no rows for userid='$userid' AS cardnumber\n";
                            }
                        }
                    }
                    if ( $sth->rows ) {
                        ( $borrowernumber, $firstname, $surname, $userflags,
                            $branchcode, $branchname, $branchprinter, $emailaddress ) = $sth->fetchrow;
                        $debug and print STDERR "AUTH_3 results: " .
                          "$cardnumber,$borrowernumber,$userid,$firstname,$surname,$userflags,$branchcode,$emailaddress\n";
                    } else {
                        print STDERR "AUTH_3: no results for userid='$userid', cardnumber='$cardnumber'.\n";
                    }

                    # launch a sequence to check if we have a ip for the branch, i
                    # if we have one we replace the branchcode of the userenv by the branch bound in the ip.

                    my $ip = $ENV{'REMOTE_ADDR'};

                    # if they specify at login, use that
                    if ( $query->param('branch') ) {
                        $branchcode = $query->param('branch');
                        my $library = Koha::Libraries->find($branchcode);
                        $branchname = $library? $library->branchname: '';
                    }
                    my $branches = { map { $_->branchcode => $_->unblessed } Koha::Libraries->search };
                    if ( $type ne 'opac' and C4::Context->boolean_preference('AutoLocation') ) {

                        # we have to check they are coming from the right ip range
                        my $domain = $branches->{$branchcode}->{'branchip'};
                        $domain =~ s|\.\*||g;
                        if ( $ip !~ /^$domain/ ) {
                            $loggedin = 0;
                            $cookie = $query->cookie(
                                -name     => 'CGISESSID',
                                -value    => '',
                                -HttpOnly => 1
                            );
                            $info{'wrongip'} = 1;
                        }
                    }

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
                    $session->param( 'number',       $borrowernumber );
                    $session->param( 'id',           $userid );
                    $session->param( 'cardnumber',   $cardnumber );
                    $session->param( 'firstname',    $firstname );
                    $session->param( 'surname',      $surname );
                    $session->param( 'branch',       $branchcode );
                    $session->param( 'branchname',   $branchname );
                    $session->param( 'flags',        $userflags );
                    $session->param( 'emailaddress', $emailaddress );
                    $session->param( 'ip',           $session->remote_addr() );
                    $session->param( 'lasttime',     time() );
                    $session->param( 'shibboleth',   $shibSuccess );
                    $debug and printf STDERR "AUTH_4: (%s)\t%s %s - %s\n", map { $session->param($_) } qw(cardnumber firstname surname branch);
                }
                elsif ( $return == 2 ) {

                    #We suppose the user is the superlibrarian
                    $borrowernumber = 0;
                    $session->param( 'number',       0 );
                    $session->param( 'id',           C4::Context->config('user') );
                    $session->param( 'cardnumber',   C4::Context->config('user') );
                    $session->param( 'firstname',    C4::Context->config('user') );
                    $session->param( 'surname',      C4::Context->config('user') );
                    $session->param( 'branch',       'NO_LIBRARY_SET' );
                    $session->param( 'branchname',   'NO_LIBRARY_SET' );
                    $session->param( 'flags',        1 );
                    $session->param( 'emailaddress', C4::Context->preference('KohaAdminEmailAddress') );
                    $session->param( 'ip',           $session->remote_addr() );
                    $session->param( 'lasttime',     time() );
                }
                $session->param('cas_ticket', $cas_ticket) if $cas_ticket;
                C4::Context->set_userenv(
                    $session->param('number'),       $session->param('id'),
                    $session->param('cardnumber'),   $session->param('firstname'),
                    $session->param('surname'),      $session->param('branch'),
                    $session->param('branchname'),   $session->param('flags'),
                    $session->param('emailaddress'), $session->param('branchprinter'),
                    $session->param('shibboleth')
                );

            }
            # $return: 0 = invalid user
            # reset to anonymous session
            else {
                $debug and warn "Login failed, resetting anonymous session...";
                if ($userid) {
                    $info{'invalid_username_or_password'} = 1;
                    C4::Context->_unset_userenv($sessionID);
                }
                $session->param( 'lasttime', time() );
                $session->param( 'ip',       $session->remote_addr() );
                $session->param( 'sessiontype', 'anon' );
            }
        }    # END if ( $q_userid
        elsif ( $type eq "opac" ) {

            # if we are here this is an anonymous session; add public lists to it and a few other items...
            # anonymous sessions are created only for the OPAC
            $debug and warn "Initiating an anonymous session...";

            # setting a couple of other session vars...
            $session->param( 'ip',          $session->remote_addr() );
            $session->param( 'lasttime',    time() );
            $session->param( 'sessiontype', 'anon' );
        }
    }    # END unless ($userid)

    # finished authentification, now respond
    if ( $loggedin || $authnotrequired )
    {
        # successful login
        unless ($cookie) {
            $cookie = $query->cookie(
                -name     => 'CGISESSID',
                -value    => '',
                -HttpOnly => 1
            );
        }

        if ( $userid ) {
            # track_login also depends on pref TrackLastPatronActivity
            my $patron = Koha::Patrons->find({ userid => $userid });
            $patron->track_login if $patron;
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

    my $patron = Koha::Patrons->find({ userid => $q_userid }); # Not necessary logged in!

    my $LibraryNameTitle = C4::Context->preference("LibraryName");
    $LibraryNameTitle =~ s/<(?:\/?)(?:br|p)\s*(?:\/?)>/ /sgi;
    $LibraryNameTitle =~ s/<(?:[^<>'"]|'(?:[^']*)'|"(?:[^"]*)")*>//sg;

    my $template_name = ( $type eq 'opac' ) ? 'opac-auth.tt' : 'auth.tt';
    my $template = C4::Templates::gettemplate( $template_name, $type, $query );
    $template->param(
        OpacAdditionalStylesheet                   => C4::Context->preference("OpacAdditionalStylesheet"),
        opaclayoutstylesheet                  => C4::Context->preference("opaclayoutstylesheet"),
        login                                 => 1,
        INPUTS                                => \@inputs,
        script_name                           => get_script_name(),
        casAuthentication                     => C4::Context->preference("casAuthentication"),
        shibbolethAuthentication              => $shib,
        SessionRestrictionByIP                => C4::Context->preference("SessionRestrictionByIP"),
        suggestion                            => C4::Context->preference("suggestion"),
        virtualshelves                        => C4::Context->preference("virtualshelves"),
        LibraryName                           => "" . C4::Context->preference("LibraryName"),
        LibraryNameTitle                      => "" . $LibraryNameTitle,
        opacuserlogin                         => C4::Context->preference("opacuserlogin"),
        OpacNav                               => C4::Context->preference("OpacNav"),
        OpacNavRight                          => C4::Context->preference("OpacNavRight"),
        OpacNavBottom                         => C4::Context->preference("OpacNavBottom"),
        opaccredits                           => C4::Context->preference("opaccredits"),
        OpacFavicon                           => C4::Context->preference("OpacFavicon"),
        opacreadinghistory                    => C4::Context->preference("opacreadinghistory"),
        opaclanguagesdisplay                  => C4::Context->preference("opaclanguagesdisplay"),
        OPACUserJS                            => C4::Context->preference("OPACUserJS"),
        opacbookbag                           => "" . C4::Context->preference("opacbookbag"),
        OpacCloud                             => C4::Context->preference("OpacCloud"),
        OpacTopissue                          => C4::Context->preference("OpacTopissue"),
        OpacAuthorities                       => C4::Context->preference("OpacAuthorities"),
        OpacBrowser                           => C4::Context->preference("OpacBrowser"),
        opacheader                            => C4::Context->preference("opacheader"),
        TagsEnabled                           => C4::Context->preference("TagsEnabled"),
        OPACUserCSS                           => C4::Context->preference("OPACUserCSS"),
        intranetcolorstylesheet               => C4::Context->preference("intranetcolorstylesheet"),
        intranetstylesheet                    => C4::Context->preference("intranetstylesheet"),
        intranetbookbag                       => C4::Context->preference("intranetbookbag"),
        IntranetNav                           => C4::Context->preference("IntranetNav"),
        IntranetFavicon                       => C4::Context->preference("IntranetFavicon"),
        IntranetUserCSS                       => C4::Context->preference("IntranetUserCSS"),
        IntranetUserJS                        => C4::Context->preference("IntranetUserJS"),
        IndependentBranches                   => C4::Context->preference("IndependentBranches"),
        AutoLocation                          => C4::Context->preference("AutoLocation"),
        wrongip                               => $info{'wrongip'},
        PatronSelfRegistration                => C4::Context->preference("PatronSelfRegistration"),
        PatronSelfRegistrationDefaultCategory => C4::Context->preference("PatronSelfRegistrationDefaultCategory"),
        opac_css_override                     => $ENV{'OPAC_CSS_OVERRIDE'},
        too_many_login_attempts               => ( $patron and $patron->account_locked )
    );

    $template->param( SCO_login => 1 ) if ( $query->param('sco_user_login') );
    $template->param( SCI_login => 1 ) if ( $query->param('sci_user_login') );
    $template->param( OpacPublic => C4::Context->preference("OpacPublic") );
    $template->param( loginprompt => 1 ) unless $info{'nopermission'};

    if ( $type eq 'opac' ) {
        require Koha::Virtualshelves;
        my $some_public_shelves = Koha::Virtualshelves->get_some_shelves(
            {
                category       => 2,
            }
        );
        $template->param(
            some_public_shelves  => $some_public_shelves,
        );
    }

    if ($cas) {

        # Is authentication against multiple CAS servers enabled?
        if ( C4::Auth_with_cas::multipleAuth && !$casparam ) {
            my $casservers = C4::Auth_with_cas::getMultipleAuth();
            my @tmplservers;
            foreach my $key ( keys %$casservers ) {
                push @tmplservers, { name => $key, value => login_cas_url( $query, $key, $type ) . "?cas=$key" };
            }
            $template->param(
                casServersLoop => \@tmplservers
            );
        } else {
            $template->param(
                casServerUrl => login_cas_url($query, undef, $type),
            );
        }

        $template->param(
            invalidCasLogin => $info{'invalidCasLogin'}
        );
    }

    if ($shib) {
        $template->param(
            shibbolethAuthentication => $shib,
            shibbolethLoginUrl       => login_shib_url($query),
        );
    }

    if (C4::Context->preference('GoogleOpenIDConnect')) {
        if ($query->param("OpenIDConnectFailed")) {
            my $reason = $query->param('OpenIDConnectFailed');
            $template->param(invalidGoogleOpenIDConnectLogin => $reason);
        }
    }

    $template->param(
        LibraryName => C4::Context->preference("LibraryName"),
    );
    $template->param(%info);

    #    $cookie = $query->cookie(CGISESSID => $session->id
    #   );
    print $query->header(
        {   type              => 'text/html',
            charset           => 'utf-8',
            cookie            => $cookie,
            'X-Frame-Options' => 'SAMEORIGIN'
        }
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

    my $query         = shift;
    my $flagsrequired = shift;
    my $dbh     = C4::Context->dbh;
    my $timeout = _timeout_syspref();

    unless ( C4::Context->preference('Version') ) {

        # database has not been installed yet
        return ( "maintenance", undef, undef );
    }
    my $kohaversion = Koha::version();
    $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    if ( C4::Context->preference('Version') < $kohaversion ) {

        # database in need of version update; assume that
        # no API should be called while databsae is in
        # this condition.
        return ( "maintenance", undef, undef );
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
    unless ( $query->param('userid') ) {
        $sessionID = $query->cookie("CGISESSID");
    }
    if ( $sessionID && not( $cas && $query->param('PT') ) ) {
        my $session = get_session($sessionID);
        C4::Context->_new_userenv($sessionID);
        if ($session) {
            C4::Context->set_userenv(
                $session->param('number'),       $session->param('id'),
                $session->param('cardnumber'),   $session->param('firstname'),
                $session->param('surname'),      $session->param('branch'),
                $session->param('branchname'),   $session->param('flags'),
                $session->param('emailaddress'), $session->param('branchprinter')
            );

            my $ip       = $session->param('ip');
            my $lasttime = $session->param('lasttime');
            my $userid   = $session->param('id');
            if ( $lasttime < time() - $timeout ) {

                # time out
                $session->delete();
                $session->flush;
                C4::Context->_unset_userenv($sessionID);
                $userid    = undef;
                $sessionID = undef;
                return ( "expired", undef, undef );
            } elsif ( C4::Context->preference('SessionRestrictionByIP') && $ip ne $ENV{'REMOTE_ADDR'} ) {

                # IP address changed
                $session->delete();
                $session->flush;
                C4::Context->_unset_userenv($sessionID);
                $userid    = undef;
                $sessionID = undef;
                return ( "expired", undef, undef );
            } else {
                my $cookie = $query->cookie(
                    -name     => 'CGISESSID',
                    -value    => $session->id,
                    -HttpOnly => 1,
                );
                $session->param( 'lasttime', time() );
                my $flags = haspermission( $userid, $flagsrequired );
                if ($flags) {
                    return ( "ok", $cookie, $sessionID );
                } else {
                    $session->delete();
                    $session->flush;
                    C4::Context->_unset_userenv($sessionID);
                    $userid    = undef;
                    $sessionID = undef;
                    return ( "failed", undef, undef );
                }
            }
        } else {
            return ( "expired", undef, undef );
        }
    } else {

        # new login
        my $userid   = $query->param('userid');
        my $password = $query->param('password');
        my ( $return, $cardnumber, $cas_ticket );

        # Proxy CAS auth
        if ( $cas && $query->param('PT') ) {
            my $retuserid;
            $debug and print STDERR "## check_api_auth - checking CAS\n";

            # In case of a CAS authentication, we use the ticket instead of the password
            my $PT = $query->param('PT');
            ( $return, $cardnumber, $userid, $cas_ticket ) = check_api_auth_cas( $dbh, $PT, $query );    # EXTERNAL AUTH
        } else {

            # User / password auth
            unless ( $userid and $password ) {

                # caller did something wrong, fail the authenticateion
                return ( "failed", undef, undef );
            }
            my $newuserid;
            ( $return, $cardnumber, $newuserid, $cas_ticket ) = checkpw( $dbh, $userid, $password, $query );
        }

        if ( $return and haspermission( $userid, $flagsrequired ) ) {
            my $session = get_session("");
            return ( "failed", undef, undef ) unless $session;

            my $sessionID = $session->id;
            C4::Context->_new_userenv($sessionID);
            my $cookie = $query->cookie(
                -name     => 'CGISESSID',
                -value    => $sessionID,
                -HttpOnly => 1,
            );
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

                unless ( $sth->rows ) {
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
                            $borrowernumber, $firstname,  $surname,       $userflags,
                            $branchcode,     $branchname, $branchprinter, $emailaddress
                        ) = $sth->fetchrow if ( $sth->rows );
                    }
                }

                my $ip = $ENV{'REMOTE_ADDR'};

                # if they specify at login, use that
                if ( $query->param('branch') ) {
                    $branchcode = $query->param('branch');
                    my $library = Koha::Libraries->find($branchcode);
                    $branchname = $library? $library->branchname: '';
                }
                my $branches = { map { $_->branchcode => $_->unblessed } Koha::Libraries->search };
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
                $session->param( 'number',       $borrowernumber );
                $session->param( 'id',           $userid );
                $session->param( 'cardnumber',   $cardnumber );
                $session->param( 'firstname',    $firstname );
                $session->param( 'surname',      $surname );
                $session->param( 'branch',       $branchcode );
                $session->param( 'branchname',   $branchname );
                $session->param( 'flags',        $userflags );
                $session->param( 'emailaddress', $emailaddress );
                $session->param( 'ip',           $session->remote_addr() );
                $session->param( 'lasttime',     time() );
            } elsif ( $return == 2 ) {

                #We suppose the user is the superlibrarian
                $session->param( 'number',       0 );
                $session->param( 'id',           C4::Context->config('user') );
                $session->param( 'cardnumber',   C4::Context->config('user') );
                $session->param( 'firstname',    C4::Context->config('user') );
                $session->param( 'surname',      C4::Context->config('user') );
                $session->param( 'branch',       'NO_LIBRARY_SET' );
                $session->param( 'branchname',   'NO_LIBRARY_SET' );
                $session->param( 'flags',        1 );
                $session->param( 'emailaddress', C4::Context->preference('KohaAdminEmailAddress') );
                $session->param( 'ip',           $session->remote_addr() );
                $session->param( 'lasttime',     time() );
            }
            $session->param( 'cas_ticket', $cas_ticket);
            C4::Context->set_userenv(
                $session->param('number'),       $session->param('id'),
                $session->param('cardnumber'),   $session->param('firstname'),
                $session->param('surname'),      $session->param('branch'),
                $session->param('branchname'),   $session->param('flags'),
                $session->param('emailaddress'), $session->param('branchprinter')
            );
            return ( "ok", $cookie, $sessionID );
        } else {
            return ( "failed", undef, undef );
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
    my $cookie        = shift;
    my $flagsrequired = shift;
    my $params        = shift;

    my $remote_addr = $params->{remote_addr} || $ENV{REMOTE_ADDR};
    my $dbh     = C4::Context->dbh;
    my $timeout = _timeout_syspref();

    unless ( C4::Context->preference('Version') ) {

        # database has not been installed yet
        return ( "maintenance", undef );
    }
    my $kohaversion = Koha::version();
    $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    if ( C4::Context->preference('Version') < $kohaversion ) {

        # database in need of version update; assume that
        # no API should be called while databsae is in
        # this condition.
        return ( "maintenance", undef );
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
    unless ( defined $cookie and $cookie ) {
        return ( "failed", undef );
    }
    my $sessionID = $cookie;
    my $session   = get_session($sessionID);
    C4::Context->_new_userenv($sessionID);
    if ($session) {
        C4::Context->set_userenv(
            $session->param('number'),       $session->param('id'),
            $session->param('cardnumber'),   $session->param('firstname'),
            $session->param('surname'),      $session->param('branch'),
            $session->param('branchname'),   $session->param('flags'),
            $session->param('emailaddress'), $session->param('branchprinter')
        );

        my $ip       = $session->param('ip');
        my $lasttime = $session->param('lasttime');
        my $userid   = $session->param('id');
        if ( $lasttime < time() - $timeout ) {

            # time out
            $session->delete();
            $session->flush;
            C4::Context->_unset_userenv($sessionID);
            $userid    = undef;
            $sessionID = undef;
            return ("expired", undef);
        } elsif ( C4::Context->preference('SessionRestrictionByIP') && $ip ne $remote_addr ) {

            # IP address changed
            $session->delete();
            $session->flush;
            C4::Context->_unset_userenv($sessionID);
            $userid    = undef;
            $sessionID = undef;
            return ( "expired", undef );
        } else {
            $session->param( 'lasttime', time() );
            my $flags = haspermission( $userid, $flagsrequired );
            if ($flags) {
                return ( "ok", $sessionID );
            } else {
                $session->delete();
                $session->flush;
                C4::Context->_unset_userenv($sessionID);
                $userid    = undef;
                $sessionID = undef;
                return ( "failed", undef );
            }
        }
    } else {
        return ( "expired", undef );
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

sub _get_session_params {
    my $storage_method = C4::Context->preference('SessionStorage');
    if ( $storage_method eq 'mysql' ) {
        my $dbh = C4::Context->dbh;
        return { dsn => "driver:MySQL;serializer:yaml;id:md5", dsn_args => { Handle => $dbh } };
    }
    elsif ( $storage_method eq 'Pg' ) {
        my $dbh = C4::Context->dbh;
        return { dsn => "driver:PostgreSQL;serializer:yaml;id:md5", dsn_args => { Handle => $dbh } };
    }
    elsif ( $storage_method eq 'memcached' && Koha::Caches->get_instance->memcached_cache ) {
        my $memcached = Koha::Caches->get_instance()->memcached_cache;
        return { dsn => "driver:memcached;serializer:yaml;id:md5", dsn_args => { Memcached => $memcached } };
    }
    else {
        # catch all defaults to tmp should work on all systems
        my $dir = File::Spec->tmpdir;
        my $instance = C4::Context->config( 'database' ); #actually for packages not exactly the instance name, but generally safer to leave it as it is
        return { dsn => "driver:File;serializer:yaml;id:md5", dsn_args => { Directory => "$dir/cgisess_$instance" } };
    }
}

sub get_session {
    my $sessionID      = shift;
    my $params = _get_session_params();
    return new CGI::Session( $params->{dsn}, $sessionID, $params->{dsn_args} );
}


# FIXME no_set_userenv may be replaced with force_branchcode_for_userenv
# (or something similar)
# Currently it's only passed from C4::SIP::ILS::Patron::check_password, but
# not having a userenv defined could cause a crash.
sub checkpw {
    my ( $dbh, $userid, $password, $query, $type, $no_set_userenv ) = @_;
    $type = 'opac' unless $type;

    my @return;
    my $patron = Koha::Patrons->find({ userid => $userid });
    my $check_internal_as_fallback = 0;
    my $passwd_ok = 0;
    # Note: checkpw_* routines returns:
    # 1 if auth is ok
    # 0 if auth is nok
    # -1 if user bind failed (LDAP only)
    # 2 if DB user is used (internal only)

    if ( $patron and $patron->account_locked ) {
        # Nothing to check, account is locked
    } elsif ($ldap) {
        $debug and print STDERR "## checkpw - checking LDAP\n";
        my ( $retval, $retcard, $retuserid ) = checkpw_ldap(@_);    # EXTERNAL AUTH
        if ( $retval == 1 ) {
            @return = ( $retval, $retcard, $retuserid );
            $passwd_ok = 1;
        }
        $check_internal_as_fallback = 1 if $retval == 0;

    } elsif ( $cas && $query && $query->param('ticket') ) {
        $debug and print STDERR "## checkpw - checking CAS\n";

        # In case of a CAS authentication, we use the ticket instead of the password
        my $ticket = $query->param('ticket');
        $query->delete('ticket');                                   # remove ticket to come back to original URL
        my ( $retval, $retcard, $retuserid, $cas_ticket ) = checkpw_cas( $dbh, $ticket, $query, $type );    # EXTERNAL AUTH
        if ( $retval ) {
            @return = ( $retval, $retcard, $retuserid, $cas_ticket );
        } else {
            @return = (0);
        }
        $passwd_ok = $retval;
    }

    # If we are in a shibboleth session (shibboleth is enabled, and a shibboleth match attribute is present)
    # Check for password to asertain whether we want to be testing against shibboleth or another method this
    # time around.
    elsif ( $shib && $shib_login && !$password ) {

        $debug and print STDERR "## checkpw - checking Shibboleth\n";

        # In case of a Shibboleth authentication, we expect a shibboleth user attribute
        # (defined under shibboleth mapping in koha-conf.xml) to contain the login of the
        # shibboleth-authenticated user

        # Then, we check if it matches a valid koha user
        if ($shib_login) {
            my ( $retval, $retcard, $retuserid ) = C4::Auth_with_shibboleth::checkpw_shib($shib_login);    # EXTERNAL AUTH
            if ( $retval ) {
                @return = ( $retval, $retcard, $retuserid );
            }
            $passwd_ok = $retval;
        }
    } else {
        $check_internal_as_fallback = 1;
    }

    # INTERNAL AUTH
    if ( $check_internal_as_fallback ) {
        @return = checkpw_internal( $dbh, $userid, $password, $no_set_userenv);
        $passwd_ok = 1 if $return[0] > 0; # 1 or 2
    }

    if( $patron ) {
        if ( $passwd_ok ) {
            $patron->update({ login_attempts => 0 });
        } else {
            $patron->update({ login_attempts => $patron->login_attempts + 1 });
        }
    }
    return @return;
}

sub checkpw_internal {
    my ( $dbh, $userid, $password, $no_set_userenv ) = @_;

    $password = Encode::encode( 'UTF-8', $password )
      if Encode::is_utf8($password);

    if ( $userid && $userid eq C4::Context->config('user') ) {
        if ( $password && $password eq C4::Context->config('pass') ) {

            # Koha superuser account
            #     C4::Context->set_userenv(0,0,C4::Context->config('user'),C4::Context->config('user'),C4::Context->config('user'),"",1);
            return 2;
        }
        else {
            return 0;
        }
    }

    my $sth =
      $dbh->prepare(
        "select password,cardnumber,borrowernumber,userid,firstname,surname,borrowers.branchcode,branches.branchname,flags from borrowers join branches on borrowers.branchcode=branches.branchcode where userid=?"
      );
    $sth->execute($userid);
    if ( $sth->rows ) {
        my ( $stored_hash, $cardnumber, $borrowernumber, $userid, $firstname,
            $surname, $branchcode, $branchname, $flags )
          = $sth->fetchrow;

        if ( checkpw_hash( $password, $stored_hash ) ) {

            C4::Context->set_userenv( "$borrowernumber", $userid, $cardnumber,
                $firstname, $surname, $branchcode, $branchname, $flags ) unless $no_set_userenv;
            return 1, $cardnumber, $userid;
        }
    }
    $sth =
      $dbh->prepare(
        "select password,cardnumber,borrowernumber,userid,firstname,surname,borrowers.branchcode,branches.branchname,flags from borrowers join branches on borrowers.branchcode=branches.branchcode where cardnumber=?"
      );
    $sth->execute($userid);
    if ( $sth->rows ) {
        my ( $stored_hash, $cardnumber, $borrowernumber, $userid, $firstname,
            $surname, $branchcode, $branchname, $flags )
          = $sth->fetchrow;

        if ( checkpw_hash( $password, $stored_hash ) ) {

            C4::Context->set_userenv( $borrowernumber, $userid, $cardnumber,
                $firstname, $surname, $branchcode, $branchname, $flags ) unless $no_set_userenv;
            return 1, $cardnumber, $userid;
        }
    }
    return 0;
}

sub checkpw_hash {
    my ( $password, $stored_hash ) = @_;

    return if $stored_hash eq '!';

    # check what encryption algorithm was implemented: Bcrypt - if the hash starts with '$2' it is Bcrypt else md5
    my $hash;
    if ( substr( $stored_hash, 0, 2 ) eq '$2' ) {
        $hash = hash_password( $password, $stored_hash );
    } else {
        $hash = md5_base64($password);
    }
    return $hash eq $stored_hash;
}

=head2 getuserflags

    my $authflags = getuserflags($flags, $userid, [$dbh]);

Translates integer flags into permissions strings hash.

C<$flags> is the integer userflags value ( borrowers.userflags )
C<$userid> is the members.userid, used for building subpermissions
C<$authflags> is a hashref of permissions

=cut

sub getuserflags {
    my $flags  = shift;
    my $userid = shift;
    my $dbh    = @_ ? shift : C4::Context->dbh;
    my $userflags;
    {
        # I don't want to do this, but if someone logs in as the database
        # user, it would be preferable not to spam them to death with
        # numeric warnings. So, we make $flags numeric.
        no warnings 'numeric';
        $flags += 0;
    }
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
    foreach my $module ( keys %$user_subperms ) {
        next if $userflags->{$module} == 1;    # user already has permission for everything in this module
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
    my $sth = $dbh->prepare( "SELECT flag, user_permissions.code
                             FROM user_permissions
                             JOIN permissions USING (module_bit, code)
                             JOIN userflags ON (module_bit = bit)
                             JOIN borrowers USING (borrowernumber)
                             WHERE userid = ?" );
    $sth->execute($userid);

    my $user_perms = {};
    while ( my $perm = $sth->fetchrow_hashref ) {
        $user_perms->{ $perm->{'flag'} }->{ $perm->{'code'} } = 1;
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
    my $sth = $dbh->prepare( "SELECT flag, code
                             FROM permissions
                             JOIN userflags ON (module_bit = bit)" );
    $sth->execute();

    my $all_perms = {};
    while ( my $perm = $sth->fetchrow_hashref ) {
        $all_perms->{ $perm->{'flag'} }->{ $perm->{'code'} } = 1;
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
    my ( $userid, $flagsrequired ) = @_;
    my $sth = C4::Context->dbh->prepare("SELECT flags FROM borrowers WHERE userid=?");
    $sth->execute($userid);
    my $row = $sth->fetchrow();
    my $flags = getuserflags( $row, $userid );
    if ( $userid eq C4::Context->config('user') ) {

        # Super User Account from /etc/koha.conf
        $flags->{'superlibrarian'} = 1;
    }

    return $flags if $flags->{superlibrarian};

    foreach my $module ( keys %$flagsrequired ) {
        my $subperm = $flagsrequired->{$module};
        if ( $subperm eq '*' ) {
            return 0 unless ( $flags->{$module} == 1 or ref( $flags->{$module} ) );
        } else {
            return 0 unless (
                ( defined $flags->{$module} and
                    $flags->{$module} == 1 )
                or
                ( ref( $flags->{$module} ) and
                    exists $flags->{$module}->{$subperm} and
                    $flags->{$module}->{$subperm} == 1 )
            );
        }
    }
    return $flags;

    #FIXME - This fcn should return the failed permission so a suitable error msg can be delivered.
}

sub getborrowernumber {
    my ($userid) = @_;
    my $userenv = C4::Context->userenv;
    if ( defined($userenv) && ref($userenv) eq 'HASH' && $userenv->{number} ) {
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

Crypt::Eksblowfish::Bcrypt(3)

Digest::MD5(3)

=cut
