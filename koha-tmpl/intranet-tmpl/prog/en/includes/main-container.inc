[% USE raw %]
[% USE Asset %]
<div class="main container-fluid">
    <div class="row">
        [% IF aside && !asides %]
            [% SET asides = [aside] %]
        [% END %]
        [% IF asides || aside_block %]
            <div class="col-md-10 order-sm-1 order-md-2">
                <main>
                    [% INCLUDE 'messages.inc' %]
                    [% content | $raw %]
                </main>
            </div>
            <div class="col-md-2 order-sm-2 order-md-1" id="sidebar-container">
                <aside>
                    <div class="sidebar-toggle">
                        <button id="toggle-sidebar" class="btn btn-default" aria-controls="sidebar-container" aria-expanded="true" title="Toggle sidebar">
                            <i class="fa fa-chevron-left" aria-hidden="true"></i>
                        </button>
                    </div>
                    [% IF aside_block %]
                        [% aside_block %]
                    [% ELSE %]
                        [% FOR aside IN asides %]
                            [% SWITCH aside %]
                            [% CASE 'acquisitions-menu' %]
                                [% INCLUDE 'acquisitions-menu.inc' %]
                            [% CASE 'admin-menu' %]
                                [% INCLUDE 'admin-menu.inc' %]
                            [% CASE 'biblio-view-menu' %]
                                [% INCLUDE 'biblio-view-menu.inc' %]
                            [% CASE 'cat-menu' %]
                                [% INCLUDE 'cat-menu.inc' %]
                            [% CASE 'circ-menu' %]
                                [% INCLUDE 'circ-menu.inc' %]
                            [% CASE 'circ-nav' %]
                                [% INCLUDE 'circ-nav.inc' %]
                            [% CASE 'facets' %]
                                [% INCLUDE 'facets.inc' %]
                            [% CASE 'guided-reports-view' %]
                                [% INCLUDE 'guided-reports-view.inc' %]
                            [% CASE 'ill-filter' %]
                                [% INCLUDE 'ill-filter.inc' %]
                            [% CASE 'labels-menu' %]
                                [% INCLUDE 'labels-menu.inc' %]
                                [% INCLUDE 'cat-menu.inc' %]
                            [% CASE 'vendor-menu' %]
                                [% INCLUDE 'vendor-menu.inc' %]
                            [% CASE 'pos-menu' %]
                                [% INCLUDE 'pos-menu.inc' %]
                            [% CASE 'prefs-menu' %]
                                [% INCLUDE 'prefs-menu.inc' %]
                            [% CASE 'reports-menu' %]
                                [% INCLUDE 'reports-menu.inc' %]
                            [% CASE 'serials-advsearch_brief' %]
                                [% INCLUDE 'serials-advsearch.inc' brief=1 %]
                            [% CASE 'serials-menu' %]
                                [% INCLUDE 'serials-menu.inc' %]
                            [% CASE 'subscriptions-search' %]
                                [% INCLUDE 'subscriptions-search.inc' %]
                            [% CASE 'tags-filter' %]
                                [% INCLUDE 'tags-filter.inc' %]
                            [% CASE 'tools-menu' %]
                                [% INCLUDE 'tools-menu.inc' %]
                            [% END %]
                        [% END %]
                    [% END %]
                </aside>
            </div>
        [% ELSIF wide_centered %]
            <div class="col-md-10 offset-md-1">
                <main>
                    [% INCLUDE 'messages.inc' %]
                    [% content | $raw %]
                </main>
            </div>
        [% ELSIF wide_full %]
            <div class="col-lg-8 offset-lg-2 col-xl-12 offset-xl-0">
                <main>
                    [% INCLUDE 'messages.inc' %]
                    [% content | $raw %]
                </main>
            </div>
        [% ELSE %]
            <div class="col-md-10 offset-md-1 col-lg-8 offset-lg-2">
                <main>
                    [% INCLUDE 'messages.inc' %]
                    [% content | $raw %]
                </main>
            </div>
        [% END %]
    </div>
</div>
[% SET islands = Asset.js("js/vue/dist/islands.esm.js").match('(src="([^"]+)")').1 %]
<script nonce="[% Koha.CSPNonce | $raw %]" type="importmap">
    { "imports": { "vue": "[% islands | $raw %]" } }
</script>
<script src="[% islands | $raw %]" type="module">
</script>
<script nonce="[% Koha.CSPNonce | $raw %]" type="module">
    import { hydrate } from "[% islands | $raw %]";
    hydrate();
</script>
