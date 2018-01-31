#!/usr/bin/perl

# script to edit a member's flags
# Written by Steve Tonnesen
# July 26, 2002 (my birthday!)

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Output;
use C4::Auth qw(:DEFAULT :EditPermissions);
use C4::Context;
use C4::Members;
use C4::Members::Attributes qw(GetBorrowerAttributes);
#use C4::Acquisitions;

use Koha::Patron::Categories;
use Koha::Patrons;

use C4::Output;
use Koha::Token;

my $input = new CGI;

my $flagsrequired = { permissions => 1 };
my $member=$input->param('member');
my $patron = Koha::Patrons->find( $member );
unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$member");
    exit;
}

my $category_type = $patron->category->category_type;
my $bor = $patron->unblessed;
if( $category_type eq 'S' )  { # FIXME Is this really needed?
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

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

my %member2;
$member2{'borrowernumber'}=$member;

if ($input->param('newflags')) {

    die "Wrong CSRF token"
        unless Koha::Token->new->check_csrf({
            session_id => scalar $input->cookie('CGISESSID'),
            token  => scalar $input->param('csrf_token'),
        });


    my $dbh=C4::Context->dbh();

    my @perms = $input->multi_param('flag');
    my %all_module_perms = ();
    my %sub_perms = ();
    foreach my $perm (@perms) {
        if ($perm !~ /:/) {
            $all_module_perms{$perm} = 1;
        } else {
            my ($module, $sub_perm) = split /:/, $perm, 2;
            push @{ $sub_perms{$module} }, $sub_perm;
        }
    }

    # construct flags
    my $module_flags = 0;
    my $sth=$dbh->prepare("SELECT bit,flag FROM userflags ORDER BY bit");
    $sth->execute();
    while (my ($bit, $flag) = $sth->fetchrow_array) {
        if (exists $all_module_perms{$flag}) {
            $module_flags += 2**$bit;
        }
    }
    
    $sth = $dbh->prepare("UPDATE borrowers SET flags=? WHERE borrowernumber=?");
    if( !C4::Context->preference('ProtectSuperlibPrivs') || C4::Context->IsSuperLibrarian ) {
        $sth->execute($module_flags, $member);
    } else {
        my $old_flags = $patron->flags // 0;
        if( ( $old_flags == 1 || $module_flags == 1 ) &&
              $old_flags != $module_flags ) {
           die "Non-superlibrarian is changing superlibrarian privileges"; # Interface should not allow this, so we can just die here
        } else {
            $sth->execute($module_flags, $member);
        }
    }
    
    # deal with subpermissions
    $sth = $dbh->prepare("DELETE FROM user_permissions WHERE borrowernumber = ?");
    $sth->execute($member); 
    $sth = $dbh->prepare("INSERT INTO user_permissions (borrowernumber, module_bit, code)
                        SELECT ?, bit, ?
                        FROM userflags
                        WHERE flag = ?");
    foreach my $module (keys %sub_perms) {
        next if exists $all_module_perms{$module};
        foreach my $sub_perm (@{ $sub_perms{$module} }) {
            $sth->execute($member, $sub_perm, $module);
        }
    }
    
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member");
} else {

    my $accessflags;
    my $dbh = C4::Context->dbh();
    # FIXME This needs to be improved to avoid doing the same query
    my $sth = $dbh->prepare("select bit,flag from userflags");
    $sth->execute;
    while ( my ( $bit, $flag ) = $sth->fetchrow ) {
        if ( $bor->{flags} && $bor->{flags} & 2**$bit ) {
            $accessflags->{$flag} = 1;
        }
    }

    my $all_perms  = get_all_subpermissions();
    my $user_perms = get_user_subpermissions($bor->{'userid'});
    $sth = $dbh->prepare("SELECT bit, flag FROM userflags ORDER BY bit");
    $sth->execute;
    my @loop;

    while (my ($bit, $flag) = $sth->fetchrow) {
        my $checked='';
        if ($accessflags->{$flag}) {
            $checked= 1;
        }

        my %row = ( bit => $bit,
            flag => $flag,
            checked => $checked,
        );

        my @sub_perm_loop = ();
        my $expand_parent = 0;
        if ($checked) {
            if (exists $all_perms->{$flag}) {
                $expand_parent = 1;
                foreach my $sub_perm (sort keys %{ $all_perms->{$flag} }) {
                    push @sub_perm_loop, {
                        id => "${flag}_$sub_perm",
                        perm => "$flag:$sub_perm",
                        code => $sub_perm,
                        checked => 1
                    };
                }
            }
        } else {
            if (exists $user_perms->{$flag}) {
                $expand_parent = 1;
                # put selected ones first
                foreach my $sub_perm (sort keys %{ $user_perms->{$flag} }) {
                    push @sub_perm_loop, {
                        id => "${flag}_$sub_perm",
                        perm => "$flag:$sub_perm",
                        code => $sub_perm,
                        checked => 1
                    };
                }
            }
            # then ones not selected
            if (exists $all_perms->{$flag}) {
                foreach my $sub_perm (sort keys %{ $all_perms->{$flag} }) {
                    push @sub_perm_loop, {
                        id => "${flag}_$sub_perm",
                        perm => "$flag:$sub_perm",
                        code => $sub_perm,
                        checked => 0
                    } unless exists $user_perms->{$flag} and exists $user_perms->{$flag}->{$sub_perm};
                }
            }
        }
        $row{expand} = $expand_parent;
        if ($#sub_perm_loop > -1) {
            $row{sub_perm_loop} = \@sub_perm_loop;
        }
        push @loop, \%row;
    }

    if ( $patron->is_child ) {
        my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
        $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
        $template->param( 'catcode' => $patron_categories->next->categorycode )  if $patron_categories->count == 1;
    }

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($bor->{'borrowernumber'});
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

$template->param(
    patron         => $patron,
    loop           => \@loop,
    csrf_token =>
        Koha::Token->new->generate_csrf( { session_id => scalar $input->cookie('CGISESSID'), } ),
    disable_superlibrarian_privs => C4::Context->preference('ProtectSuperlibPrivs') ? !C4::Context->IsSuperLibrarian : 0,
);

    output_html_with_http_headers $input, $cookie, $template->output;

}
