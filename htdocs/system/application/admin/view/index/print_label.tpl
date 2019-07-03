<extend name="public:print" />
<block name="header">
    <style >
        @page {
            size: 8cm 6cm;
            margin:0;
            padding:0;
        }
    </style>
</block>
<block name="body">
    <div id="app" class="labelpage">
    <div class="page-wrapper container ml-auto mr-auto mb-3 d-print-none">
        <div class="row">
            <div class="col-8">
                <h2>标签打印</h2>
                <span class="text-muted">本功能仅供临时打印标签使用，如已有订单打印，请在<b>销售订单管理</b>中打印标签</span>
            </div>
            <div class="col-4 text-right ">
                <a href="javascript:" class="btn btn-primary print-btn" @click="doPrint">打印</a>
            </div>
        </div>
    </div>
    <div id="page-wrapper" class="container m-auto">
        <div class="orderwrapper d-print-none" v-for="(order,index) in orders">
            <div class="goodsbox">
                <h3 class="mt-3">{{order.order_no}}</h3>
                <div class="lead">
                    <div class="input-group input-group-sm">
                        <div class="input-group-prepend">
                            <span class="input-group-text">客户</span>
                        </div>
                        <input type="text" class="form-control" :data-idx="index" @focus="showCustomer" @blur="hideCustomer" @keyup="loadCustomer"  v-model="order.customer_key" placeholder="" aria-label="" aria-describedby="basic-addon1">
                    </div>
                </div>
                <div class="lead mt-2">
                    <div class="input-group input-group-sm">
                        <div class="input-group-prepend">
                            <span class="input-group-text">品种</span>
                        </div>
                        <input type="text" class="form-control" :data-idx="index" @focus="showGoods" @blur="hideGoods" @keyup="loadGoods" v-model="order.goodspick.title" placeholder="" aria-label="" aria-describedby="basic-addon1">
                        <div class="input-group-middle">
                            <span class="input-group-text">数量</span>
                        </div>
                        <input type="text" class="form-control" v-model="order.goodspick.count" placeholder="" aria-label="" aria-describedby="basic-addon1">
                        <select name="unit" v-model="order.goodspick.unit" class="form-control">
                            <option value="">单位</option>
                            <volist name="units" id="u">
                                <option value="{$u.key}">{$u.key}</option>
                            </volist>
                        </select>
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary" @click="addGoods(index)" type="button">添加品种</button>
                        </div>
                    </div>
                </div>
                <hr class="my-3"/>
                <div class="btn-group dropright mr-3 mb-3" v-for="good in order.goods">
                    <button type="button" class="btn btn-secondary dropdown-toggle" :disabled="good.release_count <= 0" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        {{good.goods_title}}
                        <span class="badge badge-light">{{ formatNumber(good.release_count) }}/{{ formatNumber(good.count) }} {{good.goods_unit}}</span>
                        <span class="badge badge-light" v-if="good.storage_id != order.storage_id">{{good.storage_title}}</span>
                    </button>
                    <div class="dropdown-menu">
                        <template  v-for="pkg in packages[order.package_id]">
                            <a class="dropdown-item" href="javascript:" @click="addtoLabel(order.id, good.goods_id, pkg.id)">打包到 {{pkg.title}}</a>
                            <a class="dropdown-item" href="javascript:" @click="addtoLabel(order.id, good.goods_id, pkg.id, 1)">全部打包到 {{pkg.title}}</a>
                        </template>
                        <a class="dropdown-item" href="javascript:" @click="delGoods(index, good.goods_id)">移除</a>
                    </div>
                </div>
            </div>

            <div class="labelbox clearfix">
                <div class="print-page float-left ml-3" v-for="pkg in packages[order.package_id]">
                    <span class="badge badge-secondary labelid">{{pkg.title}}</span>
                    <a class="btn btn-circle btn-delete" title="删除标签" @click="delLabel(pkg.id,order.id)" href="javascript:"><i class="ion-md-close"></i> </a>
                    <a class="btn btn-circle btn-clear" title="清空标签" @click="clearLabel(pkg.id,order.id)" href="javascript:"><i class="ion-md-refresh-circle"></i> </a>
                    <table class="table">
                        <thead class="text-center">
                        <tr>
                            <td colspan="2">
                                <h3>
                                    <span v-if="order.customer_id">{{order.customer_title}}</span>
                                    <span class="text-muted" v-else>客户名称</span>
                                </h3>
                            </td>
                        </tr>
                        </thead>
                        <tbody>
                        <template v-if="pkg.goods.length>3">
                            <template v-for="idx in Math.ceil(pkg.goods.length * .5)">
                                <tr class="middle">
                                    <td>
                                        {{pkg.goods[(idx-1)*2].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*2].count)}} {{pkg.goods[(idx-1)*2].goods_unit}}
                                    </td>
                                    <td v-if="pkg.goods[(idx-1)*2+1]">
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
        <a  href="javascript:" class="btn btn-outline-primary d-print-none btn-addorder m-3" @click="createOrder()">增加订单</a>
        <ul class="list-group auto-complete goods-complete d-print-none" :style="listStyle">
            <li class="list-group-item" v-for="(good,idx) in goodslist" :data-idx="idx" :key="good.id" @click="selectThis" @mouseenter="activeThis">
                [{{good.goods_no}}]{{good.title}}
            </li>
        </ul>
        <ul class="list-group auto-complete customer-complete d-print-none" :style="customerStyle">
            <li class="list-group-item" v-for="(customer,idx) in customers" :data-idx="idx" :key="customer.id" @click="selectThisCustomer" @mouseenter="activeThisCustomer">
                [{{customer.id}}]{{customer.title}}
            </li>
        </ul>
        <div class="d-none d-print-block printwrapper">
            <template v-for="order in orders">
                <div class="print-page" v-for="pkg in packages[order.package_id]">
                    <table class="table">
                        <thead class="text-center"><tr><td colspan="2"><h3>{{order.customer_title}}</h3></td></tr></thead>
                        <tbody>
                        <template v-if="pkg.goods.length>3">
                            <template v-for="idx in Math.ceil(pkg.goods.length * .5)">
                                <tr class="middle">
                                    <td>
                                        {{pkg.goods[(idx-1)*2].goods_title}}:{{ formatNumber(pkg.goods[(idx-1)*2].count)}} {{pkg.goods[(idx-1)*2].goods_unit}}
                                    </td>
                                    <td v-if="pkg.goods[(idx-1)*2+1]">
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

        var global_id=-1;
        var order_id=0;
        var item_id=0;

        var lastGoodsKey=null;
        var lastCustomerKey=null;

        var hideTimeout=0;
        var currentInput=null;
        var hideCustomerTimeout=0;

        var app = new Vue({
            el: '#app',
            data: {
                current_index:0,

                goodslist:[],
                customers:[],
                listStyle:{
                    display:'none',
                    position:'absolute',
                    left:0,
                    top:0,
                    width:0
                },
                customerStyle:{
                    display:'none',
                    position:'absolute',
                    left:0,
                    top:0,
                    width:0
                },
                orders:[],
                packages: {

                }
            },
            watch: {

            },
            mounted: function () {
                this.initData();
            },
            methods: {
                initData:function () {
                    this.createOrder();
                },
                createOrder:function(){
                    var order = {
                        id:++order_id,
                        package_id:order_id,
                        goods:[],
                        order_no:order_id+' 号订单',
                        customer_id:0,
                        customer_key:'',
                        customer_title:'',
                        goodspick:{
                            title:'',
                            orig_title:'',
                            id:0,
                            count:'',
                            unit:''
                        }
                    };
                    this.orders.push(order);
                    Vue.set(this.packages,order.package_id,[
                        {
                            id:++item_id,
                            title:1,
                            package_id:order.package_id,
                            goods:[]
                        }
                    ]);

                },
                deleteOrder:function(order_id){
                    for(var i=0;i<this.orders.length;i++){
                        if(this.orders[i].id === order_id){
                            this.orders.splice(i,1);
                            Vue.delete(this.packages,this.orders[i].package_id);
                            break;
                        }
                    }
                },
                addGoods:function(index){
                    var goods = this.orders[index].goodspick;
                    if(goods.count===0){
                        alert('请填写数量');
                        return false;
                    }
                    var idx = this.findGoods(this.orders[index].goods, goods.id, true);
                    var order=this.orders[index];
                    if(idx>-1){
                        order.goods[idx].count+=goods.count;
                        order.goods[idx].release_count+=goods.count;
                        if(order.goods[idx].goods_unit != goods.unit) {
                            order.goods[idx].goods_unit = goods.unit;
                            var items = this.packages[order.package_id];
                            for (var i = 0; i < items.length; i++) {
                                for (var j = 0; j < items[i].goods; j++) {
                                    if (items[i].goods[j].goods_id == goods.id){
                                        items[i].goods[j].goods_unit=goods.unit;
                                    }
                                }
                            }
                        }
                    }else {
                        order.goods.push({
                            goods_id:goods.id,
                            goods_title: goods.title,
                            count: goods.count,
                            goods_unit: goods.unit,
                            release_count:goods.count
                        });
                    }
                    goods.id=0;
                    goods.title='';
                    goods.unit='';
                    goods.count='';
                    goods.orig_title='';
                },
                delGoods:function(index, goods_id){
                    var order=this.orders[index];
                    var idx = this.findGoods(order.goods, goods_id, true);
                    if(idx>-1){
                        var goods=order.goods.splice(idx, 1);
                        if(goods[0].count>goods[0].release_count){
                            var items = this.packages[order.package_id];
                            for (var i = 0; i < items.length; i++) {
                                for (var j = 0; j < items[i].goods; j++) {
                                    if (items[i].goods[j].goods_id == goods_id){
                                        items[i].goods.splice(j,1);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                },
                addtoLabel:function(order_id, goods_id, item_id, isall){
                    var order = this.findOrder(order_id);
                    if(!order){
                        alert('订单资料错误');
                        return;
                    }
                    var good = this.findGoods(order.goods, goods_id);
                    if(!good){
                        alert('品种资料错误');
                        return;
                    }
                    var pkgidx=this.findItem(order.package_id, item_id);
                    if(pkgidx<-1){
                        alert('包ID错误');
                        return;
                    }
                    var count =good.release_count;
                    if(!isall){
                        var input=prompt('请填写打包数量',good.release_count);
                        count=parseFloat(input);
                        if(!count){
                            alert('数量错误');
                            return;
                        }
                        if(count>good.release_count){
                            alert('填写数量大于剩余数量，已自动更正');
                            count = good.release_count;
                        }
                    }

                    var pkgitem = this.packages[order.package_id][pkgidx];
                    var pkgGoods = this.findGoods(pkgitem.goods, goods_id, 1);
                    if(pkgGoods>-1){
                        pkgitem.goods[pkgGoods].count += count;
                    }else{
                        pkgitem.goods.push({
                            goods_id:goods_id,
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
                        alert('订单资料错误');
                        return;
                    }
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
                    global_id -= 1;
                },
                delLabel:function (item_id, order_id) {
                    var order = this.findOrder(order_id);
                    if(!order){
                        alert('订单资料错误');
                        return;
                    }
                    if(!confirm('确定删除该标签？')){
                        return;
                    }
                    var idx = this.findItem(order.package_id, item_id);
                    if(this.clearLabelAction(order, idx)){
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
                        alert('订单资料错误');
                        return;
                    }
                    var idx = this.findItem(order.package_id, item_id);
                    if(this.clearLabelAction(order, idx)){
                        this.$nextTick(function () {
                            alert('清除完成');
                        });
                    }else{
                        alert('清除错误');
                    }
                },
                clearLabelAction:function(order, idx){
                    if(idx > -1){
                        var item=this.packages[order.package_id][idx];
                        if(item.goods && item.goods.length>0){
                            var goods=item.goods.splice(0,item.goods.length);
                            for(var i=0;i<goods.length;i++){
                                for(var j=0;j<order.goods.length;j++){
                                    if(order.goods[j].goods_id === goods[i].goods_id){
                                        order.goods[j].release_count += goods[i].count;
                                        break;
                                    }
                                }
                            }

                        }
                        return true;
                    }
                    return false;
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
                doPrint:function () {
                    window.print();
                },

                //============= goods autocomplete
                showGoods:function (e) {
                    clearTimeout(hideTimeout);
                    var target=e.target;
                    currentInput = target;
                    var offset=$(target).offset();
                    var width=$(target).outerWidth();
                    var height=$(target).outerHeight();
                    this.listStyle.top=(offset.top+height)+'px';
                    this.listStyle.left=offset.left+'px';
                    this.listStyle.width=width+'px';
                    this.listStyle.display='block';
                    this.current_index = $(e.target).data('idx');

                    $(document.body).on('keyup',this.listenKeyup);
                    this.getGoodsList(e);
                },
                hideGoods:function (e) {
                    if(e){
                        var target=e.target;
                        var goods_pick=this.orders[this.current_index].goodspick;
                        goods_pick.title=goods_pick.orig_title;
                    }
                    var self=this;
                    hideTimeout=setTimeout(function () {
                        currentInput=null;
                        $(document.body).off('keyup',self.listenKeyup);
                        self.listStyle.display='none';
                    },500);
                },
                loadGoods:function (e) {
                    this.getGoodsList(e);
                },
                activeThis:function (e) {
                    var self=$(e.target);
                    var parent=self.parents('.list-group').eq(0);
                    parent.find('.list-group-item').removeClass('hover');
                    self.addClass('hover');
                },
                listenKeyup:function (e) {
                    var lists=$('.goods-complete .list-group-item');
                    var idx=lists.index($('.goods-complete .hover'));

                    switch (e.keyCode){
                        case 40://down
                            if(idx < lists.length-1){
                                idx++;
                                lists.removeClass('hover').eq(idx).addClass('hover');
                            }
                            break;
                        case 38://up
                            if(idx > 0){
                                idx--;
                            }
                            lists.removeClass('hover').eq(idx).addClass('hover');

                            break;
                        case 13://enter
                            if(this.selectGoods()) {
                                this.hideGoods();
                            }
                            break;
                    }
                },
                selectThis:function (e) {
                    if(this.selectGoods()) {
                        this.hideGoods();
                    }
                },
                selectGoods:function () {
                    var hover=$('.goods-complete .hover');
                    if(hover.length>0 && currentInput){
                        var idx=hover.data('idx');
                        var good = this.goodslist[idx];
                        if(good){
                            var goods = this.orders[this.current_index].goodspick;
                            goods.title = good.title;
                            goods.id = good.id;
                            goods.unit = good.unit;
                            goods.orig_title = good.title;
                            $(currentInput).nextAll('input').focus();

                            return true;
                        }
                    }
                    return false;
                },
                getGoodsList:function (e) {
                    var self=this;
                    var ckey=this.orders[this.current_index].goodspick.title.toString();
                    if(ckey===lastGoodsKey)return;
                    lastGoodsKey = ckey;

                    $.ajax({
                        url: '{:url("goods/search")}',
                        type: 'GET',
                        dataType: 'JSON',
                        data: {
                            key: ckey
                        },
                        success: function (json) {
                            if (json.code == 1) {
                                if(ckey===lastGoodsKey)self.goodslist= json.data;
                            }
                        }
                    });

                },

                //====================== customer autocomplete
                showCustomer:function (e) {
                    clearTimeout(hideCustomerTimeout);
                    var target=e.target;
                    var offset=$(target).offset();
                    var width=$(target).outerWidth();
                    var height=$(target).outerHeight();
                    this.customerStyle.top=(offset.top+height)+'px';
                    this.customerStyle.left=offset.left+'px';
                    this.customerStyle.width=width+'px';
                    this.customerStyle.display='block';
                    this.current_index = $(e.target).data('idx');
                    //this.cKey = $(e.target).val();
                    $(document.body).on('keyup',this.listenCustomerKeyup);
                    this.getCustomerList(e);
                },
                hideCustomer:function (e) {
                    if(e){
                        this.orders[this.current_index].customer_key=this.orders[this.current_index].customer_title;
                    }
                    var self=this;
                    clearTimeout(hideCustomerTimeout);
                    hideCustomerTimeout=setTimeout(function () {
                        $(document.body).off('keyup',self.listenCustomerKeyup);
                        self.customerStyle.display='none';
                    },500);
                },
                loadCustomer:function (e) {
                    this.getCustomerList(e);
                },
                activeThisCustomer:function (e) {
                    var self=$(e.target);
                    var parent=self.parents('.list-group').eq(0);
                    parent.find('.list-group-item').removeClass('hover');
                    self.addClass('hover');
                },
                listenCustomerKeyup:function (e) {
                    var lists=$('.customer-complete .list-group-item');
                    var idx=lists.index($('.customer-complete .hover'));

                    switch (e.keyCode){
                        case 40://down
                            if(idx < lists.length-1){
                                idx++;
                                lists.removeClass('hover').eq(idx).addClass('hover');
                            }
                            break;
                        case 38://up
                            if(idx > 0){
                                idx--;
                            }
                            lists.removeClass('hover').eq(idx).addClass('hover');

                            break;
                        case 13://enter
                            if(this.selectCustomer()) {
                                this.hideCustomer();
                            }
                            break;
                    }
                },
                selectThisCustomer:function (e) {
                    if(this.selectCustomer()) {
                        this.hideCustomer();
                    }
                },
                selectCustomer:function () {
                    var hover=$('.customer-complete .hover');
                    if(hover.length>0){
                        var idx=hover.data('idx');
                        var customer = this.customers[idx];
                        if(customer){
                            this.orders[this.current_index].customer_id=customer.id;
                            this.orders[this.current_index].customer_key=customer.title;
                            this.orders[this.current_index].customer_title=customer.title;
                            return true;
                        }
                    }
                    return false;
                },
                getCustomerList:function (e) {
                    var self=this;
                    var ckey=this.orders[this.current_index].customer_key.toString();
                    if(ckey===lastCustomerKey)return;
                    lastCustomerKey = ckey;

                    $.ajax({
                        url: '{:url("customer/search")}',
                        type: 'GET',
                        dataType: 'JSON',
                        data: {
                            key: ckey
                        },
                        success: function (json) {
                            if (json.code == 1) {
                                if(ckey===lastCustomerKey)self.customers= json.data;
                            }
                        }
                    });
                }
            }
        });
    </script>
</block>