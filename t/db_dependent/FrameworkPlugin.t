use Modern::Perl;

use CGI;
use File::Temp qw/tempfile/;
use Getopt::Long;
use Test::MockModule;
use Test::More tests => 5;

use t::lib::TestBuilder;

use C4::Auth;
use C4::Output;
use Koha::Database;
use Koha::FrameworkPlugin;

our @includes;
GetOptions( 'include=s{,}' => \@includes ); #not used by default !

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $dbh = C4::Context->dbh;
our $builder = t::lib::TestBuilder->new;

subtest 'Test01 -- Simple tests for new and name' => sub {
    plan tests => 7;
    test01();
};
subtest 'Test02 -- test build with old styler and marc21_leader' => sub {
    plan tests => 5;
    test02();
};
subtest 'Test03 -- tests with bad plugins' => sub {
    test03();
};
subtest 'Test04 -- tests with new style plugin' => sub {
    plan tests => 5;
    test04();
};
subtest 'Test05 -- tests with build and launch for default plugins' => sub {
    test05( \@includes );
};
$schema->storage->txn_rollback;

sub test01 {
    #empty plugin
    my $plugin= Koha::FrameworkPlugin->new;
    is( ref($plugin), 'Koha::FrameworkPlugin', 'Got an object' );
    isnt( $plugin->errstr, undef, 'We should have an error for missing name');
    is( $plugin->build, undef, 'Build returns undef');

    #tests for name and path, with/without hashref
    $plugin= Koha::FrameworkPlugin->new( { name => 'marc21_leader.pl' } );
    is( $plugin->name, 'marc21_leader.pl', 'Check name without path in hash' );
    $plugin= Koha::FrameworkPlugin->new( 'marc21_leader.pl' );
    is( $plugin->name, 'marc21_leader.pl', 'Check name without path' );
    $plugin= Koha::FrameworkPlugin->new( 'cataloguing/value_builder/marc21_leader.pl' );
    is( $plugin->name, 'marc21_leader.pl', 'Check name with path' );
    $plugin= Koha::FrameworkPlugin->new({ path => 'cataloguing/value_builder', name => 'marc21_leader.pl' });
    is( $plugin->name, 'marc21_leader.pl', 'Check name and path in hash' );
}

sub test02 {
    # first test an old style item plugin
    my $old = old01(); # plugin filename
    my $path;
    if( $old =~ /^(.*)\/([^\/]+)$/ ) { # extract path
        $path = $1;
        $old = $2;
    }
    my $plugin= Koha::FrameworkPlugin->new({
        name => $old, path => $path, item_style => 1,
    });
    my $pars= { id => '234567' };
    is( $plugin->build($pars), 1, 'Build oldstyler successful' );
    is( length($plugin->javascript)>0 && !$plugin->noclick, 1,
        'Checked javascript and noclick' );

    # now test marc21_leader
    $plugin= Koha::FrameworkPlugin->new( { name => 'marc21_leader.pl' } );
    $pars= { dbh => $dbh, id => '123456' };
    is( $plugin->build($pars), 1, 'Build marc21_leader successful' );
    is( $plugin->javascript =~ /<script.*function.*\<\/script\>/s, 1,
        'Javascript looks ok' );
    is( $plugin->noclick, '', 'marc21_leader should have a popup');
}

