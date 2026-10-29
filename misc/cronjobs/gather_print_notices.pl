#!/usr/bin/perl -w

use Modern::Perl;

use CGI;    # NOT a CGI script, this is just to keep C4::Templates::gettemplate happy
use Koha::Script -cron;
use C4::Context;
use C4::Letters qw( GetPrintMessages );
use C4::Templates;
use File::Spec;

use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Email;
use Koha::Util::OpenDocument qw( generate_ods );
use Koha::SMTP::Servers;

my ( $opt, $usage ) = Koha::Script->describe_options(
    'Print all waiting print notices to output_directory.

The generated filename will be notices-TODAY.[csv|html|ods], or
notices-TODAY-BRANCHCODE.[csv|html|ods] if --split is given.

%c %o output_directory',
    [ 'split|s',        'split messages into separate files by borrower home library' ],
    [ 'html',           'generate the print notices in a html file (default, if --csv and --ods are not given)' ],
    [ 'csv',            'generate the print notices in a csv file; must be combined with exactly one --letter_code' ],
    [ 'ods',            'generate the print notices in a ods file; must be combined with exactly one --letter_code' ],
    [ 'delimiter|d:s',  'delimiter used when parsing content for --ods (default: comma)' ],
    [ 'letter_code:s@', 'filter print messages by letter_code, repeatable' ],
    [
        'send!', 'change message status from pending to sent after generating files (default: on; --nosend to disable)',
        { default => 1 }
    ],
    [ 'email|e:s@', 'email address to send the generated files to, repeatable' ],
    { args => { min => 1, name => 'output_directory' } },
);

my $output_directory = $ARGV[0];

if ( !$output_directory || !-d $output_directory || !-w $output_directory ) {
    $usage->die(
        { pre_text => "Error: You must specify a valid and writeable directory to dump the print notices in.\n\n" } );
}

