#!/usr/bin/perl

# Copyright 2009 LibLime
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
#

use strict;
use warnings;
use C4::Service;
use C4::Form::MessagingPreferences;

# Simple JSON service to get the default messaging preferences
# for a patron category - used by the patron editing form to
# update the prefs if operator is creating a new patron and has
# changed the patron category from its original value.

my ($query, $response) = C4::Service->init(borrowers => 1);
my ($categorycode) = C4::Service->require_params('categorycode');
C4::Form::MessagingPreferences::set_form_values({ categorycode => $categorycode }, $response);
C4::Service->return_success( $response );

