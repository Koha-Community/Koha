#!/usr/bin/perl

# Copyright Pat Eyler 2003
# Copyright Biblibre 2006
# Parts Copyright Liblime 2008
# Parts Copyright Chris Nighswonger 2010
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

use CGI qw ( -utf8 );
use DateTime::TimeZone;
use File::Slurp qw( read_file );
use IPC::Cmd qw(can_run);
use List::MoreUtils qw( any );
use Module::Load::Conditional qw( can_load );
use Config qw( %Config );
use Search::Elasticsearch;
use Try::Tiny qw( catch try );
use YAML::XS;
use Encode;

use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user get_user_subpermissions );
use C4::Context;
use C4::Installer::PerlModules;

use Koha;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Acquisition::Currencies;
use Koha::Authorities;
use Koha::BackgroundJob;
use Koha::BiblioFrameworks;
use Koha::Biblios;
use Koha::Email;
use Koha::Patron::Categories;
use Koha::Patrons;
use Koha::Caches;
use Koha::Config::SysPrefs;
use Koha::Illrequest::Config;
use Koha::SearchEngine::Elasticsearch;
use Koha::Logger;
use Koha::Filter::MARC::ViewPolicy;

use C4::Members::Statistics;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "about.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
    }
);

my $config_timezone = C4::Context->config('timezone') // '';
my $config_invalid  = !DateTime::TimeZone->is_valid_name( $config_timezone );
my $env_timezone    = $ENV{TZ} // '';
my $env_invalid     = !DateTime::TimeZone->is_valid_name( $env_timezone );
my $actual_bad_tz_fallback = 0;

if ( $config_timezone ne '' &&
     $config_invalid ) {
    # Bad config
    $actual_bad_tz_fallback = 1;
}
elsif ( $config_timezone eq '' &&
        $env_timezone    ne '' &&
        $env_invalid ) {
    # No config, but bad ENV{TZ}
    $actual_bad_tz_fallback = 1;
}

my $time_zone = {
    actual                 => C4::Context->tz->name,
    actual_bad_tz_fallback => $actual_bad_tz_fallback,
    config                 => $config_timezone,
    config_invalid         => $config_invalid,
    environment            => $env_timezone,
    environment_invalid    => $env_invalid
};

{ # Logger checks
    my $log4perl_config = C4::Context->config("log4perl_conf");
    my @log4perl_errors;
    if ( ! $log4perl_config ) {
        push @log4perl_errors, 'missing_config_entry'
    }
    else {
        my @lines = read_file($log4perl_config) or push @log4perl_errors, 'cannot_read_config_file';
        for my $line ( @lines ) {
            next unless $line =~ m|log4perl.appender.\w+.filename=(.*)|;
            push @log4perl_errors, 'logfile_not_writable' unless -w $1;
        }
    }
    eval {Koha::Logger->get};
    push @log4perl_errors, 'cannot_init_module' and warn $@ if $@;
    $template->param( log4perl_errors => @log4perl_errors );
}

$template->param(
    time_zone              => $time_zone,
    current_date_and_time  => output_pref({ dt => dt_from_string(), dateformat => 'iso' })
);

my $perl_path = $^X;
if ($^O ne 'VMS') {
    $perl_path .= $Config{_exe} unless $perl_path =~ m/$Config{_exe}$/i;
}

my $zebraVersion = `zebraidx -V`;

# Check running PSGI env
if ( C4::Context->psgi_env ) {
    $template->param(
        is_psgi => 1,
        psgi_server => ($ENV{ PLACK_ENV }) ? "Plack ($ENV{PLACK_ENV})" :
                       ($ENV{ MOD_PERL })  ? "mod_perl ($ENV{MOD_PERL})" :
                                             'Unknown'
    );
}

# Memcached configuration
my $memcached_servers   = $ENV{MEMCACHED_SERVERS} || C4::Context->config('memcached_servers');
my $memcached_namespace = $ENV{MEMCACHED_NAMESPACE} || C4::Context->config('memcached_namespace') // 'koha';

my $cache = Koha::Caches->get_instance;
my $effective_caching_method = ref($cache->cache);
# Memcached may have been running when plack has been initialized but could have been stopped since
# FIXME What are the consequences of that??
my $is_memcached_still_active = $cache->set_in_cache('test_for_about_page', "just a simple value");

