#!/usr/bin/env perl

use Modern::Perl;

use Test::More tests => 16;
use Template;

use C4::Context;

my $version = C4::Context->preference('Version');

my $template = Template->new({
    PLUGIN_BASE => 'Koha::Template::Plugin',
});

my $intranet_vars = {
    interface => '/intranet-tmpl',
    theme => 'prog',
};

my $opac_vars = {
    interface => '/opac-tmpl',
    theme => 'bootstrap',
};

my $output;

$output = '';
$template->process(url_template("js/staff-global.js"), $intranet_vars, \$output);
is($output, "/intranet-tmpl/prog/js/staff-global_$version.js");

$output = '';
$template->process(url_template("js/browser.js"), $intranet_vars, \$output);
is($output, "/intranet-tmpl/js/browser_$version.js");

$output = '';
$template->process(url_template("css/staff-global.css"), $intranet_vars, \$output);
is($output, "/intranet-tmpl/prog/css/staff-global_$version.css");

$output = '';
$template->process(url_template("lib/font-awesome/css/font-awesome.min.css"), $intranet_vars, \$output);
is($output, "/intranet-tmpl/lib/font-awesome/css/font-awesome.min_$version.css");

$output = '';
$template->process(url_template("js/global.js"), $opac_vars, \$output);
is($output, "/opac-tmpl/bootstrap/js/global_$version.js");

$output = '';
$template->process(url_template("lib/jquery/plugins/jquery.dataTables.min.js"), $opac_vars, \$output);
is($output, "/opac-tmpl/lib/jquery/plugins/jquery.dataTables.min_$version.js");

$output = '';
$template->process(url_template("css/opac.css"), $opac_vars, \$output);
is($output, "/opac-tmpl/bootstrap/css/opac_$version.css");

$output = '';
$template->process(url_template("lib/emoji-picker/css/emoji.css"), $opac_vars, \$output);
is($output, "/opac-tmpl/lib/emoji-picker/css/emoji_$version.css");

$output = '';
$template->process(css_template("css/opac.css"), $opac_vars, \$output);
like($output, qr/<link .*href="\/opac-tmpl\/bootstrap\/css\/opac_\Q$version\E\.css".*>/);
like($output, qr/<link .*type="text\/css".*>/);
like($output, qr/<link .*rel="stylesheet".*>/);

$output = '';
$template->process(\'[% USE Asset %][% Asset.css("css/print.css", { media = "print" }) %]', $opac_vars, \$output);
like($output, qr/<link .*href="\/opac-tmpl\/bootstrap\/css\/print_\Q$version\E\.css".*>/);
like($output, qr/<link .*type="text\/css".*>/);
like($output, qr/<link .*rel="stylesheet".*>/);
like($output, qr/<link .*media="print".*>/);

$output = '';
$template->process(js_template("js/global.js"), $opac_vars, \$output);
like($output, qr/<script .*src="\/opac-tmpl\/bootstrap\/js\/global_\Q$version\E\.js".*>/);

sub url_template {
    my ($filename) = @_;

    my $template = "[% USE Asset %][% Asset.url(\"$filename\") %]";

    return \$template;
}

sub css_template {
    my ($filename) = @_;

    my $template = "[% USE Asset %][% Asset.css(\"$filename\") %]";

    return \$template;
}

sub js_template {
    my ($filename) = @_;

    my $template = "[% USE Asset %][% Asset.js(\"$filename\") %]";

    return \$template;
}
