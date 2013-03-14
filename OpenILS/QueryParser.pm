use strict;
use warnings;

package OpenILS::QueryParser;
use JSON;

=head1 NAME

OpenILS::QueryParser - basic QueryParser class

=head1 SYNOPSIS

use OpenILS::QueryParser;
my $QParser = OpenILS::QueryParser->new(%args);

=head1 DESCRIPTION

Main entrypoint into the QueryParser functionality.

=head1 FUNCTIONS

=cut

# Note that the first key must match the name of the package.
our %parser_config = (
    'OpenILS::QueryParser' => {
        filters => [],
        modifiers => [],
        operators => {
            'and' => '&&',
            'or' => '||',
            float_start => '{{',
            float_end => '}}',
            group_start => '(',
            group_end => ')',
            required => '+',
            disallowed => '-',
            modifier => '#',
            negated => '!'
        }
    }
);

sub canonicalize {
    my $self = shift;
    return OpenILS::QueryParser::Canonicalize::abstract_query2str_impl(
        $self->parse_tree->to_abstract_query(@_)
    );
}


=head2 facet_class_count

    $count = $QParser->facet_class_count();
=cut

sub facet_class_count {
    my $self = shift;
    return @{$self->facet_classes};
}

=head2 search_class_count

    $count = $QParser->search_class_count();
=cut

sub search_class_count {
    my $self = shift;
    return @{$self->search_classes};
}

=head2 filter_count

    $count = $QParser->filter_count();
=cut

sub filter_count {
    my $self = shift;
    return @{$self->filters};
}

=head2 modifier_count

    $count = $QParser->modifier_count();
=cut

sub modifier_count {
    my $self = shift;
    return @{$self->modifiers};
}

=head2 custom_data

    $data = $QParser->custom_data($class);
=cut

sub custom_data {
    my $class = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{custom_data} ||= {};
    return $parser_config{$class}{custom_data};
}

=head2 operators

    $operators = $QParser->operators();

Returns hashref of the configured operators.
=cut

sub operators {
    my $class = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{operators} ||= {};
    return $parser_config{$class}{operators};
}

sub allow_nested_modifiers {
    my $class = shift;
    my $v = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{allow_nested_modifiers} = $v if (defined $v);
    return $parser_config{$class}{allow_nested_modifiers};
}

=head2 filters

    $filters = $QParser->filters();

Returns arrayref of the configured filters.
=cut

sub filters {
    my $class = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{filters} ||= [];
    return $parser_config{$class}{filters};
}

=head2 filter_callbacks

    $filter_callbacks = $QParser->filter_callbacks();

Returns hashref of the configured filter callbacks.
=cut

sub filter_callbacks {
    my $class = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{filter_callbacks} ||= {};
    return $parser_config{$class}{filter_callbacks};
}

=head2 modifiers

    $modifiers = $QParser->modifiers();

Returns arrayref of the configured modifiers.
=cut

sub modifiers {
    my $class = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{modifiers} ||= [];
    return $parser_config{$class}{modifiers};
}

=head2 new

    $QParser = OpenILS::QueryParser->new(%args);

Creates a new QueryParser object.
=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my %opts = @_;

    my $self = bless {} => $class;

    for my $o (keys %{OpenILS::QueryParser->operators}) {
        $class->operator($o => OpenILS::QueryParser->operator($o)) unless ($class->operator($o));
    }

    for my $opt ( keys %opts) {
        $self->$opt( $opts{$opt} ) if ($self->can($opt));
    }

    return $self;
}

=head2 new_plan

    $query_plan = $QParser->new_plan();

Create a new query plan.
=cut

sub new_plan {
    my $self = shift;
    my $pkg = ref($self) || $self;
    return do{$pkg.'::query_plan'}->new( QueryParser => $self, @_ );
}

=head2 add_search_filter

    $QParser->add_search_filter($filter, [$callback]);

Adds a filter with the specified name and an optional callback to the
QueryParser configuration.
=cut

sub add_search_filter {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $filter = shift;
    my $callback = shift;

    return $filter if (grep { $_ eq $filter } @{$pkg->filters});
    push @{$pkg->filters}, $filter;
    $pkg->filter_callbacks->{$filter} = $callback if ($callback);
    return $filter;
}

=head2 add_search_modifier

    $QParser->add_search_modifier($modifier);

Adds a modifier with the specified name to the QueryParser configuration.
=cut

sub add_search_modifier {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $modifier = shift;

    return $modifier if (grep { $_ eq $modifier } @{$pkg->modifiers});
    push @{$pkg->modifiers}, $modifier;
    return $modifier;
}

=head2 add_facet_class

    $QParser->add_facet_class($facet_class);

Adds a facet class with the specified name to the QueryParser configuration.
=cut

sub add_facet_class {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;

    return $class if (grep { $_ eq $class } @{$pkg->facet_classes});

    push @{$pkg->facet_classes}, $class;
    $pkg->facet_fields->{$class} = [];

    return $class;
}

=head2 add_search_class

    $QParser->add_search_class($class);

Adds a search class with the specified name to the QueryParser configuration.
=cut

sub add_search_class {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;

    return $class if (grep { $_ eq $class } @{$pkg->search_classes});

    push @{$pkg->search_classes}, $class;
    $pkg->search_fields->{$class} = [];
    $pkg->default_search_class( $pkg->search_classes->[0] ) if (@{$pkg->search_classes} == 1);

    return $class;
}

=head2 add_search_modifier

    $op = $QParser->operator($operator, [$newvalue]);

Retrieves or sets value for the specified operator. Valid operators and
their defaults are as follows:

=over 4

=item * and => &&

=item * or => ||

=item * group_start => (

=item * group_end => )

=item * required => +

=item * disallowed => -

=item * modifier => #

=back

=cut

sub operator {
    my $class = shift;
    $class = ref($class) || $class;
    my $opname = shift;
    my $op = shift;

    return unless ($opname);

    $parser_config{$class}{operators} ||= {};
    $parser_config{$class}{operators}{$opname} = $op if ($op);

    return $parser_config{$class}{operators}{$opname};
}

=head2 facet_classes

    $classes = $QParser->facet_classes([\@newclasses]);

Returns arrayref of all configured facet classes after optionally
replacing configuration.
=cut

sub facet_classes {
    my $class = shift;
    $class = ref($class) || $class;
    my $classes = shift;

    $parser_config{$class}{facet_classes} ||= [];
    $parser_config{$class}{facet_classes} = $classes if (ref($classes) && @$classes);
    return $parser_config{$class}{facet_classes};
}

=head2 search_classes

    $classes = $QParser->search_classes([\@newclasses]);

Returns arrayref of all configured search classes after optionally
replacing the previous configuration.
=cut

sub search_classes {
    my $class = shift;
    $class = ref($class) || $class;
    my $classes = shift;

    $parser_config{$class}{classes} ||= [];
    $parser_config{$class}{classes} = $classes if (ref($classes) && @$classes);
    return $parser_config{$class}{classes};
}

=head2 add_query_normalizer

    $function = $QParser->add_query_normalizer($class, $field, $func, [\@params]);

=cut

sub add_query_normalizer {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    my $field = shift;
    my $func = shift;
    my $params = shift || [];

    # do not add if function AND params are identical to existing member
    return $func if (grep {
        $_->{function} eq $func and
        to_json($_->{params}) eq to_json($params)
    } @{$pkg->query_normalizers->{$class}->{$field}});

    push(@{$pkg->query_normalizers->{$class}->{$field}}, { function => $func, params => $params });

    return $func;
}

