package Koha::MarcOverlayRules;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use List::Util qw(first any);
use Koha::MarcOverlayRule;
use Carp;

use Koha::Exceptions::MarcOverlayRule;
use Try::Tiny;
use Scalar::Util qw(looks_like_number);
use Clone        qw(clone);

use parent qw(Koha::Objects);

my $cache = Koha::Caches->get_instance();

=head1 NAME

Koha::MarcOverlayRules - Koha MarcOverlayRules Object set class

=head1 API

=head2 Class methods

=head3 operations

Returns a list of all valid operations.

=cut

sub operations {
    return ( 'add', 'append', 'remove', 'delete' );
}

=head3 modules

Returns a list of all modules in order of priority.

=cut

sub modules {
    return ( 'userid', 'categorycode', 'source' );
}

=head3 context_rules

    my $rules = Koha::MarcOverlayRules->context_rules($context);

Gets all MARC overlay rules for the supplied C<$context> (hashref with { module => filter, ... } values).

=cut

sub context_rules {
    my ( $self, $context ) = @_;

    return unless %{$context};

    my $rules = $cache->get_from_cache( 'marc_overlay_rules', { unsafe => 1 } );

    if ( !$rules ) {
        $rules = {};
        my @rules_rows = $self->_resultset()->search(
            undef,
            { order_by => { -desc => [qw/id/] } }
        );
        foreach my $rule_row (@rules_rows) {
            my %rule       = $rule_row->get_columns();
            my $operations = {};

            foreach my $operation ( $self->operations ) {
                $operations->{$operation} = { allow => $rule{$operation}, rule => $rule{id} };
            }

            # TODO: Remove unless check and validate on saving rules?
            if ( $rule{tag} eq '*' ) {
                unless ( exists $rules->{ $rule{module} }->{ $rule{filter} }->{'*'} ) {
                    $rules->{ $rule{module} }->{ $rule{filter} }->{'*'} = $operations;
                }
            } elsif ( $rule{tag} =~ /^(\d{3})$/ ) {
                unless ( exists $rules->{ $rule{module} }->{ $rule{filter} }->{tags}->{ $rule{tag} } ) {
                    $rules->{ $rule{module} }->{ $rule{filter} }->{tags}->{ $rule{tag} } = $operations;
                }
            } else {
                my $regexps = ( $rules->{ $rule{module} }->{ $rule{filter} }->{regexps} //= [] );
                push @{$regexps}, [ $rule{tag}, $operations ];
            }
        }
        $cache->set_in_cache( 'marc_overlay_rules', $rules );
    }

    my $context_rules;
    my @context_modules = grep { exists $context->{$_} } $self->modules();

    foreach my $module_name (@context_modules) {
        if (   exists $rules->{$module_name}
            && exists $rules->{$module_name}->{ $context->{$module_name} } )
        {
            $context_rules = $rules->{$module_name}->{ $context->{$module_name} };

            unless ( exists $rules->{$module_name}->{'*'} ) {

                # No wildcard filter rules defined
                last;
            }

            # Merge in all wildcard filter rules which has not been overridden
            # by the matching context
            if ( $context_rules->{'*'} ) {

                # Wildcard tag for matching context will override all rules,
                # nothing left to do
                last;
            }

            # Clone since we will potentially be modified cached value
            # fetched with unsafe => 1
            $context_rules = clone($context_rules);

            if ( exists $rules->{$module_name}->{'*'}->{'*'} ) {

                # Merge in wildcard filter wildcard tag rule if exists
                $context_rules->{'*'} = $rules->{$module_name}->{'*'}->{'*'};
            }

            if ( exists $rules->{$module_name}->{'*'}->{tags} ) {
                if ( exists $context_rules->{regexps} ) {

                    # If the current context has regexp rules, we have to make sure
                    # to not only to skip tags already present but also those matching
                    # any of those rules

                    my @regexps = map { qr/^$_->[0]$/ } @{ $context_rules->{regexps} };

                    foreach my $tag ( keys %{ $rules->{$module_name}->{'*'}->{tags} } ) {
                        unless ( ( any { $tag =~ $_ } @regexps ) || exists $context_rules->{tags}->{$tag} ) {
                            $context_rules->{tags}->{$tag} = $rules->{$module_name}->{'*'}->{tags}->{$tag};
                        }
                    }
                } else {

                    # Merge in wildcard filter tag rules not already present
                    # in the matching context
                    foreach my $tag ( keys %{ $rules->{$module_name}->{'*'}->{tags} } ) {
                        unless ( exists $context_rules->{tags}->{$tag} ) {
                            $context_rules->{tags}->{$tag} = $rules->{$module_name}->{'*'}->{tags}->{$tag};
                        }
                    }
                }
            }

            if ( exists $rules->{$module_name}->{'*'}->{regexps} ) {

                # Merge in wildcard filter regexp rules last, making sure rules from the
                # matching context have precedence
                $context_rules->{regexps} //= [];
                push @{ $context_rules->{regexps} }, @{ $rules->{$module_name}->{'*'}->{regexps} };
            }

            last;
        }
    }

    if ( !$context_rules ) {

        # No rules matching specific context conditions found, try wildcard value for each active context
        foreach my $module_name (@context_modules) {
            if ( exists $rules->{$module_name}->{'*'} ) {
                $context_rules = $rules->{$module_name}->{'*'};
                last;
            }
        }
    }
    return $context_rules;
}

=head3 merge_records

    my $merged_record = Koha::MarcOverlayRules->merge_records($old_record, $incoming_record, $context);

Overlay C<$old_record> with C<$incoming_record> applying overlay rules for C<$context>.
Returns merged record C<$merged_record>. C<$old_record>, C<$incoming_record> and
C<$merged_record> are all MARC::Record objects.

=cut

sub merge_records {
    my ( $self, $old_record, $incoming_record, $context ) = @_;

    my $rules = $self->context_rules($context);

    # Default when no rules found is to overwrite with incoming record
    return $incoming_record unless $rules;

    my $fields_by_tag = sub {
        my ($record) = @_;
        my $fields = {};
        foreach my $field ( $record->fields() ) {
            $fields->{ $field->tag() } //= [];
            push @{ $fields->{ $field->tag() } }, $field;
        }
        return $fields;
    };

    my $hash_field_data = sub {
        my ($field) = @_;
        my $indicators = join( "\x1E", map { $field->indicator($_) } ( 1, 2 ) );
        return $indicators . "\x1E" . join( "\x1E", sort map { join "\x1E", @{$_} } $field->subfields() );
    };

    my $diff_by_key = sub {
        my ( $a, $b ) = @_;
        my @removed;
        my @intersecting;
        my @added;
        my %keys_index = map { $_ => undef } ( keys %{$a}, keys %{$b} );
        foreach my $key ( keys %keys_index ) {
            if ( $a->{$key} && $b->{$key} ) {
                push @intersecting, [ $a->{$key}, $b->{$key} ];
            } elsif ( $a->{$key} ) {
                push @removed, $a->{$key};
            } else {
                push @added, $b->{$key};
            }
        }
        return ( \@removed, \@intersecting, \@added );
    };

    my $tag_rules    = $rules->{tags} // {};
    my $default_rule = $rules->{'*'}  // {
        add    => { allow => 1, 'rule' => 0 },
        append => { allow => 1, 'rule' => 0 },
        delete => { allow => 1, 'rule' => 0 },
        remove => { allow => 1, 'rule' => 0 },
    };

    # Precompile regexps
    my @regexp_rules = map { { regexp => qr/^$_->[0]$/, actions => $_->[1] } } @{ $rules->{regexps} // [] };

    my $get_matching_field_rule = sub {
        my ($tag) = @_;

        # Exact match takes precedence, then regexp, then wildcard/defaults
        return $tag_rules->{$tag} // %{ ( first { $tag =~ $_->{regexp} } @regexp_rules ) // {} }{actions}
            // $default_rule;
    };

    my %merged_record_fields;

    my $current_fields  = $fields_by_tag->($old_record);
    my $incoming_fields = $fields_by_tag->($incoming_record);

    # First we get all new incoming fields
    my @new_field_tags = grep { !( exists $current_fields->{$_} ) } keys %{$incoming_fields};
    foreach my $tag (@new_field_tags) {
        my $rule = $get_matching_field_rule->($tag);
        if ( $rule->{add}->{allow} ) {
            $merged_record_fields{$tag} //= [];
            push @{ $merged_record_fields{$tag} }, @{ $incoming_fields->{$tag} };
        }
    }

    # Then we get all fields no longer present in incoming fields
    my @deleted_field_tags = grep { !( exists $incoming_fields->{$_} ) } keys %{$current_fields};
    foreach my $tag (@deleted_field_tags) {
        my $rule = $get_matching_field_rule->($tag);
        if ( !$rule->{delete}->{allow} ) {
            $merged_record_fields{$tag} //= [];
            push @{ $merged_record_fields{$tag} }, @{ $current_fields->{$tag} };
        }
    }

    # Then we get the intersection of fields, present both in
    # current and incoming record (possibly to be overwritten)
    my @common_field_tags = grep { exists $incoming_fields->{$_} } keys %{$current_fields};
    foreach my $tag (@common_field_tags) {
        my $rule = $get_matching_field_rule->($tag);

        # Special handling for control fields
        if ( $tag < 10 ) {
            if ( $rule->{append}->{allow}
                && !$rule->{remove}->{allow} )
            {
                # This should be highly unlikely since we have input validation to protect against this case
                carp
                    "Allowing \"append\" and skipping \"remove\" is not permitted for control fields, falling back to skipping both \"append\" and \"remove\"";
                push @{ $merged_record_fields{$tag} }, @{ $current_fields->{$tag} };
            } elsif ( $rule->{append}->{allow} ) {
                push @{ $merged_record_fields{$tag} }, @{ $incoming_fields->{$tag} };
            } else {
                push @{ $merged_record_fields{$tag} }, @{ $current_fields->{$tag} };
            }
        } else {

            # Compute intersection and diff using field data
            my $sort_weight = 0;
            my %current_fields_by_data =
                map { $hash_field_data->($_) => [ $sort_weight++, $_ ] } @{ $current_fields->{$tag} };

            # Always put incoming fields after current fields
            my %incoming_fields_by_data =
                map { $hash_field_data->($_) => [ $sort_weight++, $_ ] } @{ $incoming_fields->{$tag} };

            my ( $current_fields_only, $common_fields, $incoming_fields_only ) =
                $diff_by_key->( \%current_fields_by_data, \%incoming_fields_by_data );

            my @merged_fields;

            # First add common fields (intersection)
            # Unchanged
            if ( @{$common_fields} ) {
                if (
                       $rule->{delete}->{allow}
                    && $rule->{add}->{allow}
                    && (
                        @{$common_fields} == 1
                        || (   $rule->{append}->{allow}
                            && $rule->{remove}->{allow} )
                    )
                    )
                {
                    # If overwritable apply possible subfield order
                    # changes from incoming fields
                    push @merged_fields, map { $_->[1] } @{$common_fields};
                } else {

                    # else keep existing subfield order
                    push @merged_fields, map { $_->[0] } @{$common_fields};
                }
            }

            # Removed
            if ( @{$current_fields_only} ) {
                if ( !$rule->{remove}->{allow} ) {
                    push @merged_fields, @{$current_fields_only};
                }
            }

            # Appended
            if ( @{$incoming_fields_only} ) {
                if ( $rule->{append}->{allow} ) {
                    push @merged_fields, @{$incoming_fields_only};
                }
            }
            $merged_record_fields{$tag} //= [];

            # Sort ascending according to weight (original order)
            push @{ $merged_record_fields{$tag} }, map { $_->[1] } sort { $a->[0] <=> $b->[0] } @merged_fields;
        }
    }

    my $merged_record = MARC::Record->new();

    # Leader is always overwritten, or kept???
    $merged_record->leader( $incoming_record->leader() );

    if (%merged_record_fields) {
        foreach my $tag ( sort keys %merged_record_fields ) {
            $merged_record->append_fields( @{ $merged_record_fields{$tag} } );
        }
    }
    return $merged_record;
}

sub _clear_caches {
    $cache->clear_from_cache('marc_overlay_rules');
}

=head2 find_or_create

Override C<find_or_create> to clear marc overlay rules cache.

=cut

sub find_or_create {
    my $self = shift @_;
    $self->_clear_caches();
    return $self->SUPER::find_or_create(@_);
}

=head2 update

Override C<update> to clear marc overlay rules cache.

=cut

sub update {
    my $self = shift @_;
    $self->_clear_caches();
    return $self->SUPER::update(@_);
}

=head2 delete

Override C<delete> to clear marc overlay rules cache.

=cut

sub delete {
    my $self = shift @_;
    $self->_clear_caches();
    return $self->SUPER::delete(@_);
}

=head2 validate

    Koha::MarcOverlayRules->validate($rule_data);

Validates C<$rule_data>. Throws C<Koha::Exceptions::MarcOverlayRule::InvalidTagRegExp>
if C<$rule_data->{tag}> contains an invalid regular expression. Throws
C<Koha::Exceptions::MarcOverlayRule::InvalidControlFieldActions> if contains invalid
combination of actions for control fields. Otherwise returns true.

=cut

sub validate {
    my ( $self, $rule_data ) = @_;

    if ( exists $rule_data->{tag} ) {
        if ( $rule_data->{tag} ne '*' ) {
            eval { qr/$rule_data->{tag}/ };
            if ($@) {
                Koha::Exceptions::MarcOverlayRule::InvalidTagRegExp->throw("Invalid tag regular expression");
            }
        }

        # TODO: Regexp or '*' that match controlfield not currently detected
        if (   looks_like_number( $rule_data->{tag} )
            && $rule_data->{tag} < 10
            && $rule_data->{append}
            && !$rule_data->{remove} )
        {
            Koha::Exceptions::MarcOverlayRule::InvalidControlFieldActions->throw(
                "Combination of allow append and skip remove not permitted for control fields");
        }
    }
    return 1;
}

sub _type {
    return 'MarcOverlayRule';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::MarcOverlayRule';
}

1;
