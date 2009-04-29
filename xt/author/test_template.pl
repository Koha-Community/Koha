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

test_template.pl

=head2 DESCRIPTION

This helper script is invoked by xt/author/valid-templates.t
and tests a template for basic syntax errors by having
HTML::Template::Pro parse it.

=cut

use FindBin qw($Bin);
use HTML::Template::Pro;

my $filename    = $ARGV[0];
my $include_dir = $ARGV[1];

my $template = HTML::Template::Pro->new(
    filename          => $filename,
    die_on_bad_params => 1,
    global_vars       => 1,
    case_sensitive    => 1,
    loop_context_vars => 1,     # enable: __first__, __last__, __inner__, __odd__, __counter__ 
    path              => [$include_dir],
);

$template->output; # tossing output

=head1 AUTHOR

Koha Developement team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut
