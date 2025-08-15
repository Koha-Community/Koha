[%# TABLE FILTER CONTROLS USAGE                                                                          %]
[%#    [ INCLUDE 'table-filters.inc'                                                                     %]
[%#        filters = [                                                                                   %]
[%#            { id = 'expired',   label_show = t('Show expired'),   label_hide = t('Hide expired') },   %]
[%#            { id = 'cancelled', label_show = t('Show cancelled'), label_hide = t('Hide cancelled') }, %]
[%#            { id = 'completed', label_show = t('Show completed'), label_hide = t('Hide completed') }  %]
[%#        ]                                                                                             %]
[%#        filter_class = 'bookings'  # Optional, defaults to 'filters'                                  %]
[%#    ]                                                                                                 %]
[%#                                                                                                      %]
[%# Parameters:                                                                                          %]
[%#   - filters: Array of filter objects with:                                                           %]
[%#       - id: Unique identifier for the filter                                                         %]
[%#       - label_show: Text when filter shows items                                                     %]
[%#       - label_hide: Text when filter hides items                                                     %]
[%#       - active: Boolean - filter starts active (optional, defaults to true)                          %]
[%#   - filter_class: CSS class prefix (optional, defaults to 'filters')                                 %]

[% IF filters && filters.size > 0 %]
    [% filter_class = filter_class || 'filters' %]

    <fieldset class="action filters filters-[% filter_class | html %] d-flex gap-2">
        [% FOREACH filter IN filters %]
            <a id="filter-[% filter.id | html %]" data-filter="[% filter.id | html %]" [% IF !filter.defined('active') || filter.active %]data-filtered[% END %]>
                <span><i class="fa fa-bars"></i> [% filter.label_show | html %]</span>
                <span><i class="fa fa-filter"></i> [% filter.label_hide | html %]</span>
            </a>
        [% END %]
    </fieldset>
[% END %]
