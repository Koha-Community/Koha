#!/usr/bin/perl

# script to edit a member's flags
# Written by Steve Tonnesen
# July 26, 2002 (my birthday!)

use strict;
use warnings;

use CGI qw ( -utf8 );
use C4::Output;
use C4::Auth qw(:DEFAULT :EditPermissions);
use C4::Context;
use C4::Members;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use Koha::Auth::PermissionManager;

use Koha::Exception::BadParameter;

use Koha::Patron::Categories;

use C4::Output;
use Koha::Patron::Images;
use Koha::Token;

my $input = new CGI;

my $flagsrequired = { permissions => 1 };
my $member=$input->param('member');
my $bor = GetMember( borrowernumber => $member );
if( $bor->{'category_type'} eq 'S' )  {
	$flagsrequired->{'staffaccess'} = 1;
}
my ($template, $loggedinuser, $cookie) = get_template_and_user({
        template_name   => "members/member-flags.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => $flagsrequired,
        debug           => 1,
});

my $permissionManager = Koha::Auth::PermissionManager->new();
my %member2;
$member2{'borrowernumber'}=$member;

if ($input->param('newflags')) {

    die "Wrong CSRF token"
        unless Koha::Token->new->check_csrf({
            session_id => scalar $input->cookie('CGISESSID'),
            token  => scalar $input->param('csrf_token'),
        });


    my $dbh=C4::Context->dbh();
    #Cast CGI-params into a permissions HASH.
    my @perms = $input->multi_param('flag');
    my %sub_perms = ();
    foreach my $perm (@perms) {
        if ($perm eq 'superlibrarian') {
            $sub_perms{superlibrarian}->{superlibrarian} = 1;
        }
        elsif ($perm !~ /:/) {
            #DEPRECATED, GUI still sends the module flags here even though they have been removed from the DB.
        } else {
            my ($module, $sub_perm) = split /:/, $perm, 2;
	    $sub_perms{$module}->{$sub_perm} = 1;
        }
    }

    $permissionManager->revokeAllPermissions($member);
    $permissionManager->grantPermissions($member, \%sub_perms);
    
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member");
} else {

    my $all_perms  = $permissionManager->listKohaPermissionsAsHASH();
    my $user_perms = $permissionManager->getBorrowerPermissions($member);

    $all_perms = markBorrowerGrantedPermissions($all_perms, $user_perms);
    my @loop;

    push @loop, preparePermissionModuleForDisplay($all_perms, 'superlibrarian');
    foreach my $module (sort(keys(%$all_perms))) {
    push @loop, preparePermissionModuleForDisplay($all_perms, $module) unless $module eq 'superlibrarian';
    }

    if ( $bor->{'category_type'} eq 'C') {
        my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
        $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
        $template->param( 'catcode' => $patron_categories->next )  if $patron_categories->count == 1;
    }
	
$template->param( adultborrower => 1 ) if ( $bor->{'category_type'} eq 'A' || $bor->{'category_type'} eq 'I' );
    my $patron_image = Koha::Patron::Images->find($bor->{borrowernumber});
    $template->param( picture => 1 ) if $patron_image;

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($bor->{'borrowernumber'});
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

$template->param(
		borrowernumber => $bor->{'borrowernumber'},
    cardnumber => $bor->{'cardnumber'},
		surname => $bor->{'surname'},
		firstname => $bor->{'firstname'},
        othernames => $bor->{'othernames'},
		categorycode => $bor->{'categorycode'},
		category_type => $bor->{'category_type'},
		categoryname => $bor->{'description'},
        address => $bor->{address},
		address2 => $bor->{'address2'},
        streettype => $bor->{streettype},
		city => $bor->{'city'},
        state => $bor->{'state'},
		zipcode => $bor->{'zipcode'},
		country => $bor->{'country'},
		phone => $bor->{'phone'},
        phonepro => $bor->{'phonepro'},
        mobile => $bor->{'mobile'},
		email => $bor->{'email'},
        emailpro => $bor->{'emailpro'},
		branchcode => $bor->{'branchcode'},
		loop => \@loop,
		is_child        => ($bor->{'category_type'} eq 'C'),
        RoutingSerials => C4::Context->preference('RoutingSerials'),
        csrf_token => Koha::Token->new->generate_csrf( { session_id => scalar $input->cookie('CGISESSID'), } ),
		);

    output_html_with_http_headers $input, $cookie, $template->output;

}

=head markBorrowerGrantedPermissions

Adds a 'checked'-value for all subpermissions in the all-Koha-Permissions-list
that the current borrower has been granted.
@PARAM1 HASHRef of all Koha permissions and modules.
@PARAM1 ARRAYRef of all the granted Koha::Auth::BorrowerPermission-objects.
@RETURNS @PARAM1, slightly checked.
=cut

sub markBorrowerGrantedPermissions {
	my ($all_perms, $user_perms) = @_;

	foreach my $borrowerPermission (@$user_perms) {
		my $module = $borrowerPermission->getPermissionModule->module;
		my $code   = $borrowerPermission->getPermission->code;
		$all_perms->{$module}->{permissions}->{$code}->{checked} = 1;
	}
	return $all_perms;
}

=head checkIfAllModulePermissionsGranted

@RETURNS Boolean, 1 if all permissions granted.
=cut

sub checkIfAllModulePermissionsGranted {
	my ($moduleHash) = @_;
	foreach my $code (keys(%{$moduleHash->{permissions}})) {
		unless ($moduleHash->{permissions}->{$code}->{checked}) {
			return 0;
		}
	}
	return 1;
}

sub preparePermissionModuleForDisplay {
	my ($all_perms, $module) = @_;

	my $moduleHash = $all_perms->{$module};
	my $checked = checkIfAllModulePermissionsGranted($moduleHash);

	my %row = (
		bit => $module,
		flag => $module,
		checked => $checked,
		flagdesc => $moduleHash->{description} );

	my @sub_perm_loop = ();
	my $expand_parent = 0;

	if ($module ne 'superlibrarian') {
		foreach my $sub_perm (sort keys %{ $all_perms->{$module}->{permissions} }) {
			my $sub_perm_checked = $all_perms->{$module}->{permissions}->{$sub_perm}->{checked};
			$expand_parent = 1 if $sub_perm_checked;

			push @sub_perm_loop, {
				id => "${module}_$sub_perm",
				perm => "$module:$sub_perm",
				code => $sub_perm,
				description => $all_perms->{$module}->{permissions}->{$sub_perm}->{description},
				checked => $sub_perm_checked || 0,
			};
		}

		$row{expand} = $expand_parent;
		if ($#sub_perm_loop > -1) {
			$row{sub_perm_loop} = \@sub_perm_loop;
		}
	}
	return \%row;
}
