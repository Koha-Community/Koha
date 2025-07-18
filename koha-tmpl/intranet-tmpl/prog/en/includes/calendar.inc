[% USE Asset %]
[% USE Koha %]
[% USE raw %]
<!-- calendar.inc -->
[% FILTER collapse %]
    <script>
        var debug    = "[% debug | html %]";
        var dateformat_pref = "[% Koha.Preference('dateformat') | html %]";
        var flatpickr_dateformat_string = "";
        var delimiter = "";
        var altinput_dateformat = "";
        switch ( dateformat_pref ){
            case "us":
                flatpickr_dateformat_string = "m/d/Y";
                altinput_dateformat = 'mm/dd/yyyy';
                delimiter = "/";
                break;
            case "metric":
                flatpickr_dateformat_string = "d/m/Y";
                 altinput_dateformat = 'dd/mm/yyyy';
                 delimiter = "/";
                break;
            case "dmydot":
                flatpickr_dateformat_string = "d.m.Y";
                altinput_dateformat = 'dd/mm/yyyy';
                delimiter = ".";
                break;
            default:
                flatpickr_dateformat_string = "Y-m-d";
                altinput_dateformat = 'yyyy/mm/dd';
                delimiter = "-";
        }
        var sentmsg = 0;
        var bidi = [% IF(bidi) %] true[% ELSE %] false[% END %];
        var calendarFirstDayOfWeek = '[% Koha.Preference('CalendarFirstDayOfWeek') | html %]';
        var flatpickr_timeformat_string = [% IF Koha.Preference('TimeFormat') == '12hr' %]"G:i K"[% ELSE %]"H:i"[% END %];
        var flatpickr_timeformat = [% IF Koha.Preference('TimeFormat') == '12hr' %]false[% ELSE %]true[% END %];
    </script>
    <!-- / calendar.inc -->
    [% Asset.js("js/calendar.js") | $raw %]
    [% Asset.js("lib/flatpickr/flatpickr.min.js") | $raw %]
    [% Asset.js("lib/flatpickr/shortcut-buttons-flatpickr.min.js") | $raw %]
    [% Asset.js("lib/maskito/maskito.core.js") | $raw %]
    [% Asset.js("lib/maskito/maskito.kit.js") | $raw %]
    <script>
        flatpickr.l10ns.default.weekdays       = flatpickr_weekdays;
        flatpickr.l10ns.default.months         = flatpickr_months;
        flatpickr.l10ns.default.rangeSeparator = flatpickr_rangeSeparator;
        let flatpickr_defaults = {
            allowInput: true,
            dateFormat: "Y-m-d",
            altInput: true,
            altFormat: flatpickr_dateformat_string,
            altInputClass: 'flatpickr-input',
            nextArrow: '<i class="fa fa-fw fa-arrow-right"></i>',
            prevArrow: '<i class="fa fa-fw fa-arrow-left"></i>',
            time_24hr: flatpickr_timeformat,
            defaultHour: 23,
            defaultMinute: 59,
            locale: {
                "firstDayOfWeek": calendarFirstDayOfWeek
            },
            onReady: function( selectedDates, dateStr, instance ){

                /* When onReady is triggered, remove any existing "clear date" link */
                $(instance.input).parent().find('.flatpickr_wrapper_' + instance.input.id).remove();

                /* When flatpickr instance is created, automatically append a "clear date" link */
                $(instance.input).find('~input.flatpickr:first')
                    /* Add a wrapper element so that we can prevent the clear button from wrapping */
                    .wrap("<span class='flatpickr_wrapper flatpickr_wrapper_"+instance.input.id+"'></span>")
                    .attr("autocomplete", "off")
                    .after( $("<a/>")
                        .attr("href","#")
                        .addClass("clear_date")
                        .on("click", function(e){
                            e.preventDefault();
                            instance.clear();
                        })
                        .addClass("fa fa-fw fa-times")
                        .attr("aria-hidden", true)
                        .attr("aria-label", _("Clear date") )
                    ).keydown(function(e) {
                        var key = (event.keyCode ? event.keyCode : event.which);
                        if ( key == 40 ) {
                            instance.set('allowInput',false);
                        }
                    });
                /* When flatpickr instance is ready, add maskito input mask */
                var thisInput = instance.input;
                let accepts_time = $(thisInput).data('flatpickr-enable-time');
                let accepts_period = $(thisInput).data('flatpickr-period');
                let accepts_time_only = $(thisInput).data('flatpickr-time-only');
                let maskitoOptions = {};
                if ( !accepts_period ) {
                    if ( accepts_time ) {
                        maskitoOptions = maskitoDateTimeOptionsGenerator({
                            dateMode: altinput_dateformat,
                            timeMode: 'HH:MM',
                            dateSeparator: delimiter,
                            overwiteMode: 'replace',
                        });
                   } else if ( accepts_time_only ) {
                        maskitoOptions = {
                            [% IF Koha.Preference('TimeFormat') == '12hr' -%] mask: [/\d/, /\d/, ':', /\d/, /\d/, ' ', /(a|A|p|P)/, /(m|M)/]
                            [%- ELSE -%]mask: [/\d/, /\d/, ':', /\d/, /\d/]
                            [%- END %],
                        };
                    } else {
                        maskitoOptions = maskitoDateOptionsGenerator({
                            mode: altinput_dateformat,
                            separator: delimiter,
                            overwiteMode: 'replace',
                        });
                    }
                }
                new Maskito( instance.altInput, maskitoOptions );

                /* If there is a node with data-date_to with the id of this node it means we are instantiating a 'from' for a date range */
                const toInput = instance.input;
                const fromInput = document.querySelector(`[data-date_to='${toInput.id}']`);
                if (fromInput && fromInput._flatpickr) {
                    const fromDate = fromInput._flatpickr.selectedDates[0];
                    if (fromDate) {
                        instance.set('minDate', fromDate);
                    }
                }

            },
            onChange: function( selectedDates, dateText, instance) {
                if (selectedDates.length === 0) {
                    return;
                }

                var thisInput = instance.input;
                let accepts_time = $(thisInput).data('flatpickr-enable-time');
                let accepts_time_only = $(thisInput).data('flatpickr-time-only');
                let accepts_period = $(thisInput).data('flatpickr-period');
                if ( !accepts_period ) {
                    if ( accepts_time ) {
                        let parsedDate = flatpickr.parseDate(dateText, instance.config.dateFormat);
                        if ( Number.isNaN(parsedDate.getHours()) ) {
                            instance.setDate(selectedDates[0].setHours(23, 59, 0, 0));
                        }
                    }
                }
            },
            onOpen: function( selectedDates, dateText, instance) {
                var thisInput = instance.input;
                let set_to_today = $(thisInput).data('flatpickr-set-to-today');
                if ( set_to_today ) {
                    if ( thisInput.value === '' ) {
                        instance.setDate( new Date() );
                    }
                }
            },
            onClose: function( selectedDates, dateText, instance) {
                validate_date( dateText, instance );
                var thisInput = instance.input;
                if ( thisInput.hasAttribute('data-date_to') ) {
                    var endPicker = document.querySelector("#"+thisInput.dataset.date_to)._flatpickr;
                    endPicker.set('minDate', selectedDates[0]);
                }

                let = on_close_focus = $(thisInput).data('flatpickr-on-close-focus');
                if ( on_close_focus ) {
                    $(on_close_focus).focus();
                }
            },
            plugins: [
              ShortcutButtonsPlugin({
                button: [
                  {
                    label: _("Yesterday")
                  },
                  {
                    label: _("Today")
                  },
                  {
                    label: _("Tomorrow")
                  }
                ],
                label: _("or"),
                onClick: (index, fp) => {
                  let date;
                  let hh = 23, mm = 59;
                  switch (index) {
                    case 0:
                      date = new Date().fp_incr(-1);
                      break;
                    case 1:
                      date = new Date();
                      if ( $(fp.input).data("flatpickr-pastinclusive") === true ) {
                        hh = date.getHours();
                        mm = date.getMinutes();
                      }
                      break;
                    case 2:
                      date = new Date().fp_incr(1);
                      break;
                  }
                  date.setHours(hh, mm, 0, 0);
                  fp.setDate(date);
                }
              })
            ]
        };

        flatpickr.setDefaults(flatpickr_defaults);

        function apply_flatpickr(input){
            let options = {};
            let refresh_max_date = 0;
            let disable_buttons = [];

            if( $(input).data("flatpickr-futureinclusive") === true
             || $(input).data("flatpickr-futuredate") === true ) {
                let original_date = $(input).val();
                if ( original_date ) {
                    original_date = flatpickr.parseDate(original_date, 'Y-m-d').getTime();
                    let tomorrow = new Date().fp_incr(1).getTime();

                    options['enable'] = [function(date){
                        date = date.getTime();
                        if ( date == original_date ) return true;
                        if ( date >= tomorrow)       return true;
                    }];
                }
                else {
                    if( $(input).data("flatpickr-futureinclusive") === true ) {
                        options['minDate'] = new Date().setHours(00, 00, 00, 00);
                    } else {
                        options['minDate'] = new Date().fp_incr(1);
                    }
                }

                disable_buttons.push(0); /* Yesterday */

                if ( $(input).data("flatpickr-futuredate") === true ) {
                    disable_buttons.push(1); /* Today */
                }
            }
            if( $(input).data("flatpickr-pastinclusive") === true ) {
                options['maxDate'] = new Date(); /* Not today or hh:mm will be 00:00 */
                refresh_max_date = 1;
                disable_buttons.push(2); /* Tomorrow */
            }
            if( $(input).data("flatpickr-pastdate") === true ) {
                options['maxDate'] = new Date().fp_incr(-1).setHours(23, 59, 00, 00);
                disable_buttons.push(1); /* Today */
                disable_buttons.push(2); /* Tomorrow */
            }
            if ( $(input).data('flatpickr-enable-time') === true ) {
                options['enableTime'] = true;
                options['dateFormat'] = "Y-m-d H:i";
                options['altFormat'] = flatpickr_dateformat_string + ", " + flatpickr_timeformat_string;
            }
            if ( $(input).data('flatpickr-disable-shortcuts') === true ) {
                options['plugins'] = [];
            }
            let maxDate = $(input).data("flatpickr-maxdate");
            if( typeof maxDate !== 'undefined' ) {
                options['maxDate'] = new Date(maxDate);
            }
            if( $(input).data("flatpickr-time-only") === true ) {
                options['enableTime'] = true;
                options['noCalendar'] = true;
                options['dateFormat'] = "H:i";
                options['defaultHour'] = "0";
                options['defaultMinute'] = "0";
                options['altFormat'] = flatpickr_timeformat_string;
                options['plugins'] = [];
            }

            let fp = $(input).flatpickr(options);

            $(disable_buttons).each(function(index, value){
                $(fp.calendarContainer).find(".shortcut-buttons-flatpickr-button[data-index='"+value+"']").prop("disabled", "disabled");
            });

            if ( refresh_max_date ) {
                /* Refresh the maxDate every 30 secondes to make sure the user will not
                   be stuck with the minute passed.
                   Adding 1 minute to not introduce a gap.
                   Example: last update at 40s, a new minute passed at 00.
                   Between 00 and 10s the user won't be able click 'Today'.
                */
                setInterval(() => {
                    let now = new Date();
                    fp.set("maxDate", now.setMinutes(now.getMinutes() + 1));
                }, 30000);
            }
        }

        $(document).ready(function(){
            $(".flatpickr").each(function(){
                apply_flatpickr(this);
            });
        });
    </script>
[% END %]
