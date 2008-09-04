#!/usr/bin/perl

# script to edit a member's flags
# Written by Steve Tonnesen
# July 26, 2002 (my birthday!)

use strict;

use CGI;
use C4::Output;
use C4::Auth qw(:DEFAULT :EditPermissions);
use C4::Context;
use C4::Members;
use C4::Branch;
#use C4::Acquisitions;

use C4::Output;

my $input = new CGI;

my $flagsrequired = { permissions => 1 };
my $member=$input->param('member');
my $bor = GetMemberDetails( $member,'');
if( $bor->{'category_type'} eq 'S' )  {
	$flagsrequired->{'staffaccess'} = 1;
}
my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "members/member-flags.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => $flagsrequired,
				debug => 1,
				});


my %member2;
$member2{'borrowernumber'}=$member;

if ($input->param('newflags')) {
    my $dbh=C4::Context->dbh();

    my @perms = $input->param('flag');
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
    $sth->execute($module_flags, $member);
    
    if (C4::Context->preference('GranularPermissions')) {
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
    }
    
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member");
} else {
#     my ($bor,$flags,$accessflags)=GetMemberDetails($member,'');
    my $flags = $bor->{'flags'};
    my $accessflags = $bor->{'authflags'};
    my $dbh=C4::Context->dbh();
    my $all_perms  = get_all_subpermissions();
    my $user_perms = get_user_subpermissions($bor->{'userid'});
    my $sth=$dbh->prepare("SELECT bit,flag,flagdesc FROM userflags ORDER BY bit");
    $sth->execute;
    my @loop;
    while (my ($bit, $flag, $flagdesc) = $sth->fetchrow) {
	    my $checked='';
	    if ($accessflags->{$flag}) {
	        $checked= 1;
	    }

	    my %row = ( bit => $bit,
		    flag => $flag,
		    checked => $checked,
		    flagdesc => $flagdesc );

        if (C4::Context->preference('GranularPermissions')) {
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
                            description => $all_perms->{$flag}->{$sub_perm},
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
                            description => $all_perms->{$flag}->{$sub_perm},
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
                            description => $all_perms->{$flag}->{$sub_perm},
                            checked => 0
                        } unless exists $user_perms->{$flag} and exists $user_perms->{$flag}->{$sub_perm};
                    }
                }
            }
            $row{expand} = $expand_parent;
            if ($#sub_perm_loop > -1) {
            $row{sub_perm_loop} = \@sub_perm_loop;
            }
        }
	    push @loop, \%row;
    }

    if ( $bor->{'category_type'} eq 'C') {
        my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
        my $cnt = scalar(@$catcodes);
        $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
        $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
    }
	
$template->param( adultborrower => 1 ) if ( $bor->{'category_type'} eq 'A' );
    my ($picture, $dberror) = GetPatronImage($bor->{'cardnumber'});
    $template->param( picture => 1 ) if $picture;
		
$template->param(
		borrowernumber => $bor->{'borrowernumber'},
    cardnumber => $bor->{'cardnumber'},
		surname => $bor->{'surname'},
		firstname => $bor->{'firstname'},
		categorycode => $bor->{'categorycode'},
		category_type => $bor->{'category_type'},
		categoryname => $bor->{'description'},
		address => $bor->{'address'},
		address2 => $bor->{'address2'},
		city => $bor->{'city'},
		zipcode => $bor->{'zipcode'},
		phone => $bor->{'phone'},
		email => $bor->{'email'},
		branchcode => $bor->{'branchcode'},
		branchname => GetBranchName($bor->{'branchcode'}),
		loop => \@loop,
		is_child        => ($bor->{'category_type'} eq 'C'),
		);

    output_html_with_http_headers $input, $cookie, $template->output;

}
