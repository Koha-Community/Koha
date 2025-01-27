[% USE raw %]
[% BLOCK ill_request_log %]
    <p>
        [% log.timestamp | $KohaDates with_hours => 1 %] :
        [% IF log.patron %]
            [%- INCLUDE 'patron-title.inc' patron => log.patron hide_patron_infos_if_needed => 1 -%]
        [% ELSE %]
            [% PROCESS 'action-logs.inc' %]
            [% PROCESS translate_log_interface log_interface = log.interface %]
        [% END %]
        - <strong>[% action_label | html %]: </strong>
        [% content | $raw %]
    </p>
[% END %]
