#!/usr/bin/perl -d

# Copyright 2015 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

interactiveWebDriverShell.pl

=head1 SYNOPSIS

    misc/devel/interactiveWebDriverShell.pl -p mainpage.pl

Prepares a perl debugger session with the requested PageObject loaded.
Then you can easily guide the UserAgent through the web session.

=cut

use Modern::Perl;

use Getopt::Long qw(:config no_ignore_case);
use Data::Dumper;

my ($help, $page, $list, @params, @login);

GetOptions(
    "h|help"        => \$help,
    "p|page=s"      => \$page,
    "P|params=s{,}" => \@params,
    "L|login=s{,}"  => \@login,
    "l|list"        => \$list,
);

my $help_msg = <<HELP;

interactiveWebDriverShell.pl

    Prepares a perl debugger session with the requested PageObject loaded.
    Then you can easily guide the UserAgent through the web session.

    You should install Term::ReadLine::Gnu for a more pleasant debugging experience.

    -h --help   This help!

    -p --page   Which PageObject matching the given page you want to preload?

    -P --params List of parameters the PageObject must have.

    -L --login  List of userid and password to automatically login to Koha. Eg:
                ./interactiveWebDriverShell.pl -L admin 1234 -p members/moremember.pl -P 12

    -l --list   Lists available PageObjects and their matching --page -parameter
                values.

EXAMPLE INVOCATIONS:

./interactiveWebDriverShell.pl -p mainpage.pl -L admin 1234
./interactiveWebDriverShell.pl -p members/moremember.pl -P 1 -L admin 1234

USAGE:

Start the session from your shell
    ..\$ misc/devel/interactiveWebDriverShell.pl -p mainpage.pl
or
Start the session from your shell with parameters
    ..\$ misc/devel/interactiveWebDriverShell.pl -p members/moremember.pl -P 12

Continue to the breakpoint set in this script
    DB<1> c

The PageObject is bound to variable \$po,
and the Selenium::Remote::Driver-implementation to \$d.
Then all you need to do is start navigating the web!
    DB<2> \$po->isPasswordLoginAvailable()->doPasswordLogin('admin','1234');

    DB<3> \$ele = \$d->find_element('input[value="Save"]');

Note! Do not use "my \$ele = 123;" in the debugger session, because that doesn't
work as excepted, simply use "\$ele = 123;".

HELP

if ($help) {
    print $help_msg;
    exit;
}
unless ($page || $list) {
    print $help_msg;
    exit;
}

my $supportedPageObjects = {
################################################################################
  ########## STAFF CONFIGURATIONS ##########
################################################################################
    'mainpage.pl' =>
    {   package     => "t::lib::Page::Mainpage",
        urlEndpoint => "mainpage.pl",
        status      => "OK",
        params      => "none",
    },
    "members/moremember.pl" =>
    {   package     => "t::lib::Page::Members::Moremember",
        urlEndpoint => "members/moremember.pl",
        status      => "not implemented",
        params      => ["borrowernumber"],
    },
    "members/statistics.pl" =>
    {   package     => "t::lib::Page::Members::Statistics",
        urlEndpoint => "members/statistics.pl",
        status      => "OK",
        params      => ["borrowernumber"],
    },
    "members/member-flags.pl" =>
    {   package     => "t::lib::Page::Members::MemberFlags",
        urlEndpoint => "members/member-flags.pl",
        status      => "not implemented",
        params      => ["borrowernumber"],
    },
    "catalogue/detail.pl" =>
    {   package     => "t::lib::Page::Catalogue::Detail",
        urlEndpoint => "catalogue/detail.pl",
        status      => "OK",
        params      => ["biblionumber"],
    },
################################################################################
  ########## OPAC CONFIGURATIONS ##########
################################################################################
    "opac/opac-main.pl" =>
    {   package     => "t::lib::Page::Opac::OpacMain",
        urlEndpoint => "opac/opac-main.pl",
        status      => "OK",
    },
};
################################################################################
  ########## END OF PAGE CONFIGURATIONS ##########
################################################################################

listSupportedPageObjects ($supportedPageObjects) if $list;
my ($po, $d) = deployPageObject($supportedPageObjects, $page, \@params, \@login) if $page;



print "--Debugging--\n";
$DB::single = 1; #Breakpoint here
$DB::single = 1;



sub listSupportedPageObjects {
    my ($supportedPageObjects) = @_;
    print Data::Dumper::Dumper($supportedPageObjects);
    exit;
}
sub deployPageObject {
    my ($supportedPageObjects, $page, $params, $login) = @_;

    ##Find correct PageObject deployment rules
    my $pageObjectMapping = $supportedPageObjects->{$page};
    die "No PageObject mapped to --page '$page'. See --list to list available PageObjects.\n" unless $pageObjectMapping;

    ##Dynamically load package
    my $package = $pageObjectMapping->{package};
    eval "require $package";

    ##Fill required parameters
    my $poParams = {};
    if (ref($pageObjectMapping->{params}) eq 'ARRAY') {
        foreach my $paramName (@{$pageObjectMapping->{params}}) {
            $poParams->{$paramName} = shift(@$params);
            die "Insufficient parameters given, parameter '$paramName' unsatisfied.\n" unless $poParams->{$paramName};
        }
    }

    ##Check if the status is OK
    die "PageObject status for '$page' is not 'OK'. Current status '".$pageObjectMapping->{status}."'.\nPlease implement the missing PageObject.\n" unless $pageObjectMapping->{status} eq 'OK';

    ##Create PageObject
    my $po = $package->new($poParams);

    ##Password login if desired
    eval {
       $po->isPasswordLoginAvailable->doPasswordLogin($login->[0], $login->[1]) if scalar(@$login);
    }; if ($@) {
        print "Password login unavailable.\n";
    }

    return ($po, $po->getDriver());
}
