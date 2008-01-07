package C4::Languages;

# Copyright 2006 (C) LibLime
# Joshua Ferraro <jmf@liblime.com>
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
use warnings;	#FIXME: turn off warnings before release
use C4::Context;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $DEBUG);

BEGIN {
	$VERSION = 3.00;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&getFrameworkLanguages
		&getTranslatedLanguages
		&getAllLanguages
	);
	@EXPORT_OK = qw(getFrameworkLanguages getTranslatedLanguages getAllLanguages get_bidi regex_lang_subtags language_get_description accept_language);
	$DEBUG = 0;
}

=head1 NAME

C4::Languages - Perl Module containing language list functions for Koha 

=head1 SYNOPSIS

use C4::Languages;

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 getFrameworkLanguages

Returns a reference to an array of hashes:

 my $languages = getFrameworkLanguages();
 for my $language(@$languages) {
    print "$language->{language_code}\n"; # language code in iso 639-2
    print "$language->{language_name}\n"; # language name in native script
    print "$language->{language_locale_name}\n"; # language name in current locale
 }

=cut

sub getFrameworkLanguages {
    # get a hash with all language codes, names, and locale names
    my $all_languages = getAllLanguages();
    my @languages;
    
    # find the available directory names
    my $dir=C4::Context->config('intranetdir')."/installer/data/";
    opendir (MYDIR,$dir);
    my @listdir= grep { !/^\.|CVS/ && -d "$dir/$_"} readdir(MYDIR);    
    closedir MYDIR;

    # pull out all data for the dir names that exist
    for my $dirname (@listdir) {
        for my $language_set (@$all_languages) {

            if ($dirname eq $language_set->{language_code}) {
                push @languages, {
					'language_code'=>$dirname, 
					'language_description'=>$language_set->{language_description}, 
					'native_descrition'=>$language_set->{language_native_description} }
            }
        }
    }
    return \@languages;
}

=head2 getTranslatedLanguages

Returns a reference to an array of hashes:

 my $languages = getTranslatedLanguages();
 print "Available translated langauges:\n";
 for my $language(@$trlanguages) {
    print "$language->{language_code}\n"; # language code in iso 639-2
    print "$language->{language_name}\n"; # language name in native script
    print "$language->{language_locale_name}\n"; # language name in current locale
 }

=cut

sub getTranslatedLanguages {
    my ($interface, $theme) = @_;
    my $htdocs;
    my $all_languages = getAllLanguages();
    my @languages;
    my $lang;
    
    if ($interface && $interface eq 'opac' ) {
        $htdocs = C4::Context->config('opachtdocs');
        if ( $theme and -d "$htdocs/$theme" ) {
            (@languages) = _get_language_dirs($htdocs,$theme);
            return _build_languages_arrayref($all_languages,@languages);
        }
        else {
            for my $theme ( _get_themes('opac') ) {
                push @languages, _get_language_dirs($htdocs,$theme);
            }
            return _build_languages_arrayref($all_languages,@languages);
        }
    }
    elsif ($interface && $interface eq 'intranet' ) {
        $htdocs = C4::Context->config('intrahtdocs');
        if ( $theme and -d "$htdocs/$theme" ) {
            @languages = _get_language_dirs($htdocs,$theme);
            return _build_languages_arrayref($all_languages,@languages);
        }
        else {
            foreach my $theme ( _get_themes('opac') ) {
                push @languages, _get_language_dirs($htdocs,$theme);
            }
            return _build_languages_arrayref($all_languages,@languages);
        }
    }
    else {
        my $htdocs = C4::Context->config('intrahtdocs');
        foreach my $theme ( _get_themes('intranet') ) {
            push @languages, _get_language_dirs($htdocs,$theme);
        }
        $htdocs = C4::Context->config('opachtdocs');
        foreach my $theme ( _get_themes('opac') ) {
            push @languages, _get_language_dirs($htdocs,$theme);
        }
        return _build_languages_arrayref($all_languages,@languages);
    }
}

=head2 getAllLanguages

Returns a reference to an array of hashes:

 my $alllanguages = getAllLanguages();
 print "Available translated langauges:\n";
 for my $language(@$alllanguages) {
    print "$language->{language_code}\n";
    print "$language->{language_name}\n";
    print "$language->{language_locale_name}\n";
 }

=cut

