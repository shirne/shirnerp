<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge;chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>{:lang('Dashboard')}</title>

    <!-- Bootstrap core CSS -->
    <link href="__STATIC__/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- Add custom CSS here -->
    <link rel="stylesheet" href="__STATIC__/ionicons/css/ionicons.min.css">
    <link href="__STATIC__/admin/css/common.css?v={:config('template.static_version')}" rel="stylesheet">

    <!-- JavaScript -->
    <script src="__STATIC__/jquery/jquery.min.js"></script>
    <script src="__STATIC__/bootstrap/js/bootstrap.bundle.min.js"></script>
    <style type="text/css">
        body{
            padding:0;
        }
        @page {
          size: A4;  /* auto is the initial value */
          margin: 10mm; /* this affects the margin in the printer settings */
        }
        #page-wrapper{
            padding:0;
        }
        .print-page {
            padding:50px 0;
            font-size:9pt;
            height:100%;
            vertical-align: middle;
            
        }
        .print-page .bigger{
            font-weight: bold;
            font-size:60pt;
        }
        .print-page h1,
        .print-page h2,
        .print-page h3,
        .print-page h4,
        .print-page h5,
        .print-page h6{
            font-weight: bold;
        }
        .print-page h1{
            font-size:36pt;
        }
        .print-page h2{
            font-size:30pt;
        }
        .print-page h3{
            font-size:24pt;
        }
        .print-page h4{
            font-size:16pt;
        }
        .print-page h5{
            font-size:12pt;
        }
        .print-page h6{
            font-size:9pt;
        }
        .table-page h1{
            font-size:2.5em;
        }
        .table-page h2{
            font-size:2em;
        }
        .table-page h3{
            font-size:1.75em;
        }
        .table-page h4{
            font-size:1.5em;
        }
        .table-page h5{
            font-size:1.25em;
        }
        .table-page h6{
             font-size:1em;
         }
        .table-page table{
            font-size:1em;
        }
        @media screen {
            #page-wrapper{
                margin-bottom:3em !important;
            }
        }
    </style>
    {block name="header"}{/block}

</head>

<body>


    {block name="body" }{/block}


    {block name="script"}{/block}
</body>
</html>