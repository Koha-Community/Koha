[%# Summon this block to the template by INCLUDEing it like this in the header:
        % INCLUDE 'admin/floating-matrix-floatingType.inc' %
    You must have the required parameters in the template toolkit parameter-space.
%]
[%#REQUIRES branchRule (Koha::FloatingMatrix::BranchRule), fm (Koha::FloatingMatrix) %]
[% preselectedFloatingType = branchRule.getFloating() %]
    <select name="floating">
        <option value="DISABLED"[% IF ! preselectedFloatingType %] selected="selected"[% END %]>
            Disabled
        </option>

        [% FOR floatingType IN fm.getFloatingTypes() %]
            <option value="[% floatingType %]"[% IF floatingType == preselectedFloatingType %] selected="selected"[% END %]>
                [% SWITCH floatingType %]
                [% CASE 'ALWAYS' %]
                    Always
                [% CASE 'POSSIBLE' %]
                    Possible
                [% CASE 'CONDITIONAL' %]
                    Conditional
                [% CASE %]
                    Unknown floating type '[% floatingType %]'
                [% END #SWITCH floatingType %]
            </option>
        [% END #FOR fm.getFloatingTypes() %]
    </select>
