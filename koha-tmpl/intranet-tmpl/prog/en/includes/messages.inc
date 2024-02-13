<div id="messages">
    [% INCLUDE 'blocking_errors.inc' %]
    [% IF dev_install && debug_programming_error %]
        <div class="dialog alert">Programming error: [% debug_programming_error %]</div>
    [% END %]
</div>
