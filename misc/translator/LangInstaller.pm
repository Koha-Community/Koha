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
use YAML::Syck qw( Dump LoadFile );
use Locale::PO;
use FindBin qw( $Bin );

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
    $self->{domain}          = 'messages';
    $self->{cp}              = `which cp`;
    $self->{msgmerge}        = `which msgmerge`;
    $self->{xgettext}        = `which xgettext`;
    $self->{sed}             = `which sed`;
    chomp $self->{cp};
    chomp $self->{msgmerge};
    chomp $self->{xgettext};
    chomp $self->{sed};

    # Get all .pref file names
    opendir my $fh, $self->{path_pref_en};
    my @pref_files = grep { /.pref/ } readdir($fh);
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
            suffix => '-i-staff-t-prog-v-3006000.po',
        },
        {
            name   => 'Intranet prog help',
            dir    => $context->config('intrahtdocs') . '/prog/en/modules/help',
            suffix => '-staff-help.po',
        },
    ];

    # OPAC themes
    opendir my $dh, $context->config('opachtdocs');
    for my $theme ( grep { not /^\.|lib/ } readdir($dh) ) {
        push @{$self->{interface}}, {
            name   => "OPAC $theme",
            dir    => "$opachtdocs/$theme",
            suffix => "-opac-$theme.po",
        };
    }

    bless $self, $class;
}


sub po_filename {
    my $self = shift;

    my $context    = C4::Context->new;
    my $trans_path = $Bin . '/po';
    my $trans_file = "$trans_path/" . $self->{lang} . "-pref.po";
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
                    next unless $key eq 'choices';
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
                    next unless $key eq 'choices';
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
    Locale::PO->save_file_fromhash( $self->po_filename, $po );
    say "Saved in file: ", $self->po_filename if $self->{verbose};
}


sub get_po_merged_with_en {
    my $self = shift;

    # Get po from current 'en' .pref files
    $self->get_po_from_prefs();
    my $po_current = $self->{po};

    # Get po from previous generation
    my $po_previous = Locale::PO->load_file_ashash( $self->po_filename );

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
                $ntab->{$nsection} = $tab_content->{$section};
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
        print
            "  Install templates '$trans->{name}'\n",
            "    From: $trans->{dir}/en/\n",
            "    To  : $trans->{dir}/$self->{lang}\n",
            "    With: $self->{path_po}/$self->{lang}$trans->{suffix}\n"
                if $self->{verbose};

        my $trans_dir = ( $trans->{name} =~ /help/ )?"$trans->{dir}":"$trans->{dir}/en/";
        my $lang_dir  = ( $trans->{name} =~ /help/ )?"$trans->{dir}":"$trans->{dir}/$self->{lang}";
        $lang_dir =~ s|/en/|/$self->{lang}/|;
        mkdir $lang_dir unless -d $lang_dir;
        my $excludes  = ( $trans->{name} =~ /UI/   )?"-x 'help'":"";

        system
            "$self->{process} install " .
            "-i $trans_dir " .
            "-o $lang_dir  ".
            "-s $self->{path_po}/$self->{lang}$trans->{suffix} -r $excludes" .
            (
                @$files
                    ? ' -f ' . join ' -f ', @$files
                    : ''
            )
    }
}


sub update_tmpl {
    my ($self, $files) = @_;

    say "Update templates" if $self->{verbose};
    for my $trans ( @{$self->{interface}} ) {
        print
            "  Update templates '$trans->{name}'\n",
            "    From: $trans->{dir}/en/\n",
            "    To  : $self->{path_po}/$self->{lang}$trans->{suffix}\n"
                if $self->{verbose};
        my $lang_dir = "$trans->{dir}/$self->{lang}";

        my $trans_dir = ( $trans->{name} =~ /help/ )?"$trans->{dir}":"$trans->{dir}/en/";
        my $excludes  = ( $trans->{name} =~ /UI/   )?"-x 'help'":"";

        system
            "$self->{process} update " .
            "-i $trans_dir " .
            "-s $self->{path_po}/$self->{lang}$trans->{suffix} -r $excludes" .
            (
                @$files
                    ? ' -f ' . join ' -f ', @$files
                    : ''
            )
    }
}


sub create_prefs {
    my $self = shift;

    if ( -e $self->po_filename ) {
        say "Preferences .po file already exists. Delete it if you want to recreate it.";
        return;
    }
    $self->get_po_from_prefs();
    $self->save_po();
}


sub create_tmpl {
    my ($self, $files) = @_;

    say "Create templates\n" if $self->{verbose};
    for my $trans ( @{$self->{interface}} ) {
        print
            "  Create templates .po files for '$trans->{name}'\n",
            "    From: $trans->{dir}/en/\n",
            "    To  : $self->{path_po}/$self->{lang}$trans->{suffix}\n"
                if $self->{verbose};

        my $trans_dir = ( $trans->{name} =~ /help/ )?"$trans->{dir}":"$trans->{dir}/en/";
        my $excludes  = ( $trans->{name} =~ /UI/   )?"-x 'help'":"";

        system
            "$self->{process} create " .
            "-i $trans_dir " .
            "-s $self->{path_po}/$self->{lang}$trans->{suffix} -r $excludes" .
            (
                @$files
                    ? ' -f ' . join ' -f ', @$files
                    : ''
            )
    }
}

