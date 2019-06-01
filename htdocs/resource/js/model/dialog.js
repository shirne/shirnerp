(function(window,$){
    var dialogTpl='<div class="modal fade" id="{@id}" tabindex="-1" role="dialog" aria-labelledby="{@id}Label" aria-hidden="true">\n' +
        '    <div class="modal-dialog">\n' +
        '        <div class="modal-content">\n' +
        '            <div class="modal-header">\n' +
        '                <h4 class="modal-title" id="{@id}Label"></h4>\n' +
        '                <button type="button" class="close" data-dismiss="modal">\n' +
        '                    <span aria-hidden="true">&times;</span>\n' +
        '                    <span class="sr-only">Close</span>\n' +
        '                </button>\n' +
        '            </div>\n' +
        '            <div class="modal-body">\n' +
        '            </div>\n' +
        '            <div class="modal-footer">\n' +
        '                <nav class="nav nav-fill"></nav>\n' +
        '            </div>\n' +
        '        </div>\n' +
        '    </div>\n' +
        '</div>';
    var dialogIdx=0;
    function Dialog(opts){
        if(!opts)opts={};
        //处理按钮
        if(opts.btns) {
            if (typeof(opts.btns) == 'string') {
                opts.btns = [{'text':opts.btns}];
            }
            else if(opts.btns instanceof Array) {
                for (var i = 0; i < opts.btns.length; i++) {
                    if (typeof(opts.btns[i]) == 'string') {
                        opts.btns[i] = {'text': opts.btns[i]};
                    }
                    if (opts.btns[i].isdefault) {
                        opts.defaultBtn = i;
                    }
                }
            }else{
                console.error('Dialog::construct argument btns error.');
                opts.btns=[];
            }
            if(opts.btns.length>0) {
                if (opts.defaultBtn === undefined) {
                    opts.defaultBtn = opts.btns.length - 1;
                    opts.btns[opts.defaultBtn].isdefault = true;
                }

                if (opts.btns[opts.defaultBtn] && !opts.btns[opts.defaultBtn]['type']) {
                    opts.btns[opts.defaultBtn]['type'] = 'primary';
                }
            }
        }

        this.options=$.extend({
            'id':'modal_dialog_'+dialogIdx++,
            'header':true,
            'footer':true,
            'backdrop':true,
            'size':'',
            'btns':[
                {'text':'取消','type':'secondary'},
                {'text':'确定','isdefault':true,'type':'primary'}
            ],
            'defaultBtn':1,
            'contentClass':'',
            'onsure':null,
            'onshow':null,
            'onshown':null,
            'onhide':null,
            'onhidden':null
        },opts);
        if(!this.options.btns || this.options.btns.length<1){
            this.options.footer=false;
        }

        this.closed=true;
        this.box=$(this.options.id);
    }
    Dialog.prototype.generBtn=function(opt,idx){
        if(opt['type'])opt['class']='btn-outline-'+opt['type'];
        return '<a href="javascript:" class="nav-item btn '+(opt['class']?opt['class']:'btn-outline-secondary')+'" data-index="'+idx+'">'+opt.text+'</a>';
    };
    Dialog.prototype.show=function(html,title){
        this.box=$('#'+this.options.id);
        if(!title)title='系统提示';

        if(this.box.length<1) {
            $(document.body).append(dialogTpl.replace('modal-body','modal-body'+(this.options.bodyClass?(' '+this.options.bodyClass):'')).compile({'id': this.options.id}));
            this.box=$('#'+this.options.id);
        }else{
            this.box.unbind();
        }
        if(!this.options.header){
            this.box.find('.modal-header').remove();
        }
        if(!this.options.footer){
            this.box.find('.modal-footer').remove();
        }
        if(this.options.backdrop!==true){
            this.box.data('backdrop',this.options.backdrop);

            //不需要背景的情况下会影响下面元素的点击
            if(this.options.backdrop===false) {
                this.box.css({'height':0,'overflow':'visible'});
            }
        }
        if(!this.options.keyboard){
            this.box.data('keyboard',false);
        }

        //this.box.find('.modal-footer .btn-primary').unbind();
        var self=this;
        Dialog.instance=self;

        //生成按钮
        var btns=[];
        for(var i=0;i<this.options.btns.length;i++){
            btns.push(this.generBtn(this.options.btns[i],i));
        }
        this.box.find('.modal-footer .nav').html(btns.join('\n'));

        var dialog=this.box.find('.modal-dialog');
        dialog.removeClass('modal-sm').removeClass('modal-lg');
        if(this.options.size=='sm') {
            dialog.addClass('modal-sm');
        }else if(this.options.size=='lg') {
            dialog.addClass('modal-lg');
        }
        if(this.options.contentClass){
            dialog.find('.modal-content').addClass(this.options.contentClass);
        }
        this.box.find('.modal-title').text(title);

        var body=this.box.find('.modal-body');
        body.html(html);
        this.box.on('hide.bs.modal',function(){
            if(self.options.onhide){
                self.options.onhide(body,self.box);
            }
            Dialog.instance=null;
        });
        this.box.on('hidden.bs.modal',function(){
            if(self.options.onhidden){
                self.options.onhidden(body,self.box);
            }
            self.closed=true;
            self.box.remove();
            self.box=null;
        });
        this.box.on('show.bs.modal',function(){
            if(self.options.onshow){
                self.options.onshow(body,self.box);
            }
        });
        this.box.on('shown.bs.modal',function(){
            if(self.options.onshown){
                self.options.onshown(body,self.box);
            }
        });
        if(this.options.footer) {
            this.box.find('.modal-footer .btn').click(function () {
                var result = true, idx = $(this).data('index');
                if (self.options.btns[idx].click) {
                    result = self.options.btns[idx].click.apply(this, [body, self.box]);
                }
                if (idx == self.options.defaultBtn) {
                    if (self.options.onsure) {
                        result = self.options.onsure.apply(this, [body, self.box]);
                    }
                }
                if (result !== false) {
                    self.box.modal('hide');
                }
            });
        }
        this.closed=false;
        this.box.modal('show');
        return this;
    };
    Dialog.prototype.hide=Dialog.prototype.close=function(){
        if(this.box && !this.closed) {
            this.closed=true;
            this.box.modal('hide');
        }
        return this;
    };

    var dialog={
        error:function (message,time) {
            return this.message(message,'error',time);
        },
        success:function (message,time) {
            return this.message(message,'success',time);
        },
        warning:function (message,time) {
            return this.message(message,'warning',time);
        },
        info:function (message,time) {
            return this.message(message,'info',time);
        },
        message:function (message,type,time) {
            var cssClass='bg-info text-white';
            var icon='information-circle';
            if(type) {
                switch (type) {
                    case 'danger':
                    case 'error':
                        icon='close-circle';
                        cssClass='bg-danger text-white';
                        break;
                    case 'warning':
                        icon='warning';
                        cssClass='bg-warning text-white';
                        break;
                    case 'success':
                        icon='checkmark-circle';
                        cssClass='bg-success text-white';
                        break;
                }
            }
            var html='<div class="dialog-message" ><i class="ion-md-'+icon+'"></i>&nbsp;&nbsp;'+message+'<a href="javascript:" class="ion-md-close closebtn"></a></div>';

            var dlg= new Dialog({
                footer:false,
                header:false,
                backdrop:false,
                size:'sm',
                contentClass:cssClass,
                onshow:function (body) {
                    body.find('.closebtn').click(function () {
                        dlg.close();
                    })
                }
            }).show(html,'');
            if(!time)time=2;
            setTimeout(function(){dlg.close();},time*1000);
            return dlg;
        },
        alert:function(message,callback,icon){
            var called=false;
            var iscallback=typeof callback=='function';
            var title='';
            var size='sm';
            var html='';
            if(callback!==undefined && !iscallback){
                icon=callback;
            }
            if($.isPlainObject(message)){
                if(message['title']){
                    title=message['title'];
                }
                if(message['size']!==undefined){
                    size=message['size'];
                }
                if(message['content']===undefined){
                    throw 'message.content can not be empty.';
                }
                message=message['content'];
            }
            var iconMap= {
                'success':'checkmark-circle',
                'info': 'information-circle',
                'warning':'alert',
                'error':'remove-circle'
            };
            var color='primary';
            if(icon===undefined)icon='information-circle';
            else if(iconMap[icon]){
                color=icon=='error'?'danger':icon;
                icon=iconMap[icon];
            }
            if(icon) {
                html = '<div class="row" style="align-items: center;"><div class="col-3 text-right"><i class="ion-md-{@icon} text-{@color}" style="font-size:3em;"></i> </div><div class="col-9" >{@message}</div> </div>'.compile({
                    message: message,
                    icon: icon,
                    color: color
                });
            }else{
                html=message;
            }
            return new Dialog({
                btns:'确定',
                size:size,
                header:title?true:false,
                onsure:function(){
                    if(iscallback){
                        called=true;
                        return callback(true);
                    }
                },
                onhide:function(){
                    if(!called && iscallback){
                        callback(false);
                    }
                }
            }).show(html,title);
        },
        confirm:function(message,confirm,cancel, icon, countdown){
            var called=false;
            if(typeof confirm !== 'function'){
                icon = confirm;
                if(typeof cancel === 'function'){
                    confirm = cancel;
                    cancel = null;
                }else{
                    countdown = cancel;
                }
            }else if(typeof cancel !== 'function'){
                countdown = icon;
                icon = cancel;
            }
            if(typeof icon ===  'number'){
                countdown = icon;
                icon = undefined;
            }
            var title='';
            var size='sm';
            var btns=[
                {'text':'取消','type':'secondary'},
                {'text':'确定','isdefault':true,'type':'primary'}
            ];
            if($.isPlainObject(message)){
                if(message['title']){
                    title=message['title'];
                }
                if(message['size']!==undefined){
                    size=message['size'];
                }
                if(message['btns']!==undefined){
                    btns=message['btns'];
                }
                if(message['content']===undefined){
                    throw 'message.content can not be empty.';
                }
                message=message['content'];
            }

            var iconMap= {
                'success':'checkmark-circle',
                'info': 'information-circle',
                'warning':'alert',
                'error':'remove-circle'
            };
            var color='primary';
            if(!icon)icon='information-circle';
            else if(iconMap[icon]){
                color = icon==='error'?'danger':icon;
                icon = iconMap[icon];
            }
            var html='<div class="row" style="align-items: center;"><div class="col-3 text-right"><i class="ion-md-{@icon} text-{@color}" style="font-size:3em;"></i> </div><div class="col-9" >{@message}</div> </div>'.compile({
                message:message,
                icon:icon,
                color:color
            });

            var inteval=0;

            var dlg = new Dialog({
                'header':title?true:false,
                'btns':btns,
                'size':size,
                'backdrop':'static',
                'onsure':function(){
                    if(confirm && typeof confirm==='function'){
                        called=true;
                        return confirm();
                    }
                },
                'onhide':function () {
                    clearInterval(inteval);
                    if(called === false && typeof cancel === 'function'){
                        return cancel();
                    }
                }
            }).show(html, title);

            if(countdown && typeof countdown === 'number') {
                var btn = dlg.box.find('.modal-footer .btn-outline-primary');
                var btnText = dlg.options.btns[dlg.options.defaultBtn].text;
                btn.addClass('disabled').text(btnText+'(' + countdown + ')');
                inteval = setInterval(function () {
                    countdown--;
                    if (countdown > 0) {
                        btn.text(btnText+'(' + countdown + ')');
                    } else {
                        btn.text(btnText);
                        btn.removeClass('disabled');
                        clearInterval(inteval);
                    }
                }, 1000);
            }
            return dlg;
        },
        prompt:function(message,callback,cancel){
            var called=false;
            var contentHtml='<div class="form-group">{@input}</div>';
            var title='请输入信息';
            if(typeof message=='string'){
                title=message;
            }else{
                title=message.title;
                if(message.content) {
                    contentHtml = message.content.indexOf('{@input}') > -1 ? message.content : message.content + contentHtml;
                }
            }
            return new Dialog({
                'backdrop':'static',
                'onshow':function(body){
                    if(message && message.onshow){
                        message.onshow(body);
                    }
                },
                'onshown':function(body){
                    body.find('[name=confirm_input]').focus();
                    if(message && message.onshown){
                        message.onshown(body);
                    }
                },
                'onsure':function(body){
                    var val=body.find('[name=confirm_input]').val();
                    if(typeof callback=='function'){
                        var result = callback(val);
                        if(result===true){
                            called=true;
                        }
                        return result;
                    }
                },
                'onhide':function () {
                    if(called=false && typeof cancel=='function'){
                        return cancel();
                    }
                }
            }).show(contentHtml.compile({input:'<input type="text" name="confirm_input" class="form-control" />'}),title);
        },
        action:function (list,callback,title) {
            var html='<div class="list-group"><a href="javascript:" class="list-group-item list-group-item-action">'+list.join('</a><a href="javascript:" class="list-group-item list-group-item-action">')+'</a></div>';
            var actions=null;
            var dlg=new Dialog({
                'bodyClass':'modal-action',
                'backdrop':'static',
                'size':'sm',
                'btns':[
                    {'text':'取消','type':'secondary'}
                ],
                'onshow':function(body){
                    actions=body.find('.list-group-item-action');
                    actions.click(function (e) {
                        actions.removeClass('active');
                        $(this).addClass('active');
                        var val=actions.index(this);
                        if(typeof callback=='function'){
                            if( callback(val)!==false){
                                dlg.close();
                            }
                        }else {
                            dlg.close();
                        }
                    })
                },
                'onsure':function(body){
                    return true;
                },
                'onhide':function () {
                    return true;
                }
            }).show(html,title?title:'请选择');
        },
        pickList:function (config,callback,filter) {
            if(typeof config==='string')config={url:config};
            config=$.extend({
                'url':'',
                'name':'对象',
                'searchHolder':'根据名称搜索',
                'idkey':'id',
                'onRow':null,
                'extend':null,
                'rowTemplate':'<a href="javascript:" data-id="{@id}" class="list-group-item list-group-item-action">[{@id}]&nbsp;<i class="ion-md-person"></i> {@username}&nbsp;&nbsp;&nbsp;<small><i class="ion-md-phone-portrait"></i> {@mobile}</small></a>'
            },config||{});
            var current=null;
            var exthtml='';
            if(config.extend){
                exthtml='<select name="'+config.extend.name+'" class="form-control"><option value="">'+config.extend.title+'</option></select>';
            }
            if(!filter)filter={};
            var dlg=new Dialog({
                'backdrop':'static',
                'onshown':function(body){
                    var btn=body.find('.searchbtn');
                    var input=body.find('.searchtext');
                    var listbox=body.find('.list-group');
                    var isloading=false;
                    var extField=null;
                    if(config.extend){
                        extField=body.find('[name='+config.extend.name+']');
                        $.ajax({
                           url:config.extend.url,
                            type:'GET',
                            dataType:'JSON',
                            success:function (json) {
                                extField.append(config.extend.htmlRow.compile(json.data,true));
                            }
                        });
                    }
                    btn.click(function(){
                        if(isloading)return;
                        isloading=true;
                        listbox.html('<span class="list-loading">加载中...</span>');
                        filter['key']=input.val();
                        if(config.extend){
                            filter[config.extend.name]=extField.val();
                        }
                        $.ajax(
                            {
                                url:config.url,
                                type:'GET',
                                dataType:'JSON',
                                data:filter,
                                success:function(json){
                                    isloading=false;
                                    if(json.code===1){
                                        if(json.data && json.data.length) {
                                            listbox.html(config.rowTemplate.compile(json.data, true));
                                            listbox.find('a.list-group-item').click(function () {
                                                var id = $(this).data('id');
                                                for (var i = 0; i < json.data.length; i++) {
                                                    if(json.data[i][config.idkey]==id){
                                                        current=json.data[i];
                                                        listbox.find('a.list-group-item').removeClass('active');
                                                        $(this).addClass('active');
                                                        break;
                                                    }
                                                }
                                            })
                                        }else{
                                            listbox.html('<span class="list-loading"><i class="ion-md-warning"></i> 没有检索到'+config.name+'</span>');
                                        }
                                    }else{
                                        listbox.html('<span class="text-danger"><i class="ion-md-warning"></i> 加载失败</span>');
                                    }
                                }
                            }
                        );

                    }).trigger('click');
                },
                'onsure':function(body){
                    if(!current){
                        dialog.warning('没有选择'+config.name+'!');
                        return false;
                    }
                    if(typeof callback=='function'){
                        var result = callback(current);
                        return result;
                    }
                }
            }).show('<div class="input-group">'+exthtml+'<input type="text" class="form-control searchtext" name="keyword" placeholder="'+config.searchHolder+'"/><div class="input-group-append"><a class="btn btn-outline-secondary searchbtn"><i class="ion-md-search"></i></a></div></div><div class="list-group list-group-picker mt-2"></div>','请搜索并选择'+config.name);
        },
        pickUser:function(callback,filter){
            return this.pickList({
                'url':window.get_search_url('member'),
                'name':'会员',
                'searchHolder':'根据会员id或名称，电话来搜索'
            },callback,filter);
        },
        pickArticle:function(callback,filter){
            return this.pickList({
                'url':window.get_search_url('article'),
                rowTemplate:'<a href="javascript:" data-id="{@id}" class="list-group-item list-group-item-action">{if @cover}<div style="background-image:url({@cover})" class="imgview" ></div>{/if}<div class="text-block">[{@id}]&nbsp;{@title}&nbsp;<br />{@description}</div></a>',
                name:'文章',
                idkey:'id',
                extend:{
                   name:'cate',
                    title:'按分类搜索',
                    url:get_cate_url('article'),
                    htmlRow:'<option value="{@id}">{@html}{@title}</option>'
                },
                'searchHolder':'根据文章标题搜索'
            },callback,filter);
        },
        pickProduct:function(callback,filter){
            return this.pickList({
                'url':window.get_search_url('product'),
                rowTemplate:'<a href="javascript:" data-id="{@id}" class="list-group-item list-group-item-action">{if @image}<div style="background-image:url({@image})" class="imgview" ></div>{/if}<div class="text-block">[{@id}]&nbsp;{@title}&nbsp;<br />{@min_price}~{@max_price}</div></a>',
                name:'产品',
                idkey:'id',
                extend:{
                    name:'cate',
                    title:'按分类搜索',
                    url:get_cate_url('product'),
                    htmlRow:'<option value="{@id}">{@html}{@title}</option>'
                },
                'searchHolder':'根据产品名称搜索'
            },callback,filter);
        },
        pickLocate:function(type, callback, locate){
            var settedLocate=null;
            var dlg=new Dialog({
                'size':'lg',
                'backdrop':'static',
                'onshown':function(body){
                    var btn=body.find('.searchbtn');
                    var input=body.find('.searchtext');
                    var mapbox=body.find('.map');
                    var mapinfo=body.find('.mapinfo');
                    mapbox.css('height',$(window).height()*.6);
                    var isloading=false;
                    var map=InitMap('tencent',mapbox,function(address,locate){
                        mapinfo.html(address+'&nbsp;'+locate.lng+','+locate.lat);
                        settedLocate=locate;
                    },locate);
                    btn.click(function(){
                        var search=input.val();
                        map.setLocate(search);
                    });
                    body.find('.setToCenter').click(function (e) {
                        map.showAtCenter();
                    })
                },
                'onsure':function(body){
                    if(!settedLocate){
                        dialog.warning('没有选择位置!');
                        return false;
                    }
                    if(typeof callback==='function'){
                        var result = callback(settedLocate);
                        return result;
                    }
                }
            }).show('<div class="input-group"><input type="text" class="form-control searchtext" name="keyword" placeholder="填写地址检索位置"/><div class="input-group-append"><a class="btn btn-outline-secondary searchbtn"><i class="ion-md-search"></i></a></div></div>' +
                '<div class="map mt-2"></div>' +
                '<div class="float-right mt-2 mapactions"><a href="javascript:" class="setToCenter">定位到地图中心</a></div>' +
                '<div class="mapinfo mt-2 text-muted">未选择位置</div>','请选择地图位置');
        }
    };

    //监控按键
    $(document).on('keydown', function(e){
        if(!Dialog.instance)return;
        var dlg=Dialog.instance;
        if (e.keyCode == 13) {
            dlg.box.find('.modal-footer .btn').eq(dlg.options.defaultBtn).trigger('click');
        }
        //默认已监听关闭
        /*if (e.keyCode == 27) {
         self.hide();
         }*/
    });

    //暴露接口
    window.Dialog=$.Dialog=Dialog;
    window.dialog=$.dialog=dialog;
})(window,jQuery||Zepto);