my $split        = $opt->split;
my $csv          = $opt->csv;
my $ods          = $opt->ods;
my @letter_codes = @{ $opt->letter_code // [] };
my $send         = $opt->send;
my @emails       = @{ $opt->email // [] };

# Default value is html
my $html = $opt->html;
$html = 1 if not $html and not $csv and not $ods;

if ( $csv and @letter_codes != 1 ) {
    $usage->die( { pre_text => "It is not consistent to use --csv without one (and only one) letter_code\n\n" } );
}

if ( $ods and @letter_codes != 1 ) {
    $usage->die( { pre_text => "It is not consistent to use --ods without one (and only one) letter_code\n\n" } );
}

my $delimiter = $opt->delimiter || q|,|;

my $today_iso     = output_pref( { dt => dt_from_string, dateonly => 1, dateformat => 'iso' } );
my $today_syspref = output_pref( { dt => dt_from_string, dateonly => 1 } );

my @all_messages = @{ GetPrintMessages() };

# Filter by letter_code
@all_messages = map {
    my $letter_code = $_->{letter_code};
    ( grep { $_ eq $letter_code } @letter_codes ) ? $_ : ()
} @all_messages if @letter_codes;
exit unless @all_messages;

my ( $html_filenames, $csv_filenames, $ods_filenames );
$csv_filenames = print_notices(
    {
        messages         => \@all_messages,
        split            => $split,
        output_directory => $output_directory,
        format           => 'csv',
    }
) if $csv;

$ods_filenames = print_notices(
    {
        messages         => \@all_messages,
        split            => $split,
        output_directory => $output_directory,
        format           => 'ods',
    }
) if $ods;

if ($html) {
    $html_filenames = print_notices(
        {
            messages         => \@all_messages,
            split            => $split,
            output_directory => $output_directory,
            format           => 'html',
        }
    );
}

if (@emails) {
    my $files = {
        html => $html_filenames,
        csv  => $csv_filenames,
        ods  => $ods_filenames,
    };

    my $transport = Koha::SMTP::Servers->get_default->transport;

    for my $email (@emails) {
        send_files(
            {
                directory => $output_directory,
                files     => $files,
                from      => C4::Context->preference('KohaAdminEmailAddress'),
                to        => $email,
                transport => $transport,
            }
        );
    }
}

sub print_notices {
    my ($params) = @_;

    my $messages         = $params->{messages};
    my $split            = $params->{split};
    my $output_directory = $params->{output_directory};
    my $format           = $params->{format} // 'html';

    die "Format $format is not known"
        unless $format =~ m[^html$|^csv$|^ods$];

    my ( @filenames, $messages_by_branch );

    if ($split) {
        foreach my $message (@$messages) {
            push( @{ $messages_by_branch->{ $message->{'branchcode'} } }, $message );
        }
    } else {
        $messages_by_branch->{all_branches} = $messages;
    }

    while ( my ( $branchcode, $branch_messages ) = each %$messages_by_branch ) {
        my $letter_codes = @letter_codes == 0 ? 'all' : join '_', @letter_codes;
        my $filename =
            $split
            ? "notices_$letter_codes-" . $today_iso . "-$branchcode.$format"
            : "notices_$letter_codes-" . $today_iso . ".$format";
        my $filepath = File::Spec->catdir( $output_directory, $filename );
        if ( $format eq 'html' ) {
            generate_html(
                {
                    messages => $branch_messages,
                    filepath => $filepath,
                }
            );
        } elsif ( $format eq 'csv' ) {
            generate_csv(
                {
                    messages => $branch_messages,
                    filepath => $filepath,
                }
            );
        } elsif ( $format eq 'ods' ) {
            _generate_ods(
                {
                    messages => $branch_messages,
                    filepath => $filepath,
                }
            );
        }

        if ($send) {
            foreach my $message (@$branch_messages) {
                C4::Letters::_set_message_status(
                    {
                        message_id => $message->{'message_id'},
                        status     => 'printed'
                    }
                );
            }
        }
        push @filenames, $filename;
    }
    return \@filenames;
}

sub generate_html {
    my ($params) = @_;
    my $messages = $params->{messages};
    my $filepath = $params->{filepath};

    my $template = C4::Templates::gettemplate(
        'batch/print-notices.tt', 'intranet',
        CGI->new
    );

    foreach my $message (@$messages) {
        $message->{is_html} = $message->{content_type} && $message->{content_type} =~ /html/i;
    }

    $template->param(
        stylesheet       => C4::Context->preference("NoticeCSS"),
        all_notice_css   => C4::Context->preference("AllNoticeCSS"),
        print_notice_css => C4::Context->preference("PrintNoticeCSS"),
        today            => $today_syspref,
        messages         => $messages,
    );

    open my $OUTPUT, '>encoding(utf-8)', $filepath
        or die "Could not open $filepath: $!";
    print $OUTPUT $template->output;
    close $OUTPUT;
}

sub generate_csv {
    my ($params) = @_;
    my $messages = $params->{messages};
    my $filepath = $params->{filepath};

    open my $OUTPUT, '>encoding(utf-8)', $filepath
        or die "Could not open $filepath: $!";
    my $headers;
    foreach my $message (@$messages) {
        my @lines = split /\n/, $message->{content};
        chomp for @lines;

        # We don't have headers, get them
        unless ($headers) {
            $headers = $lines[0];
            say $OUTPUT $headers;
        }

        shift @lines;
        for my $line (@lines) {
            next if $line =~ /^\s$/;
            say $OUTPUT $line;
        }
    }
}

sub _generate_ods {
    my ($params)     = @_;
    my $messages     = $params->{messages};
    my $ods_filepath = $params->{filepath};

    # Prepare sheet
    my $ods_content;
    my $has_headers;
    foreach my $message (@$messages) {
        my @message_lines = split /\n/, $message->{content};
        chomp for @message_lines;

        # Get headers from first message
        if ($has_headers) {
            shift @message_lines;
        } else {
            $has_headers = 1;
        }
        foreach my $message_line (@message_lines) {
            my @content_row;
            my @message_cells = split $delimiter, $message_line;
            foreach (@message_cells) {
                push @content_row, Encode::encode( 'UTF8', $_ );
            }
            push @$ods_content, \@content_row;
        }
    }

    # Process
    generate_ods( $ods_filepath, $ods_content );
}

sub send_files {
    my ($params)  = @_;
    my $directory = $params->{directory};
    my $files     = $params->{files};
    my $to        = $params->{to};
    my $from      = $params->{from};
    my $transport = $params->{transport};

    return unless $to and $from and $transport;

    my $email = Koha::Email->create(
        {
            from      => $from,
            to        => $to,
            subject   => 'Print notices for ' . $today_syspref,
            text_body => ' ',
        }
    );

    while ( my ( $type, $filenames ) = each %$files ) {
        for my $filename (@$filenames) {
            my $mimetype =
                  $type eq 'html' ? 'text/html'
                : $type eq 'csv'  ? 'text/csv'
                : $type eq 'ods'  ? 'application/vnd.oasis.opendocument.spreadsheet'
                :                   undef;

            next unless $mimetype;

            my $filepath = File::Spec->catfile( $directory, $filename );

            next unless $filepath or -f $filepath;

            $email->attach_file(
                $filepath,
                content_type => $mimetype,
                charset      => 'UTF-8',
                name         => $filename,
                disposition  => 'attachment',
            );
        }
    }

    $email->send_or_die( { transport => $transport } );

}

=head1 NAME

gather_print_notices - Print waiting print notices

=head1 SYNOPSIS

gather_print_notices output_directory [-s|--split] [--html] [--csv] [--ods] [--letter_code=LETTER_CODE] [-e|--email=your_email@example.org] [--help]

Will print all waiting print notices to the output_directory.

The generated filename will be notices-TODAY.[csv|html|ods] or notices-TODAY-BRANCHCODE.[csv|html|ods] if the --split parameter is given.

=head1 OPTIONS

=over

=item B<output_directory>

Define the output directory where the files will be generated.

=item B<--send|--nosend>

After files have been generated, messages status is changed from 'pending' to
'printed'. This is the default action, without this parameter or with --send.
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

=item B<--help>

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
along with Koha; if not, see <https://www.gnu.org/licenses>.

=cut
