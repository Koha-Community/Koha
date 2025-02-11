[%# To select all include with selectall = 1 %]
<div class="branchselector">
    <p
        ><a href="#" id="checkall"> <i class="fa fa-check"></i> Select all</a> | <a href="#" id="checknone"> <i class="fa fa-times"></i> Clear all</a></p
    >
    [% SET branches_for_loop = branches.hash(1).keys.nsort || [] %][%# Do not modify the original variable 'branches' %]
    [% WHILE branches_for_loop.size > 0 %]
        <div class="branchgridrow">
            [% FOREACH i IN branches_for_loop.splice(0, 4) %]
                [% i = i - 1 %]
                [% SET branch = branches.$i %]
                <div class="branchgriditem">
                    [% IF branch.selected || (selectall == 1) %]
                        <input id="branch_[% branch.branchcode | html %]" class="branch_select" type="checkbox" name="branch" value="[% branch.branchcode | html %]" checked="checked" />
                    [% ELSE %]
                        <input id="branch_[% branch.branchcode | html %]" class="branch_select" type="checkbox" name="branch" value="[% branch.branchcode | html %]" />
                    [% END %]

                    <label for="branch_[% branch.branchcode | html %]">[% branch.branchname | html %]</label>
                </div>
            [% END %]
        </div>
    [% END %]
</div>
