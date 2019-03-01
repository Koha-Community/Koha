package t::Koha::Logger;

use Modern::Perl;

my $logfile = '/tmp/log4perl_test.log';

=head2 getLog4perlConfig

@returns {ScalarRef} Get the default and reasonable test config String

=cut

sub getLog4perlConfig {
    my $cfg = qq(
        layout_class   = Log::Log4perl::Layout::PatternLayout
        layout_pattern = [%c] [%d] [%p] %m %l %n

        log4perl.logger.intranet = WARN, INTRANET
        log4perl.appender.INTRANET=Log::Log4perl::Appender::File
        log4perl.appender.INTRANET.filename=$logfile
        log4perl.appender.INTRANET.mode=append
        log4perl.appender.INTRANET.layout=\${layout_class}
        log4perl.appender.INTRANET.layout.ConversionPattern=\${layout_pattern}

        log4perl.logger.opac = WARN, OPAC
        log4perl.appender.OPAC=Log::Log4perl::Appender::File
        log4perl.appender.OPAC.filename=$logfile
        log4perl.appender.OPAC.mode=append
        log4perl.appender.OPAC.layout=\${layout_class}
        log4perl.appender.OPAC.layout.ConversionPattern=\${layout_pattern}

        log4perl.logger.commandline = WARN, CLI
        log4perl.appender.CLI=Log::Log4perl::Appender::File
        log4perl.appender.CLI.filename=$logfile
        log4perl.appender.CLI.mode=append
        log4perl.appender.CLI.layout=\${layout_class}
        log4perl.appender.CLI.layout.ConversionPattern=\${layout_pattern}
    );
    return $cfg;
}


=head2 slurpLog

@param {Boolean} $asArrayRef, should we return an ArrayRef of log file lines or just the logfile contents as String?
@returns {ArrayRef of Strings or String}

=cut

sub slurpLog {
    my ($asArrayRef) = @_;
    open(my $FH, '<', $logfile) or die $!;
    my @log = <$FH>;
    close($FH);
    return \@log if $asArrayRef;
    return join("\n", @log);
}

=head2 getFirstLogRow

@returns {String}, first line in the log file

=cut

sub getFirstLogRow {
    open(my $FH, '<', $logfile) or die $!;
    my $firstRow = <$FH>;
    close($FH);
    return $firstRow;
}

=head2 clearLog

Empties the test log

=cut

sub clearLog {
    open(my $FH, '>', $logfile) or die $!;
    close($FH);
}

sub getLogfile {
    return $logfile;
}

1; #Satisfy insanity
