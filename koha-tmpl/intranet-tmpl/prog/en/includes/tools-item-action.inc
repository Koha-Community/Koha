          <select name="item_action" id="item_action">
            <!-- TMPL_IF NAME="item_action_always_add" -->
                <option value="always_add" selected="selected">
            <!-- TMPL_ELSE -->
                <option value="always_add">
            <!-- /TMPL_IF -->
                Always add items</option>
            <!-- TMPL_IF NAME="item_action_add_only_for_matches" -->
                <option value="add_only_for_matches" selected="selected">
            <!-- TMPL_ELSE -->
                <option value="add_only_for_matches">
            <!-- /TMPL_IF -->
                Add items only if matching bib was found</option>
            <!-- TMPL_IF NAME="item_action_add_only_for_new" -->
                <option value="add_only_for_new" selected="selected">
            <!-- TMPL_ELSE -->
                <option value="add_only_for_new">
            <!-- /TMPL_IF -->
                Add items only if no matching bib was found</option>
            <!-- TMPL_IF NAME="item_action_ignore" -->
                <option value="ignore" selected="selected">
            <!-- TMPL_ELSE -->
                <option value="ignore">
            <!-- /TMPL_IF -->
                Ignore items</option>
        </select>
