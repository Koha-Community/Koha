package LangInstaller;

# Copyright (C) 2010 Tamil s.a.r.l.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
# WARNING: Any other tested YAML library fails to work properly in this
# script content
# FIXME Really?
use YAML::XS;
use Locale::PO;
use FindBin qw( $Bin );
use File::Path qw( make_path );
use File::Copy;

sub set_lang {
    my ($self, $lang) = @_;

    $self->{lang} = $lang;
    $self->{po_path_lang} = C4::Context->config('intrahtdocs') .
                            "/prog/$lang/modules/admin/preferences";
}

sub new {
    my ($class, $lang, $pref_only, $verbose) = @_;

    my $self                 = { };

    $self->{path_pref_en}    = C4::Context->config('intrahtdocs') .
                               '/prog/en/modules/admin/preferences';
    set_lang( $self, $lang ) if $lang;
    $self->{pref_only}       = $pref_only;
    $self->{verbose}         = $verbose;
    $self->{process}         = "$Bin/tmpl_process3.pl " . ($verbose ? '' : '-q');
    $self->{path_po}         = "$Bin/po";
    $self->{po}              = {};
    $self->{domain}          = 'Koha';
    $self->{msgfmt}          = `which msgfmt`;
    $self->{po2json}         = "$Bin/po2json";
    $self->{gzip}            = `which gzip`;
    $self->{gunzip}          = `which gunzip`;
    chomp $self->{msgfmt};
    chomp $self->{gzip};
    chomp $self->{gunzip};

    # Get all .pref file names
    opendir my $fh, $self->{path_pref_en};
    my @pref_files = grep { /\.pref$/ } readdir($fh);
    close $fh;
    $self->{pref_files} = \@pref_files;

    # Get all available language codes
    opendir $fh, $self->{path_po};
    my @langs =  map { ($_) =~ /(.*)-pref/ }
        grep { $_ =~ /.*-pref/ } readdir($fh);
    closedir $fh;
    $self->{langs} = \@langs;

    # Map for both interfaces opac/intranet
    my $opachtdocs = C4::Context->config('opachtdocs');
    $self->{interface} = [
        {
            name   => 'Intranet prog UI',
            dir    => C4::Context->config('intrahtdocs') . '/prog',
            suffix => '-staff-prog.po',
        },
    ];

    # OPAC themes
    opendir my $dh, C4::Context->config('opachtdocs');
    for my $theme ( grep { not /^\.|lib|xslt/ } readdir($dh) ) {
        push @{$self->{interface}}, {
            name   => "OPAC $theme",
            dir    => "$opachtdocs/$theme",
            suffix => "-opac-$theme.po",
        };
    }

    # MARC flavours (hardcoded list)
    for ( "MARC21", "UNIMARC" ) {
        # search for strings on staff & opac marc files
        my $dirs = C4::Context->config('intrahtdocs') . '/prog';
        opendir $fh, C4::Context->config('opachtdocs');
        for ( grep { not /^\.|\.\.|lib$|xslt/ } readdir($fh) ) {
            $dirs .= ' ' . "$opachtdocs/$_";
        }
        push @{$self->{interface}}, {
            name   => "$_",
            dir    => $dirs,
            suffix => "-marc-$_.po",
        };
    }

    # EN YAML installer files
    push @{$self->{installer}}, {
        name   => "YAML installer files",
        dirs   => [ 'installer/data/mysql/en/mandatory',
                    'installer/data/mysql/en/optional'],
        suffix => "-installer.po",
    };

    # EN MARC21 YAML installer files
    push @{$self->{installer}}, {
        name   => "MARC21 YAML installer files",
        dirs   => [ 'installer/data/mysql/en/marcflavour/marc21/mandatory',
                    'installer/data/mysql/en/marcflavour/marc21/optional'],
        suffix => "-installer-MARC21.po",
    };

    # EN UNIMARC YAML installer files
    push @{$self->{installer}}, {
        name   => "UNIMARC YAML installer files",
        dirs   => [ 'installer/data/mysql/en/marcflavour/unimarc/mandatory',
                    'installer/data/mysql/en/marcflavour/unimarc/optional'],
        suffix => "-installer-UNIMARC.po",
    };

    bless $self, $class;
}