my $where_is_memcached_config = 'nowhere';
if ( $ENV{MEMCACHED_SERVERS} and C4::Context->config('memcached_servers') ) {
    $where_is_memcached_config = 'both';
} elsif ( $ENV{MEMCACHED_SERVERS} and not C4::Context->config('memcached_servers') ) {
    $where_is_memcached_config = 'ENV_only';
} elsif ( C4::Context->config('memcached_servers') ) {
    $where_is_memcached_config = 'config_only';
}

$template->param(
    effective_caching_method => $effective_caching_method,
    memcached_servers   => $memcached_servers,
    memcached_namespace => $memcached_namespace,
    is_memcached_still_active => $is_memcached_still_active,
    where_is_memcached_config => $where_is_memcached_config,
    memcached_running   => Koha::Caches->get_instance->memcached_cache,
);

# Additional system information for warnings

my $warnStatisticsFieldsError;
my $prefStatisticsFields = C4::Context->preference('StatisticsFields');
if ($prefStatisticsFields) {
    $warnStatisticsFieldsError = $prefStatisticsFields
        unless ( $prefStatisticsFields eq C4::Members::Statistics->get_fields() );
}

my $prefAutoCreateAuthorities = C4::Context->preference('AutoCreateAuthorities');
my $prefRequireChoosingExistingAuthority = C4::Context->preference('RequireChoosingExistingAuthority');
my $warnPrefRequireChoosingExistingAuthority = ( !$prefAutoCreateAuthorities && ( !$prefRequireChoosingExistingAuthority) );

my $prefEasyAnalyticalRecords  = C4::Context->preference('EasyAnalyticalRecords');
my $prefUseControlNumber  = C4::Context->preference('UseControlNumber');
my $warnPrefEasyAnalyticalRecords  = ( $prefEasyAnalyticalRecords  && $prefUseControlNumber );

my $AnonymousPatron = C4::Context->preference('AnonymousPatron');
my $warnPrefAnonymousPatronOPACPrivacy = (
    C4::Context->preference('OPACPrivacy')
        and not $AnonymousPatron
);
my $warnPrefAnonymousPatronAnonSuggestions = (
    C4::Context->preference('AnonSuggestions')
        and not $AnonymousPatron
);

my $anonymous_patron = Koha::Patrons->find( $AnonymousPatron );
my $warnPrefAnonymousPatronAnonSuggestions_PatronDoesNotExist = ( $AnonymousPatron && C4::Context->preference('AnonSuggestions') && not $anonymous_patron );

my $warnPrefAnonymousPatronOPACPrivacy_PatronDoesNotExist = ( not $anonymous_patron and Koha::Patrons->search({ privacy => 2 })->count );

my $warnPrefKohaAdminEmailAddress = !Koha::Email->is_valid(C4::Context->preference('KohaAdminEmailAddress'));

my $c = Koha::Items->filter_by_visible_in_opac->count;
my @warnings = C4::Context->dbh->selectrow_array('SHOW WARNINGS');
my $warnPrefOpacHiddenItems = $warnings[2];

my $invalid_yesno = Koha::Config::SysPrefs->search(
    {
        type  => 'YesNo',
        value => { -or => { 'is' => undef, -not_in => [ "1", "0" ] } }
    }
);
$template->param( invalid_yesno => $invalid_yesno );

my $errZebraConnection = C4::Context->Zconn("biblioserver",0)->errcode();

my $warnIsRootUser   = (! $loggedinuser);

my $warnNoActiveCurrency = (! defined Koha::Acquisition::Currencies->get_active);

my @xml_config_warnings;

if (    C4::Context->config('zebra_bib_index_mode')
    and C4::Context->config('zebra_bib_index_mode') eq 'grs1' )
{
    push @xml_config_warnings, { error => 'zebra_bib_index_mode_is_grs1' };
}

if (    C4::Context->config('zebra_auth_index_mode')
    and C4::Context->config('zebra_auth_index_mode') eq 'grs1' )
{
    push @xml_config_warnings, { error => 'zebra_auth_index_mode_is_grs1' };
}

my $authorityserver = C4::Context->zebraconfig('authorityserver');
if( (   C4::Context->config('zebra_auth_index_mode')
    and C4::Context->config('zebra_auth_index_mode') eq 'dom' )
    && ( $authorityserver->{config} !~ /zebra-authorities-dom.cfg/ ) )
{
    push @xml_config_warnings, {
        error => 'zebra_auth_index_mode_mismatch_warn'
    };
}

