#!/usr/bin/perl

# Copyright (C) 2009 LibLime
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
use warnings;

=head1 NAME

valid-templates.t

=head1 DESCRIPTION

This test checks all staff and OPAC templates and includes for syntax errors 
by running a helper script that loads each template into a HTML::Template::Pro
object and calls the output() method, which forces the template to be parsed.
HTML::Template::Pro currently reports any syntax errors to STDERR.

This test currently ignores error messages of the form

EXPR:at pos n: non-initialized variable foo

However, note that TMPL_IF EXPR is currently discouraged for use in Koha
templates.

=cut

use Test::More qw/no_plan/;
use File::Find;
use File::Spec;
use FindBin;
use IPC::Open3;

foreach my $type qw(intranet opac) {
    my $template_dir = File::Spec->rel2abs("koha-tmpl/$type-tmpl/prog/en/modules");
    my $include_dir  = File::Spec->rel2abs("koha-tmpl/$type-tmpl/prog/en/includes");
   
    my $template_test = gen_template_test($include_dir);
    find({ wanted => $template_test, no_chdir => 1 }, $template_dir, $include_dir);
}

sub gen_template_test {
    my $include_dir = shift;
    return sub {
        return unless -f $File::Find::name;

        # We're starting a seprate process to test the template
        # because some of the error messages we're interested in
        # are written directly to STDERR in HTML::Template::Pro's
        # XS code.  I haven't found any other way to capture
        # those messages. --gmc
        local *CHILD_IN;
        local *CHILD_OUT;
        my $pid = open3(\*CHILD_IN, \*CHILD_OUT, \*CHILD_ERR, 
                        "$FindBin::Bin/test_template.pl", $File::Find::name, $include_dir);
        my @errors = ();
        while (<CHILD_ERR>) {
            push @errors, $_;
        }
        waitpid($pid, 0);

        @errors = grep { ! /^EXPR:.*non-initialized variable/ } @errors; # ignoring EXPR errors for now
        my $rel_filename = File::Spec->abs2rel($File::Find::name);
        ok(@errors == 0, "no errors in $rel_filename") or diag(join("", @errors) );
    }

}

=head1 AUTHOR

Koha Developement team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut
