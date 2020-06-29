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
use YAML::Syck qw( Dump LoadFile DumpFile );
use Locale::PO;
use FindBin qw( $Bin );
use File::Basename;
use File::Find;
use File::Path qw( make_path );
use File::Copy;
use File::Slurp;
use File::Spec;
use File::Temp qw( tempdir tempfile );
use Template::Parser;
use PPI;


$YAML::Syck::ImplicitTyping = 1;


# Default file header for .po syspref files
my $default_pref_po_header = Locale::PO->new(-msgid => '', -msgstr =>
    "Project-Id-Version: PACKAGE VERSION\\n" .
    "PO-Revision-Date: YEAR-MO-DA HO:MI +ZONE\\n" .
    "Last-Translator: FULL NAME <EMAIL\@ADDRESS>\\n" .
    "Language-Team: Koha Translate List <koha-translate\@lists.koha-community.org>\\n" .
    "MIME-Version: 1.0\\n" .
    "Content-Type: text/plain; charset=UTF-8\\n" .
    "Content-Transfer-Encoding: 8bit\\n" .
    "Plural-Forms: nplurals=2; plural=(n > 1);\\n"
);


sub set_lang {
    my ($self, $lang) = @_;

    $self->{lang} = $lang;
    $self->{po_path_lang} = $self->{context}->config('intrahtdocs') .
                            "/prog/$lang/modules/admin/preferences";
}


sub new {
    my ($class, $lang, $pref_only, $verbose) = @_;

    my $self                 = { };

    my $context              = C4::Context->new();
    $self->{context}         = $context;
    $self->{path_pref_en}    = $context->config('intrahtdocs') .
                               '/prog/en/modules/admin/preferences';
    set_lang( $self, $lang ) if $lang;
    $self->{pref_only}       = $pref_only;
    $self->{verbose}         = $verbose;
    $self->{process}         = "$Bin/tmpl_process3.pl " . ($verbose ? '' : '-q');
    $self->{path_po}         = "$Bin/po";
    $self->{po}              = { '' => $default_pref_po_header };
    $self->{domain}          = 'Koha';
    $self->{cp}              = `which cp`;
    $self->{msgmerge}        = `which msgmerge`;
    $self->{msgfmt}          = `which msgfmt`;
    $self->{msginit}         = `which msginit`;
    $self->{msgattrib}       = `which msgattrib`;
    $self->{xgettext}        = `which xgettext`;
    $self->{sed}             = `which sed`;
    $self->{po2json}         = "$Bin/po2json";
    $self->{gzip}            = `which gzip`;
    $self->{gunzip}          = `which gunzip`;
    chomp $self->{cp};
    chomp $self->{msgmerge};
    chomp $self->{msgfmt};
    chomp $self->{msginit};
    chomp $self->{msgattrib};
    chomp $self->{xgettext};
    chomp $self->{sed};
    chomp $self->{gzip};
    chomp $self->{gunzip};

    unless ($self->{xgettext}) {
        die "Missing 'xgettext' executable. Have you installed the gettext package?\n";
    }

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
    my $opachtdocs = $context->config('opachtdocs');
    $self->{interface} = [
        {
            name   => 'Intranet prog UI',
            dir    => $context->config('intrahtdocs') . '/prog',
            suffix => '-staff-prog.po',
        },
    ];

    # OPAC themes
    opendir my $dh, $context->config('opachtdocs');
    for my $theme ( grep { not /^\.|lib|xslt/ } readdir($dh) ) {
        push @{$self->{interface}}, {
            name   => "OPAC $theme",
            dir    => "$opachtdocs/$theme",
            suffix => "-opac-$theme.po",
        };
    }

    # MARC flavours (hardcoded list)
    for ( "MARC21", "UNIMARC", "NORMARC" ) {
        # search for strings on staff & opac marc files
        my $dirs = $context->config('intrahtdocs') . '/prog';
        opendir $fh, $context->config('opachtdocs');
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
        dirs   => [ 'installer/data/mysql/en/marcflavour/unimarc/mandatory', ],
        suffix => "-installer-UNIMARC.po",
    };

    bless $self, $class;
}


sub po_filename {
    my $self   = shift;
    my $suffix = shift;

    my $context    = C4::Context->new;
    my $trans_path = $Bin . '/po';
    my $trans_file = "$trans_path/" . $self->{lang} . $suffix;
    return $trans_file;
}


sub po_append {
    my ($self, $id, $comment) = @_;
    my $po = $self->{po};
    my $p = $po->{$id};
    if ( $p ) {
        $p->comment( $p->comment . "\n" . $comment );
    }
    else {
        $po->{$id} = Locale::PO->new(
            -comment => $comment,
            -msgid   => $id,
            -msgstr  => ''
        );
    }
}


sub add_prefs {
    my ($self, $comment, $prefs) = @_;

    for my $pref ( @$prefs ) {
        my $pref_name = '';
        for my $element ( @$pref ) {
            if ( ref( $element) eq 'HASH' ) {
                $pref_name = $element->{pref};
                last;
            }
        }
        for my $element ( @$pref ) {
            if ( ref( $element) eq 'HASH' ) {
                while ( my ($key, $value) = each(%$element) ) {
                    next unless $key eq 'choices' or $key eq 'multiple';
                    next unless ref($value) eq 'HASH';
                    for my $ckey ( keys %$value ) {
                        my $id = $self->{file} . "#$pref_name# " . $value->{$ckey};
                        $self->po_append( $id, $comment );
                    }
                }
            }
            elsif ( $element ) {
                $self->po_append( $self->{file} . "#$pref_name# $element", $comment );
            }
        }
    }
}


sub get_trans_text {
    my ($self, $id) = @_;

    my $po = $self->{po}->{$id};
    return unless $po;
    return Locale::PO->dequote($po->msgstr);
}


sub update_tab_prefs {
    my ($self, $pref, $prefs) = @_;

    for my $p ( @$prefs ) {
        my $pref_name = '';
        next unless $p;
        for my $element ( @$p ) {
            if ( ref( $element) eq 'HASH' ) {
                $pref_name = $element->{pref};
                last;
            }
        }
        for my $i ( 0..@$p-1 ) {
            my $element = $p->[$i];
            if ( ref( $element) eq 'HASH' ) {
                while ( my ($key, $value) = each(%$element) ) {
                    next unless $key eq 'choices' or $key eq 'multiple';
                    next unless ref($value) eq 'HASH';
                    for my $ckey ( keys %$value ) {
                        my $id = $self->{file} . "#$pref_name# " . $value->{$ckey};
                        my $text = $self->get_trans_text( $id );
                        $value->{$ckey} = $text if $text;
                    }
                }
            }
            elsif ( $element ) {
                my $id = $self->{file} . "#$pref_name# $element";
                my $text = $self->get_trans_text( $id );
                $p->[$i] = $text if $text;
            }
        }
    }
}


sub get_po_from_prefs {
    my $self = shift;

    for my $file ( @{$self->{pref_files}} ) {
        my $pref = LoadFile( $self->{path_pref_en} . "/$file" );
        $self->{file} = $file;
        # Entries for tab titles
        $self->po_append( $self->{file}, $_ ) for keys %$pref;
        while ( my ($tab, $tab_content) = each %$pref ) {
            if ( ref($tab_content) eq 'ARRAY' ) {
                $self->add_prefs( $tab, $tab_content );
                next;
            }
            while ( my ($section, $sysprefs) = each %$tab_content ) {
                my $comment = "$tab > $section";
                $self->po_append( $self->{file} . " " . $section, $comment );
                $self->add_prefs( $comment, $sysprefs );
            }
        }
    }
}


sub save_po {
    my $self = shift;

    # Create file header if it doesn't already exist
    my $po = $self->{po};
    $po->{''} ||= $default_pref_po_header;

    # Write .po entries into a file put in Koha standard po directory
    Locale::PO->save_file_fromhash( $self->po_filename("-pref.po"), $po );
    say "Saved in file: ", $self->po_filename("-pref.po") if $self->{verbose};
}


sub get_po_merged_with_en {
    my $self = shift;

    # Get po from current 'en' .pref files
    $self->get_po_from_prefs();
    my $po_current = $self->{po};

    # Get po from previous generation
    my $po_previous = Locale::PO->load_file_ashash( $self->po_filename("-pref.po") );

    for my $id ( keys %$po_current ) {
        my $po =  $po_previous->{Locale::PO->quote($id)};
        next unless $po;
        my $text = Locale::PO->dequote( $po->msgstr );
        $po_current->{$id}->msgstr( $text );
    }
}


sub update_prefs {
    my $self = shift;
    print "Update '", $self->{lang},
          "' preferences .po file from 'en' .pref files\n" if $self->{verbose};
    $self->get_po_merged_with_en();
    $self->save_po();
}


sub install_prefs {
    my $self = shift;

    unless ( -r $self->{po_path_lang} ) {
        print "Koha directories hierarchy for ", $self->{lang}, " must be created first\n";
        exit;
    }

    # Get the language .po file merged with last modified 'en' preferences
    $self->get_po_merged_with_en();

    for my $file ( @{$self->{pref_files}} ) {
        my $pref = LoadFile( $self->{path_pref_en} . "/$file" );
        $self->{file} = $file;
        # First, keys are replaced (tab titles)
        $pref = do {
            my %pref = map { 
                $self->get_trans_text( $self->{file} ) || $_ => $pref->{$_}
            } keys %$pref;
            \%pref;
        };
        while ( my ($tab, $tab_content) = each %$pref ) {
            if ( ref($tab_content) eq 'ARRAY' ) {
                $self->update_tab_prefs( $pref, $tab_content );
                next;
            }
            while ( my ($section, $sysprefs) = each %$tab_content ) {
                $self->update_tab_prefs( $pref, $sysprefs );
            }
            my $ntab = {};
            for my $section ( keys %$tab_content ) {
                my $id = $self->{file} . " $section";
                my $text = $self->get_trans_text($id);
                my $nsection = $text ? $text : $section;
                if( exists $ntab->{$nsection} ) {
                    # When translations collide (see BZ 18634)
                    push @{$ntab->{$nsection}}, @{$tab_content->{$section}};
                } else {
                    $ntab->{$nsection} = $tab_content->{$section};
                }
            }
            $pref->{$tab} = $ntab;
        }
        my $file_trans = $self->{po_path_lang} . "/$file";
        print "Write $file\n" if $self->{verbose};
        open my $fh, ">", $file_trans;
        print $fh Dump($pref);
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
            @nomarc      = ( 'marc21', 'unimarc', 'normarc' ) if ( $trans->{name} !~ /MARC/ ); # hardcoded MARC variants

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


sub update_tmpl {
    my ($self, $files) = @_;

    say "Update templates" if $self->{verbose};
    for my $trans ( @{$self->{interface}} ) {
        my @files   = @$files;
        my @nomarc = ();
        print
            "  Update templates '$trans->{name}'\n",
            "    From: $trans->{dir}/en/\n",
            "    To  : $self->{path_po}/$self->{lang}$trans->{suffix}\n"
                if $self->{verbose};

        my $trans_dir = join("/en/ -i ",split(" ",$trans->{dir}))."/en/"; # multiple source dirs
        # if processing MARC po file, only use corresponding files
        my $marc      = ( $trans->{name} =~ /MARC/ )?"-m \"$trans->{name}\"":"";            # for MARC translations
        # if not processing MARC po file, ignore all MARC files
        @nomarc       = ( 'marc21', 'unimarc', 'normarc' ) if ( $trans->{name} !~ /MARC/ );      # hardcoded MARC variants

        system
            "$self->{process} update " .
            "-i $trans_dir " .
            "-s $self->{path_po}/$self->{lang}$trans->{suffix} -r " .
            "$marc "     .
            ( @files   ? ' -f ' . join ' -f ', @files : '') .
            ( @nomarc  ? ' -n ' . join ' -n ', @nomarc : '');
    }
}


sub create_prefs {
    my $self = shift;

    if ( -e $self->po_filename("-pref.po") ) {
        say "Preferences .po file already exists. Delete it if you want to recreate it.";
        return;
    }
    $self->get_po_from_prefs();
    $self->save_po();
}

sub get_po_from_target {
    my $self   = shift;
    my $target = shift;

    my $po;
    my $po_head = Locale::PO->new;
    $po_head->{msgid}  = "\"\"";
    $po_head->{msgstr} = "".
        "Project-Id-Version: Koha Project - Installation files\\n" .
        "PO-Revision-Date: YEAR-MO-DA HO:MI +ZONE\\n" .
        "Last-Translator: FULL NAME <EMAIL\@ADDRESS>\\n" .
        "Language-Team: Koha Translation Team\\n" .
        "Language: ".$self->{lang}."\\n" .
        "MIME-Version: 1.0\\n" .
        "Content-Type: text/plain; charset=UTF-8\\n" .
        "Content-Transfer-Encoding: 8bit\\n";

    my @dirs = @{ $target->{dirs} };
    my $intradir = $self->{context}->config('intranetdir');
    for my $dir ( @dirs ) {                                                     # each dir
        opendir( my $dh, "$intradir/$dir" ) or die ("Can't open $intradir/$dir");
        my @filelist = grep { $_ =~ m/\.yml/ } readdir($dh);                    # Just yaml files
        close($dh);
        for my $file ( @filelist ) {                                            # each file
            my $yaml   = LoadFile( "$intradir/$dir/$file" );
            my @tables = @{ $yaml->{'tables'} };
            my $tablec;
            for my $table ( @tables ) {                                         # each table
                $tablec++;
                my $table_name = ( keys %$table )[0];
                my @translatable = @{ $table->{$table_name}->{translatable} };
                my @rows = @{ $table->{$table_name}->{rows} };
                my @multiline = @{ $table->{$table_name}->{'multiline'} };      # to check multiline values
                my $rowc;
                for my $row ( @rows ) {                                         # each row
                    $rowc++;
                    for my $field ( @translatable ) {                           # each field
                        if ( @multiline and grep { $_ eq $field } @multiline ) {    # multiline fields, only notices ATM
                            my $mulc;
                            foreach my $line ( @{$row->{$field}} ) {
                                $mulc++;
                                next if ( $line =~ /^(\s*<.*?>\s*$|^\s*\[.*?\]\s*|\s*)$/ );                     # discard pure html, TT, empty
                                $line =~ s/(<<.*?>>|\[\%.*?\%\]|<.*?>)/\%s/g;                                   # put placeholders
                                next if ( $line =~ /^(\s|%s|-|[[:punct:]]|\(|\))*$/ or length($line) < 2 );     # discard non strings
                                if ( not $po->{ $line } ) {
                                    my $msg = Locale::PO->new(
                                                -msgid => $line, -msgstr => '',
                                                -reference => "$dir/$file:$table_name:$tablec:row:$rowc:mul:$mulc" );
                                    $po->{ $line } = $msg;
                                }
                            }
                        } else {
                            if ( defined $row->{$field} and length($row->{$field}) > 1                         # discard null values and small strings
                                 and not $po->{ $row->{$field} } ) {
                                my $msg = Locale::PO->new(
                                            -msgid => $row->{$field}, -msgstr => '',
                                            -reference => "$dir/$file:$table_name:$tablec:row:$rowc" );
                                $po->{ $row->{$field} } = $msg;
                            }
                        }
                    }
                }
            }
            my $desccount;
            for my $description ( @{ $yaml->{'description'} } ) {
                $desccount++;
                if ( length($description) > 1 and not $po->{ $description } ) {
                    my $msg = Locale::PO->new(
                                -msgid => $description, -msgstr => '',
                                -reference => "$dir/$file:description:$desccount" );
                    $po->{ $description } = $msg;
                }
            }
        }
    }
    $po->{''} = $po_head if ( $po );

    return $po;
}

sub create_installer {
    my $self = shift;
    return unless ( $self->{installer} );

    say "Create installer translation files\n" if $self->{verbose};

    my @targets = @{ $self->{installer} };             # each installer target (common,marc21,unimarc)

    for my $target ( @targets ) {
        if ( -e $self->po_filename( $target->{suffix} ) ) {
            say "$self->{lang}$target->{suffix} file already exists. Delete it if you want to recreate it.";
            return;
        }
    }

    for my $target ( @targets ) {
        my $po = get_po_from_target( $self, $target );
        # create output file only if there is something to write
        if ( $po ) {
            my $po_file = $self->po_filename( $target->{suffix} );
            Locale::PO->save_file_fromhash( $po_file, $po );
            say "Saved in file: ", $po_file if $self->{verbose};
        }
    }
}

sub update_installer {
    my $self = shift;
    return unless ( $self->{installer} );

    say "Update installer translation files\n" if $self->{verbose};

    my @targets = @{ $self->{installer} };             # each installer target (common,marc21,unimarc)

    for my $target ( @targets ) {
        return unless ( -e $self->po_filename( $target->{suffix} ) );
        my $po = get_po_from_target( $self, $target );
        # update file only if there is something to update
        if ( $po ) {
            my ( $fh, $po_temp ) = tempfile();
            binmode( $fh, ":encoding(UTF-8)" );
            Locale::PO->save_file_fromhash( $po_temp, $po );
            my $po_file = $self->po_filename( $target->{suffix} );
            eval {
                my $st = system($self->{msgmerge}." ".($self->{verbose}?'':'-q').
                         " -s $po_file $po_temp -o - | ".$self->{msgattrib}." --no-obsolete -o $po_file");
            };
            say "Updated file: ", $po_file if $self->{verbose};
        }
    }
}

sub translate_yaml {
    my $self   = shift;
    my $target = shift;
    my $srcyml = shift;

    my $po_file = $self->po_filename( $target->{suffix} );
    return $srcyml unless ( -e $po_file );

    my $po_ref  = Locale::PO->load_file_ashash( $po_file );

    my $dstyml   = LoadFile( $srcyml );

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
                        next if ( $line =~ /^(\s*<.*?>\s*$|^\s*\[.*?\]\s*|\s*)$/ );     # discard pure html, TT, empty
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

    my $intradir  = $self->{context}->config('intranetdir');
    my $db_scheme = $self->{context}->config('db_scheme');
    my $langdir  = "$intradir/installer/data/$db_scheme/$self->{lang}";
    if ( -d $langdir ) {
        say "$self->{lang} installer dir $langdir already exists.\nDelete it if you want to recreate it." if $self->{verbose};
        return;
    }

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
                    open(my $fh, ">:encoding(UTF-8)", "$intradir/$tdir/$file");
                    DumpFile( $fh, $translated_yaml );
                    close($fh);
                } else {
                    File::Copy::copy( "$intradir/$dir/$file", "$intradir/$tdir/$file" );
                }
            }
        }
    }
}

sub create_tmpl {
    my ($self, $files) = @_;

    say "Create templates\n" if $self->{verbose};
    for my $trans ( @{$self->{interface}} ) {
        my @files   = @$files;
        my @nomarc = ();
        print
            "  Create templates .po files for '$trans->{name}'\n",
            "    From: $trans->{dir}/en/\n",
            "    To  : $self->{path_po}/$self->{lang}$trans->{suffix}\n"
                if $self->{verbose};

        my $trans_dir = join("/en/ -i ",split(" ",$trans->{dir}))."/en/"; # multiple source dirs
        # if processing MARC po file, only use corresponding files
        my $marc      = ( $trans->{name} =~ /MARC/ )?"-m \"$trans->{name}\"":"";            # for MARC translations
        # if not processing MARC po file, ignore all MARC files
        @nomarc       = ( 'marc21', 'unimarc', 'normarc' ) if ( $trans->{name} !~ /MARC/ ); # hardcoded MARC variants

        system
            "$self->{process} create " .
            "-i $trans_dir " .
            "-s $self->{path_po}/$self->{lang}$trans->{suffix} -r " .
            "$marc " .
            ( @files  ? ' -f ' . join ' -f ', @files   : '') .
            ( @nomarc ? ' -n ' . join ' -n ', @nomarc : '');
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

sub create_messages {
    my $self = shift;

    my $pot = "$Bin/$self->{domain}.pot";
    my $po = "$self->{path_po}/$self->{lang}-messages.po";
    my $js_pot = "$self->{domain}-js.pot";
    my $js_po = "$self->{path_po}/$self->{lang}-messages-js.po";

    unless ( -f $pot && -f $js_pot ) {
        $self->extract_messages();
    }

    say "Create messages ($self->{lang})" if $self->{verbose};
    my $locale = $self->locale_name();
    system "$self->{msginit} -i $pot -o $po -l $locale --no-translator 2> /dev/null";
    warn "Problems creating $pot ".$? if ( $? == -1 );
    system "$self->{msginit} -i $js_pot -o $js_po -l $locale --no-translator 2> /dev/null";
    warn "Problems creating $js_pot ".$? if ( $? == -1 );

    # If msginit failed to correctly set Plural-Forms, set a default one
    system "$self->{sed} --in-place "
        . "--expression='s/Plural-Forms: nplurals=INTEGER; plural=EXPRESSION/Plural-Forms: nplurals=2; plural=(n != 1)/' "
        . "$po $js_po";
}

sub update_messages {
    my $self = shift;

    my $pot = "$Bin/$self->{domain}.pot";
    my $po = "$self->{path_po}/$self->{lang}-messages.po";
    my $js_pot = "$self->{domain}-js.pot";
    my $js_po = "$self->{path_po}/$self->{lang}-messages-js.po";

    unless ( -f $pot && -f $js_pot ) {
        $self->extract_messages();
    }

    if ( -f $po && -f $js_pot ) {
        say "Update messages ($self->{lang})" if $self->{verbose};
        system "$self->{msgmerge} --backup=off --quiet -U $po $pot";
        system "$self->{msgmerge} --backup=off --quiet -U $js_po $js_pot";
    } else {
        $self->create_messages();
    }
}

sub extract_messages_from_templates {
    my ($self, $tempdir, $type, @files) = @_;

    my $htdocs = $type eq 'intranet' ? 'intrahtdocs' : 'opachtdocs';
    my $dir = $self->{context}->config($htdocs);
    my @keywords = qw(t tx tn txn tnx tp tpx tnp tnpx);
    my $parser = Template::Parser->new();

    foreach my $file (@files) {
        say "Extract messages from $file" if $self->{verbose};
        my $template = read_file(File::Spec->catfile($dir, $file));

        # No need to process a file that doesn't use the i18n.inc file.
        next unless $template =~ /i18n\.inc/;

        my $data = $parser->parse($template);
        unless ($data) {
            warn "Error at $file : " . $parser->error();
            next;
        }

        my $destfile = $type eq 'intranet' ?
            File::Spec->catfile($tempdir, 'koha-tmpl', 'intranet-tmpl', $file) :
            File::Spec->catfile($tempdir, 'koha-tmpl', 'opac-tmpl', $file);

        make_path(dirname($destfile));
        open my $fh, '>', $destfile;

        my @blocks = ($data->{BLOCK}, values %{ $data->{DEFBLOCKS} });
        foreach my $block (@blocks) {
            my $document = PPI::Document->new(\$block);

            # [% t('foo') %] is compiled to
            # $output .= $stash->get(['t', ['foo']]);
            # We try to find all nodes corresponding to keyword (here 't')
            my $nodes = $document->find(sub {
                my ($topnode, $element) = @_;

                # Filter out non-valid keywords
                return 0 unless ($element->isa('PPI::Token::Quote::Single'));
                return 0 unless (grep {$element->content eq qq{'$_'}} @keywords);

                # keyword (e.g. 't') should be the first element of the arrayref
                # passed to $stash->get()
                return 0 if $element->sprevious_sibling;

                return 0 unless $element->snext_sibling
                    && $element->snext_sibling->snext_sibling
                    && $element->snext_sibling->snext_sibling->isa('PPI::Structure::Constructor');

                # Check that it's indeed a call to $stash->get()
                my $statement = $element->statement->parent->statement->parent->statement;
                return 0 unless grep { $_->isa('PPI::Token::Symbol') && $_->content eq '$stash' } $statement->children;
                return 0 unless grep { $_->isa('PPI::Token::Operator') && $_->content eq '->' } $statement->children;
                return 0 unless grep { $_->isa('PPI::Token::Word') && $_->content eq 'get' } $statement->children;

                return 1;
            });

            next unless $nodes;

            # Write the Perl equivalent of calls to t* functions family, so
            # xgettext can extract the strings correctly
            foreach my $node (@$nodes) {
                my @args = map {
                    $_->significant && !$_->isa('PPI::Token::Operator') ? $_->content : ()
                } $node->snext_sibling->snext_sibling->find_first('PPI::Statement')->children;

                my $keyword = $node->content;
                $keyword =~ s/^'t(.*)'$/__$1/;

                # Only keep required args to have a clean output
                my @required_args = shift @args;
                push @required_args, shift @args if $keyword =~ /n/;
                push @required_args, shift @args if $keyword =~ /p/;

                say $fh "$keyword(" . join(', ', @required_args) . ");";
            }

        }

        close $fh;
    }

    return $tempdir;
}

sub extract_messages {
    my $self = shift;

    say "Extract messages into POT file" if $self->{verbose};

    my $intranetdir = $self->{context}->config('intranetdir');
    my $opacdir = $self->{context}->config('opacdir');

    # Find common ancestor directory
    my @intranetdirs = File::Spec->splitdir($intranetdir);
    my @opacdirs = File::Spec->splitdir($opacdir);
    my @basedirs;
    while (@intranetdirs and @opacdirs) {
        my ($dir1, $dir2) = (shift @intranetdirs, shift @opacdirs);
        last if $dir1 ne $dir2;
        push @basedirs, $dir1;
    }
    my $basedir = File::Spec->catdir(@basedirs);

    my @files_to_scan;
    my @directories_to_scan = ('.');
    my @blacklist = map { File::Spec->catdir(@intranetdirs, $_) } qw(blib koha-tmpl skel tmp t);
    while (@directories_to_scan) {
        my $dir = shift @directories_to_scan;
        opendir DIR, File::Spec->catdir($basedir, $dir) or die "Unable to open $dir: $!";
        foreach my $entry (readdir DIR) {
            next if $entry =~ /^\./;
            my $relentry = File::Spec->catfile($dir, $entry);
            my $abspath = File::Spec->catfile($basedir, $relentry);
            if (-d $abspath and not grep { $_ eq $relentry } @blacklist) {
                push @directories_to_scan, $relentry;
            } elsif (-f $abspath and $relentry =~ /\.(pl|pm)$/) {
                push @files_to_scan, $relentry;
            }
        }
    }

    my $intrahtdocs = $self->{context}->config('intrahtdocs');
    my $opachtdocs = $self->{context}->config('opachtdocs');

    my @intranet_tt_files;
    find(sub {
        if ($File::Find::dir =~ m|/en/| && $_ =~ m/\.(tt|inc)$/) {
            my $filename = $File::Find::name;
            $filename =~ s|^$intrahtdocs/||;
            push @intranet_tt_files, $filename;
        }
    }, $intrahtdocs);

    my @opac_tt_files;
    find(sub {
        if ($File::Find::dir =~ m|/en/| && $_ =~ m/\.(tt|inc)$/) {
            my $filename = $File::Find::name;
            $filename =~ s|^$opachtdocs/||;
            push @opac_tt_files, $filename;
        }
    }, $opachtdocs);

    my $tempdir = tempdir('Koha-translate-XXXX', TMPDIR => 1, CLEANUP => 1);
    $self->extract_messages_from_templates($tempdir, 'intranet', @intranet_tt_files);
    $self->extract_messages_from_templates($tempdir, 'opac', @opac_tt_files);

    @intranet_tt_files = map { File::Spec->catfile('koha-tmpl', 'intranet-tmpl', $_) } @intranet_tt_files;
    @opac_tt_files = map { File::Spec->catfile('koha-tmpl', 'opac-tmpl', $_) } @opac_tt_files;
    my @tt_files = grep { -e File::Spec->catfile($tempdir, $_) } @intranet_tt_files, @opac_tt_files;

    push @files_to_scan, @tt_files;

    my $xgettext_common_args = "--force-po --from-code=UTF-8 "
        . "--package-name=Koha --package-version='' "
        . "-k -k__ -k__x -k__n:1,2 -k__nx:1,2 -k__xn:1,2 -k__p:1c,2 "
        . "-k__px:1c,2 -k__np:1c,2,3 -k__npx:1c,2,3 -kN__ -kN__n:1,2 "
        . "-kN__p:1c,2 -kN__np:1c,2,3 ";
    my $xgettext_cmd = "$self->{xgettext} -L Perl $xgettext_common_args "
        . "-o $Bin/$self->{domain}.pot -D $tempdir -D $basedir";
    $xgettext_cmd .= " $_" foreach (@files_to_scan);

    if (system($xgettext_cmd) != 0) {
        die "system call failed: $xgettext_cmd";
    }

    my @js_dirs = (
        "$intrahtdocs/prog/js",
        "$opachtdocs/bootstrap/js",
    );

    my @js_files;
    find(sub {
        if ($_ =~ m/\.js$/) {
            my $filename = $File::Find::name;
            $filename =~ s|^$intranetdir/||;
            push @js_files, $filename;
        }
    }, @js_dirs);

    $xgettext_cmd = "$self->{xgettext} -L JavaScript $xgettext_common_args "
        . "-o $Bin/$self->{domain}-js.pot -D $intranetdir";
    $xgettext_cmd .= " $_" foreach (@js_files);

    if (system($xgettext_cmd) != 0) {
        die "system call failed: $xgettext_cmd";
    }

    my $replace_charset_cmd = "$self->{sed} --in-place " .
        "--expression='s/charset=CHARSET/charset=UTF-8/' " .
        "$Bin/$self->{domain}.pot $Bin/$self->{domain}-js.pot";
    if (system($replace_charset_cmd) != 0) {
        die "system call failed: $replace_charset_cmd";
    }
}

sub install_messages {
    my ($self) = @_;

    my $locale = $self->locale_name();
    my $modir = "$self->{path_po}/$locale/LC_MESSAGES";
    my $pofile = "$self->{path_po}/$self->{lang}-messages.po";
    my $mofile = "$modir/$self->{domain}.mo";
    my $js_pofile = "$self->{path_po}/$self->{lang}-messages-js.po";

    unless ( -f $pofile && -f $js_pofile ) {
        $self->create_messages();
    }
    say "Install messages ($locale)" if $self->{verbose};
    make_path($modir);
    system "$self->{msgfmt} -o $mofile $pofile";

    my $js_locale_data = 'var json_locale_data = {"Koha":' . `$self->{po2json} $js_pofile` . '};';
    my $progdir = $self->{context}->config('intrahtdocs') . '/prog';
    mkdir "$progdir/$self->{lang}/js";
    open my $fh, '>', "$progdir/$self->{lang}/js/locale_data.js";
    print $fh $js_locale_data;
    close $fh;

    my $opachtdocs = $self->{context}->config('opachtdocs');
    opendir(my $dh, $opachtdocs);
    for my $theme ( grep { not /^\.|lib|xslt/ } readdir($dh) ) {
        mkdir "$opachtdocs/$theme/$self->{lang}/js";
        open my $fh, '>', "$opachtdocs/$theme/$self->{lang}/js/locale_data.js";
        print $fh $js_locale_data;
        close $fh;
    }
}

sub remove_pot {
    my $self = shift;

    unlink "$Bin/$self->{domain}.pot";
    unlink "$Bin/$self->{domain}-js.pot";
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
    $self->install_tmpl($files) unless $self->{pref_only};
    $self->install_prefs();
    $self->install_messages();
    $self->remove_pot();
    $self->install_installer();
}


sub get_all_langs {
    my $self = shift;
    opendir( my $dh, $self->{path_po} );
    my @files = grep { $_ =~ /-pref.(po|po.gz)$/ }
        readdir $dh;
    @files = map { $_ =~ s/-pref.(po|po.gz)$//r } @files;
}


sub update {
    my ($self, $files) = @_;
    my @langs = $self->{lang} ? ($self->{lang}) : $self->get_all_langs();
    for my $lang ( @langs ) {
        $self->set_lang( $lang );
        $self->uncompress();
        $self->update_tmpl($files) unless $self->{pref_only};
        $self->update_prefs();
        $self->update_messages();
        $self->update_installer();
    }
    $self->remove_pot();
}


sub create {
    my ($self, $files) = @_;
    return unless $self->{lang};
    $self->create_tmpl($files) unless $self->{pref_only};
    $self->create_prefs();
    $self->create_messages();
    $self->remove_pot();
    $self->create_installer();
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

