[%- BLOCK keyboard_shortcut_descriptions -%]
    [% SWITCH shortcut_name %]
    [%- CASE 'insert_copyright' -%]
        <span>Insert copyright symbol (©)</span>
    [%- CASE 'insert_copyright_sound' -%]
        <span>Insert copyright symbol (℗) (sound recordings)</span>
    [%- CASE 'insert_delimiter' -%]
        <span>Insert delimiter (‡)</span>
    [%- CASE 'subfield_help' -%]
        <span>Get help on current subfield</span>
    [%- CASE 'link_authorities' -%]
        <span>Link field to authorities</span>
    [%- CASE 'delete_field' -%]
        <span>Delete current field and copy to 'clipboard'</span>
    [%- CASE 'delete_subfield' -%]
        <span>Delete current subfield and copy to 'clipboard'</span>
    [%- CASE 'new_line' -%]
        <span>New field on next line</span>
    [%- CASE 'line_break' -%]
        <span>Insert line break</span>
    [%- CASE 'next_position' -%]
        <span>Move to next position</span>
    [%- CASE 'prev_position' -%]
        <span>Move to previous position</span>
    [%- CASE 'toggle_keyboard' -%]
        <span>Toggle Keyboard</span>
    [%- CASE 'copy_line' -%]
        <span>Copy current field</span>
    [%- CASE 'copy_subfield' -%]
        <span>Copy current subfield</span>
    [%- CASE 'paste_line' -%]
        <span>Paste selection from 'clipboard'</span>
    [%- CASE 'insert_line' -%]
        <span>Copy current field on next line</span>
    [%- END -%]
[%- END -%]