=head2 query_normalizers

    $normalizers = $QParser->query_normalizers($class, $field);

Returns a list of normalizers associated with the specified search class
and field
=cut

sub query_normalizers {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;

    my $class = shift;
    my $field = shift;

    $parser_config{$pkg}{normalizers} ||= {};
    if ($class) {
        if ($field) {
            $parser_config{$pkg}{normalizers}{$class}{$field} ||= [];
            return $parser_config{$pkg}{normalizers}{$class}{$field};
        } else {
            return $parser_config{$pkg}{normalizers}{$class};
        }
    }

    return $parser_config{$pkg}{normalizers};
}

=head2 add_filter_normalizer

    $normalizer = $QParser->add_filter_normalizer($filter, $func, [\@params]);

Adds a normalizer function to the specified filter.
=cut

sub add_filter_normalizer {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $filter = shift;
    my $func = shift;
    my $params = shift || [];

    return $func if (grep { $_ eq $func } @{$pkg->filter_normalizers->{$filter}});

    push(@{$pkg->filter_normalizers->{$filter}}, { function => $func, params => $params });

    return $func;
}

=head2 filter_normalizers

    $normalizers = $QParser->filter_normalizers($filter);

Return arrayref of normalizer functions associated with the specified filter.
=cut

sub filter_normalizers {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;

    my $filter = shift;

    $parser_config{$pkg}{filter_normalizers} ||= {};
    if ($filter) {
        $parser_config{$pkg}{filter_normalizers}{$filter} ||= [];
        return $parser_config{$pkg}{filter_normalizers}{$filter};
    }

    return $parser_config{$pkg}{filter_normalizers};
}

=head2 default_search_class

    $default_class = $QParser->default_search_class([$class]);

Set or return the default search class.
=cut

sub default_search_class {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    $OpenILS::QueryParser::parser_config{$pkg}{default_class} = $pkg->add_search_class( $class ) if $class;

    return $OpenILS::QueryParser::parser_config{$pkg}{default_class};
}

=head2 remove_facet_class

    $QParser->remove_facet_class($class);

Remove the specified facet class from the configuration.
=cut

sub remove_facet_class {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;

    return $class if (!grep { $_ eq $class } @{$pkg->facet_classes});

    $pkg->facet_classes( [ grep { $_ ne $class } @{$pkg->facet_classes} ] );
    delete $OpenILS::QueryParser::parser_config{$pkg}{facet_fields}{$class};

    return $class;
}

=head2 remove_search_class

    $QParser->remove_search_class($class);

Remove the specified search class from the configuration.
=cut

sub remove_search_class {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;

    return $class if (!grep { $_ eq $class } @{$pkg->search_classes});

    $pkg->search_classes( [ grep { $_ ne $class } @{$pkg->search_classes} ] );
    delete $OpenILS::QueryParser::parser_config{$pkg}{fields}{$class};

    return $class;
}

=head2 add_facet_field

    $QParser->add_facet_field($class, $field);

