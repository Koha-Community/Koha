#!/usr/bin/perl -w

use Modern::Perl;

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use CGI qw( utf8 ); # NOT a CGI script, this is just to keep C4::Templates::gettemplate happy
use C4::Context;
use C4::Debug;
use C4::Letters;
use C4::Templates;
use File::Spec;
use Pod::Usage;
use Getopt::Long;
use C4::Log;

use File::Basename qw( dirname );
use Koha::DateUtils;
use MIME::Lite;

my (
    $stylesheet,
    $help,
    $split,
    $html,
    $csv,
    $ods,
    $delimiter,
    @letter_codes,
    $send,
    @emails,
);

$send = 1;
GetOptions(
    'h|help'  => \$help,
    's|split' => \$split,
    'html'    => \$html,
    'csv'     => \$csv,
    'ods'     => \$ods,
    'd|delimiter:s' => \$delimiter,
    'letter_code:s' => \@letter_codes,
    'send!'         => \$send,
    'e|email:s'     => \@emails,
) || pod2usage(1);

pod2usage(0) if $help;

my $output_directory = $ARGV[0];

if ( !$output_directory || !-d $output_directory || !-w $output_directory ) {
    pod2usage({
        -exitval => 1,
        -msg => qq{\nError: You must specify a valid and writeable directory to dump the print notices in.\n},
    });
}

# Default value is html
$html = 1 if not $html and not $csv and not $ods;

if ( $csv and @letter_codes != 1 ) {
    pod2usage({
        -exitval => 1,
        -msg => qq{\nIt is not consistent to use --csv without one (and only one) letter_code\n},
    });
}

if ( $ods and @letter_codes != 1 ) {
    pod2usage({
        -exitval => 1,
        -msg => qq{\nIt is not consistent to use --ods without one (and only one) letter_code\n},
    });
}

$delimiter ||= q|,|;

cronlogaction();

my $today_iso     = output_pref( { dt => dt_from_string, dateonly => 1, dateformat => 'iso' } ) ;
my $today_syspref = output_pref( { dt => dt_from_string, dateonly => 1 } );

my @all_messages = @{ GetPrintMessages() };

# Filter by letter_code
@all_messages = map {
    my $letter_code = $_->{letter_code};
    (
        grep { /^$letter_code$/ } @letter_codes
    ) ? $_ : ()
} @all_messages if @letter_codes;
exit unless @all_messages;

my ( $html_filenames, $csv_filenames, $ods_filenames );
$csv_filenames = print_notices({
    messages => \@all_messages,
    split => $split,
    output_directory => $output_directory,
    format => 'csv',
}) if $csv;

$ods_filenames = print_notices({
    messages => \@all_messages,
    split => $split,
    output_directory => $output_directory,
    format => 'ods',
}) if $ods;

if ( $html ) {
    ## carriage return replaced by <br/> as output is html
    foreach my $message (@all_messages) {
        local $_ = $message->{'content'};
        s/\n/<br \/>/g;
        s/\r//g;
        $message->{'content'} = $_;
    }

    $html_filenames = print_notices({
        messages => \@all_messages,
        split => $split,
        output_directory => $output_directory,
        format => 'html',
    });
}

if ( @emails ) {
    my $files = {
        html => $html_filenames,
        csv  => $csv_filenames,
        ods  => $ods_filenames,
    };
    for my $email ( @emails ) {
        send_files({
            directory => $output_directory,
            files => $files,
            to => $email,
            from => C4::Context->preference('KohaAdminEmailAddress'), # Should be replaced if bug 8000 is pushed
        });
    }
}

sub print_notices {
    my ( $params ) = @_;

    my $messages = $params->{messages};
    my $split = $params->{split};
    my $output_directory = $params->{output_directory};
    my $format = $params->{format} // 'html';

    die "Format $format is not known"
        unless $format =~ m[^html$|^csv$|^ods$];

    my ( @filenames, $messages_by_branch );

    if ( $split ) {
        foreach my $message (@$messages) {
            push( @{ $messages_by_branch->{ $message->{'branchcode'} } }, $message );
        }
    } else {
        $messages_by_branch->{all_branches} = $messages;
    }

    while ( my ( $branchcode, $branch_messages ) = each %$messages_by_branch ) {
        my $letter_codes = @letter_codes == 0 ? 'all' : join '_', @letter_codes;
        my $filename = $split
            ? "notices_$letter_codes-" . $today_iso . "-$branchcode.$format"
            : "notices_$letter_codes-" . $today_iso . ".$format";
        my $filepath = File::Spec->catdir( $output_directory, $filename );
        if ( $format eq 'html' ) {
            generate_html({
                messages => $branch_messages,
                filepath => $filepath,
            });
        } elsif ( $format eq 'csv' ) {
            generate_csv ({
                messages => $branch_messages,
                filepath => $filepath,
            });
        } elsif ( $format eq 'ods' ) {
            generate_ods ({
                messages => $branch_messages,
                filepath => $filepath,
            });
        }

        if ( $send ) {
            foreach my $message ( @$branch_messages ) {
                C4::Letters::_set_message_status(
                    {
                        message_id => $message->{'message_id'},
                        status => 'sent'
                    }
                );
            }
        }
        push @filenames, $filename;
    }
    return \@filenames;
}

sub generate_html {
    my ( $params ) = @_;
    my $messages = $params->{messages};
    my $filepath = $params->{filepath};

    my $template =
      C4::Templates::gettemplate( 'batch/print-notices.tt', 'intranet',
        new CGI );

    $template->param(
        stylesheet => C4::Context->preference("NoticeCSS"),
        today      => $today_syspref,
        messages   => $messages,
    );

    open my $OUTPUT, '>encoding(utf-8)', $filepath
        or die "Could not open $filepath: $!";
    print $OUTPUT $template->output;
    close $OUTPUT;
}