if ( ! defined C4::Context->config('log4perl_conf') ) {
    push @xml_config_warnings, {
        error => 'log4perl_entry_missing'
    }
}

if ( ! defined C4::Context->config('lockdir') ) {
    push @xml_config_warnings, {
        error => 'lockdir_entry_missing'
    }
}
else {
    unless ( -w C4::Context->config('lockdir') ) {
        push @xml_config_warnings, {
            error   => 'lockdir_not_writable',
            lockdir => C4::Context->config('lockdir')
        }
    }
}

if ( ! defined C4::Context->config('upload_path') ) {
    if ( Koha::Config::SysPrefs->find('OPACBaseURL')->value ) {
        # OPACBaseURL seems to be set
        push @xml_config_warnings, {
            error => 'uploadpath_entry_missing'
        }
    } else {
        push @xml_config_warnings, {
            error => 'uploadpath_and_opacbaseurl_entry_missing'
        }
    }
}

if ( ! C4::Context->config('tmp_path') ) {
    my $temporary_directory = C4::Context::temporary_directory;
    push @xml_config_warnings, {
        error             => 'tmp_path_missing',
        effective_tmp_dir => $temporary_directory,
    }
}

if( ! C4::Context->config('encryption_key') ) {
    push @xml_config_warnings, { error => 'encryption_key_missing' };
}

# Test Zebra facets configuration
if ( !defined C4::Context->config('use_zebra_facets') ) {
    push @xml_config_warnings, { error => 'use_zebra_facets_entry_missing' };
}

# ILL module checks
if ( C4::Context->preference('ILLModule') ) {
    my $warnILLConfiguration = 0;
    my $ill_config_from_file = C4::Context->config("interlibrary_loans");
    my $ill_config = Koha::Illrequest::Config->new;

    my $available_ill_backends =
      ( scalar @{ $ill_config->available_backends } > 0 );

    # Check backends
    if ( !$available_ill_backends ) {
        $template->param( no_ill_backends => 1 );
        $warnILLConfiguration = 1;
    }

    # Check partner_code
    if ( !Koha::Patron::Categories->find($ill_config->partner_code) ) {
        $template->param( ill_partner_code_doesnt_exist => $ill_config->partner_code );
        $warnILLConfiguration = 1;
    }

    if ( !$ill_config_from_file->{partner_code} ) {
        # partner code not defined
        $template->param( ill_partner_code_not_defined => 1 );
        $warnILLConfiguration = 1;
    }


    if ( !$ill_config_from_file->{branch} ) {
        # branch not defined
        $template->param( ill_branch_not_defined => 1 );
        $warnILLConfiguration = 1;
    }

    $template->param( warnILLConfiguration => $warnILLConfiguration );
}
unless ( can_run('weasyprint') ) {
    $template->param( weasyprint_missing => 1 );
}

{
    # XSLT sysprefs
    my @xslt_prefs = qw(
        OPACXSLTDetailsDisplay
        OPACXSLTListsDisplay
        OPACXSLTResultsDisplay
        XSLTDetailsDisplay
        XSLTListsDisplay
        XSLTResultsDisplay
    );
    my @warnXSLT;
    for my $p ( @xslt_prefs ) {
        my $xsl_filename = C4::XSLT::get_xsl_filename( $p );
        next if -e $xsl_filename;
        push @warnXSLT,
          {
            syspref  => $p,
            value    => C4::Context->preference("$p"),
            filename => $xsl_filename
          };
    }

    $template->param( warnXSLT => \@warnXSLT ) if @warnXSLT;
}

