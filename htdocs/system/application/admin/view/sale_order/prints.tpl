<extend name="public:print" />
<block name="header">
    <style >
        @page {
            size: 8cm 6cm;
            margin:0;
            padding:0;
        }
        .moving{
            position: absolute;
        }
        .placeele{
            border:2px #999 dashed;
            border-radius:5px;
            background:transparent;
        }
    </style>
</block>
<block name="body">
    <div id="app" class="labelpage">
    <div class="page-wrapper container ml-auto mr-auto mb-3 d-print-none">
        <div class="row">
            <h2 class="col-md-6">标签打印</h2>
            <div class="col-md-6 text-right ">
                <a href="javascript:" class="btn btn-secondary " @click="clearEmptyPkg">清除空包</a>
                <a href="javascript:" class="btn btn-info " @click="savePkg">保存</a>
                <a href="javascript:" class="btn btn-primary print-btn" @click="doPrint">打印</a>
            </div>
        </div>
    </div>
    <div id="page-wrapper" class="container m-auto">

        <div class="orderwrapper d-print-none" v-for="order in orders">
            <div class="goodsbox">
                <h3 class="mt-3">订单：{{order.order_no}}</h3>
                <div class="lead">
                    下单日期：{{order.create_date}}&nbsp;&nbsp;交货日期：{{order.customer_date}}&nbsp;&nbsp;出库仓：{{order.storage_title}}
                </div>
                <hr class="my-3"/>
                <div class="btn-group dropright mr-3 mb-3" v-for="good in order.goods" :data-orderid="order.id" :data-goodsid="good.goods_id" >
                    <button type="button" class="btn btn-secondary dropdown-toggle" @mousedown="startDrag" :disabled="good.release_count <= 0" aria-haspopup="true" aria-expanded="false">
                        {{good.goods_title}}
                        <span class="badge badge-light">{{ formatNumber(good.release_count) }}/{{ formatNumber(good.count) }} {{good.goods_unit}}</span>
                        <span class="badge badge-light" v-if="good.storage_id != order.storage_id">{{good.storage_title}}</span>
                    </button>
                    <div class="dropdown-menu">
                        <a class="dropdown-item" href="javascript:" @click="autoPack(order.id, good.goods_id)">自动分包</a>
                        <template  v-for="pkg in packages[order.package_id]">
                            <a class="dropdown-item" href="javascript:" @click="addtoLabel(order.id, good.goods_id, pkg.id)">打包到 {{pkg.title}}</a>
                            <a class="dropdown-item" href="javascript:" @click="addtoLabel(order.id, good.goods_id, pkg.id, 1)">全部打包到 {{pkg.title}}</a>
                        </template>
                    </div>
                </div>
            </div>

            <div class="labelbox clearfix">
                <div class="print-page float-left ml-3" v-for="pkg in packages[order.package_id]" :data-pkgid="pkg.id" >
                    <span class="badge badge-secondary labelid">{{pkg.title}}</span>
                    <a class="btn btn-circle btn-delete" title="删除标签" @click="delLabel(pkg.id,order.id)" href="javascript:"><i class="ion-md-close"></i> </a>
                    <a class="btn btn-circle btn-clear" title="清空标签" @click="clearLabel(pkg.id,order.id)" href="javascript:"><i class="ion-md-refresh-circle"></i> </a>
                    <table class="table">
                        <thead class="text-center"><tr><td colspan="2"><h3>{{order.customer_title}}</h3></td></tr></thead>
                        <tbody>
                        <template v-if="pkg.goods.length>10">
                            <template v-for="idx in Math.ceil(pkg.goods.length / 3)">
                                <tr class="small">
                                    <td class="text-right">
                                        {{pkg.goods[(idx-1)*3].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*3].count)}} {{pkg.goods[(idx-1)*3].goods_unit}}
                                    </td>
                                    <td class="text-right" v-if="pkg.goods[(idx-1)*3+1]">
                                        {{pkg.goods[(idx-1)*3+1].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*3+1].count)}} {{pkg.goods[(idx-1)*3+1].goods_unit}}
                                    </td>
                                    <td v-else></td>
                                    <td class="text-right" v-if="pkg.goods[(idx-1)*3+2]">
                                        {{pkg.goods[(idx-1)*3+1].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*3+1].count)}} {{pkg.goods[(idx-1)*3+1].goods_unit}}
                                    </td>
                                    <td v-else></td>
                                </tr>
                            </template>
                        </template>
                        <template v-else-if="pkg.goods.length>3">
                            <template v-for="idx in Math.ceil(pkg.goods.length * .5)">
                                <tr class="middle">
                                    <td class="text-right">
                                        {{pkg.goods[(idx-1)*2].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*2].count)}} {{pkg.goods[(idx-1)*2].goods_unit}}
                                    </td>
                                    <td class="text-right" v-if="pkg.goods[(idx-1)*2+1]">
                                        {{pkg.goods[(idx-1)*2+1].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*2+1].count)}} {{pkg.goods[(idx-1)*2+1].goods_unit}}
                                    </td>
                                    <td v-else></td>
                                </tr>
                            </template>
                        </template>
                        <template v-else-if="pkg.goods.length>1">
                            <tr class="middle" v-for="good in pkg.goods">
                                <td class="text-right">
                                    {{good.goods_title}}
                                </td>
                                <td class="text-left">
                                    {{ formatNumber(good.count)}} {{good.goods_unit}}
                                </td>
                            </tr>
                        </template>
                        <template v-else>
                            <tr v-for="good in pkg.goods">
                                <td colspan="2">
                                    <div class="row">
                                        <h4 class="col-5 text-right">品名：</h4>
                                        <h4 class="col text-left">{{good.goods_title}}</h4>
                                    </div>
                                    <div class="row">
                                        <h4 class="col-5 text-right">数量：</h4>
                                        <h4 class="col text-left">{{ formatNumber(good.count)}} {{good.goods_unit}}</h4>
                                    </div>
                                </td>
                            </tr>
                        </template>
                        </tbody>
                    </table>
                </div>
                <a  href="javascript:" class="btn btn-outline-primary btn-addlabel mt-3 ml-3" @click="addLabel(order.id)">增加标签</a>
            </div>
        </div>
        <div class="d-none d-print-block printwrapper">
            <template v-for="order in orders">
            <div class="print-page" v-for="pkg in packages[order.package_id]">
                <table class="table">
                    <thead class="text-center"><tr><td colspan="2"><h3>{{order.customer_title}}</h3></td></tr></thead>
                    <tbody>
                    <template v-if="pkg.goods.length>10">
                        <template v-for="idx in Math.ceil(pkg.goods.length / 3)">
                            <tr class="small">
                                <td class="text-right">
                                    {{pkg.goods[(idx-1)*3].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*3].count)}} {{pkg.goods[(idx-1)*3].goods_unit}}
                                </td>
                                <td class="text-right" v-if="pkg.goods[(idx-1)*3+1]">
                                    {{pkg.goods[(idx-1)*3+1].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*3+1].count)}} {{pkg.goods[(idx-1)*3+1].goods_unit}}
                                </td>
                                <td v-else></td>
                                <td class="text-right" v-if="pkg.goods[(idx-1)*3+2]">
                                    {{pkg.goods[(idx-1)*3+1].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*3+1].count)}} {{pkg.goods[(idx-1)*3+1].goods_unit}}
                                </td>
                                <td v-else></td>
                            </tr>
                        </template>
                    </template>
                    <template v-else-if="pkg.goods.length>3">
                        <template v-for="idx in Math.ceil(pkg.goods.length * .5)">
                            <tr class="middle">
                                <td class="text-right">
                                    {{pkg.goods[(idx-1)*2].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*2].count)}} {{pkg.goods[(idx-1)*2].goods_unit}}
                                </td>
                                <td class="text-right" v-if="pkg.goods[(idx-1)*2+1]">
                                    {{pkg.goods[(idx-1)*2+1].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*2+1].count)}} {{pkg.goods[(idx-1)*2+1].goods_unit}}
                                </td>
                                <td v-else></td>
                            </tr>
                        </template>
                    </template>
                    <template v-else-if="pkg.goods.length>1">
                        <tr class="middle" v-for="good in pkg.goods">
                            <td class="text-right">
                                {{good.goods_title}}
                            </td>
                            <td class="text-left">
                                {{good.count}} {{good.goods_unit}}
                            </td>
                        </tr>
                    </template>
                    <template v-else>
                        <tr v-for="good in pkg.goods">
                            <td colspan="2">
                                <div class="row">
                                    <h4 class="col-5 text-right">品名：</h4>
                                    <h4 class="col text-left">{{good.goods_title}}</h4>
                                </div>
                                <div class="row">
                                    <h4 class="col-5 text-right">数量：</h4>
                                    <h4 class="col text-left">{{ formatNumber(good.count) }} {{good.goods_unit}}</h4>
                                </div>
                            </td>
                        </tr>
                    </template>
                    </tbody>
                </table>
            </div>
            </template>
        </div>
    </div>
    </div>