sub create_messages {
    my $self = shift;

    print "Create messages ($self->{lang})\n" if $self->{verbose};
    system
        "$self->{cp} $self->{domain}.pot " .
        "$self->{path_po}/$self->{lang}-$self->{domain}.po";
}

sub update_messages {
    my $self = shift;

    my $pofile = "$self->{path_po}/$self->{lang}-$self->{domain}.po";
    print "Update messages ($self->{lang})\n" if $self->{verbose};
    if ( not -f $pofile ) {
        print "File $pofile does not exist\n" if $self->{verbose};
        $self->create_messages();
    }
    system "$self->{msgmerge} -U $pofile $self->{domain}.pot";
}

sub extract_messages {
    my $self = shift;

    my $intranetdir = $self->{context}->config('intranetdir');
    my @files_to_scan;
    my @directories_to_scan = ('.');
    my @blacklist = qw(blib koha-tmpl skel tmp t);
    while (@directories_to_scan) {
        my $dir = shift @directories_to_scan;
        opendir DIR, "$intranetdir/$dir" or die "Unable to open $dir: $!";
        foreach my $entry (readdir DIR) {
            next if $entry =~ /^\./;
            my $relentry = "$dir/$entry";
            $relentry =~ s|^\./||;
            if (-d "$intranetdir/$relentry" and not grep /^$relentry$/, @blacklist) {
                push @directories_to_scan, "$relentry";
            } elsif (-f "$intranetdir/$relentry" and $relentry =~ /(pl|pm)$/) {
                push @files_to_scan, "$relentry";
            }
        }
    }

    my $xgettext_cmd = "$self->{xgettext} -L Perl --from-code=UTF-8 " .
        "-o $Bin/$self->{domain}.pot -D $intranetdir";
    $xgettext_cmd .= " $_" foreach (@files_to_scan);

    if (system($xgettext_cmd) != 0) {
        die "system call failed: $xgettext_cmd";
    }

    if ( -f "$Bin/$self->{domain}.pot" ) {
        my $replace_charset_cmd = "$self->{sed} --in-place " .
            "$Bin/$self->{domain}.pot " .
            "--expression='s/charset=CHARSET/charset=UTF-8/'";
        if (system($replace_charset_cmd) != 0) {
            die "system call failed: $replace_charset_cmd";
        }
    } else {
        print "No messages found\n" if $self->{verbose};
        return;
    }
    return 1;
}

sub remove_pot {
    my $self = shift;

    unlink "$Bin/$self->{domain}.pot";
}

sub install {
    my ($self, $files) = @_;
    return unless $self->{lang};
    $self->install_tmpl($files) unless $self->{pref_only};
    $self->install_prefs();
}


sub get_all_langs {
    my $self = shift;
    opendir( my $dh, $self->{path_po} );
    my @files = grep { $_ =~ /-pref.po$/ }
        readdir $dh;
    @files = map { $_ =~ s/-pref.po$//; $_ } @files;
}


sub update {
    my ($self, $files) = @_;
    my @langs = $self->{lang} ? ($self->{lang}) : $self->get_all_langs();
    my $extract_ok = $self->extract_messages();
    for my $lang ( @langs ) {
        $self->set_lang( $lang );
        $self->update_tmpl($files) unless $self->{pref_only};
        $self->update_prefs();
        $self->update_messages() if $extract_ok;
    }
    $self->remove_pot() if $extract_ok;
}


sub create {
    my ($self, $files) = @_;
    return unless $self->{lang};
    $self->create_tmpl($files) unless $self->{pref_only};
    $self->create_prefs();
    if ($self->extract_messages()) {
        $self->create_messages();
        $self->remove_pot();
    }
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

Create 3 .po files in F<po> subdirectory: (1) from opac pages templates, (2)
intranet templates, and (3) from preferences.

=over

=item F<lang>-opac-{theme}.po

Contains extracted text from english (en) OPAC templates found in
<KOHA_ROOT>/koha-tmpl/opac-tmpl/{theme}/en/ directory.

=item F<lang>-intranet.po

Contains extracted text from english (en) intranet templates found in
<KOHA_ROOT>/koha-tmpl/intranet-tmpl/prog/en/ directory.

=item F<lang>-pref.po

Contains extracted text from english (en) preferences. They are found in files
located in <KOHA_ROOT>/koha-tmpl/intranet-tmpl/prog/en/admin/preferences
directory.

=back

=item pref-trans update F<lang>

Update .po files in F<po> directory, named F<lang>-*.po.

=item pref-trans install F<lang>

=back

=cut