if ( C4::Context->preference('SearchEngine') eq 'Elasticsearch' ) {
    # Check ES configuration health and runtime status

    my $es_status;
    my $es_config_error;
    my $es_running = 1;
    my $es_has_missing = 0;

    my $es_conf;
    try {
        $es_conf = Koha::SearchEngine::Elasticsearch::_read_configuration();
    }
    catch {
        if ( ref($_) eq 'Koha::Exceptions::Config::MissingEntry' ) {
            $template->param( elasticsearch_fatal_config_error => $_->message );
            $es_config_error = 1;
        }
    };
    if ( !$es_config_error ) {

        my $biblios_index_name     = $es_conf->{index_name} . "_" . $Koha::SearchEngine::BIBLIOS_INDEX;
        my $authorities_index_name = $es_conf->{index_name} . "_" . $Koha::SearchEngine::AUTHORITIES_INDEX;

        my @indexes = ($biblios_index_name, $authorities_index_name);
        # TODO: When new indexes get added, we could have other ways to
        #       fetch the list of available indexes (e.g. plugins, etc)
        $es_status->{nodes} = $es_conf->{nodes};
        my $es = Search::Elasticsearch->new({ nodes => $es_conf->{nodes} });
        my $es_status->{version} = $es->info->{version}->{number};

        foreach my $index ( @indexes ) {
            my $index_count;
            try {
                $index_count = $es->indices->stats( index => $index )
                      ->{_all}{primaries}{docs}{count};
            }
            catch {
                if ( ref($_) eq 'Search::Elasticsearch::Error::Missing' ) {
                    push @{ $es_status->{errors} }, "Index not found ($index)";
                    $index_count = -1;
                }
                elsif ( ref($_) eq 'Search::Elasticsearch::Error::NoNodes' ) {
                    $es_running = 0;
                }
                else {
                    # TODO: when time comes, we will cover more use cases
                    die $_;
                }
            };

            my $db_count = -1;
            my $missing_count = 0;
            if ( $index eq $biblios_index_name ) {
                $db_count = Koha::Biblios->search->count;
            } elsif ( $index eq $authorities_index_name ) {
                $db_count = Koha::Authorities->search->count;
            }
            if ( $db_count != -1 && $index_count != -1 ) {
                $missing_count = $db_count - $index_count;
                $es_has_missing = 1 if $missing_count > 0;
            }
            push @{ $es_status->{indexes} },
              {
                index_name    => $index,
                index_count   => $index_count,
                db_count      => $db_count,
                missing_count => $missing_count,
              };
        }
        $es_status->{running} = $es_running;

        $template->param(
            elasticsearch_status      => $es_status,
            elasticsearch_has_missing => $es_has_missing,
        );
    }
}

if ( C4::Context->preference('RESTOAuth2ClientCredentials') ) {
    # Do we have the required deps?
    unless ( can_load( modules => { 'Net::OAuth2::AuthorizationServer' => undef }) ) {
        $template->param( oauth2_missing_deps => 1 );
    }
}

# Sco Patron should not contain any other perms than circulate => self_checkout
if (  C4::Context->preference('WebBasedSelfCheck')
      and C4::Context->preference('AutoSelfCheckAllowed')
) {
    my $userid = C4::Context->preference('AutoSelfCheckID');
    my $all_permissions = C4::Auth::get_user_subpermissions( $userid );
    my ( $has_self_checkout_perm, $has_other_permissions );
    while ( my ( $module, $permissions ) = each %$all_permissions ) {
        if ( $module eq 'self_check' ) {
            while ( my ( $permission, $flag ) = each %$permissions ) {
                if ( $permission eq 'self_checkout_module' ) {
                    $has_self_checkout_perm = 1;
                } else {
                    $has_other_permissions = 1;
                }
            }
        } else {
            $has_other_permissions = 1;
        }
    }
    $template->param(
        AutoSelfCheckPatronDoesNotHaveSelfCheckPerm => not ( $has_self_checkout_perm ),
        AutoSelfCheckPatronHasTooManyPerm => $has_other_permissions,
    );
}

# Test YAML system preferences
# FIXME: This is list of current YAML formatted prefs, should by type of preference
my @yaml_prefs = (
    "UpdateNotForLoanStatusOnCheckin",
    "OpacHiddenItems",
    "BibtexExportAdditionalFields",
    "RisExportAdditionalFields",
    "UpdateItemWhenLostFromHoldList",
    "MarcFieldsToOrder",
    "MarcItemFieldsToOrder",
    "UpdateitemLocationOnCheckin",
    "ItemsDeniedRenewal"
);
my @bad_yaml_prefs;
foreach my $syspref (@yaml_prefs) {
    my $yaml = C4::Context->preference( $syspref );
    if ( $yaml ) {
        eval { YAML::XS::Load( Encode::encode_utf8("$yaml\n\n") ); };
        if ($@) {
            push @bad_yaml_prefs, $syspref;
        }
    }
}
$template->param( 'bad_yaml_prefs' => \@bad_yaml_prefs ) if @bad_yaml_prefs;