</block>
<block name="script">
    <script type="text/javascript" src="__STATIC__/admin/js/label.min.js"></script>
    <script type="text/javascript" src="__STATIC__/js/vue-2.6.min.js"></script>
    <script type="text/javascript">

        function formatNumber(number){
            if(!number)return 0;
            var num=number.toString().split('.');
            var len=0;
            if(num.length === 2){
                len = num[1].length;
                if(len>4)len=4;
            }
            var p=Math.pow(10,len);
            return (Math.round(number * p)/p).toFixed(len);
        }

        var autoscroll_ticker=0;
        $(window).bind('scroll',function (e) {
            clearTimeout(autoscroll_ticker)
            autoscroll_ticker = setTimeout(fixpageScroll,500);
        }).trigger('scroll');
        function fixpageScroll() {
            var scrollTop = $(window).scrollTop()
            if(scrollTop < 10)return;
            var windowheight=$(window).height();

            var pages=$('.orderwrapper')
            var needscroll=null
            for(var i=0;i<pages.length;i++){
                var curpage = pages.eq(i);
                var offset=curpage.offset();
                var pageheight=curpage.height();
                if(offset.top>=scrollTop && offset.top+pageheight <= scrollTop+windowheight){
                    return;
                }
                var curscroll = offset.top-scrollTop
                if(needscroll===null || Math.abs(needscroll)>Math.abs(curscroll)){
                    needscroll = curscroll
                }
            }
            $('html,body').animate({scrollTop: scrollTop+needscroll},500);
        }

        var global_id=-1;
        var app = new Vue({
            el: '#app',
            data: {
                ischanged:false,
                orders:[],
                packages:[],
                storage_ids:[]
            },
            watch: {

            },
            mounted: function () {
                this.initData();
            },
            methods: {
                initData:function () {
                    var self=this;
                    $.ajax({
                        url:'',
                        method:'POST',
                        data:{
                            test:1
                        },
                        success:function (json) {
                            if(json.code===1) {
                                var data = json.data;
                                for(var i in data.orders){
                                    if(data.orderGoods[data.orders[i].id]){
                                        var goods=data.orderGoods[data.orders[i].id];
                                        goods.release_count=0;
                                        data.orders[i].goods=goods;
                                    }else{
                                        data.orders[i].goods=[];
                                    }
                                }
                                for(var package_id in data.packages){
                                    for(var i=0;i<data.packages[package_id].length;i++ ){
                                        var item_id=data.packages[package_id][i].id;
                                        if(data.packageGoods[item_id]){
                                            data.packages[package_id][i].goods=data.packageGoods[item_id];
                                        }else{
                                            data.packages[package_id][i].goods=[];
                                        }

                                    }
                                }
                                self.orders = data.orders;
                                self.packages = data.packages;
                                self.initCount();
                            }
                        }
                    });
                },
                startDrag:function(e){
                    var self=$(e.target),startX=e.screenX,startY=e.screenY,moved=false;
                    var movedX=0,movedY=0,absX=0,absY=0;
                    var pself=self.parents('.btn-group').eq(0),dropdown=pself.find('.dropdown-menu');
                    var place=null
                    var labelbox=pself.parents('.orderwrapper').find('.labelbox')

                    var movefunc=function (me) {
                        e.preventDefault()
                        e.stopPropagation()

                        movedX = me.screenX-startX
                        movedY = me.screenY-startY
                        //console.log(moved)
                        if(!moved) {
                            moved = true;
                            var offset=pself.position()
                            absX=offset.left
                            absY=offset.top
                            place=$('<div class="'+pself.attr('class')+' placeele"></div>')
                            pself.addClass('moving')
                            place.css({width:pself.width(),height:pself.height()}).insertBefore(pself)
                        }
                        pself.css({ top:absY+movedY,left:absX+movedX})
                    },upfunc=null;
                    $(document.body).on('mousemove',movefunc).on('mouseup',function (me) {
                        upfunc = arguments.callee
                        //console.log(moved)
                        if(moved){
                            var scrolltop=labelbox.scrollTop()
                            var pages=labelbox.find('.print-page')
                            for(var i=0;i<pages.length;i++){
                                var page=pages.eq(i)
                                var offset=page.position()
                                var box={
                                    left:offset.left,
                                    top:offset.top,
                                    right:offset.left+page.width(),
                                    bottom:offset.top+page.height()
                                }
                                if(absY+movedY>box.top && absY+movedY<box.bottom && absX+movedX>box.left && absX+movedX<box.right){
                                    var data=pself.data()
                                    var tdata=page.data()
                                    app.addtoLabel(data.orderid,data.goodsid,tdata.pkgid)
                                    break;
                                }
                            }
                        }else{
                            if(dropdown.hasClass('show')){
                                dropdown.removeClass('show')
                            }else {
                                dropdown.addClass('show')
                                setTimeout(function () {
                                    $(document.body).one('click', function () {
                                        console.log('hided')
                                        dropdown.removeClass('show')
                                        moved=false
                                    })
                                }, 200)
                            }
                        }

                        if(movefunc)$(document.body).off('mousemove',movefunc)
                        if(upfunc)$(document.body).off('mouseup',upfunc)
                        if(place)place.remove()
                        pself.removeClass('moving').css({top:'',left:''})
                    })
                },
                autoPack:function(order_id, goods_id){
                    var order = this.findOrder(order_id);
                    if(!order){
                        dialog.error('订单资料错误');
                        return;
                    }
                    var good = this.findGoods(order.goods, goods_id);
                    if(!good){
                        dialog.error('品种资料错误');
                        return;
                    }
                    var count =good.release_count;
                    if(!count){
                        dialog.error('该品种已打包完了');
                        return;
                    }
                    dialog.prompt({
                        title:'将['+good.goods_title+']自动分包',
                        content:'<div class="text-muted">请填写分包数量</div><div class="form-group"><div class="input-group">{@input}<span class="input-group-append"><span class="input-group-text">'+good.goods_unit+'</span></span></div></div>',
                        default:good.release_count
                    },function (input) {
                        if(!input)return;
                        count=parseFloat(input);
                        if(!count){
                            dialog.error('数量错误');
                            return;
                        }
                        if(count>good.release_count){
                            dialog.warning('填写数量大于剩余数量，已自动更正');
                            count = good.release_count;
                        }
                        var packcount = Math.floor(good.release_count/count)
                        for(var i=0;i<packcount;i++){
                            var pkgidx = app.add_label(order)
                            app.add_goods_to_label(order.package_id, pkgidx, good, count)
                        }
                    })

                },
                addtoLabel:function(order_id, goods_id, item_id, isall){
                    var order = this.findOrder(order_id);
                    if(!order){
                        dialog.error('订单资料错误');
                        return;
                    }
                    var good = this.findGoods(order.goods, goods_id);
                    if(!good){
                        dialog.error('品种资料错误');
                        return;
                    }
                    var pkgidx=this.findItem(order.package_id, item_id);
                    if(pkgidx<0){
                        dialog.error('包ID错误');
                        return;
                    }
                    var count =good.release_count;
                    if(!count){
                        dialog.error('该品种已打包完了');
                        return;
                    }
                    if(!isall){
                        dialog.prompt({
                            title:'将['+good.goods_title+']打包到 '+this.packages[order.package_id][pkgidx].title,
                            content:'<div class="form-group"><div class="input-group">{@input}<span class="input-group-append"><span class="input-group-text">'+good.goods_unit+'</span></span></div></div>',
                            default:good.release_count
                        },function (input) {
                            if(!input)return;
                            count=parseFloat(input);
                            if(!count){
                                dialog.error('数量错误');
                                return false;
                            }
                            if(count>good.release_count){
                                dialog.warning('填写数量大于剩余数量，已自动更正');
                                count = good.release_count;
                            }
                            app.add_goods_to_label(order.package_id, pkgidx, good, count)
                            app.ischanged = true;
                        })
                    }else {
                        this.add_goods_to_label(order.package_id, pkgidx, good, count)
                        this.ischanged = true;
                    }
                },
                add_goods_to_label:function(package_id,pkgidx,good, count){
                    var pkgitem = this.packages[package_id][pkgidx];
                    var pkgGoods = this.findGoods(pkgitem.goods, good.id, 1);
                    if(pkgGoods>-1){
                        pkgitem.goods[pkgGoods].count += count;
                    }else{
                        pkgitem.goods.push({
                            goods_id: good.goods_id,
                            goods_title:good.goods_title,
                            count:count,
                            goods_unit:good.goods_unit
                        });
                    }
                    good.release_count -= count;
                },
                addLabel:function (order_id) {
                    var order = this.findOrder(order_id);
                    if(!order){
                        dialog.error('订单资料错误');
                        return;
                    }
                    this.add_label(order)
                    this.ischanged=true;

                },
                add_label:function(order){

                    if(!this.packages[order.package_id]){
                        Vue.set(this.packages,order.package_id,[]);
                    }
                    this.packages[order.package_id].push({
                        id:global_id,
                        title:this.packages[order.package_id].length+1,
                        package_id:order.package_id,
                        storage_id:order.storage_id,
                        customer_id:order.customer_id,
                        goods:[]
                    });
                    //添加后重新编号
                    for(var i=0;i<this.packages[order.package_id].length;i++){
                        this.packages[order.package_id][i].title = i+1;
                    }
                    global_id -= 1;

                    return this.packages[order.package_id].length-1
                },
                delLabel:function (item_id, order_id) {
                    var order = this.findOrder(order_id);
                    if(!order){
                        dialog.error('订单资料错误');
                        return;
                    }
                    var idx = this.findItem(order.package_id, item_id);
                    var item=this.packages[order.package_id][idx];
                    if(item.goods && item.goods.length>0) {
                        dialog.confirm('确定删除该标签？',function () {
                            app.del_label(order, idx);
                            app.ischanged=true;
                        })
                        return;
                    }

                    this.del_label(order, idx);
                    this.ischanged=true;
                },
                del_label:function (order, idx){
                    if(this.clear_label(order, idx)){
                        this.packages[order.package_id].splice(idx,1);

                        //删除后重新编号
                        for(var i=0;i<this.packages[order.package_id].length;i++){
                            this.packages[order.package_id][i].title = i+1;
                        }
                    }
                },
                clearLabel:function(item_id, order_id){
                    var order = this.findOrder(order_id);
                    if(!order){
                        dialog.error('订单资料错误');
                        return;
                    }
                    var idx = this.findItem(order.package_id, item_id);
                    if(this.clear_label(order, idx)){
                        this.$nextTick(function () {
                            dialog.success('清除完成');
                        });
                    }else{
                        dialog.error('清除错误');
                    }
                    this.ischanged=true;
                },
                clear_label:function(order, idx){
                    if(idx > -1){
                        var item=this.packages[order.package_id][idx];
                        if(item.goods && item.goods.length>0){
                            var goods=item.goods.splice(0,item.goods.length);
                            for(var i=0;i<goods.length;i++){
                                for(var j=0;j<order.goods.length;j++){
                                    if(order.goods[j].goods_id == goods[i].goods_id){
                                        order.goods[j].release_count = order.goods[j].release_count+goods[i].count;
                                        break;
                                    }
                                }
                            }

                        }
                        return true;
                    }
                    return false;
                },
                clearEmptyPkg:function(){
                    for(var pkd_id in this.packages){
                        for(var i=0;i<this.packages[pkd_id].length;i++) {
                            var pkg = this.packages[pkd_id][i]
                            if(!pkg.goods || pkg.goods.length<1){
                                this.packages[pkd_id].splice(i,1)
                                i--
                            }
                        }
                    }
                    this.ischanged=true;
                },
                initCount:function(){
                    for(var i=0;i<this.orders.length;i++){
                        var order = this.orders[i];
                        var items = this.packages[order.package_id];
                        if(order.goods && order.goods.length>0
                            && items && items.length>0
                        ){
                            var counts={  };
                            for(var j=0;j<items.length;j++){
                                var igoods=items[j].goods;
                                if(igoods && igoods.length>0) {
                                    for (var k = 0; k < igoods.length; k++) {
                                        var goods_id=igoods[k].goods_id;
                                        if(!counts[goods_id])counts[goods_id]=0;
                                        counts[goods_id] += parseFloat(igoods[k].count);
                                    }
                                }
                            }
                            for(j=0;j<order.goods.length;j++){
                                var total = parseFloat(order.goods[j].count);
                                if(order.from_order_id>0 && total<0){
                                    total = -total;
                                }
                                order.goods[j].count = total;
                                order.goods[j].release_count=total;

                                if(counts[order.goods[j].goods_id]){
                                    order.goods[j].release_count -= counts[order.goods[j].goods_id];
                                }
                            }
                        }
                    }
                },
                findOrder:function (order_id) {
                    for(var i=0;i<this.orders.length;i++){
                        if(this.orders[i].id.toString() === order_id.toString()){
                            return this.orders[i];
                        }
                    }
                    return null;
                },
                findGoods:function(goods, goods_id, findid){
                    for(var i=0;i<goods.length;i++){
                        if(goods[i].goods_id.toString() === goods_id.toString()){
                            if(findid)return i;
                            return goods[i];
                        }
                    }
                    if(findid)return -1;
                    return null;
                },
                findItem:function (package_id, item_id) {
                    var items=this.packages[package_id];
                    for(var i=0;i<items.length;i++){
                        if(items[i].id.toString() === item_id.toString()){
                            return i;
                        }
                    }
                    return -1;
                },
                savePkg:function (e) {
                    $.ajax({
                        url:'',
                        data: {
                            packages:this.packages
                        },
                        dataType:'JSON',
                        type:'POST',
                        success:function(json){
                            if(!e)return
                            if(json.code==1){
                                dialog.alert(json.msg,function () {
                                    location.reload();
                                });
                            }else{
                                dialog.error('保存失败')
                            }
                        }
                    })
                },
                doPrint:function (e) {
                    if(this.ischanged && confirm('是否保存打包设置')){
                        this.savePkg(null);
                    }
                    window.print();
                }
            }
        });
    </script>
</block>