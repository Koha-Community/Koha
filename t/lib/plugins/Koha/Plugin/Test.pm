package Koha::Plugin::Test;

## It's good practice to use Modern::Perl
use Modern::Perl;

use Koha::Exception;
use Koha::Plugins::Tab;

use MARC::Field;
use Mojo::JSON qw( decode_json );

use t::lib::TestBuilder;

## Required for all plugins
use base qw(Koha::Plugins::Base);

our $VERSION  = "v1.01";
our $metadata = {
    name            => 'Test Plugin',
    author          => 'Kyle M Hall',
    description     => 'Test plugin',
    date_authored   => '2013-01-14',
    date_updated    => '2013-01-14',
    minimum_version => '3.11',
    maximum_version => undef,
    version         => $VERSION,
    namespace       => 'test',
    my_example_tag  => 'find_me',
};

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);
    return $self;
}

sub report {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::report";
}

sub tool {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::tool";
}

sub to_marc {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::to_marc";
}

sub intranet_catalog_biblio_enhancements_toolbar_button {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::intranet_catalog_biblio_enhancements_toolbar_button";
}

sub intranet_catalog_biblio_enhancements {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::intranet_catalog_biblio_enhancements";
}

sub opac_online_payment {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_online_payment";
}

sub opac_online_payment_begin {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_online_payment_begin";
}

sub opac_online_payment_end {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_online_payment_end";
}

sub opac_head {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_head";
}

sub opac_js {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_js";
}

sub intranet_head {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::intranet_head";
}

sub intranet_js {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::intranet_js";
}

sub item_barcode_transform {
    my ( $self, $barcode ) = @_;
    my $param = $$barcode;
    if ( Scalar::Util::looks_like_number($$barcode) ) {
        $$barcode = $$barcode * 2;
    }
    Koha::Exception->throw("item_barcode_transform called with parameter: $param");
}

sub patron_barcode_transform {
    my ( $self, $barcode ) = @_;
    $$barcode //= '';
    Koha::Exception->throw("patron_barcode_transform called with parameter: $$barcode");
}

sub configure {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::configure";
}

sub install {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::install";
}

sub upgrade {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::upgrade";
}

sub uninstall {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::uninstall";
}

sub test_output {
    my ($self) = @_;
    $self->output( '¡Hola output!', 'json' );
}

sub test_output_html {
    my ($self) = @_;
    $self->output_html('¡Hola output_html!');
}

sub api_namespace {
    return "testplugin";
}

sub after_hold_create {
    my ( $self, $param ) = @_;
    Koha::Exception->throw( "after_hold_create called with parameter " . ref($param) );
}

sub before_send_messages {
    my ( $self, $param ) = @_;
    Koha::Exception->throw("before_send_messages called");
}

sub notices_content {
    my ( $self, $params ) = @_;
    return {
        custom_attribute => {
            module  => $params->{module},
            message => 'notices_content() called',
        },
    };
}

sub before_biblio_action {
    my ( $self, $params ) = @_;

    my $action   = $params->{action} // '';
    my $payload  = $params->{payload};
    my $bibli_id = $payload->{biblio_id};
    my $record   = $payload->{record};

    $record->insert_fields_ordered(
        MARC::Field->new(
            '990', '', '',
            'a' => 'Arte club'
        )
    );

    return $record;
}

sub after_biblio_action {
    my ( $self, $params ) = @_;
    my $action    = $params->{action} // '';
    my $payload   = $params->{payload};
    my $biblio    = $payload->{biblio};
    my $biblio_id = $payload->{biblio_id};

    if ( $action ne 'delete' ) {
        Koha::Exception->throw( "after_biblio_action called with action: $action, ref: " . ref($biblio) );
    } else {
        Koha::Exception->throw("after_biblio_action called with action: $action, id: $biblio_id") if $biblio_id;
    }
}

sub after_item_action {
    my ( $self, $params ) = @_;
    my $action  = $params->{action} // '';
    my $item    = $params->{item};
    my $item_id = $params->{item_id};

    if ( $action ne 'delete' ) {
        my $itemnumber_defined = ( defined $item->itemnumber ) ? 'yes' : 'no';
        my $item_id_defined    = ( defined $item_id )          ? 'yes' : 'no';
        Koha::Exception->throw( "after_item_action called with action: $action, ref: "
                . ref($item) . " "
                . "item_id defined: $item_id_defined "
                . "itemnumber defined: $itemnumber_defined" );
    } else {
        Koha::Exception->throw("after_item_action called with action: $action, id: $item_id") if $item_id;
    }
}

sub after_authority_action {
    my ( $self, $params ) = @_;
    my $action = $params->{action}       // q{};
    my $id     = $params->{authority_id} // 0;
    Koha::Exception->throw("after_authority_action called with action: $action, id: $id");
}

sub after_circ_action {
    my ( $self, $params ) = @_;

    my $action   = $params->{action};
    my $checkout = $params->{payload}->{checkout};
    my $payload  = $params->{payload};

    my $type = $payload->{type};

    if ( $action eq 'renewal' ) {
        Koha::Exception->throw( "after_circ_action called with action: $action, ref: " . ref($checkout) );
    } elsif ( $action eq 'checkout' ) {
        Koha::Exception->throw(
            "after_circ_action called with action: $action, ref: " . ref($checkout) . " type: $type" );
    } elsif ( $action eq 'checkin' ) {
        Koha::Exception->throw( "after_circ_action called with action: $action, ref: " . ref($checkout) );
    }
}

sub after_hold_action {
    my ( $self, $params ) = @_;

    my $action = $params->{action};
    my $hold   = $params->{payload}->{hold};

    Koha::Exception->throw( "after_hold_action called with action: $action, ref: " . ref($hold) );
}

