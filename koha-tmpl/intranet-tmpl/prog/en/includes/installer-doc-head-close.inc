<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/jquery/jquery-ui-1.11.4.min.css" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/bootstrap/bootstrap.min.css" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/font-awesome/css/font-awesome.min.css" />
<link rel="stylesheet" type="text/css" media="print" href="[% interface %]/[% theme %]/css/print.css" />
<style type="text/css" media="screen">

[% IF ( login ) %]
    @import url([% interface %]/[% theme %]/css/login.css);
[% END %]

html { background: #eee; }

body {
        background: #fff;
        color: #000;
        font-family: Georgia, "Times New Roman", Times, serif;
        margin-left: 20%;
        margin-right: 20%;
        padding: .2em 2em;
}

h1 {
        color: #006;
        font-size: 2em;
        font-weight: normal;
        vertical-align:middle;
}

h2 { font-size: 1.75em; }

h3 {
        color: #006;
        font-size: 1.5em;
        font-weight: lighter;
}

p, li, dt {
        line-height: 140%;
        padding-bottom: 2px;
}

ul, ol { padding: 5px 5px 5px 20px; }

#logo { margin-bottom: 2em; }

.step a, .step input { font-size: 2em; }

td input { font-size: 1.5em; }

.step, th { text-align: right; }

#bloc25, .bloc25 {
        float:left;
        border:1px solid #000000;
        margin:0px;
        padding:0px;

}

#footer {
        text-align: center;
        border-top: 1px solid #ccc;
        padding-top: 1em;
        font-style: italic;
}

.update_error {
        color: red;
        font-weight: bold;
}

</style>

<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-2.2.3.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-migrate-1.3.0.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-ui-1.11.4.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/shortcut/shortcut.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/jquery.cookie.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/jquery.highlight-3.js"></script>
<script type="text/javascript" src="[% interface %]/lib/bootstrap/bootstrap.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/jquery.validate.min.js"></script>
<!-- koha core js -->
<script type="text/javascript" src="[% interface %]/[% theme %]/js/staff-global.js"></script>

<script type="text/javascript">
    //<![CDATA[
        function _(s) { return s } // dummy function for gettext
    //]]>
</script>
</head>
<body id="installer" class="installer">
