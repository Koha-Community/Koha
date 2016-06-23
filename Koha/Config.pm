package Koha::Config;

use Modern::Perl;
use XML::Simple;

# Default config file, if none is specified
use constant CONFIG_FNAME => "/etc/koha/koha-conf.xml";

# path to config file set by installer
# __KOHA_CONF_DIR__ is set by rewrite-confg.PL
# when Koha is installed in 'standard' or 'single'
# mode.  If Koha was installed in 'dev' mode,
# __KOHA_CONF_DIR__ is *not* rewritten; instead
# developers should set the KOHA_CONF environment variable
my $INSTALLED_CONFIG_FNAME = '__KOHA_CONF_DIR__/koha-conf.xml';

# Should not be called outside of C4::Context or Koha::Cache
# use C4::Context->config instead
sub read_from_file {
    my ( $class, $file ) = @_;
    return XMLin($file, keyattr => ['id'], forcearray => ['listen', 'server', 'serverinfo'], suppressempty => '');
}

# Koha's main configuration file koha-conf.xml
# is searched for according to this priority list:
#
# 1. Path supplied via use C4::Context '/path/to/koha-conf.xml'
# 2. Path supplied in KOHA_CONF environment variable.
# 3. Path supplied in INSTALLED_CONFIG_FNAME, as long
#    as value has changed from its default of
#    '__KOHA_CONF_DIR__/koha-conf.xml', as happens
#    when Koha is installed in 'standard' or 'single'
#    mode.
# 4. Path supplied in CONFIG_FNAME.
#
# The first entry that refers to a readable file is used.

sub guess_koha_conf {

    # If the $KOHA_CONF environment variable is set, use
    # that. Otherwise, use the built-in default.
    my $conf_fname;
    if ( exists $ENV{"KOHA_CONF"} and $ENV{'KOHA_CONF'} and -s $ENV{"KOHA_CONF"} ) {
        $conf_fname = $ENV{"KOHA_CONF"};
    } elsif ( $INSTALLED_CONFIG_FNAME !~ /__KOHA_CONF_DIR/ and -s $INSTALLED_CONFIG_FNAME ) {
        # NOTE: be careful -- don't change __KOHA_CONF_DIR in the above
        # regex to anything else -- don't want installer to rewrite it
        $conf_fname = $INSTALLED_CONFIG_FNAME;
    } elsif ( -s CONFIG_FNAME ) {
        $conf_fname = CONFIG_FNAME;
    }
    return $conf_fname;
}

1;