sub test03 {
    #file not found
    my $plugin= Koha::FrameworkPlugin->new('file_does_not_exist');
    $plugin->build;
    is( $plugin->errstr =~ /not found/i, 1, 'File not found-message');

    #three bad ones: no perl, syntax error, bad return value
    foreach my $f ( bad01(), bad02(), bad03() ) {
        next if !$f;
        $plugin= Koha::FrameworkPlugin->new( $f );
        $plugin->build({ id => '998877' });
        is( defined($plugin->errstr), 1,
            "Saw: ". ( $plugin->errstr//'no error??' ));
    }
    done_testing();
}

sub test04 {
    #two simple new style plugins
    my $plugin= Koha::FrameworkPlugin->new( good01() );
    my $pars= { id => 'example_345' };
    is( $plugin->build($pars), 1, 'Build 1 ok');
    isnt( $plugin->javascript, '', 'Checked javascript property' );

    $plugin= Koha::FrameworkPlugin->new( ugly01() );
    $pars= { id => 'example_456' };
    is( $plugin->build($pars), 1, 'Build 2 ok');
    is( $plugin->build($pars), 1, 'Second build 2 ok');
    is( $plugin->launch($pars), 'abc', 'Launcher returned something' );
        #note: normally you will not call build and launch like that
}

sub test05 {
    my ( $incl ) = @_;
    #mock to simulate some authorization and eliminate lots of output
    my $launched = 0;
    my $mContext = new Test::MockModule('C4::Context');
    my $mAuth = new Test::MockModule('C4::Auth');
    my $mOutput = new Test::MockModule('C4::Output');
    $mContext->mock( 'userenv', \&mock_userenv );
    $mAuth->mock( 'checkauth', sub { return ( 1, undef, 1, all_perms() ); } );
    $mOutput->mock('output_html_with_http_headers',  sub { ++$launched; } );

    my $cgi=new CGI;
    my ( $plugins, $min ) = selected_plugins( $incl );

    # test building them
    my $objs;
    foreach my $f ( @$plugins ) {
        $objs->{$f} = Koha::FrameworkPlugin->new( $f );
        my $pars= { dbh => $dbh, id => $f };
        is( $objs->{$f}->build($pars), 1, "Builded ".$objs->{$f}->name );
    }

    # test launching them (but we cannot verify returned results here)
    undef $objs;
    foreach my $f ( @$plugins ) {
        $objs->{$f} = Koha::FrameworkPlugin->new( $f );
        my $pars= { dbh => $dbh, id => $f };
        $objs->{$f}->launch({ cgi => $cgi });
            # may generate some uninitialized warnings for missing params
        is( $objs->{$f}->errstr, undef, "Launched ".$objs->{$f}->name );
    }
    is( $launched >= $min, 1,
            "$launched of ". scalar @$plugins.' plugins generated output ');
    done_testing();
}

sub selected_plugins {
    my ( $incl ) = @_;
    #if you use includes, FIRST assure yourself that you do not
    #include any destructive perl scripts! You know what you are doing..

    my ( @fi, $min);
    if( $incl && @$incl ) {
        @fi = @$incl;
        $min = 0; #not sure how many will output
    } else { # some default MARC, UNIMARC and item plugins
        @fi = qw| barcode.pl dateaccessioned.pl marc21_orgcode.pl
marc21_field_005.pl marc21_field_006.pl marc21_field_007.pl marc21_field_008.pl
marc21_field_008_authorities.pl marc21_leader.pl marc21_leader_authorities.pl
unimarc_leader.pl unimarc_field_100.pl unimarc_field_105.pl
unimarc_field_106.pl unimarc_field_110.pl unimarc_field_120.pl
unimarc_field_130.pl unimarc_field_140.pl unimarc_field_225a.pl
unimarc_field_4XX.pl |;
        $min = 16; # the first four generate no output
    }
    @fi = grep
        { !/ajax|callnumber(-KU)?\.pl|labs_theses/ } # skip these
        @fi;
    return ( \@fi, $min);
}

sub mock_userenv {
    my $branch = $builder->build({ source => 'Branch' });
    return { branch => $branch->{branchcode}, flags => 1, id => 1 };
}

sub all_perms {
    my $p = $dbh->selectcol_arrayref("SELECT flag FROM userflags");
    my $rv= {};
    foreach my $module ( @$p ) {
        $rv->{ $module } = 1;
    }
    return $rv;
}

sub mytempfile {
    my ( $fh, $fn ) = tempfile( SUFFIX => '.plugin', UNLINK => 1 );
    print $fh $_[0]//'';
    close $fh;
    return $fn;
}

sub old01 {
# simple old style item plugin: note that Focus has two pars
# includes a typical empty Clic function and plugin subroutine
    return mytempfile( <<'HERE'
sub plugin_javascript {
    my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
    my $function_name = $field_number;
    my $res = "
<script type=\"text/javascript\">
//<![CDATA[
function Focus$function_name(subfield_managed,id) {
    document.getElementById(id).value='test';
    return 0;
}
function Clic$function_name(subfield_managed) {
}
//]]>
</script>
";
    return ($function_name,$res);
}
sub plugin {
    return "";
}
HERE
    );
}

sub good01 { #very simple new style plugin, no launcher
    return mytempfile( <<'HERE'
my $builder = sub {
    my $params = shift;
    return qq|
<script type="text/javascript">
    function Focus$params->{id}(event) {
        if( document.getElementById(event.data.id).value == '' ) {
            document.getElementById(event.data.id).value='EXAMPLE: ';
        }
    }
</script>|;
};
return { builder => $builder };
HERE
    );
}

sub bad01 { # this is no plugin
    return mytempfile( 'Just nonsense' );
}

sub bad02 { # common syntax error: you forgot the semicolon of sub1 declare
    return mytempfile( <<'HERE'
my $sub1= sub {
    my $params = shift;
    return qq|<script type="text/javascript">function Change$params->{id}(event) { alert("Changed"); }</script>|;
}
return { builder => $sub1 };
HERE
    );
}

sub bad03 { # badscript tag should trigger an error
    return mytempfile( <<'HERE'
my $sub1= sub {
    my $params = shift;
    return qq|<badscript type="text/javascript">function Click$params->{id} (event) { alert("Hi there"); return false; }</badscript>|;
};
return { builder => $sub1 };
HERE
    );
}

sub ugly01 { #works, but not very readable..
    return mytempfile( <<'HERE'
return {builder=>sub{return qq|<script type="text/javascript">function Blur$_[0]->{id}(event){alert('Bye');}</script>|;},launcher=>sub{'abc'}};
HERE
    );
}
