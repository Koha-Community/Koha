<script>
   var showLastPatronCount = "[% Koha.Preference('showLastPatronCount') | html %]";
</script>
<div id="lastborrower-window">
    <div class="btn-group">
        <a class="btn btn-default navbar-btn lastborrower" id="lastborrowerlink" href="#" title=""><i class="fa fa-arrow-right"></i> Last patron</a>
        <button type="button" data-toggle="dropdown" class="btn btn-default navbar-btn dropdown-toggle" aria-haspopup="true" aria-expanded="false">
            <span class="caret"></span>
            <span class="sr-only">Toggle Dropdown</span>
        </button>
        <ul id="lastBorrowerList" class="dropdown-menu">
            <li role="separator" class="divider"></li>
            <li><a id="lastborrower-remove" class="lastborrower" href="#">Clear list</a></li>
        </ul>
    </div>
</div>