{
    my $dbh       = C4::Context->dbh;
    my $patrons = $dbh->selectall_arrayref(
        q|select b.borrowernumber from borrowers b join deletedborrowers db on b.borrowernumber=db.borrowernumber|,
        { Slice => {} }
    );
    my $biblios = $dbh->selectall_arrayref(
        q|select b.biblionumber from biblio b join deletedbiblio db on b.biblionumber=db.biblionumber|,
        { Slice => {} }
    );
    my $items = $dbh->selectall_arrayref(
        q|select i.itemnumber from items i join deleteditems di on i.itemnumber=di.itemnumber|,
        { Slice => {} }
    );
    my $checkouts = $dbh->selectall_arrayref(
        q|select i.issue_id from issues i join old_issues oi on i.issue_id=oi.issue_id|,
        { Slice => {} }
    );
    my $holds = $dbh->selectall_arrayref(
        q|select r.reserve_id from reserves r join old_reserves o on r.reserve_id=o.reserve_id|,
        { Slice => {} }
    );
    if ( @$patrons or @$biblios or @$items or @$checkouts or @$holds ) {
        $template->param(
            has_ai_issues => 1,
            ai_patrons    => $patrons,
            ai_biblios    => $biblios,
            ai_items      => $items,
            ai_checkouts  => $checkouts,
            ai_holds      => $holds,
        );
    }
}

# Circ rule warnings
{
    my $dbh   = C4::Context->dbh;
    my $units = Koha::CirculationRules->search({ rule_name => 'lengthunit', rule_value => { -not_in => ['days', 'hours'] } });

    if ( $units->count ) {
        $template->param(
            warnIssuingRules => 1,
            ir_units         => $units,
        );
    }
}

# Guarantor relationships warnings
{
    my $dbh   = C4::Context->dbh;
    my ($bad_relationships_count) = $dbh->selectall_arrayref(q{
        SELECT COUNT(*)
        FROM (
            SELECT relationship FROM borrower_relationships WHERE relationship='_bad_data'
            UNION ALL
            SELECT relationship FROM borrowers WHERE relationship='_bad_data') a
    });

    $bad_relationships_count = $bad_relationships_count->[0]->[0];

    my $existing_relationships = $dbh->selectall_arrayref(q{
          SELECT DISTINCT(relationship)
          FROM (
              SELECT relationship FROM borrower_relationships WHERE relationship IS NOT NULL
              UNION ALL
              SELECT relationship FROM borrowers WHERE relationship IS NOT NULL) a
    });

    my %valid_relationships = map { $_ => 1 } split( /,|\|/, C4::Context->preference('borrowerRelationship') );
    $valid_relationships{ _bad_data } = 1; # we handle this case in another way

    my $wrong_relationships = [ grep { !$valid_relationships{ $_->[0] } } @{$existing_relationships} ];
    if ( @$wrong_relationships or $bad_relationships_count ) {

        $template->param(
            warnRelationships => 1,
        );

        if ( $wrong_relationships ) {
            $template->param(
                wrong_relationships => $wrong_relationships
            );
        }
        if ($bad_relationships_count) {
            $template->param(
                bad_relationships_count => $bad_relationships_count,
            );
        }
    }
}

{
    # Test 'bcrypt_settings' config for Pseudonymization
    $template->param( config_bcrypt_settings_no_set => 1 )
      if C4::Context->preference('Pseudonymization')
      and not C4::Context->config('bcrypt_settings');
}

{
    my @frameworkcodes = Koha::BiblioFrameworks->search->get_column('frameworkcode');
    my @hidden_biblionumbers;
    push @frameworkcodes, ""; # it's not in the biblio_frameworks table!
    my $no_FA_framework = 1;
    for my $frameworkcode ( @frameworkcodes ) {
        $no_FA_framework = 0 if $frameworkcode eq 'FA';
        my $shouldhidemarc_opac = Koha::Filter::MARC::ViewPolicy->should_hide_marc(
            {
                frameworkcode => $frameworkcode,
                interface     => "opac"
            }
        );
        push @hidden_biblionumbers, { frameworkcode => $frameworkcode, interface => 'opac' }
          if $shouldhidemarc_opac->{biblionumber};

        my $shouldhidemarc_intranet = Koha::Filter::MARC::ViewPolicy->should_hide_marc(
            {
                frameworkcode => $frameworkcode,
                interface     => "intranet"
            }
        );
        push @hidden_biblionumbers, { frameworkcode => $frameworkcode, interface => 'intranet' }
          if $shouldhidemarc_intranet->{biblionumber};
    }
    $template->param( warnHiddenBiblionumbers => \@hidden_biblionumbers );
    $template->param( warnFastCataloging => $no_FA_framework );
}

