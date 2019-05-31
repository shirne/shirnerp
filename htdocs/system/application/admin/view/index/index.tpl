<extend name="public:base" />
<block name="header">
    <style type="text/css">
        html,body{height:100%;overflow:hidden;}
        body{
            padding-top: 3.5rem;
        }
        #wrapper{
            height :100%;
        }
    </style>
    <script type="text/javascript">
        window.IS_TOP = true;
    </script>
</block>
<block name="body">
    <!-- Sidebar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top" role="navigation">

        <a class="navbar-brand" href="{:url('index/index')}">{:lang('Management')}</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse justify-content-end navbar-ex1-collapse" id="navbarSupportedContent">

            <include file="public/sidebar" />

            <div class="nav navbar-nav navbar-user">

                <li class="dropdown user-dropdown">
                    <a href="javascript:" class="nav-link dropdown-toggle" data-toggle="dropdown"><i class="ion-md-person"></i> {:lang('Welcome %s',[session('adminname')])} <b class="caret"></b></a>
                    <div class="dropdown-menu">
                        <a class="dropdown-item" href="/" target="_blank"><i class="ion-md-home"></i> {:lang('Home ')}</a>
                        <a class="dropdown-item" href="{:url('index/clearcache')}"><i class="ion-md-sync"></i> {:lang('Clear Cache')}</a>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item" href="{:url('setting/index')}"><i class="ion-md-options"></i> {:lang('Settings')}</a>
                        <a class="dropdown-item" href="{:url('index/profile')}"><i class="ion-md-person"></i> {:lang('Profile')}</a>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item" href="{:url('login/logout')}"><i class="ion-md-log-out"></i> {:lang('Sign out')}</a>
                    </div>
                </li>
                </ul>
            </div>
        </div>
    </nav>
    <div id="wrapper">
        <div class="page-tabs">
            <div class="tab-header">
                <div class="arrow arrow-left"><i class="ion-md-arrow-dropleft"></i> </div>
                <div class="tabwrapper">
                <ul class="list-unstyled">

                </ul>
                </div>
                <div class="arrow arrow-right"><i class="ion-md-arrow-dropright"></i> </div>
            </div>
            <div class="tab-content"></div>
        </div>
    </div>
</block>

<block name="script">
    <script type="text/javascript">
        (function(){
            var func=arguments.callee;
            if(window.stop_ajax){
                setTimeout(func, 2000);
            }else {
                return;
            }
        })();
        if(window.frameElement){
            top.location = location.href;
        }
        jQuery(function ($) {

            var pages = [];
            var header_box=$('.tab-header ul');
            var content_box=$('.tab-content');
            var current_index=0;

            header_box.on('click','a',function (e) {
                e.stopPropagation();
                removePage($(this).parents('li').data('key'));
                //console.log(e);
            });
            header_box.on('click','li',function (e) {
                activePageByKey($(this).data('key'));
                //console.log(e);
            });

            function createPageByLink(link) {
                if(link) {
                    var key = $(link).data('key');
                    var url = $(link).attr('href');

                    createPage(key, $(link).text(), url);
                }
            }
            
            function createNavPage(key) {
                createPageByLink($('.side-nav a[data-key='+key+']')[0]);
            }

            function createPage(key, title ,url, fromkey) {
                var exist = existsPage(key);
                var refresh=false;
                if(exist === -1){
                    pages.push({
                        key:key,
                        title:title,
                        url:url,
                        refresh:false,
                        fromkey:fromkey
                    });
                    if(pages.length===1){
                        header_box.append('<li class="noclose h-'+key+'" data-key="'+key+'">'+title+'</li>');
                    }else {
                        header_box.append('<li class="h-' + key + '" data-key="' + key + '"><a class="float-right" href="javascript:"><i class="ion-md-close"></i> </a><span>' + title + '</span></li>');
                    }
                    content_box.append('<iframe class="c-'+key+'" data-key="' + key + '" src="'+url+'" frameborder="0"></iframe>');
                    refresh=true;
                }
                activePageByKey(key, refresh);
            }

            function activePageByKey(key, refresh) {
                var exist = existsPage(key);
                activePage(exist, refresh);
            }
            function activePage(idx, refresh) {
                var curPage = pages[idx];
                if(curPage) {
                    var key = curPage.key;
                    header_box.find('li').removeClass('active');
                    header_box.find('li.h-' + key).addClass('active');
                    content_box.find('iframe').removeClass('active');
                    content_box.find('iframe.c-' + key).addClass('active');
                    if(refresh ){
                        refreshPage(key, curPage.url);
                    }else if(curPage.refresh){
                        refreshPage(key);
                    }
                }

            }
            function refreshPage(key, url) {
                var frame = $('.c-'+key)[0];
                if(frame && frame.contentWindow){
                    if(url){
                        frame.contentWindow.location.href=url;
                    }else {
                        frame.contentWindow.location.reload();
                    }
                }
            }
            function updatePage(key, title) {
                var exist = existsPage(key);
                if(exist>-1){
                    var updatetitle=false;
                    if(typeof title === 'object'){
                        for(var i in title){
                            pages[exist][i]=title[i];
                            if(i==='title'){
                                updatetitle=true;
                            }else if(i === 'key'){
                                var newKey = title[i];
                                header_box.find('li.h-'+key)
                                    .removeClass('h-'+key)
                                    .addClass('h-'+newKey)
                                    .data('key',newKey);
                                content_box.find('.c-'+key)
                                    .removeClass('c-'+key)
                                    .addClass('c-'+newKey)
                                    .data('key',newKey);
                            }
                        }
                    }else{
                        updatetitle=true;
                        pages[exist].title = title;
                    }
                    header_box.find('li.h-' + key+' span').text(title);
                }
            }

            function existsPage(key){
                for(var i=0;i<pages.length;i++){
                    if(pages[i].key === key){
                        return i;
                    }
                }
                return -1;
            }
            function removePage(key) {
                var exist = existsPage(key);
                if(exist > 0){
                    var item = pages.splice(exist,1);
                    header_box.find('.h-'+key).remove();
                    content_box.find('.c-'+key).remove();

                    activePage(exist-1);
                }
            }

            function checkScroll(){

            }

            window.createPage = createPage;
            window.createNavPage=createNavPage;
            window.refreshPage = refreshPage;
            window.removePage = window.closePage = removePage;
            window.updatePage = updatePage;


            var navlinks=$('.side-nav a');
            navlinks.click(function (e) {
                e.preventDefault();

                var href=$(this).attr('href');
                if(href && href.indexOf('#') !== 0){
                    if(!$(this).is('.menu_top')){
                        $('.side-nav a.active').removeClass('active');
                        $(this).addClass("active");
                    }
                    createPageByLink(this);
                }
            }).eq(0).trigger('click');

            var initurl = '{$Request.get.url|filterurl}';
            if(initurl){
                var isnav=false;
                for(var i=0;i<navlinks.length;i++){
                    if(navlinks.eq(i).attr('href') === initurl){
                        isnav = navlinks.eq(i);
                        break;
                    }
                }

                if(isnav){
                    isnav.trigger('click');
                    isnav.parents('.card').find('.card-header a').trigger('click');
                }else{
                    createPage(initurl.replace('/admin/','').replace('.html','').replace('/','_'),'...',initurl);
                }
            }
        });
    </script>
</block>