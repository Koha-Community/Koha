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


use strict; use warnings; #FIXME: turn off warnings before release
require Exporter;
use C4::Context;
use vars qw($VERSION @ISA @EXPORT);

=head1 NAME

C4::Languages - Perl Module containing language list functions for Koha 

=head1 SYNOPSIS

use C4::Languages;

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(
  &getFrameworkLanguages
  &getTranslatedLanguages
  &getAllLanguages
  );

my $DEBUG = 0;

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
            my $language_name = $language_set->{language_name};
            my $language_locale_name = $language_set->{language_locale_name};

            if ($dirname eq $language_set->{language_code}) {
                push @languages, {'language_code'=>$dirname, 'language_name'=>$language_name, 'language_locale_name'=>$language_locale_name}
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
            return _get_final_languages($all_languages,@languages);
        }
        else {
            for my $theme ( _get_themes('opac') ) {
                push @languages, _get_language_dirs($htdocs,$theme);
            }
            return _get_final_languages($all_languages,@languages);
        }
    }
    elsif ($interface && $interface eq 'intranet' ) {
        $htdocs = C4::Context->config('intrahtdocs');
        if ( $theme and -d "$htdocs/$theme" ) {
            @languages = _get_language_dirs($htdocs,$theme);
            return _get_final_languages($all_languages,@languages);
        }
        else {
            foreach my $theme ( _get_themes('opac') ) {
                push @languages, _get_language_dirs($htdocs,$theme);
            }
            return _get_final_languages($all_languages,@languages);
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
        return _get_final_languages($all_languages,@languages);
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
    my $languages_loop = [
        {
            language_code          => "",
            language_name => "No Limit",
            language_locale_name   => "",
            selected       => "selected",
        },
        {
            language_code          => "ara",
            language_name =>
              "&#1575;&#1604;&#1593;&#1585;&#1576;&#1610;&#1577;",
            language_locale_name => "Arabic",
            ,
        },
        {
            language_code          => "bul",
            language_name =>
              "&#1041;&#1098;&#1083;&#1075;&#1072;&#1088;&#1089;&#1082;&#1080;",
            language_locale_name => "Bulgarian",
            ,
        },
        {
            language_code          => "chi",
            language_name => "&#20013;&#25991;",
            language_locale_name   => "Chinese",
            ,
        },
        {
            language_code          => "scr",
            language_name => "Hrvatski",
            language_locale_name   => "Croatian",
            ,
        },
        {
            language_code          => "cze",
            language_name => "&#x010D;e&#353;tina",
            language_locale_name   => "Czech",
            ,
        },
        {
            language_code          => "dan",
            language_name => "D&aelig;nsk",
            language_locale_name   => "Danish",
            ,
        },
        {
            language_code          => "dut",
            language_name => "ned&#601;rl&#593;ns",
            language_locale_name   => "Dutch",
            ,
        },
        {
            language_code          => "en",
            language_name => "English",
            language_locale_name   => "English",
            ,
        },
        {
            language_code          => "fr",
            language_name => "Fran&ccedil;ais",
            language_locale_name   => "French",
            ,
        },
        {
            language_code          => "ger",
            language_name => "Deutsch",
            language_locale_name   => "German",
            ,
        },
        {
            language_code          => "gre",
            language_name =>
              "&#949;&#955;&#955;&#951;&#957;&#953;&#954;&#940;",
            language_locale_name => "Greek, Modern [1453- ]",
            ,
        },
        {
            language_code          => "heb",
            language_name => "&#1506;&#1489;&#1512;&#1497;&#1514;",
            language_locale_name   => "Hebrew",
            ,
        },
        {
            language_code          => "hin",
            language_name => "&#2361;&#2367;&#2344;&#2381;&#2342;&#2368;",
            language_locale_name   => "Hindi",
            ,
        },
        {
            language_code          => "hun",
            language_name => "Magyar",
            language_locale_name   => "Hungarian",
            ,
        },
        {
            language_code          => "ind",
            language_name => "",
            language_locale_name   => "Indonesian",
            ,
        },
        {
            language_code          => "ita",
            language_name => "Italiano",
            language_locale_name   => "Italian",
            ,
        },
        {
            language_code          => "jpn",
            language_name => "&#26085;&#26412;&#35486;",
            language_locale_name   => "Japanese",
            ,
        },
        {
            language_code          => "kor",
            language_name => "&#54620;&#44397;&#50612;",
            language_locale_name   => "Korean",
            ,
        },
        {
            language_code          => "lat",
            language_name => "Latina",
            language_locale_name   => "Latin",
            ,
        },
        {
            language_code          => "nor",
            language_name => "Norsk",
            language_locale_name   => "Norwegian",
            ,
        },
        {
            language_code          => "per",
            language_name => "&#1601;&#1575;&#1585;&#1587;&#1609;",
            language_locale_name   => "Persian",
            ,
        },
        {
            language_code          => "pol",
            language_name => "Polski",
            language_locale_name   => "Polish",
            ,
        },
        {
            language_code          => "por",
            language_name => "Portugu&ecirc;s",
            language_locale_name   => "Portuguese",
            ,
        },
        {
            language_code          => "rum",
            language_name => "Rom&acirc;n&#259;",
            language_locale_name   => "Romanian",
            ,
        },
        {
            language_code          => "rus",
            language_name =>
              "&#1056;&#1091;&#1089;&#1089;&#1082;&#1080;&#1081;",
            language_locale_name => "Russian",
            ,
        },
        {
            language_code          => "spa",
            language_name => "Espa&ntilde;ol",
            language_locale_name   => "Spanish",
            ,
        },
        {
            language_code          => "swe",
            language_name => "Svenska",
            language_locale_name   => "Swedish",
            ,
        },
        {
            language_code          => "tha",
            language_name =>
              "&#3616;&#3634;&#3625;&#3634;&#3652;&#3607;&#3618;",
            language_locale_name => "Thai",
            ,
        },
        {
            language_code          => "tur",
            language_name => "T&uuml;rk&ccedil;e",
            language_locale_name   => "Turkish",
            ,
        },
        {
            language_code          => "ukr",
            language_name =>
"&#1059;&#1082;&#1088;&#1072;&#1111;&#1085;&#1089;&#1100;&#1082;&#1072;",
            language_locale_name => "Ukrainian",
            ,
        },

    ];
    return $languages_loop;
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
        next if $language =~/itemtypeimg$/;
        next if $language =~/\.txt$/i;     #Don't read the readme.txt !
        next if $language eq 'images';
        push @languages, $language;
    }
        return (@languages);
}

=head2 _get_final_languages 

Internal function for building the ref to array of hashes

FIXME: this could be rewritten and simplified using map

=cut

sub _get_final_languages {
        my ($all_languages,@languages) = @_;
        my @final_languages;
        my %seen_languages;
        for my $language (@languages) {
            unless ($seen_languages{$language}) {
                for my $language_code (@$all_languages) {
                    if ($language eq $language_code->{'language_code'}) {
                        push @final_languages, $language_code;
                    }
                }
                $seen_languages{$language}++;
            }
        }
        return \@final_languages;
}

1;

__END__

=head1 AUTHOR

Joshua Ferraro

=cut