sub getAllLanguages {
	my @languages_loop;
	my $dbh=C4::Context->dbh;
	my $current_language = 'en';
	my $sth = $dbh->prepare('SELECT * FROM language_subtag_registry WHERE type=\'language\'');
	$sth->execute();
	while (my $language_subtag_registry = $sth->fetchrow_hashref) {

		# pull out all the script descriptions for each language
		my $sth2= $dbh->prepare('SELECT * FROM language_descriptions WHERE type=\'language\' AND subtag =?');
		$sth2->execute($language_subtag_registry->{subtag});

		# add the correct description info
		while (my $language_descriptions = $sth2->fetchrow_hashref) {
			
			# Insert the language description using the current language script
			#if ( $language_subtag_registry->{subtag}
			if ( $current_language eq $language_descriptions->{lang} ) {
				$language_subtag_registry->{language_description} = $language_descriptions->{description};
				#warn "CUR:".$language_subtag_registry->{description};
			}

			# Insert the language name using the script	native to the language (FIXME: should really be based on script)
			if  ($language_subtag_registry->{subtag} eq $language_descriptions->{lang}) {
				$language_subtag_registry->{language_native_description} = $language_descriptions->{description};
				#warn "NAT: Desc:$language_descriptions->{description} SubtagDesc: $language_subtag_registry->{language_description}";
			}
		}	
		push @languages_loop, $language_subtag_registry;
	}
    return \@languages_loop;
}

=head2 _get_themes

Internal function, returns an array of all available themes.

  (@themes) = &_get_themes('opac');
  (@themes) = &_get_themes('intranet');

=cut

sub _get_themes {
    my $interface = shift;
    my $htdocs;
    my @themes;
    if ( $interface eq 'intranet' ) {
        $htdocs = C4::Context->config('intrahtdocs');
    }
    else {
        $htdocs = C4::Context->config('opachtdocs');
    }
    opendir D, "$htdocs";
    my @dirlist = readdir D;
    foreach my $directory (@dirlist) {
        # if there's an en dir, it's a valid theme
        -d "$htdocs/$directory/en" and push @themes, $directory;
    }
    return @themes;
}

=head2 _get_language_dirs

Internal function, returns an array of directory names, excluding non-language directories

=cut

sub _get_language_dirs {
    my ($htdocs,$theme) = @_;
    my @languages;
    opendir D, "$htdocs/$theme";
    for my $language ( readdir D ) {
        next if $language =~/^\./;
        next if $language eq 'all';
        next if $language =~/png$/;
        next if $language =~/css$/;
        next if $language =~/CVS$/;
        next if $language =~/\.txt$/i;     #Don't read the readme.txt !
		next if $language =~/img|images/;
        push @languages, $language;
    }
        return (@languages);
}

=head2 _build_languages_arrayref 

Internal function for building the ref to array of hashes

FIXME: this could be rewritten and simplified using map

=cut

sub _build_languages_arrayref {
        my ($all_languages,@languages) = @_;
        my @final_languages;
        my %seen_languages;
		my %found_languages;
		# Loop through the languages, pick the ones that are translated
        for my $language (@languages) {

			# separate the language string into its subtag types
			my $language_subtags_hashref = regex_lang_subtags($language);
            unless ($seen_languages{$language}) {
                for my $language_code (@$all_languages) {
                    if ($language_subtags_hashref->{language} eq $language_code->{'subtag'}) {
						$language_code->{'language_lang'} = $language;
						$language_code->{'language_code'} = $language_subtags_hashref->{'language'};
						$language_code->{'script_code'} = $language_subtags_hashref->{'script'};
						$language_code->{'region_code'} = $language_subtags_hashref->{'region'};
						$language_code->{'variant_code'} = $language_subtags_hashref->{'variant'};
                        push @final_languages, $language_code;
						$found_languages{$language}++;
                    }
                }
                $seen_languages{$language}++;

				# Handle languages not in our database with their code
				unless ($found_languages{$language}) {
					my $language_code;
					$language_code->{'language_lang'} = $language;
					$language_code->{'language_code'} = $language;
					push @final_languages, $language_code;
				}
            }
        }
        return \@final_languages;
}

