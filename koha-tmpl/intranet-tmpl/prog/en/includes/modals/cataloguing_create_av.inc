<div id="avCreate" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="avCreateLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="closebtn" data-dismiss="modal" aria-hidden="true">×</button>
                <h3 id="avCreateLabel">Create a new authorised value</h3>
            </div>
            <form id="add_new_av" method="post">
                <div class="modal-body">
                    <div class="error"></div>
                    <fieldset class="rows">
                        <ol>
                            <li>
                                <span class="label">Category:</span>
                                <input type="hidden" name="category" value="" />
                                <span id="new_av_category"></span>
                            </li>
                            <li>
                                <span class="label" for="value">Authorised value:</span>
                                <input type="text" id="value" name="value" />
                            </li>
                            <li>
                                <span class="label" for="description">Description:</span>
                                <input type="text" id="description" name="description" />
                            </li>
                            <li>
                                <span class="label" for="opac_description">Description (OPAC):</span>
                                <input type="text" id="opac_description" name="opac_description" />
                            </li>
                        </ol>
                    </fieldset>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default" data-dismiss="modal" aria-hidden="true">Close</button>
                    <input type="hidden" name="select2" value="" />
                    <input type="submit" class="btn btn-primary" value="Save">
                </div>
            </form>
        </div> <!-- /.modal-content -->
    </div> <!-- /.modal-dialog -->
</div> <!-- /#avCreate -->