Adds the specified field (and facet class if it doesn't already exist)
to the configuration.
=cut

sub add_facet_field {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    my $field = shift;

    $pkg->add_facet_class( $class );

    return { $class => $field }  if (grep { $_ eq $field } @{$pkg->facet_fields->{$class}});

    push @{$pkg->facet_fields->{$class}}, $field;

    return { $class => $field };
}

=head2 facet_fields

    $fields = $QParser->facet_fields($class);

Returns arrayref with list of fields for specified facet class.
=cut

sub facet_fields {
    my $class = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{facet_fields} ||= {};
    return $parser_config{$class}{facet_fields};
}

=head2 add_search_field

    $QParser->add_search_field($class, $field);

Adds the specified field (and facet class if it doesn't already exist)
to the configuration.
=cut

sub add_search_field {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    my $field = shift;

    $pkg->add_search_class( $class );

    return { $class => $field }  if (grep { $_ eq $field } @{$pkg->search_fields->{$class}});

    push @{$pkg->search_fields->{$class}}, $field;

    return { $class => $field };
}

=head2 search_fields

    $fields = $QParser->search_fields();

Returns arrayref with list of configured search fields.
=cut

sub search_fields {
    my $class = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{fields} ||= {};
    return $parser_config{$class}{fields};
}

=head2 add_search_class_alias

    $QParser->add_search_class_alias($class, $alias);
=cut

sub add_search_class_alias {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    my $alias = shift;

    $pkg->add_search_class( $class );

    return { $class => $alias }  if (grep { $_ eq $alias } @{$pkg->search_class_aliases->{$class}});

    push @{$pkg->search_class_aliases->{$class}}, $alias;

    return { $class => $alias };
}

=head2 search_class_aliases

    $aliases = $QParser->search_class_aliases($class);
=cut

sub search_class_aliases {
    my $class = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{class_map} ||= {};
    return $parser_config{$class}{class_map};
}

=head2 add_search_field_alias

    $QParser->add_search_field_alias($class, $field, $alias);
=cut

sub add_search_field_alias {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    my $field = shift;
    my $alias = shift;

    return { $class => { $field => $alias } }  if (grep { $_ eq $alias } @{$pkg->search_field_aliases->{$class}{$field}});

    push @{$pkg->search_field_aliases->{$class}{$field}}, $alias;

    return { $class => { $field => $alias } };
}

=head2 search_field_aliases

    $aliases = $QParser->search_field_aliases();
=cut

sub search_field_aliases {
    my $class = shift;
    $class = ref($class) || $class;

    $parser_config{$class}{field_alias_map} ||= {};
    return $parser_config{$class}{field_alias_map};
}

=head2 remove_facet_field

    $QParser->remove_facet_field($class, $field);
=cut

sub remove_facet_field {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    my $field = shift;

    return { $class => $field }  if (!$pkg->facet_fields->{$class} || !grep { $_ eq $field } @{$pkg->facet_fields->{$class}});

    $pkg->facet_fields->{$class} = [ grep { $_ ne $field } @{$pkg->facet_fields->{$class}} ];

    return { $class => $field };
}

=head2 remove_search_field

    $QParser->remove_search_field($class, $field);
=cut

sub remove_search_field {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    my $field = shift;

    return { $class => $field }  if (!$pkg->search_fields->{$class} || !grep { $_ eq $field } @{$pkg->search_fields->{$class}});

    $pkg->search_fields->{$class} = [ grep { $_ ne $field } @{$pkg->search_fields->{$class}} ];

    return { $class => $field };
}

=head2 remove_search_field_alias

    $QParser->remove_search_field_alias($class, $field, $alias);
=cut

sub remove_search_field_alias {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    my $field = shift;
    my $alias = shift;

    return { $class => { $field => $alias } }  if (!$pkg->search_field_aliases->{$class}{$field} || !grep { $_ eq $alias } @{$pkg->search_field_aliases->{$class}{$field}});

    $pkg->search_field_aliases->{$class}{$field} = [ grep { $_ ne $alias } @{$pkg->search_field_aliases->{$class}{$field}} ];

    return { $class => { $field => $alias } };
}

=head2 remove_search_class_alias

    $QParser->remove_search_class_alias($class, $alias);
=cut

sub remove_search_class_alias {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $class = shift;
    my $alias = shift;

    return { $class => $alias }  if (!$pkg->search_class_aliases->{$class} || !grep { $_ eq $alias } @{$pkg->search_class_aliases->{$class}});

    $pkg->search_class_aliases->{$class} = [ grep { $_ ne $alias } @{$pkg->search_class_aliases->{$class}} ];

    return { $class => $alias };
}

=head2 debug

    $debug = $QParser->debug([$debug]);

Return or set whether debugging output is enabled.
=cut

sub debug {
    my $self = shift;
    my $q = shift;
    $self->{_debug} = $q if (defined $q);
    return $self->{_debug};
}

=head2 query

    $query = $QParser->query([$query]);

Return or set the query.
=cut

sub query {
    my $self = shift;
    my $q = shift;
    $self->{_query} = " $q " if (defined $q);
    return $self->{_query};
}

=head2 parse_tree

    $parse_tree = $QParser->parse_tree([$parse_tree]);

Return or set the parse tree associated with the QueryParser.
=cut

sub parse_tree {
    my $self = shift;
    my $q = shift;
    $self->{_parse_tree} = $q if (defined $q);
    return $self->{_parse_tree};
}

sub floating_plan {
    my $self = shift;
    my $q = shift;
    $self->{_top} = $q if (defined $q);
    return $self->{_top};
}

=head2 parse

    $QParser->parse([$query]);

Parse the specified query, or the query already associated with the QueryParser
object.
=cut

sub parse {
    my $self = shift;
    my $pkg = ref($self) || $self;
    warn " ** parse package is $pkg\n" if $self->debug;
#    $self->parse_tree(
#        $self->decompose(
#            $self->query( shift() )
#        )
#    );

    undef $self->{_parse_tree};

    $self->decompose( $self->query( shift() ) );

    if ($self->floating_plan) {
        $self->floating_plan->add_node( $self->parse_tree );
        $self->parse_tree( $self->floating_plan );
    }

    $self->parse_tree->plan_level(0);

    return $self;
}

=head2 decompose

    ($struct, $remainder) = $QParser->decompose($querystring, [$current_class], [$recursing], [$phrase_helper]);

This routine does the heavy work of parsing the query string recursively.
Returns the top level query plan, or the query plan from a lower level plus
the portion of the query string that needs to be processed at a higher level.
=cut

our $last_class = '';
our $last_type = '';
our $floating = 0;
our $fstart;

sub decompose {
    my $self = shift;
    my $pkg = ref($self) || $self;


    $_ = shift;
    my $current_class = shift || $self->default_search_class;

    my $recursing = shift || 0;
    my $phrase_helper = shift || 0;

    # Build the search class+field uber-regexp
    my $search_class_re = '^\s*(';
    my $first_class = 1;

    warn '  'x$recursing." ** decompose package is $pkg\n" if $self->debug;

    my %seen_classes;
    for my $class ( keys %{$pkg->search_field_aliases} ) {
        warn '  'x$recursing." *** ... Looking for search fields in $class\n" if $self->debug;

        for my $field ( keys %{$pkg->search_field_aliases->{$class}} ) {
            warn '  'x$recursing." *** ... Looking for aliases of $field\n" if $self->debug;

            for my $alias ( @{$pkg->search_field_aliases->{$class}{$field}} ) {
                next unless ($alias);
                my $aliasr = qr/$alias/;
                s/(^|\s+)$aliasr\|/$1$class\|$field#$alias\|/g;
                s/(^|\s+)$aliasr[:=]/$1$class\|$field#$alias:/g;
                warn '  'x$recursing." *** Rewriting: $alias ($aliasr) as $class\|$field\n" if $self->debug;
            }
        }

        $search_class_re .= '|' unless ($first_class);
        $first_class = 0;
        $search_class_re .= $class . '(?:[|#][^:|]+)*';
        $seen_classes{$class} = 1;
    }

    for my $class ( keys %{$pkg->search_class_aliases} ) {

        for my $alias ( @{$pkg->search_class_aliases->{$class}} ) {
            next unless ($alias);
            my $aliasr = qr/$alias/;
            s/(^|[^|])\b$aliasr\|/$1$class#$alias\|/g;
            s/(^|[^|])\b$aliasr[:=]/$1$class#$alias:/g;
            warn '  'x$recursing." *** Rewriting: $alias ($aliasr) as $class\n" if $self->debug;
        }

        if (!$seen_classes{$class}) {
            $search_class_re .= '|' unless ($first_class);
            $first_class = 0;

            $search_class_re .= $class . '(?:[|#][^:|]+)*';
            $seen_classes{$class} = 1;
        }
    }
    $search_class_re .= '):';

    warn '  'x$recursing." ** Rewritten query: $_\n" if $self->debug;
    warn '  'x$recursing." ** Search class RE: $search_class_re\n" if $self->debug;

    my $required_op = $pkg->operator('required');
    my $required_re = qr/\Q$required_op\E/;

    my $disallowed_op = $pkg->operator('disallowed');
    my $disallowed_re = qr/\Q$disallowed_op\E/;

    my $negated_op = $pkg->operator('negated');
    my $negated_re = qr/\Q$negated_op\E/;

    my $and_op = $pkg->operator('and');
    my $and_re = qr/^\s*\Q$and_op\E/;

    my $or_op = $pkg->operator('or');
    my $or_re = qr/^\s*\Q$or_op\E/;

    my $group_start = $pkg->operator('group_start');
    my $group_start_re = qr/^\s*($negated_re|$disallowed_re)?\Q$group_start\E/;

    my $group_end = $pkg->operator('group_end');
    my $group_end_re = qr/^\s*\Q$group_end\E/;

    my $float_start = $pkg->operator('float_start');
    my $float_start_re = qr/^\s*\Q$float_start\E/;

    my $float_end = $pkg->operator('float_end');
    my $float_end_re = qr/^\s*\Q$float_end\E/;

    my $modifier_tag = $pkg->operator('modifier');
    my $modifier_tag_re = qr/^\s*\Q$modifier_tag\E/;

    # Group start/end normally are ( and ), but can be overridden.
    # We thus include ( and ) specifically due to filters, as well as : for classes.
    my $phrase_cleanup_re = qr/\s*(\Q$required_op\E|\Q$disallowed_op\E|\Q$and_op\E|\Q$or_op\E|\Q$group_start\E|\Q$group_end\E|\Q$float_start\E|\Q$float_end\E|\Q$modifier_tag\E|\Q$negated_op\E|:|\(|\))/;

    # Build the filter and modifier uber-regexps
    my $facet_re = '^\s*(-?)((?:' . join( '|', @{$pkg->facet_classes}) . ')(?:\|\w+)*)\[(.+?)\]';
    warn '  'x$recursing." ** Facet RE: $facet_re\n" if $self->debug;

    my $filter_re = '^\s*(-?)(' . join( '|', @{$pkg->filters}) . ')\(([^()]+)\)';
    my $filter_as_class_re = '^\s*(-?)(' . join( '|', @{$pkg->filters}) . '):\s*(\S+)';

    my $modifier_re = '^\s*'.$modifier_tag_re.'(' . join( '|', @{$pkg->modifiers}) . ')\b';
    my $modifier_as_class_re = '^\s*(' . join( '|', @{$pkg->modifiers}) . '):\s*(\S+)';

    my $struct = shift || $self->new_plan( level => $recursing );
    $self->parse_tree( $struct ) if (!$self->parse_tree);

    my $remainder = '';

    while (!$remainder) {
        warn '  'x$recursing."Start of the loop. last_type: $last_type, joiner: ".$struct->joiner.", struct: $struct\n" if $self->debug;
        if ($last_type eq 'FEND' and $fstart and $fstart !=  $struct) { # fall back further
            $remainder = $_;
            last;
        } elsif ($last_type eq 'FEND') {
            $fstart = undef;
            $last_type = '';
        }

        if (/^\s*$/) { # end of an explicit group
            local $last_type = '';
            last;
        } elsif (/$float_end_re/) { # end of an explicit group
            warn '  'x$recursing."Encountered explicit float end, remainder: $'\n" if $self->debug;

            $remainder = $';
            $_ = '';

            $floating = 0;
            $last_type = 'FEND';
            last;
        } elsif (/$group_end_re/) { # end of an explicit group
            warn '  'x$recursing."Encountered explicit group end, remainder: $'\n" if $self->debug;

            $remainder = $';
            $_ = '';

            local $last_type = '';
        } elsif ($self->filter_count && /$filter_re/) { # found a filter
            warn '  'x$recursing."Encountered search filter: $1$2 set to $3\n" if $self->debug;

            my $negate = ($1 eq $pkg->operator('disallowed')) ? 1 : 0;
            $_ = $';

            my $filter = $2;
            my $params = [ split '[,]+', $3 ];

            if ($pkg->filter_callbacks->{$filter}) {
                my $replacement = $pkg->filter_callbacks->{$filter}->($self, $struct, $filter, $params, $negate);
                $_ = "$replacement $_" if ($replacement);
            } else {
                $struct->new_filter( $filter => $params, $negate );
            }


            local $last_type = '';
        } elsif ($self->filter_count && /$filter_as_class_re/) { # found a filter
            warn '  'x$recursing."Encountered search filter: $1$2 set to $3\n" if $self->debug;

            my $negate = ($1 eq $pkg->operator('disallowed')) ? 1 : 0;
            $_ = $';

            my $filter = $2;
            my $params = [ split '[,]+', $3 ];

            if ($pkg->filter_callbacks->{$filter}) {
                my $replacement = $pkg->filter_callbacks->{$filter}->($self, $struct, $filter, $params, $negate);
                $_ = "$replacement $_" if ($replacement);
            } else {
                $struct->new_filter( $filter => $params, $negate );
            }

            local $last_type = '';
        } elsif ($self->modifier_count && /$modifier_re/) { # found a modifier
            warn '  'x$recursing."Encountered search modifier: $1\n" if $self->debug;

            $_ = $';
            if (!($struct->top_plan || $parser_config{$pkg}->{allow_nested_modifiers})) {
                warn '  'x$recursing."  Search modifiers only allowed at the top level of the query\n" if $self->debug;
            } else {
                $struct->new_modifier($1);
            }

            local $last_type = '';
        } elsif ($self->modifier_count && /$modifier_as_class_re/) { # found a modifier
            warn '  'x$recursing."Encountered search modifier: $1\n" if $self->debug;

            my $mod = $1;

            $_ = $';
            if (!($struct->top_plan || $parser_config{$pkg}->{allow_nested_modifiers})) {
                warn '  'x$recursing."  Search modifiers only allowed at the top level of the query\n" if $self->debug;
            } elsif ($2 =~ /^[ty1]/i) {
                $struct->new_modifier($mod);
            }

            local $last_type = '';
        } elsif (/$float_start_re/) { # start of an explicit float
            warn '  'x$recursing."Encountered explicit float start\n" if $self->debug;
            $floating = 1;
            $fstart = $struct;

            $last_class = $current_class;
            $current_class = undef;

            $self->floating_plan( $self->new_plan( floating => 1 ) ) if (!$self->floating_plan);

            # pass the floating_plan struct to be modified by the float'ed chunk
            my ($floating_plan, $subremainder) = $self->new( debug => $self->debug )->decompose( $', undef, undef, undef,  $self->floating_plan);
            $_ = $subremainder;
            warn '  'x$recursing."Remainder after explicit float: $_\n" if $self->debug;

            $current_class = $last_class;

            $last_type = '';
        } elsif (/$group_start_re/) { # start of an explicit group
            warn '  'x$recursing."Encountered explicit group start\n" if $self->debug;
            my $negate = $1;
            my ($substruct, $subremainder) = $self->decompose( $', $current_class, $recursing + 1 );
            $substruct->negate(1) if ($substruct && $negate);
            $struct->add_node( $substruct ) if ($substruct);
            $_ = $subremainder;
            warn '  'x$recursing."Query remainder after bool group: $_\n" if $self->debug;

            local $last_type = '';

        } elsif (/$and_re/) { # ANDed expression
            $_ = $';
            warn '  'x$recursing."Encountered AND\n" if $self->debug;
            do {warn '  'x$recursing."!!! Already doing the bool dance for AND\n" if $self->debug; next} if ($last_type eq 'AND');
            do {warn '  'x$recursing."!!! Already doing the bool dance for OR\n" if $self->debug; next} if ($last_type eq 'OR');
            local $last_type = 'AND';

            warn '  'x$recursing."Saving LHS, building RHS\n" if $self->debug;
            my $LHS = $struct;
            #my ($RHS, $subremainder) = $self->decompose( "$group_start $_ $group_end", $current_class, $recursing + 1 );
            my ($RHS, $subremainder) = $self->decompose( $_, $current_class, $recursing + 1 );
            $_ = $subremainder;

            warn '  'x$recursing."RHS built\n" if $self->debug;
            warn '  'x$recursing."Post-AND remainder: $subremainder\n" if $self->debug;

            my $wrapper = $self->new_plan( level => $recursing + 1 );

            if ($LHS->floating) {
                $wrapper->{query} = $LHS->{query};
                my $outer_wrapper = $self->new_plan( level => $recursing + 1 );
                $outer_wrapper->add_node($_) for ($wrapper,$RHS);
                $LHS->{query} = [$outer_wrapper];
                $struct = $LHS;
            } else {
                $wrapper->add_node($_) for ($LHS, $RHS);
                $wrapper->plan_level($wrapper->plan_level); # reset levels all the way down
                $struct = $self->new_plan( level => $recursing );
                $struct->add_node($wrapper);
            }

            $self->parse_tree( $struct ) if ($self->parse_tree == $LHS);

            local $last_type = '';
        } elsif (/$or_re/) { # ORed expression
            $_ = $';
            warn '  'x$recursing."Encountered OR\n" if $self->debug;
            do {warn '  'x$recursing."!!! Already doing the bool dance for AND\n" if $self->debug; next} if ($last_type eq 'AND');
            do {warn '  'x$recursing."!!! Already doing the bool dance for OR\n" if $self->debug; next} if ($last_type eq 'OR');
            local $last_type = 'OR';

            warn '  'x$recursing."Saving LHS, building RHS\n" if $self->debug;
            my $LHS = $struct;
            #my ($RHS, $subremainder) = $self->decompose( "$group_start $_ $group_end", $current_class, $recursing + 1 );
            my ($RHS, $subremainder) = $self->decompose( $_, $current_class, $recursing + 2 );
            $_ = $subremainder;

            warn '  'x$recursing."RHS built\n" if $self->debug;
            warn '  'x$recursing."Post-OR remainder: $subremainder\n" if $self->debug;

            my $wrapper = $self->new_plan( level => $recursing + 1, joiner => '|' );

            if ($LHS->floating) {
                $wrapper->{query} = $LHS->{query};
                my $outer_wrapper = $self->new_plan( level => $recursing + 1, joiner => '|' );
                $outer_wrapper->add_node($_) for ($wrapper,$RHS);
                $LHS->{query} = [$outer_wrapper];
                $struct = $LHS;
            } else {
                $wrapper->add_node($_) for ($LHS, $RHS);
                $wrapper->plan_level($wrapper->plan_level); # reset levels all the way down
                $struct = $self->new_plan( level => $recursing );
                $struct->add_node($wrapper);
            }

            $self->parse_tree( $struct ) if ($self->parse_tree == $LHS);

            local $last_type = '';
        } elsif ($self->facet_class_count && /$facet_re/) { # changing current class
            warn '  'x$recursing."Encountered facet: $1$2 => $3\n" if $self->debug;

            my $negate = ($1 eq $pkg->operator('disallowed')) ? 1 : 0;
            my $facet = $2;
            my $facet_value = [ split '\s*#\s*', $3 ];
            $struct->new_facet( $facet => $facet_value, $negate );
            $_ = $';

            local $last_type = '';
        } elsif ($self->search_class_count && /$search_class_re/) { # changing current class

            if ($last_type eq 'CLASS') {
                $struct->remove_last_node( $current_class );
                warn '  'x$recursing."Encountered class change with no searches!\n" if $self->debug;
            }

            warn '  'x$recursing."Encountered class change: $1\n" if $self->debug;

            $current_class = $struct->classed_node( $1 )->requested_class();
            $_ = $';

            local $last_type = 'CLASS';
        } elsif (/^\s*($required_re|$disallowed_re|$negated_re)?"([^"]+)"/) { # phrase, always anded
            warn '  'x$recursing.'Encountered' . ($1 ? " ['$1' modified]" : '') . " phrase: $2\n" if $self->debug;

            my $req_ness = $1 || '';
            $req_ness = $disallowed_op if ($req_ness eq $negated_op);
            my $phrase = $2;

            if (!$phrase_helper) {
                warn '  'x$recursing."Recursing into decompose with the phrase as a subquery\n" if $self->debug;
                my $after = $';
                my ($substruct, $subremainder) = $self->decompose( qq/$req_ness"$phrase"/, $current_class, $recursing + 1, 1 );
                $struct->add_node( $substruct ) if ($substruct);
                $_ = $after;
            } else {
                warn '  'x$recursing."Directly parsing the phrase subquery\n" if $self->debug;
                $struct->joiner( '&' );

                my $class_node = $struct->classed_node($current_class);

                if ($req_ness eq $disallowed_op) {
                    $class_node->negate(1);
                }
                $class_node->add_phrase( $phrase );

                # Save $' before we clean up $phrase
                my $temp_val = $';

                # Cleanup the phrase to make it so that we don't parse things in it as anything other than atoms
                $phrase =~ s/$phrase_cleanup_re/ /g;

                $_ = $temp_val;

            }

            local $last_type = '';

        } elsif (/^\s*($required_re|$disallowed_re)([^${group_end}${float_end}\s"]+)/) { # convert require/disallow word to {un}phrase
            warn '  'x$recursing."Encountered required atom (mini phrase), transforming for phrase parse: $1\n" if $self->debug;

            $_ = $1 . '"' . $2 . '"' . $';

            local $last_type = '';
        } elsif (/^\s*([^${group_end}${float_end}\s]+)/o) { # atom
            warn '  'x$recursing."Encountered atom: $1\n" if $self->debug;
            warn '  'x$recursing."Remainder: $'\n" if $self->debug;

            my $atom = $1;
            my $after = $';

            $_ = $after;
            local $last_type = '';

            my $class_node = $struct->classed_node($current_class);

            my $prefix = ($atom =~ s/^$negated_re//o) ? '!' : '';
            my $truncate = ($atom =~ s/\*$//o) ? '*' : '';

            if ($atom ne '' and !grep { $atom =~ /^\Q$_\E+$/ } ('&','|')) { # throw away & and |, not allowed in tsquery, and not really useful anyway
#                $class_node->add_phrase( $atom ) if ($atom =~ s/^$required_re//o);

                $class_node->add_fts_atom( $atom, suffix => $truncate, prefix => $prefix, node => $class_node );
                $struct->joiner( '&' );
            }

            local $last_type = '';
        }

        last unless ($_);

    }

    $struct = undef if
        scalar(@{$struct->query_nodes}) == 0 &&
        scalar(@{$struct->filters}) == 0 &&
        !$struct->top_plan;

    return $struct if !wantarray;
    return ($struct, $remainder);
}

=head2 find_class_index

    $index = $QParser->find_class_index($class, $query);
=cut

sub find_class_index {
    my $class = shift;
    my $query = shift;

    my ($class_part, @field_parts) = split '\|', $class;
    $class_part ||= $class;

    for my $idx ( 0 .. scalar(@$query) - 1 ) {
        next unless ref($$query[$idx]);
        return $idx if ( $$query[$idx]{requested_class} && $class eq $$query[$idx]{requested_class} );
    }

    push(@$query, { classname => $class_part, (@field_parts ? (fields => \@field_parts) : ()), requested_class => $class, ftsquery => [], phrases => [] });
    return -1;
}

=head2 core_limit

    $limit = $QParser->core_limit([$limit]);

Return and/or set the core_limit.
=cut

sub core_limit {
    my $self = shift;
    my $l = shift;
    $self->{core_limit} = $l if ($l);
    return $self->{core_limit};
}

=head2 superpage

    $superpage = $QParser->superpage([$superpage]);

Return and/or set the superpage.
=cut

sub superpage {
    my $self = shift;
    my $l = shift;
    $self->{superpage} = $l if ($l);
    return $self->{superpage};
}

=head2 superpage_size

    $size = $QParser->superpage_size([$size]);

Return and/or set the superpage size.
=cut

sub superpage_size {
    my $self = shift;
    my $l = shift;
    $self->{superpage_size} = $l if ($l);
    return $self->{superpage_size};
}


#-------------------------------
package OpenILS::QueryParser::_util;

# At this level, joiners are always & or |.  This is not
# the external, configurable representation of joiners that
# defaults to # && and ||.
sub is_joiner {
    my $str = shift;

    return (not ref $str and ($str eq '&' or $str eq '|'));
}

sub default_joiner { '&' }

# 0 for different, 1 for the same.
sub compare_abstract_atoms {
    my ($left, $right) = @_;

    foreach (qw/prefix suffix content/) {
        no warnings;    # undef can stand in for '' here
        return 0 unless $left->{$_} eq $right->{$_};
    }

    return 1;
}

sub fake_abstract_atom_from_phrase {
    my $phrase = shift;
    my $neg = shift;
    my $qp_class = shift || 'OpenILS::QueryParser';

    my $prefix = '"';
    if ($neg) {
        $prefix =
            $OpenILS::QueryParser::parser_config{$qp_class}{operators}{disallowed} .
            $prefix;
    }

    return {
        "type" => "atom", "prefix" => $prefix, "suffix" => '"',
        "content" => $phrase
    }
}

sub find_arrays_in_abstract {
    my ($hash) = @_;

    my @arrays;
    foreach my $key (keys %$hash) {
        if (ref $hash->{$key} eq "ARRAY") {
            push @arrays, $hash->{$key};
            foreach (@{$hash->{$key}}) {
                push @arrays, find_arrays_in_abstract($_);
            }
        }
    }

    return @arrays;
}

#-------------------------------
package OpenILS::QueryParser::Canonicalize;  # not OO
use Data::Dumper;

sub _abstract_query2str_filter {
    my $f = shift;
    my $qp_class = shift || 'OpenILS::QueryParser';
    my $qpconfig = $OpenILS::QueryParser::parser_config{$qp_class};

    return sprintf(
        '%s%s(%s)',
        $f->{negate} ? $qpconfig->{operators}{disallowed} : "",
        $f->{name},
        join(",", @{$f->{args}})
    );
}

sub _abstract_query2str_modifier {
    my $f = shift;
    my $qp_class = shift || 'OpenILS::QueryParser';
    my $qpconfig = $OpenILS::QueryParser::parser_config{$qp_class};

    return $qpconfig->{operators}{modifier} . $f;
}

sub _kid_list {
    my $children = shift;
    my $op = (keys %$children)[0];
    return @{$$children{$op}};
}


# This should produce an equivalent query to the original, given an
# abstract_query.
sub abstract_query2str_impl {
    my $abstract_query  = shift;
    my $depth = shift || 0;

    my $qp_class ||= shift || 'OpenILS::QueryParser';
    my $force_qp_node = shift || 0;
    my $qpconfig = $OpenILS::QueryParser::parser_config{$qp_class};

    my $fs = $qpconfig->{operators}{float_start};
    my $fe = $qpconfig->{operators}{float_end};
    my $gs = $qpconfig->{operators}{group_start};
    my $ge = $qpconfig->{operators}{group_end};
    my $and = $qpconfig->{operators}{and};
    my $or = $qpconfig->{operators}{or};
    my $ng = $qpconfig->{operators}{negated};

    my $isnode = 0;
    my $negate = '';
    my $size = 0;
    my $q = "";

    if (exists $abstract_query->{type}) {
        if ($abstract_query->{type} eq 'query_plan') {
            $q .= join(" ", map { _abstract_query2str_filter($_, $qp_class) } @{$abstract_query->{filters}}) if
                exists $abstract_query->{filters};

            $q .= ($q ? ' ' : '') . join(" ", map { _abstract_query2str_modifier($_, $qp_class) } @{$abstract_query->{modifiers}}) if
                exists $abstract_query->{modifiers};

            $size = _kid_list($abstract_query->{children});
            if ($abstract_query->{negate}) {
                $isnode = 1;
                $negate = $ng;
            }
            $isnode = 1 if ($size > 1 and ($force_qp_node or $depth));
            #warn "size: $size, depth: $depth, isnode: $isnode, AQ: ".Dumper($abstract_query);
        } elsif ($abstract_query->{type} eq 'node') {
            if ($abstract_query->{alias}) {
                $q .= ($q ? ' ' : '') . $abstract_query->{alias};
                $q .= "|$_" foreach @{$abstract_query->{alias_fields}};
            } else {
                $q .= ($q ? ' ' : '') . $abstract_query->{class};
                $q .= "|$_" foreach @{$abstract_query->{fields}};
            }
            $q .= ":";
            $isnode = 1;
        } elsif ($abstract_query->{type} eq 'atom') {
            my $prefix = $abstract_query->{prefix} || '';
            $prefix = $qpconfig->{operators}{negated} if $prefix eq '!';
            $q .= ($q ? ' ' : '') . $prefix .
                ($abstract_query->{content} || '') .
                ($abstract_query->{suffix} || '');
        } elsif ($abstract_query->{type} eq 'facet') {
            # facet syntax [ # ] is hardcoded I guess?
            my $prefix = $abstract_query->{negate} ? $qpconfig->{operators}{disallowed} : '';
            $q .= ($q ? ' ' : '') . $prefix . $abstract_query->{name} . "[" .
                join(" # ", @{$abstract_query->{values}}) . "]";
        }
    }

    my $next_depth = int($size > 1);

    if (exists $abstract_query->{children}) {

        my $op = (keys(%{$abstract_query->{children}}))[0];

        if ($abstract_query->{floating}) { # always the top node!
            my $sub_node = pop @{$abstract_query->{children}{$op}};

            $abstract_query->{floating} = 0;
            $q = $fs . " " . abstract_query2str_impl($abstract_query,0,$qp_class, 1) . $fe. " ";

            $abstract_query = $sub_node;
        }

        if ($abstract_query && exists $abstract_query->{children}) {
            $op = (keys(%{$abstract_query->{children}}))[0];
            $q .= ($q ? ' ' : '') . join(
                ($op eq '&' ? ' ' : " $or "),
                map {
                    my $x = abstract_query2str_impl($_, $depth + $next_depth, $qp_class, $force_qp_node); $x =~ s/^\s+//; $x =~ s/\s+$//; $x;
                } @{$abstract_query->{children}{$op}}
            );
        }
    } elsif ($abstract_query->{'&'} or $abstract_query->{'|'}) {
        my $op = (keys(%{$abstract_query}))[0];
        $q .= ($q ? ' ' : '') . join(
            ($op eq '&' ? ' ' : " $or "),
            map {
                    my $x = abstract_query2str_impl($_, $depth + $next_depth, $qp_class, $force_qp_node); $x =~ s/^\s+//; $x =~ s/\s+$//; $x;
            } @{$abstract_query->{$op}}
        );
    }

    $q = "$gs$q$ge" if ($isnode);
    $q = $negate . $q if ($q);;

    return $q;
}

#-------------------------------
package OpenILS::QueryParser::query_plan;

sub QueryParser {
    my $self = shift;
    return unless ref($self);
    return $self->{QueryParser};
}

sub new {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my %args = (query => [], joiner => '&', @_);

    return bless \%args => $pkg;
}

sub new_node {
    my $self = shift;
    my $pkg = ref($self) || $self;
    my $node = do{$pkg.'::node'}->new( plan => $self, @_ );
    $self->add_node( $node );
    return $node;
}

sub new_facet {
    my $self = shift;
    my $pkg = ref($self) || $self;
    my $name = shift;
    my $args = shift;
    my $negate = shift;

    my $node = do{$pkg.'::facet'}->new( plan => $self, name => $name, 'values' => $args, negate => $negate );
    $self->add_node( $node );

    return $node;
}

sub new_filter {
    my $self = shift;
    my $pkg = ref($self) || $self;
    my $name = shift;
    my $args = shift;
    my $negate = shift;

    my $node = do{$pkg.'::filter'}->new( plan => $self, name => $name, args => $args, negate => $negate );
    $self->add_filter( $node );

    return $node;
}


sub _merge_filters {
    my $left_filter = shift;
    my $right_filter = shift;
    my $join = shift;

    return unless $left_filter or $right_filter;
    return $right_filter unless $left_filter;
    return $left_filter unless $right_filter;

    my $args = $left_filter->{args} || [];

    if ($join eq '|') {
        push(@$args, @{$right_filter->{args}});

    } else {
        # find the intersect values
        my %new_vals;
        map { $new_vals{$_} = 1 } @{$right_filter->{args} || []};
        $args = [ grep { $new_vals{$_} } @$args ];
    }

    $left_filter->{args} = $args;
    return $left_filter;
}

sub collapse_filters {
    my $self = shift;
    my $name = shift;

    # start by merging any filters at this level.
    # like-level filters are always ORed together

    my $cur_filter;
    my @cur_filters = grep {$_->name eq $name } @{ $self->filters };
    if (@cur_filters) {
        $cur_filter = shift @cur_filters;
        my $args = $cur_filter->{args} || [];
        $cur_filter = _merge_filters($cur_filter, $_, '|') for @cur_filters;
    }

    # next gather the collapsed filters from sub-plans and
    # merge them with our own

    my @subquery = @{$self->{query}};

    while (@subquery) {
        my $blob = shift @subquery;
        shift @subquery; # joiner
        next unless $blob->isa('OpenILS::QueryParser::query_plan');
        my $sub_filter = $blob->collapse_filters($name);
        $cur_filter = _merge_filters($cur_filter, $sub_filter, $self->joiner);
    }

    if ($self->QueryParser->debug) {
        my @args = ($cur_filter and $cur_filter->{args}) ? @{$cur_filter->{args}} : ();
        warn "collapse_filters($name) => [@args]\n";
    }

    return $cur_filter;
}

sub find_filter {
    my $self = shift;
    my $needle = shift;;
    return unless ($needle);

    my $filter = $self->collapse_filters($needle);

    warn "find_filter($needle) => " .
        (($filter and $filter->{args}) ? "@{$filter->{args}}" : '[]') . "\n"
        if $self->QueryParser->debug;

    return $filter ? ($filter) : ();
}

sub find_modifier {
    my $self = shift;
    my $needle = shift;;
    return unless ($needle);
    return grep { $_->name eq $needle } @{ $self->modifiers };
}

sub new_modifier {
    my $self = shift;
    my $pkg = ref($self) || $self;
    my $name = shift;

    my $node = do{$pkg.'::modifier'}->new( $name );
    $self->add_modifier( $node );

    return $node;
}

sub classed_node {
    my $self = shift;
    my $requested_class = shift;

    my $node;
    for my $n (@{$self->{query}}) {
        next unless (ref($n) && $n->isa( 'OpenILS::QueryParser::query_plan::node' ));
        if ($n->requested_class eq $requested_class) {
            $node = $n;
            last;
        }
    }

    if (!$node) {
        $node = $self->new_node;
        $node->requested_class( $requested_class );
    }

    return $node;
}

sub remove_last_node {
    my $self = shift;
    my $requested_class = shift;

    my $old = pop(@{$self->query_nodes});
    pop(@{$self->query_nodes}) if (@{$self->query_nodes});

    return $old;
}

sub query_nodes {
    my $self = shift;
    return $self->{query};
}

sub floating {
    my $self = shift;
    my $f = shift;
    $self->{floating} = $f if (defined $f);
    return $self->{floating};
}

sub add_node {
    my $self = shift;
    my $node = shift;

    $self->{query} ||= [];
    push(@{$self->{query}}, $self->joiner) if (@{$self->{query}});
    push(@{$self->{query}}, $node);

    return $self;
}

sub top_plan {
    my $self = shift;

    return $self->{level} ? 0 : 1;
}

sub plan_level {
    my $self = shift;
    my $level = shift;

    if (defined $level) {
        $self->{level} = $level;
        for (@{$self->query_nodes}) {
            $_->plan_level($level + 1) if (ref and $_->isa('OpenILS::QueryParser::query_plan'));
        }
    }

    return $self->{level};
}

sub joiner {
    my $self = shift;
    my $joiner = shift;

    $self->{joiner} = $joiner if ($joiner);
    return $self->{joiner};
}

sub modifiers {
    my $self = shift;
    $self->{modifiers} ||= [];
    return $self->{modifiers};
}

sub add_modifier {
    my $self = shift;
    my $modifier = shift;

    $self->{modifiers} ||= [];
    $self->{modifiers} = [ grep {$_->name ne $modifier->name} @{$self->{modifiers}} ];

    push(@{$self->{modifiers}}, $modifier);

    return $self;
}

sub facets {
    my $self = shift;
    $self->{facets} ||= [];
    return $self->{facets};
}

sub add_facet {
    my $self = shift;
    my $facet = shift;

    $self->{facets} ||= [];
    $self->{facets} = [ grep {$_->name ne $facet->name} @{$self->{facets}} ];

    push(@{$self->{facets}}, $facet);

    return $self;
}

sub filters {
    my $self = shift;
    $self->{filters} ||= [];
    return $self->{filters};
}

sub add_filter {
    my $self = shift;
    my $filter = shift;

    $self->{filters} ||= [];

    push(@{$self->{filters}}, $filter);

    return $self;
}

sub negate {
    my $self = shift;
    my $negate = shift;

    $self->{negate} = $negate if (defined $negate);

    return $self->{negate};
}

# %opts supports two options at this time:
#   no_phrases :
#       If true, do not do anything to the phrases
#       fields on any discovered nodes.
#   with_config :
#       If true, also return the query parser config as part of the blob.
#       This will get set back to 0 before recursion to avoid repetition.
sub to_abstract_query {
    my $self = shift;
    my %opts = @_;

    my $pkg = ref $self->QueryParser || $self->QueryParser;

    my $abstract_query = {
        type => "query_plan",
        floating => $self->floating,
        level => $self->plan_level,
        filters => [map { $_->to_abstract_query } @{$self->filters}],
        modifiers => [map { $_->to_abstract_query } @{$self->modifiers}],
        negate => $self->negate
    };

    if ($opts{with_config}) {
        $opts{with_config} = 0;
        $abstract_query->{config} = $OpenILS::QueryParser::parser_config{$pkg};
    }

    my $kids = [];

    for my $qnode (@{$self->query_nodes}) {
        # Remember: qnode can be a joiner string, a node, or another query_plan

        if (OpenILS::QueryParser::_util::is_joiner($qnode)) {
            if ($abstract_query->{children}) {
                my $open_joiner = (keys(%{$abstract_query->{children}}))[0];
                next if $open_joiner eq $qnode;

                my $oldroot = $abstract_query->{children};
                $kids = [$oldroot];
                $abstract_query->{children} = {$qnode => $kids};
            } else {
                $abstract_query->{children} = {$qnode => $kids};
            }
        } else {
            push @$kids, $qnode->to_abstract_query(%opts);
        }
    }

    $abstract_query->{children} ||= { OpenILS::QueryParser::_util::default_joiner() => $kids };
    return $abstract_query;
}


#-------------------------------
package OpenILS::QueryParser::query_plan::node;
use Data::Dumper;
$Data::Dumper::Indent = 0;

sub new {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my %args = @_;

    return bless \%args => $pkg;
}

sub new_atom {
    my $self = shift;
    my $pkg = ref($self) || $self;
    return do{$pkg.'::atom'}->new( @_ );
}

sub requested_class { # also split into classname, fields and alias
    my $self = shift;
    my $class = shift;

    if ($class) {
        my @afields;
        my (undef, $alias) = split '#', $class;
        if ($alias) {
            $class =~ s/#[^|]+//;
            ($alias, @afields) = split '\|', $alias;
        }

        my @fields = @afields;
        my ($class_part, @field_parts) = split '\|', $class;
        for my $f (@field_parts) {
             push(@fields, $f) unless (grep { $f eq $_ } @fields);
        }

        $class_part ||= $class;

        $self->{requested_class} = $class;
        $self->{alias} = $alias if $alias;
        $self->{alias_fields} = \@afields if $alias;
        $self->{classname} = $class_part;
        $self->{fields} = \@fields;
    }

    return $self->{requested_class};
}

sub plan {
    my $self = shift;
    my $plan = shift;

    $self->{plan} = $plan if ($plan);
    return $self->{plan};
}

sub alias {
    my $self = shift;
    my $alias = shift;

    $self->{alias} = $alias if ($alias);
    return $self->{alias};
}

sub alias_fields {
    my $self = shift;
    my $alias = shift;

    $self->{alias_fields} = $alias if ($alias);
    return $self->{alias_fields};
}

sub classname {
    my $self = shift;
    my $class = shift;

    $self->{classname} = $class if ($class);
    return $self->{classname};
}

sub fields {
    my $self = shift;
    my @fields = @_;

    $self->{fields} ||= [];
    $self->{fields} = \@fields if (@fields);
    return $self->{fields};
}

sub phrases {
    my $self = shift;
    my @phrases = @_;

    $self->{phrases} ||= [];
    $self->{phrases} = \@phrases if (@phrases);
    return $self->{phrases};
}

sub add_phrase {
    my $self = shift;
    my $phrase = shift;

    push(@{$self->phrases}, $phrase);

    return $self;
}

sub negate {
    my $self = shift;
    my $negate = shift;

    $self->{negate} = $negate if (defined $negate);

    return $self->{negate};
}

sub query_atoms {
    my $self = shift;
    my @query_atoms = @_;

    $self->{query_atoms} ||= [];
    $self->{query_atoms} = \@query_atoms if (@query_atoms);
    return $self->{query_atoms};
}

sub add_fts_atom {
    my $self = shift;
    my $atom = shift;

    if (!ref($atom)) {
        my $content = $atom;
        my @parts = @_;

        $atom = $self->new_atom( content => $content, @parts );
    }

    push(@{$self->query_atoms}, $self->plan->joiner) if (@{$self->query_atoms});
    push(@{$self->query_atoms}, $atom);

    return $self;
}

sub add_dummy_atom {
    my $self = shift;
    my @parts = @_;

    my $atom = $self->new_atom( @parts, dummy => 1 );

    push(@{$self->query_atoms}, $self->plan->joiner) if (@{$self->query_atoms});
    push(@{$self->query_atoms}, $atom);

    return $self;
}

# This will find up to one occurence of @$short_list within @$long_list, and
# replace it with the single atom $replacement.
sub replace_phrase_in_abstract_query {
    my ($self, $short_list, $long_list, $replacement) = @_;

    my $success = 0;
    my @already = ();
    my $goal = scalar @$short_list;

    for (my $i = 0; $i < scalar (@$long_list); $i++) {
        my $right = $long_list->[$i];

        if (OpenILS::QueryParser::_util::compare_abstract_atoms(
            $short_list->[scalar @already], $right
        )) {
            push @already, $i;
        } elsif (scalar @already) {
            @already = ();
            next;
        }

        if (scalar @already == $goal) {
            splice @$long_list, $already[0], scalar(@already), $replacement;
            $success = 1;
            last;
        }
    }

    return $success;
}

sub to_abstract_query {
    my $self = shift;
    my %opts = @_;

    my $pkg = ref $self->plan->QueryParser || $self->plan->QueryParser;

    my $abstract_query = {
        "type" => "node",
        "alias" => $self->alias,
        "alias_fields" => $self->alias_fields,
        "class" => $self->classname,
        "fields" => $self->fields
    };

    my $kids = [];

    for my $qatom (@{$self->query_atoms}) {
        if (OpenILS::QueryParser::_util::is_joiner($qatom)) {
            if ($abstract_query->{children}) {
                my $open_joiner = (keys(%{$abstract_query->{children}}))[0];
                next if $open_joiner eq $qatom;

                my $oldroot = $abstract_query->{children};
                $kids = [$oldroot];
                $abstract_query->{children} = {$qatom => $kids};
            } else {
                $abstract_query->{children} = {$qatom => $kids};
            }
        } else {
            push @$kids, $qatom->to_abstract_query;
        }
    }

    $abstract_query->{children} ||= { OpenILS::QueryParser::_util::default_joiner() => $kids };

    if ($self->{phrases} and not $opts{no_phrases}) {
        for my $phrase (@{$self->{phrases}}) {
            # Phrases appear duplication in a real QP tree, and we don't want
            # that duplication in our abstract query.  So for all our phrases,
            # break them into atoms as QP would, and remove any matching
            # sequences of atoms from our abstract query.

            my $tmp_prefix = '';
            $tmp_prefix = $OpenILS::QueryParser::parser_config{$pkg}{operators}{disallowed} if ($self->{negate});

            my $tmptree = $self->{plan}->{QueryParser}->new(query => $tmp_prefix.'"'.$phrase.'"')->parse->parse_tree;
            if ($tmptree) {
                # For a well-behaved phrase, we should now have only one node
                # in the $tmptree query plan, and that node should have an
                # orderly list of atoms and joiners.

                if ($tmptree->{query} and scalar(@{$tmptree->{query}}) == 1) {
                    my $tmplist;

                    eval {
                        $tmplist = $tmptree->{query}->[0]->to_abstract_query(
                            no_phrases => 1
                        )->{children}->{'&'}->[0]->{children}->{'&'};
                    };
                    next if $@;

                    foreach (
                        OpenILS::QueryParser::_util::find_arrays_in_abstract($abstract_query->{children})
                    ) {
                        last if $self->replace_phrase_in_abstract_query(
                            $tmplist,
                            $_,
                            OpenILS::QueryParser::_util::fake_abstract_atom_from_phrase($phrase, $self->{negate}, $pkg)
                        );
                    }
                }
            }
        }
    }

    $abstract_query->{children} ||= { OpenILS::QueryParser::_util::default_joiner() => $kids };
    return $abstract_query;
}

#-------------------------------
package OpenILS::QueryParser::query_plan::node::atom;

sub new {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my %args = @_;

    return bless \%args => $pkg;
}

sub node {
    my $self = shift;
    return unless (ref $self);
    return $self->{node};
}

sub content {
    my $self = shift;
    return unless (ref $self);
    return $self->{content};
}

sub prefix {
    my $self = shift;
    return unless (ref $self);
    return $self->{prefix};
}

sub suffix {
    my $self = shift;
    return unless (ref $self);
    return $self->{suffix};
}

sub to_abstract_query {
    my ($self) = @_;

    return {
        (map { $_ => $self->$_ } qw/prefix suffix content/),
        "type" => "atom"
    };
}
#-------------------------------
package OpenILS::QueryParser::query_plan::filter;

sub new {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my %args = @_;

    return bless \%args => $pkg;
}

sub plan {
    my $self = shift;
    return $self->{plan};
}

sub name {
    my $self = shift;
    return $self->{name};
}

sub negate {
    my $self = shift;
    return $self->{negate};
}

sub args {
    my $self = shift;
    return $self->{args};
}

sub to_abstract_query {
    my ($self) = @_;

    return {
        map { $_ => $self->$_ } qw/name negate args/
    };
}

#-------------------------------
package OpenILS::QueryParser::query_plan::facet;

sub new {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my %args = @_;

    return bless \%args => $pkg;
}

sub plan {
    my $self = shift;
    return $self->{plan};
}

sub name {
    my $self = shift;
    return $self->{name};
}

sub negate {
    my $self = shift;
    return $self->{negate};
}

sub values {
    my $self = shift;
    return $self->{'values'};
}

sub to_abstract_query {
    my ($self) = @_;

    return {
        (map { $_ => $self->$_ } qw/name negate values/),
        "type" => "facet"
    };
}

#-------------------------------
package OpenILS::QueryParser::query_plan::modifier;

sub new {
    my $pkg = shift;
    $pkg = ref($pkg) || $pkg;
    my $modifier = shift;
    my $negate = shift;

    return bless { name => $modifier, negate => $negate } => $pkg;
}

sub name {
    my $self = shift;
    return $self->{name};
}

sub negate {
    my $self = shift;
    return $self->{negate};
}

sub to_abstract_query {
    my ($self) = @_;

    return $self->name;
}
1;