sub language_get_description {
	my ($script,$lang,$type) = @_;
	my $dbh = C4::Context->dbh;
	my $desc;
	my $sth = $dbh->prepare('SELECT description FROM language_descriptions WHERE subtag=? AND lang=? AND type=?');
	$sth->execute($script,$lang,$type);
	while (my $descriptions = $sth->fetchrow_hashref) {
		$desc = $descriptions->{'description'};
	}
	return $desc;
}
=head2 regex_lang_subtags

This internal sub takes a string composed according to RFC 4646 as
an input and returns a reference to a hash containing keys and values
for ( language, script, region, variant, extension, privateuse )

=cut

sub regex_lang_subtags {
    my $string = shift;

    # Regex for recognizing RFC 4646 well-formed tags
    # http://www.rfc-editor.org/rfc/rfc4646.txt

    # regexes based on : http://unicode.org/cldr/data/tools/java/org/unicode/cldr/util/data/langtagRegex.txt
    # The structure requires no forward references, so it reverses the order.
    # The uppercase comments are fragments copied from RFC 4646
    #
    # Note: the tool requires that any real "=" or "#" or ";" in the regex be escaped.

    my $alpha   = qr/[a-zA-Z]/ ;    # ALPHA
    my $digit   = qr/[0-9]/ ;   # DIGIT
    my $alphanum    = qr/[a-zA-Z0-9]/ ; # ALPHA / DIGIT
    my $x   = qr/[xX]/ ;    # private use singleton
    my $singleton = qr/[a-w y-z A-W Y-Z]/ ; # other singleton
    my $s   = qr/[-]/ ; # separator -- lenient parsers will use [-_]

    # Now do the components. The structure is slightly different to allow for capturing the right components.
    # The notation (?:....) is a non-capturing version of (...): so the "?:" can be deleted if someone doesn't care about capturing.

    my $extlang = qr{(?: $s $alpha{3} )}x ; # *3("-" 3ALPHA)
    my $language    = qr{(?: $alpha{2,3} | $alpha{4,8} )}x ;
    #my $language   = qr{(?: $alpha{2,3}$extlang{0,3} | $alpha{4,8} )}x ;   # (2*3ALPHA [ extlang ]) / 4ALPHA / 5*8ALPHA

    my $script  = qr{(?: $alpha{4} )}x ;    # 4ALPHA 

    my $region  = qr{(?: $alpha{2} | $digit{3} )}x ;     # 2ALPHA / 3DIGIT

    my $variantSub  = qr{(?: $digit$alphanum{3} | $alphanum{5,8} )}x ;  # *("-" variant), 5*8alphanum / (DIGIT 3alphanum)
    my $variant = qr{(?: $variantSub (?: $s$variantSub )* )}x ; # *("-" variant), 5*8alphanum / (DIGIT 3alphanum)

    my $extensionSub    = qr{(?: $singleton (?: $s$alphanum{2,8} )+ )}x ;   # singleton 1*("-" (2*8alphanum))
    my $extension   = qr{(?: $extensionSub (?: $s$extensionSub )* )}x ; # singleton 1*("-" (2*8alphanum))

    my $privateuse  = qr{(?: $x (?: $s$alphanum{1,8} )+ )}x ;   # ("x"/"X") 1*("-" (1*8alphanum))

    # Define certain grandfathered codes, since otherwise the regex is pretty useless.
    # Since these are limited, this is safe even later changes to the registry --
    # the only oddity is that it might change the type of the tag, and thus
    # the results from the capturing groups.
    # http://www.iana.org/assignments/language-subtag-registry
    # Note that these have to be compared case insensitively, requiring (?i) below.

    my $grandfathered   = qr{(?: (?i)
        en $s GB $s oed
    |   i $s (?: ami | bnn | default | enochian | hak | klingon | lux | mingo | navajo | pwn | tao | tay | tsu )
    |   sgn $s (?: BE $s fr | BE $s nl | CH $s de)
)}x;

    # For well-formedness, we don't need the ones that would otherwise pass, so they are commented out here

    #   |   art $s lojban
    #   |   cel $s gaulish
    #   |   en $s (?: boont | GB $s oed | scouse )
    #   |   no $s (?: bok | nyn)
    #   |   zh $s (?: cmn | cmn $s Hans | cmn $s Hant | gan | guoyu | hakka | min | min $s nan | wuu | xiang | yue)

    # Here is the final breakdown, with capturing groups for each of these components
    # The language, variants, extensions, grandfathered, and private-use may have interior '-'

    #my $root = qr{(?: ($language) (?: $s ($script) )? 40% (?: $s ($region) )? 40% (?: $s ($variant) )? 10% (?: $s ($extension) )? 5% (?: $s ($privateuse) )? 5% ) 90% | ($grandfathered) 5% | ($privateuse) 5% };

	$string =~  qr{^ (?:($language)) (?:$s($script))? (?:$s($region))?  (?:$s($variant))?  (?:$s($extension))?  (?:$s($privateuse))? $}xi;  # |($grandfathered) | ($privateuse) $}xi;
	my %subtag = (
        'language' => $1,
        'script' => $2,
        'region' => $3,
        'variant' => $4,
        'extension' => $5,
        'privateuse' => $6,
    );
    return \%subtag;
}