{
    # BackgroundJob - test connection to message broker
    eval {
        Koha::BackgroundJob->connect;
    };
    if ( $@ ) {
        warn $@;
        $template->param( warnConnectBroker => $@ );
    }
}

my %versions = C4::Context::get_versions();

$template->param(
    kohaVersion   => $versions{'kohaVersion'},
    osVersion     => $versions{'osVersion'},
    perlPath      => $perl_path,
    perlVersion   => $versions{'perlVersion'},
    perlIncPath   => [ map { perlinc => $_ }, @INC ],
    mysqlVersion  => $versions{'mysqlVersion'},
    apacheVersion => $versions{'apacheVersion'},
    zebraVersion  => $zebraVersion,
    prefRequireChoosingExistingAuthority => $prefRequireChoosingExistingAuthority,
    prefAutoCreateAuthorities => $prefAutoCreateAuthorities,
    warnPrefRequireChoosingExistingAuthority => $warnPrefRequireChoosingExistingAuthority,
    warnPrefEasyAnalyticalRecords  => $warnPrefEasyAnalyticalRecords,
    warnPrefAnonymousPatronOPACPrivacy        => $warnPrefAnonymousPatronOPACPrivacy,
    warnPrefAnonymousPatronAnonSuggestions    => $warnPrefAnonymousPatronAnonSuggestions,
    warnPrefAnonymousPatronOPACPrivacy_PatronDoesNotExist     => $warnPrefAnonymousPatronOPACPrivacy_PatronDoesNotExist,
    warnPrefAnonymousPatronAnonSuggestions_PatronDoesNotExist => $warnPrefAnonymousPatronAnonSuggestions_PatronDoesNotExist,
    warnPrefKohaAdminEmailAddress => $warnPrefKohaAdminEmailAddress,
    warnPrefOpacHiddenItems => $warnPrefOpacHiddenItems,
    errZebraConnection => $errZebraConnection,
    warnIsRootUser => $warnIsRootUser,
    warnNoActiveCurrency => $warnNoActiveCurrency,
    warnNoTemplateCaching => ( C4::Context->config('template_cache_dir') ? 0 : 1 ),
    xml_config_warnings => \@xml_config_warnings,
    warnStatisticsFieldsError => $warnStatisticsFieldsError,
);

my @components = ();

my $perl_modules = C4::Installer::PerlModules->new;
$perl_modules->versions_info;

my @pm_types = qw(missing_pm upgrade_pm current_pm);

foreach my $pm_type(@pm_types) {
    my $modules = $perl_modules->get_attr($pm_type);
    foreach (@$modules) {
        my ($module, $stats) = each %$_;
        push(
            @components,
            {
                name    => $module,
                version => $stats->{'cur_ver'},
                missing => ($pm_type eq 'missing_pm' ? 1 : 0),
                upgrade => ($pm_type eq 'upgrade_pm' ? 1 : 0),
                current => ($pm_type eq 'current_pm' ? 1 : 0),
                require => $stats->{'required'},
                reqversion => $stats->{'min_ver'},
                maxversion => $stats->{'max_ver'},
                excversion => $stats->{'exc_ver'}
            }
        );
    }
}

@components = sort {$a->{'name'} cmp $b->{'name'}} @components;

my $counter=0;
my $row = [];
my $table = [];
foreach (@components) {
    push (@$row, $_);
    unless (++$counter % 4) {
        push (@$table, {row => $row});
        $row = [];
    }
}
# Processing the last line (if there are any modules left)
if (scalar(@$row) > 0) {
    # Extending $row to the table size
    $$row[3] = '';
    # Pushing the last line
    push (@$table, {row => $row});
}
## ## $table

$template->param( table => $table );


## ------------------------------------------
## Koha contributions
my $docdir;
if ( defined C4::Context->config('docdir') ) {
    $docdir = C4::Context->config('docdir');
} else {
    # if no <docdir> is defined in koha-conf.xml, use the default location
    # this is a work-around to stop breakage on upgraded Kohas, bug 8911
    $docdir = C4::Context->config('intranetdir') . '/docs';
}