sub po_filename {
    my $self   = shift;
    my $suffix = shift;

    my $trans_path = $Bin . '/po';
    my $trans_file = "$trans_path/" . $self->{lang} . $suffix;
    return $trans_file;
}

sub get_trans_text {
    my ($self, $msgid, $default) = @_;

    my $po = $self->{po}->{Locale::PO->quote($msgid)};
    if ( $po and not defined( $po->fuzzy() ) ) {
        my $msgstr = Locale::PO->dequote($po->msgstr);
        if ($msgstr and length($msgstr) > 0) {
            return $msgstr;
        }
    }

    return $default;
}

sub get_translated_tab_content {
    my ($self, $file, $tab_content) = @_;

    if ( ref($tab_content) eq 'ARRAY' ) {
        return $self->get_translated_prefs($file, $tab_content);
    }

    my $translated_tab_content = {
        map {
            my $section = $_;
            my $sysprefs = $tab_content->{$section};
            my $msgid = sprintf('%s %s', $file, $section);

            $self->get_trans_text($msgid, $section) => $self->get_translated_prefs($file, $sysprefs);
        } keys %$tab_content
    };

    if ( keys %$translated_tab_content != keys %$tab_content ) {
        my %duplicates;
        for my $section (keys %$tab_content) {
            push @{$duplicates{$self->get_trans_text("$file $section", $section)}}, $section;
        }
        for my $translation (keys %duplicates) {
            if (@{$duplicates{$translation}} > 1) {
                warn qq(In file "$file", "$translation" is a translation for sections ") . join('", "', @{$duplicates{$translation}}) . '"';
            }
        }
    }

    return $translated_tab_content;
}

sub get_translated_prefs {
    my ($self, $file, $sysprefs) = @_;

    my $translated_prefs = [
        map {
            my ($pref_elt) = grep { ref($_) eq 'HASH' && exists $_->{pref} } @$_;
            my $pref_name = $pref_elt ? $pref_elt->{pref} : '';

            my $translated_syspref = [
                map {
                    $self->get_translated_pref($file, $pref_name, $_);
                } @$_
            ];

            $translated_syspref;
        } @$sysprefs
    ];

    return $translated_prefs;
}

sub get_translated_pref {
    my ($self, $file, $pref_name, $syspref) = @_;

    unless (ref($syspref)) {
        $syspref //= '';
        my $msgid = sprintf('%s#%s# %s', $file, $pref_name, $syspref);
        return $self->get_trans_text($msgid, $syspref);
    }

    my $translated_pref = {
        map {
            my $key = $_;
            my $value = $syspref->{$key};

            my $translated_value = $value;
            if (($key eq 'choices' || $key eq 'multiple') && ref($value) eq 'HASH') {
                $translated_value = {
                    map {
                        my $msgid = sprintf('%s#%s# %s', $file, $pref_name, $value->{$_});
                        $_ => $self->get_trans_text($msgid, $value->{$_})
                    } keys %$value
                }
            }

            $key => $translated_value
        } keys %$syspref
    };

    return $translated_pref;
}

sub install_prefs {
    my $self = shift;

    unless ( -r $self->{po_path_lang} ) {
        print "Koha directories hierarchy for ", $self->{lang}, " must be created first\n";
        exit;
    }

    $self->{po} = Locale::PO->load_file_ashash($self->po_filename("-pref.po"), 'utf8');

    for my $file ( @{$self->{pref_files}} ) {
        my $pref = YAML::XS::LoadFile( $self->{path_pref_en} . "/$file" );

        my $translated_pref = {
            map {
                my $tab = $_;
                my $tab_content = $pref->{$tab};

                $self->get_trans_text($file, $tab) => $self->get_translated_tab_content($file, $tab_content);
            } keys %$pref
        };

        if ( keys %$translated_pref != keys %$pref ) {
            my %duplicates;
            for my $tab (keys %$pref) {
                push @{$duplicates{$self->get_trans_text($file, $tab)}}, $tab;
            }
            for my $translation (keys %duplicates) {
                if (@{$duplicates{$translation}} > 1) {
                    warn qq(In file "$file", "$translation" is a translation for tabs ") . join('", "', @{$duplicates{$translation}}) . '"';
                }
            }
        }

        my $file_trans = $self->{po_path_lang} . "/$file";
        print "Write $file\n" if $self->{verbose};
        YAML::XS::DumpFile($file_trans, $translated_pref);
    }
}


sub install_tmpl {
    my ($self, $files) = @_;
    say "Install templates" if $self->{verbose};
    for my $trans ( @{$self->{interface}} ) {
        my @t_dirs = split(" ", $trans->{dir});
        for my $t_dir ( @t_dirs ) {
            my @files   = @$files;
            my @nomarc = ();
            print
                "  Install templates '$trans->{name}'\n",
                "    From: $t_dir/en/\n",
                "    To  : $t_dir/$self->{lang}\n",
                "    With: $self->{path_po}/$self->{lang}$trans->{suffix}\n"
                if $self->{verbose};

            my $trans_dir = "$t_dir/en/";
            my $lang_dir  = "$t_dir/$self->{lang}";
            $lang_dir =~ s|/en/|/$self->{lang}/|;
            mkdir $lang_dir unless -d $lang_dir;
            # if installing MARC po file, only touch corresponding files
            my $marc     = ( $trans->{name} =~ /MARC/ )?"-m \"$trans->{name}\"":"";            # for MARC translations
            # if not installing MARC po file, ignore all MARC files
            @nomarc      = ( 'marc21', 'unimarc' ) if ( $trans->{name} !~ /MARC/ ); # hardcoded MARC variants

            system
                "$self->{process} install " .
                "-i $trans_dir " .
                "-o $lang_dir  ".
                "-s $self->{path_po}/$self->{lang}$trans->{suffix} -r " .
                "$marc " .
                ( @files   ? ' -f ' . join ' -f ', @files : '') .
                ( @nomarc  ? ' -n ' . join ' -n ', @nomarc : '');
        }
    }
}

sub translate_yaml {
    my $self   = shift;
    my $target = shift;
    my $srcyml = shift;

    my $po_file = $self->po_filename( $target->{suffix} );
    return $srcyml unless ( -e $po_file );

    my $po_ref  = Locale::PO->load_file_ashash( $po_file, 'utf8' );

    my $dstyml   = YAML::XS::LoadFile( $srcyml );

    # translate fields in table rows
    my @tables = @{ $dstyml->{'tables'} };
    for my $table ( @tables ) {                                                         # each table
        my $table_name = ( keys %$table )[0];
        my @translatable = @{ $table->{$table_name}->{translatable} };
        my @rows = @{ $table->{$table_name}->{rows} };
        my @multiline = @{ $table->{$table_name}->{'multiline'} };                      # to check multiline values
        for my $row ( @rows ) {                                                         # each row
            for my $field ( @translatable ) {                                           # each translatable field
                if ( @multiline and grep { $_ eq $field } @multiline ) {                # multiline fields, only notices ATM
                    foreach my $line ( @{$row->{$field}} ) {
                        my @ttvar;
                        while ( $line =~ s/(<<.*?>>|\[\%.*?\%\]|<.*?>)/\%s/ ) {         # put placeholders, save matches
                            my $var = $1;
                            push @ttvar, $var;
                        }

                        if ( $line =~ /^(\s|%s|-|[[:punct:]]|\(|\))*$/ ) {              # ignore non strings
                            while ( @ttvar ) {                                          # restore placeholders
                                my $var = shift @ttvar;
                                $line =~ s/\%s/$var/;
                            }
                            next;
                        } else {
                            my $po = $po_ref->{"\"$line\""};                            # quoted key
                            if ( $po  and not defined( $po->fuzzy() )                   # not fuzzy
                                      and length( $po->msgid() ) > 2                    # not empty msgid
                                      and length( $po->msgstr() ) > 2 ) {               # not empty msgstr
                                $line = $po->dequote( $po->msgstr() );
                            }
                            while ( @ttvar ) {                                          # restore placeholders
                                my $var = shift @ttvar;
                                $line =~ s/\%s/$var/;
                            }
                        }
                    }
                } else {
                    next unless defined $row->{$field};                                 # next if null value
                    my $po = $po_ref->{"\"$row->{$field}\""};                           # quoted key
                    if ( $po  and not defined( $po->fuzzy() )                           # not fuzzy
                              and length( $po->msgid() ) > 2                            # not empty msgid
                              and length( $po->msgstr() ) > 2 ) {                       # not empty msgstr
                        $row->{$field} = $po->dequote( $po->msgstr() );
                    }
                }
            }
        }
    }

    # translate descriptions
    for my $description ( @{ $dstyml->{'description'} } ) {
        my $po = $po_ref->{"\"$description\""};
        if ( $po  and not defined( $po->fuzzy() )
                  and length( $po->msgid() ) > 2
                  and length( $po->msgstr() ) > 2 ) {
            $description = $po->dequote( $po->msgstr() );
        }
    }

    return $dstyml;
}

sub install_installer {
    my $self = shift;
    return unless ( $self->{installer} );

    my $intradir  = C4::Context->config('intranetdir');
    my $db_scheme = C4::Context->config('db_scheme');
    my $langdir  = "$intradir/installer/data/$db_scheme/$self->{lang}";

    say "Install installer files\n" if $self->{verbose};

    for my $target ( @{ $self->{installer} } ) {
        return unless ( -e $self->po_filename( $target->{suffix} ) );
        for my $dir ( @{ $target->{dirs} } ) {
            ( my $tdir = "$dir" ) =~ s|/en/|/$self->{lang}/|;
            make_path("$intradir/$tdir");

            opendir( my $dh, "$intradir/$dir" ) or die ("Can't open $intradir/$dir");
            my @files = grep { ! /^\.+$/ } readdir($dh);
            close($dh);

            for my $file ( @files ) {
                if ( $file =~ /yml$/ ) {
                    my $translated_yaml = translate_yaml( $self, $target, "$intradir/$dir/$file" );
                    YAML::XS::DumpFile( "$intradir/$tdir/$file", $translated_yaml );
                } else {
                    File::Copy::copy( "$intradir/$dir/$file", "$intradir/$tdir/$file" );
                }
            }
        }
    }
}

sub locale_name {
    my $self = shift;

    my ($language, $region, $country) = split /-/, $self->{lang};
    $country //= $region;
    my $locale = $language;
    if ($country && length($country) == 2) {
        $locale .= '_' . $country;
    }

    return $locale;
}

sub install_messages {
    my ($self) = @_;

    my $locale = $self->locale_name();
    my $modir = "$self->{path_po}/$locale/LC_MESSAGES";
    my $pofile = "$self->{path_po}/$self->{lang}-messages.po";
    my $mofile = "$modir/$self->{domain}.mo";
    my $js_pofile = "$self->{path_po}/$self->{lang}-messages-js.po";

    unless ( -f $pofile && -f $js_pofile ) {
        die "PO files for language '$self->{lang}' do not exist";
    }

    say "Install messages ($locale)" if $self->{verbose};
    make_path($modir);
    system "$self->{msgfmt} -o $mofile $pofile";

    my $js_locale_data = 'var json_locale_data = {"Koha":' . `$self->{po2json} $js_pofile` . '};';
    my $progdir = C4::Context->config('intrahtdocs') . '/prog';
    mkdir "$progdir/$self->{lang}/js";
    open my $fh, '>', "$progdir/$self->{lang}/js/locale_data.js";
    print $fh $js_locale_data;
    close $fh;

    my $opachtdocs = C4::Context->config('opachtdocs');
    opendir(my $dh, $opachtdocs);
    for my $theme ( grep { not /^\.|lib|xslt/ } readdir($dh) ) {
        mkdir "$opachtdocs/$theme/$self->{lang}/js";
        open my $fh, '>', "$opachtdocs/$theme/$self->{lang}/js/locale_data.js";
        print $fh $js_locale_data;
        close $fh;
    }
}

sub compress {
    my ($self, $files) = @_;
    my @langs = $self->{lang} ? ($self->{lang}) : $self->get_all_langs();
    for my $lang ( @langs ) {
        $self->set_lang( $lang );
        opendir( my $dh, $self->{path_po} );
        my @files = grep { $_ =~ /^$self->{lang}.*po$/ } readdir $dh;
        foreach my $file ( @files ) {
            say "Compress file $file" if $self->{verbose};
            system "$self->{gzip} -9 $self->{path_po}/$file";
        }
    }
}

sub uncompress {
    my ($self, $files) = @_;
    my @langs = $self->{lang} ? ($self->{lang}) : $self->get_all_langs();
    for my $lang ( @langs ) {
        opendir( my $dh, $self->{path_po} );
        $self->set_lang( $lang );
        my @files = grep { $_ =~ /^$self->{lang}.*po.gz$/ } readdir $dh;
        foreach my $file ( @files ) {
            say "Uncompress file $file" if $self->{verbose};
            system "$self->{gunzip} $self->{path_po}/$file";
        }
    }
}

sub install {
    my ($self, $files) = @_;
    return unless $self->{lang};
    $self->uncompress();

    if ($self->{pref_only}) {
        $self->install_prefs();
    } else {
        $self->install_tmpl($files);
        $self->install_prefs();
        $self->install_messages();
        $self->install_installer();
    }
}


sub get_all_langs {
    my $self = shift;
    opendir( my $dh, $self->{path_po} );
    my @files = grep { $_ =~ /-pref.(po|po.gz)$/ }
        readdir $dh;
    @files = map { $_ =~ s/-pref.(po|po.gz)$//r } @files;
}

1;


=head1 NAME

LangInstaller.pm - Handle templates and preferences translation

=head1 SYNOPSYS

  my $installer = LangInstaller->new( 'fr-FR' );
  $installer->create();
  $installer->update();
  $installer->install();
  for my $lang ( @{$installer->{langs} ) {
    $installer->set_lang( $lan );
    $installer->install();
  }

=head1 METHODS

=head2 new

Create a new instance of the installer object. 

=head2 create

For the current language, create .po files for templates and preferences based
of the english ('en') version.

=head2 update

For the current language, update .po files.

=head2 install

For the current langage C<$self->{lang}, use .po files to translate the english
version of templates and preferences files and copy those files in the
appropriate directory.

=over

=item translate create F<lang>

Create 4 kinds of .po files in F<po> subdirectory:
(1) one from each theme on opac pages templates,
(2) intranet templates,
(3) preferences, and
(4) one for each MARC dialect.


=over

=item F<lang>-opac-{theme}.po

Contains extracted text from english (en) OPAC templates found in
<KOHA_ROOT>/koha-tmpl/opac-tmpl/{theme}/en/ directory.

=item F<lang>-staff-prog.po

Contains extracted text from english (en) intranet templates found in
<KOHA_ROOT>/koha-tmpl/intranet-tmpl/prog/en/ directory.

=item F<lang>-pref.po

Contains extracted text from english (en) preferences. They are found in files
located in <KOHA_ROOT>/koha-tmpl/intranet-tmpl/prog/en/admin/preferences
directory.

=item F<lang>-marc-{MARC}.po

Contains extracted text from english (en) files from opac and intranet,
related with MARC dialects.

=back

=item pref-trans update F<lang>

Update .po files in F<po> directory, named F<lang>-*.po.

=item pref-trans install F<lang>

=back

=cut