# Script Direction Resources:
# http://www.w3.org/International/questions/qa-scripts
sub get_bidi {
	my ($language_script)= @_;
	my $dbh = C4::Context->dbh;
	my $bidi;
	my $sth = $dbh->prepare('SELECT bidi FROM language_script_bidi WHERE rfc4646_subtag=?');
	$sth->execute($language_script);
	while (my $result = $sth->fetchrow_hashref) {
		$bidi = $result->{'bidi'};
	}
	return $bidi;
};

sub accept_language {
	# referenced http://search.cpan.org/src/CGILMORE/I18N-AcceptLanguage-1.04/lib/I18N/AcceptLanguage.pm
	my 	($clientPreferences,$supportedLanguages) = @_;
	# There should be no whitespace anways, but a cleanliness/sanity check
	$clientPreferences =~ s/\s//g;
  
	# Prepare the list of client-acceptable languages
	my @languages = ();
	foreach my $tag (split(/,/, $clientPreferences)) {
		my ($language, $quality) = split(/\;/, $tag);
		$quality =~ s/^q=//i if $quality;
		$quality = 1 unless $quality;
		next if $quality <= 0;
		# We want to force the wildcard to be last
		$quality = 0 if ($language eq '*');
		# Pushing lowercase language here saves processing later
		push(@languages, { quality => $quality,
		       language => $language,
		       lclanguage => lc($language) });
	}
	# Prepare the list of server-supported languages
	my %supportedLanguages = ();
	my %secondaryLanguages = ();
	foreach my $language (@$supportedLanguages) {
		warn "SUP: ".$language->{language_code};
		$supportedLanguages{lc($language->{language_code})} = $language->{language_code};
		if ($language->{language_code} =~ /^([^-]+)-?/) {
			$secondaryLanguages{lc($1)} = $language->{language_code};
		}
	}

	# Reverse sort the list, making best quality at the front of the array
	@languages = sort { $b->{quality} <=> $a->{quality} } @languages;
	my $secondaryMatch = '';
	foreach my $tag (@languages) {
		if (exists($supportedLanguages{$tag->{lclanguage}})) {
			# Client en-us eq server en-us
			return $supportedLanguages{$tag->{language}} if exists($supportedLanguages{$tag->{language}});
			return $supportedLanguages{$tag->{lclanguage}};
		} elsif (exists($secondaryLanguages{$tag->{lclanguage}})) {
			# Client en eq server en-us
			return $secondaryLanguages{$tag->{language}} if exists($secondaryLanguages{$tag->{language}});
			return $supportedLanguages{$tag->{lclanguage}};
		} elsif ($tag->{lclanguage} =~ /^([^-]+)-/ && exists($secondaryLanguages{$1}) && $secondaryMatch eq '') {
			# Client en-gb eq server en-us
			$secondaryMatch = $secondaryLanguages{$1};
		} elsif ($tag->{lclanguage} =~ /^([^-]+)-/ && exists($secondaryLanguages{$1}) && $secondaryMatch eq '') {
			# Client en-us eq server en
			$secondaryMatch = $supportedLanguages{$1};
		} elsif ($tag->{lclanguage} eq '*') {
		# * matches every language not already specified.
		# It doesn't care which we pick, so let's pick the default,
		# if available, then the first in the array.
		#return $acceptor->defaultLanguage() if $acceptor->defaultLanguage();
		return $supportedLanguages->[0];
		}
	}
	# No primary matches. Secondary? (ie, en-us requested and en supported)
	return $secondaryMatch if $secondaryMatch;
}
1;

__END__

=head1 AUTHOR

Joshua Ferraro

=cut
