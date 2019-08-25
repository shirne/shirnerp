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
    <link href="__STATIC__/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css" rel="stylesheet">
    <link rel="stylesheet" href="__STATIC__/ionicons/css/ionicons.min.css">
    <link href="__STATIC__/admin/css/common.css?v={:config('template.static_version')}" rel="stylesheet">

    <!-- JavaScript -->
    <script src="__STATIC__/jquery/jquery.min.js"></script>
    <script src="__STATIC__/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script type="text/javascript">
        window.get_cate_url=function (model) {
            return "{:url('admin/index/getCate',['model'=>'__MODEL__'])}".replace('__MODEL__',model);
        };
        window.get_search_url=function (model) {
            return "{:url('admin/--model--/search')}".replace('--model--',model);
        };
        window.get_view_url=function (model,id) {
            var baseurl='';
            switch (model){
                case 'article':
                    baseurl="{:url('index/article/view',['id'=>0])}";
                    break;
                case 'product':
                    baseurl="{:url('index/product/view',['id'=>0])}";
                    break;
            }
            return baseurl.replace('0',id);
        };
        //地图密钥
        window['MAPKEY_BAIDU'] = '{:getSetting("mapkey_baidu")}';
        window['MAPKEY_GOOGLE'] = '{:getSetting("mapkey_google")}';
        window['MAPKEY_TENCENT'] = '{:getSetting("mapkey_tencent")}';
        window['MAPKEY_GAODE'] = '{:getSetting("mapkey_gaode")}';
    </script>

    <block name="header"></block>
    <script type="text/javascript">
        if(!window.IS_TOP && !window.frameElement){
            //console.log('{:url("index/index")}?url={:url()}')
            top.location = '{:url("index/index")}?url={:url()}'
        }
    </script>
</head>

<body>

    <block name="body" ></block>

    <script src="__STATIC__/moment/min/moment.min.js"></script>
    <script src="__STATIC__/moment/locale/zh-cn.js"></script>
    <script src="__STATIC__/bootstrap-datetimepicker/js/bootstrap-datetimepicker.min.js"></script>
    <script src="__STATIC__/admin/js/app.min.js?v={:config('template.static_version')}"></script>

    <block name="script"></block>
    <script type="text/javascript">
        jQuery(function ($) {
            var table = $('table.excel')
            if(table.length>0){
                table.each(function () {
                    var self=$(this)
                    var lastEle=null

                    $(window).bind('keyup',function (e) {
                        var cell,cellIndex,control,controlIndex,row;
                        var nextRow, nextCell, nextControl;
                        switch (e.keyCode) {
                            case 37: //left
                                if(lastEle && lastEle.is('select'))e.preventDefault();
                                if(!lastEle){
                                    self.find('tbody tr').eq(0).find('.form-control').eq(-1).focus()
                                }else{
                                    cell = lastEle.parents('td').prev('td');
                                    control = lastEle.prevAll('.form-control').eq(0);
                                    if(control.length>0){
                                        lastEle = control.focus()
                                    }else {
                                        while (cell && cell.length) {
                                            control = cell.find('.form-control').eq(-1)
                                            if (control.length > 0) {
                                                lastEle = control.focus()
                                                break;
                                            }
                                            cell = cell.prev('td');
                                        }
                                    }
                                }
                                break;
                            case 38: //top
                                if(lastEle && lastEle.is('select'))return;
                                if(lastEle && lastEle.is('.isgoods'))return;
                                if(!lastEle){
                                    self.find('tbody tr').eq(-1).find('.form-control').eq(0).focus()
                                }else{
                                    cell = lastEle.parents('td');
                                    row = cell.parents('tr').eq(0)
                                    cellIndex=row.find('td').index(cell)
                                    controlIndex = cell.find('.form-control').index(lastEle)

                                    nextRow = row.prev()
                                    if(nextRow.length>0){
                                        nextCell = nextRow.find('td').eq(cellIndex)
                                        nextControl = nextCell.find('.form-control').eq(controlIndex)
                                        if(nextControl.length<0){
                                            nextControl = nextCell.find('.form-control').eq(-1)
                                        }
                                        if(nextControl.length>0){
                                            lastEle = nextControl.focus()
                                        }
                                    }
                                }
                                break;
                            case 39: //right
                                if(lastEle && lastEle.is('select'))e.preventDefault();
                                if(!lastEle){
                                    self.find('tbody tr').eq(0).find('.form-control').eq(0).focus()
                                }else{
                                    control = lastEle.nextAll('.form-control').eq(0);
                                    if(control.length>0){
                                        lastEle = control.focus()
                                    }else {
                                        cell = lastEle.parents('td').next('td');
                                        while (cell && cell.length) {
                                            control = cell.find('.form-control').eq(0)
                                            if (control.length > 0) {
                                                lastEle = control.focus()
                                                break;
                                            }
                                            cell = cell.next('td');
                                        }
                                    }
                                }
                                break;
                            case 40: //bottom
                            case 13: //enter
                                if(lastEle && lastEle.is('select'))return;
                                if(lastEle && lastEle.is('.isgoods'))return;
                                if(!lastEle){
                                    self.find('tbody tr').eq(0).find('.form-control').eq(0).focus()
                                }else{
                                    cell = lastEle.parents('td');
                                    row = cell.parents('tr').eq(0)
                                    cellIndex=row.find('td').index(cell)
                                    controlIndex = cell.find('.form-control').index(lastEle)

                                    nextRow = row.next()
                                    if(nextRow.length>0){
                                        nextCell = nextRow.find('td').eq(cellIndex)
                                        nextControl = nextCell.find('.form-control').eq(controlIndex)
                                        if(nextControl.length<0){
                                            nextControl = nextCell.find('.form-control').eq(-1)
                                        }
                                        if(nextControl.length>0){
                                            lastEle = nextControl.focus()
                                        }
                                    }
                                }
                                break;

                            case 27: //esc
                                if(lastEle){
                                    $(lastEle).blur()
                                }
                                break;
                            default:
                                return;
                        }
                        if(lastEle && lastEle.is('input')){
                            lastEle.select()
                        }
                    });
                    $(document.body).on('focus','.form-control',function (e) {
                        lastEle = $(this)
                    });
                })
            }
        });
        (function(){
            if(!window.IS_TOP){
                var curkey = $(window.frameElement).data('key');

                $('a[data-tab],.alert a').click(function (e) {
                    e.preventDefault();
                    var islist = window.IS_LIST;
                    var url=$(this).attr('href');
                    var subkey = $(this).data('tab');
                    var key = curkey + '_';
                    if(subkey === 'random') {
                        key += Math.random().toString().substr(2);
                    }else if(subkey === 'timestamp'){
                        key += new Date().getTime();
                    }else{
                        if(!subkey)subkey=url.replace(/[^a-zA-Z0-9]/g,'_');
                        key += subkey;
                    }
                    var title=$(this).text();
                    if(!title)title=$(this).attr('title');
                    top.createPage(key, title, url, curkey);
                });
                $('a[data-nav]').click(function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    top.createNavPage($(this).data('nav'));
                });
                if(window.page_title){
                    top.updatePage(curkey, window.page_title);
                }else {
                    var title = $('.breadcrumb').data('title');
                    if (title) {
                        top.updatePage(curkey, title);
                    }
                }

                $('.bread_refresh').click(function (e) {
                    location.reload();
                });

                $(document.body).click(function () {
                    top.$(top.document.body).trigger('click');
                });
            }
        })();

    </script>
</body>
</html>