sub generate_csv {
    my ( $params ) = @_;
    my $messages = $params->{messages};
    my $filepath = $params->{filepath};

    open my $OUTPUT, '>encoding(utf-8)', $filepath
        or die "Could not open $filepath: $!";
    my ( @csv_lines, $headers );
    foreach my $message ( @$messages ) {
        my @lines = split /\n/, $message->{content};
        chomp for @lines;

        # We don't have headers, get them
        unless ( $headers ) {
            $headers = $lines[0];
            say $OUTPUT $headers;
        }

        shift @lines;
        for my $line ( @lines ) {
            next if $line =~ /^\s$/;
            say $OUTPUT $line;
        }
    }
}

sub generate_ods {
    my ( $params ) = @_;
    my $messages = $params->{messages};
    my $filepath = $params->{filepath};

    use OpenOffice::OODoc;
    my $tmpdir = dirname $filepath;
    odfWorkingDirectory( $tmpdir );
    my $container = odfContainer( $filepath, create => 'spreadsheet' );
    my $doc = odfDocument (
        container => $container,
        part      => 'content'
    );
    my $table = $doc->getTable(0);

    my @headers;
    my ( $nb_rows, $nb_cols, $i ) = ( scalar(@$messages), 0, 0 );
    foreach my $message ( @$messages ) {
        my @lines = split /\n/, $message->{content};
        chomp for @lines;

        # We don't have headers, get them
        unless ( @headers ) {
            @headers = split $delimiter, $lines[0];

            $nb_cols = @headers;
            $doc->expandTable( $table, $nb_rows + 1, $nb_cols );
            my $row = $doc->getRow( $table, 0 );
            my $j = 0;
            for my $header ( @headers ) {
                $doc->cellValue( $row, $j, Encode::encode( 'UTF8', $header ) );
                $j++;
            }
            $i = 1;
        }

        shift @lines; # remove headers
        for my $line ( @lines ) {
            my @row_data = split $delimiter, $line;
            my $row = $doc->getRow( $table, $i );
            # Note scalar(@$row_data) should be equal to $nb_cols
            for ( my $j = 0 ; $j < scalar(@row_data) ; $j++ ) {
                my $value = Encode::encode( 'UTF8', $row_data[$j] );
                $doc->cellValue( $row, $j, $value );
            }
            $i++;
        }
    }
    $doc->save();
}

sub send_files {
    my ( $params ) = @_;
    my $directory = $params->{directory};
    my $files = $params->{files};
    my $to = $params->{to};
    my $from = $params->{from};
    return unless $to and $from;

    my $mail = MIME::Lite->new(
        From     => $from,
        To       => $to,
        Subject  => 'Print notices for ' . $today_syspref,
        Type     => 'multipart/mixed',
    );

    while ( my ( $type, $filenames ) = each %$files ) {
        for my $filename ( @$filenames ) {
            my $mimetype = $type eq 'html'
                ? 'text/html'
                : $type eq 'csv'
                    ? 'text/csv'
                    : $type eq 'ods'
                        ? 'application/vnd.oasis.opendocument.spreadsheet'
                        : undef;

            next unless $mimetype;

            my $filepath = File::Spec->catdir( $directory, $filename );

            next unless $filepath or -f $filepath;

            $mail->attach(
              Type     => $mimetype,
              Path     => $filepath,
              Filename => $filename,
              Encoding => 'base64',
            );
        }
    }

    $mail->send;
}

=head1 NAME

gather_print_notices - Print waiting print notices

=head1 SYNOPSIS

gather_print_notices output_directory [-s|--split] [--html] [--csv] [--ods] [--letter_code=LETTER_CODE] [-e|--email=your_email@example.org] [-h|--help]

Will print all waiting print notices to the output_directory.

The generated filename will be notices-TODAY.[csv|html|ods] or notices-TODAY-BRANCHCODE.[csv|html|ods] if the --split parameter is given.

=head1 OPTIONS

=over

=item B<output_directory>

Define the output directory where the files will be generated.

=item B<--send|--nosend>

After files have been generated, messages status is changed from 'pending' to
'sent'. This is the default action, without this parameter or with --send.
Using --nosend, the message status is not changed.

=item B<-s|--split>

Split messages into separate files by borrower home library to OUTPUT_DIRECTORY/notices-CURRENT_DATE-BRANCHCODE.[csv|html|ods]

=item B<--html>

Generate the print notices in a html file (default is --html, if --csv and --ods are not given).

=item B<--csv>

Generate the print notices in a csv file.
If you use this parameter, the template should contain 2 lines.
The first one the csv headers and the second one the value list.

For example:
cardnumber:patron:email:item
<<borrowers.cardnumber>>:<<borrowers.firstname>> <<borrowers.surname>>:<<borrowers.email>>:<<items.barcode>>

You have to combine this option with one (and only one) letter_code.

=item B<--ods>

Generate the print notices in a ods file.

This is the same as the csv parameter but using csv2odf to generate an ods file instead of a csv file.

=item B<--letter_code>

Filter print messages by letter_code.
Several letter_code parameters can be given.

=item B<-e|--email>

Repeatable.
E-mail address to send generated files to.

=item B<-h|--help>

Print a brief help message

=back

=head1 AUTHOR

Jesse Weaver <pianohacker@gmail.com>

Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT

Copyright 2009 Jesse Weaver

Copyright 2014 BibLibre

=head1 LICENSE
This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.

=cut