sub api_routes {
    my ( $self, $args ) = @_;

    my $spec = qq{
{
  "/patrons/bother": {
    "get": {
      "x-mojo-to": "Test::Controller#bother",
      "operationId": "BotherPatron",
      "tags": ["patrons"],
      "produces": [
        "application/json"
      ],
      "responses": {
        "200": {
          "description": "A bothered patron",
          "schema": {
              "type": "object",
                "properties": {
                  "bothered": {
                    "description": "If the patron has been bothered",
                    "type": "boolean"
                  }
                }
          }
        },
        "401": {
          "description": "An error occurred",
          "schema": {
              "type": "object",
              "properties": {
                "error": {
                  "description": "An explanation for the error",
                  "type": "string"
                }
              }
          }
        }
      },
      "x-koha-authorization": {
        "permissions": {
          "borrowers": "1"
        }
      }
    }
  },
  "/public/patrons/bother": {
    "get": {
      "x-mojo-to": "Test::Controller#bother",
      "operationId": "PubliclyBotherPatron",
      "tags": ["patrons"],
      "produces": [
        "application/json"
      ],
      "responses": {
        "200": {
          "description": "A bothered patron",
          "schema": {
              "type": "object",
              "properties": {
                "bothered": {
                  "description": "If the patron has been bothered",
                  "type": "boolean"
                }
              }
          }
        },
        "401": {
          "description": "Authentication required",
          "schema": {
            "type": "object",
            "properties": {
              "error": {
                "description": "An explanation for the error",
                "type": "string"
              }
            }
          }
        }
      }
    }
  }
}
    };

    return decode_json($spec);
}

sub check_password {
    my ( $self, $args ) = @_;

    my $password = $args->{'password'};
    if ( $password && $password =~ m/^\d{4}$/ ) {
        return { error => 0 };
    } else {
        return {
            error => 1,
            msg   => "PIN should be four digits"
        };
    }
}

sub intranet_catalog_biblio_tab {
    my @tabs;
    push @tabs,
        Koha::Plugins::Tab->new(
        {
            title   => 'Tab 1',
            content => 'This is content for tab 1'
        }
        );

    push @tabs,
        Koha::Plugins::Tab->new(
        {
            title   => 'Tab 2',
            content => 'This is content for tab 2'
        }
        );

    return @tabs;
}

sub background_tasks {
    return {
        foo => 'MyPlugin::Class::Foo',
        bar => {
            class => 'MyPlugin::Class::Bar',
            name  => "Bar task",
        },
    };
}

sub after_account_action {
    my ( $self, $params ) = @_;

    my $action = $params->{action};
    my $line   = $params->{payload}->{line};
    my $type   = $params->{payload}->{type};

    Koha::Exception->throw( "after_account_action called with action: $action, type: $type, ref: " . ref($line) );
}

sub after_recall_action {
    my ( $self, $params ) = @_;

    my $action = $params->{action};
    my $recall = $params->{payload}->{recall};

    Koha::Exception->throw( "after_recall_action called with action: $action, ref: " . ref($recall) );
}

sub template_include_paths {
    my ($self) = @_;

    return [
        $self->mbf_path('inc'),
    ];
}

sub ill_table_actions {
    my ( $self, $table_actions ) = @_;

    push(
        @{$$table_actions},
        {
            button_link_text           => 'Test text',
            append_column_data_to_link => 1,
            button_class               => 'test class',
            button_link                => 'test link'
        }
    );
}

sub transform_prepared_letter {
    my ( $self, $params ) = @_;

    $params->{letter}->{title}   .= '!';
    $params->{letter}->{content} .= "\nThank you for using your local library!";

    Koha::Exception->throw("transform_prepared_letter called with letter content $params->{letter}->{content}");
}

sub ill_backend {
    my ( $class, $args ) = @_;
    return 'Test Plugin';
}

sub new_ill_backend {
    my ( $self, $params ) = @_;

    require Koha::Plugin::ILL::TestPlugin;
    return Koha::Plugin::ILL::TestPlugin->new($params);
}

sub auth_client_get_user {
    my ( $self, $params ) = @_;

    my $builder = t::lib::TestBuilder->new;

    my $new_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    $params->{patron} = $new_patron;

    my $new_domain = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value => {
                domain      => 'changed', update_on_auth => 0, allow_opac => 1,
                allow_staff => 0
            }
        }
    );
    $params->{domain} = $new_domain;

    if ( defined $params->{mapped_data}->{'cardnumber'} ) {

        # Split data (e. g. kit.edu:123456789) and set the card number.
        my ( $card_domain, $cardnumber ) = split( /\:/, $params->{mapped_data}->{'cardnumber'} );
        $params->{mapped_data}->{'cardnumber'} = $cardnumber;
    }
    return;
}

sub overwrite_calc_fine {
    my ( $self, $params ) = @_;

    warn "itemnumber:" . $params->{itemnumber};
    warn "borrowernumber:" . $params->{borrowernumber};
    warn "branchcode:" . $params->{branchcode};
    warn "categorycode:" . $params->{categorycode};
    warn "due_date_type:" . ref( $params->{due_date} );
    warn "end_date_type:" . ref( $params->{end_date} );

    return [ 1, 2, 3 ];
}

sub _private_sub {
    return "";
}

sub elasticsearch_to_document {
    my ( $self, $params ) = @_;
    my $record = $params->{record};
    my $doc    = $params->{document};

    Koha::Exception->throw( "elasticsearch_to_document ref record: " . ref($record) . " - ref document: " . ref($doc) );
}

1;