## Release teams
my $teams =
  -e "$docdir" . "/teams.yaml"
  ? YAML::XS::LoadFile( "$docdir" . "/teams.yaml" )
  : {};
my $dev_team = (sort {$b <=> $a} (keys %{$teams->{team}}))[0];
my $short_version = substr($versions{'kohaVersion'},0,5);
my $minor = substr($versions{'kohaVersion'},3,2);
my $development_version = ( $minor eq '05' || $minor eq '11' ) ? 0 : 1;
my $codename;
$template->param( short_version => $short_version );
$template->param( development_version => $development_version );

## Contributors
my $contributors =
  -e "$docdir" . "/contributors.yaml"
  ? YAML::XS::LoadFile( "$docdir" . "/contributors.yaml" )
  : {};
delete $contributors->{_others_};
for my $version ( sort { $a <=> $b } keys %{$teams->{team}} ) {
    for my $role ( keys %{ $teams->{team}->{$version} } ) {
        my $normalized_role = "$role";
        $normalized_role =~ s/s$//;
        if ( ref( $teams->{team}->{$version}->{$role} ) eq 'ARRAY' ) {
            for my $contributor ( @{ $teams->{team}->{$version}->{$role} } ) {
                my $name = $contributor->{name};
                # Add role to contributors
                push @{ $contributors->{$name}->{roles}->{$normalized_role} },
                  $version;
                # Add openhub to teams
                if ( exists( $contributors->{$name}->{openhub} ) ) {
                    $contributor->{openhub} = $contributors->{$name}->{openhub};
                }
            }
        }
        elsif ( $role eq 'release_date' ) {
            $teams->{team}->{$version}->{$role} = DateTime->from_epoch( epoch => $teams->{team}->{$version}->{$role});
        }
        elsif ( $role eq 'codename' ) {
            if ( $version == $short_version ) {
                $codename = $teams->{team}->{$version}->{$role};
            }
            next;
        }
        else {
            my $name = $teams->{team}->{$version}->{$role}->{name};
            # Add role to contributors
            push @{ $contributors->{$name}->{roles}->{$normalized_role} },
              $version;
            # Add openhub to teams
            if ( exists( $contributors->{$name}->{openhub} ) ) {
                $teams->{team}->{$version}->{$role}->{openhub} =
                  $contributors->{$name}->{openhub};
            }
        }
    }
}

## Create last name ordered array of people from contributors
my @people = map {
    { name => $_, ( $contributors->{$_} ? %{ $contributors->{$_} } : () ) }
} sort {
  my ($alast) = $a =~ /(\S+)$/;
  my ($blast) = $b =~ /(\S+)$/;
  my $cmp = lc($alast||"") cmp lc($blast||"");
  return $cmp if $cmp;

  my ($a2last) = $a =~ /(\S+)\s\S+$/;
  my ($b2last) = $b =~ /(\S+)\s\S+$/;
  lc($a2last||"") cmp lc($b2last||"");
} keys %$contributors;

$template->param( kohaCodename  => $codename);
$template->param( contributors => \@people );
$template->param( maintenance_team => $teams->{team}->{$dev_team} );
$template->param( release_team => $teams->{team}->{$short_version} );

## Timeline
if ( open( my $file, "<:encoding(UTF-8)", "$docdir" . "/history.txt" ) ) {

    my $i = 0;

    my @rows2 = ();
    my $row2  = [];

    my @lines = <$file>;
    close($file);

    shift @lines; #remove header row

    foreach (@lines) {
        my ( $epoch, $date, $desc, $tag ) = split(/\t/);
        if(!$desc && $date=~ /(?<=\d{4})\s+/) {
            ($date, $desc)= ($`, $');
        }
        push(
            @rows2,
            {
                date => $date,
                desc => $desc,
            }
        );
    }

    my $table2 = [];
    #foreach my $row2 (@rows2) {
    foreach  (@rows2) {
        push (@$row2, $_);
        push( @$table2, { row2 => $row2 } );
        $row2 = [];
    }

    $template->param( table2 => $table2 );
} else {
    $template->param( timeline_read_error => 1 );
}

output_html_with_http_headers $query, $cookie, $template->output;
