package C4::Output;

# $Id$

#package to deal with marking up output
#You will need to edit parts of this pm
#set the value of path to be where your html lives


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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# NOTE: I'm pretty sure this module is deprecated in favor of
# templates.

use strict;
require Exporter;

use C4::Context;
use C4::Database;
use HTML::Template;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Output - Functions for managing templates

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
		&themelanguage &gettemplate setlanguagecookie
		);

#FIXME: this is a quick fix to stop rc1 installing broken
#Still trying to figure out the correct fix.
my $path = C4::Context->config('intrahtdocs')."/default/en/includes/";

#---------------------------------------------------------------------------------------------------------
# FIXME - POD
sub gettemplate {
	my ($tmplbase, $opac, $query) = @_;
if (!$query){
  warn "no query in gettemplate";
  }
	my $htdocs;
	if ($opac ne "intranet") {
		$htdocs = C4::Context->config('opachtdocs');
	} else {
		$htdocs = C4::Context->config('intrahtdocs');
	}

	my ($theme, $lang) = themelanguage($htdocs, $tmplbase, $opac, $query);

	my $template = HTML::Template->new(filename      => "$htdocs/$theme/$lang/$tmplbase",
				   die_on_bad_params => 0,
				   global_vars       => 1,
				   path              => ["$htdocs/$theme/$lang/includes"]);

	$template->param(themelang => ($opac ne 'intranet'? '/opac-tmpl': '/intranet-tmpl') . "/$theme/$lang",
							interface => ($opac ne 'intranet'? '/opac-tmpl': '/intranet-tmpl'),
							theme => $theme,
							lang => $lang);

        
	return $template;
}

#---------------------------------------------------------------------------------------------------------
# FIXME - POD
sub themelanguage {
  my ($htdocs, $tmpl, $section, $query) = @_;
#   if (!$query) {
#     warn "no query";
#   }
  my $dbh = C4::Context->dbh;
  my @languages;
  my @themes;
  if ( $section eq "intranet")
  {
    @languages = split " ", C4::Context->preference("opaclanguages");
    @themes = split " ", C4::Context->preference("template");
  }
  else
  {
  # we are in the opac here, what im trying to do is let the individual user
  # set the theme they want to use.
  # and perhaps the them as well.
  my $lang=$query->cookie('KohaOpacLanguage');
  if ($lang){
  
    push @languages,$lang;
    @themes = split " ", C4::Context->preference("opacthemes");
  } 
  else {
    @languages = split " ", C4::Context->preference("opaclanguages");
    @themes = split " ", C4::Context->preference("opacthemes");
    }
  }

  my ($theme, $lang);
# searches through the themes and languages. First template it find it returns.
# Priority is for getting the theme right.
  THEME:
  foreach my $th (@themes) {
    foreach my $la (@languages) {
	for (my $pass = 1; $pass <= 2; $pass += 1) {
	  $la =~ s/([-_])/ $1 eq '-'? '_': '-' /eg if $pass == 2;
	  if (-e "$htdocs/$th/$la/$tmpl") {
	      $theme = $th;
	      $lang = $la;
	      last THEME;
	  }
	last unless $la =~ /[-_]/;
	}
    }
  }
  if ($theme and $lang) {
    return ($theme, $lang);
  } else {
    return ('default', 'en');
  }
}

sub setlanguagecookie {
   my ($query,$language,$uri)=@_;
   my $cookie=$query->cookie(-name => 'KohaOpacLanguage',
                                           -value => $language,
					   -expires => '');
   print $query->redirect(-uri=>$uri,
   -cookie=>$cookie);
}				   


END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
