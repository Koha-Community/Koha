package C4::Interface::CGI::Template;

# $Id$

# convenience package for HTML templating
# Note: This is just a utility module; it should not be instantiated.


# Copyright 2003 Katipo Communications
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
require Exporter;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Members - Convenience functions for using HTML::Template

=head1 SYNOPSIS

  use C4::Interface::HTML::Template;

=head1 DESCRIPTION

The functions in this module peek into a piece of HTML and return strings
related to the (guessed) charset.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
		&expand_sex_into_predicate
	     );

=item expand_sex_into_predicate

  $data{&expand_sex_into_predicate($data{sex})} = 1;

Converts a single 'M' or 'F' into 'sex_M_p' or 'sex_F_p'
respectively.

In some languages, 'M' and 'F' are not appropriate. However,
with HTML::Template, there is no way to localize 'M' or 'F'
unless these are converted into variables that TMPL_IF can
understand. This function provides this conversion.

=cut

sub expand_sex_into_predicate ($) {
   my($sex) = @_;
   return "sex_${sex}_p";
} # expand_sex_into_predicate

#---------------------------------

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
