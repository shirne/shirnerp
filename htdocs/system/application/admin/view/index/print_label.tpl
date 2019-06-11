<extend name="public:print" />
<block name="header">
    <style >
        @page {
            size: 10cm 10cm;
            margin:0;
        }
        #page-wrapper{

        }
        .print-page{
            width :8cm;
            padding:0;
            height:6cm;
            margin-top:1em;
            position: relative;
            border-radius:5px;
            box-shadow: 1px 2px 5px rgba(0,0,0,.2);
        }
        .print-page .labelid{
            position: absolute;
            left:10px;
            top:10px;
            padding:0;
            font-size:16px;
            border-radius:100%;
            line-height:24px;
            height : 24px;
            width : 24px;
            text-align: center;
        }
        .print-page .btn-circle{
            position: absolute;
            font-size:22px;
            padding:0;
            border-radius:100%;
            line-height:24px;
            width:24px;
            text-align: center;
        }
        .print-page .btn-delete{
            color:red;
            right:10px;
            top:10px;
        }
        .print-page .btn-clear{
            color:#999;
            right:10px;
            bottom:10px;
        }
        .print-page .table{
            height:90%;
        }
        .print-page .table td{
            border-top:0;
            vertical-align: middle;
        }
        .orderwrapper{
            padding:10px;
            border-bottom:1px #ddd solid;
            display:flex;
        }
        .goodsbox{
            flex:1;
        }
        .goodsbox .lead{
            font-size:13px;
        }
        .labelbox{
            width:17cm;
            flex:0 0 auto;
        }
        .btn-addlabel{
            clear:left;
            float: left;
        }
        .table thead h3{
            white-space: nowrap;
        }
        .table tbody td{
            white-space: nowrap;
            padding:0 0.3cm 0 0.3cm;
            font-size:0.7cm;
        }
        .table tbody tr.middle td{
            font-size:0.5cm;
        }
        .table tbody tr.small td{
            font-size:0.3cm;
        }
        @media print {
            .orderwrapper{
                padding:0;
                border:0;
            }
        }
    </style>
</block>
<block name="body">
    <div class="page-wrapper container ml-auto mr-auto mb-3 d-print-none">
        <div class="row">
            <h2 class="col-md-6">标签打印</h2>
            <div class="col-md-6 text-right ">
                <a href="javascript:" class="btn btn-primary print-btn" @click="doPrint">打印</a>
            </div>
        </div>
    </div>
    <div id="page-wrapper" class="container m-auto">
        <div class="orderwrapper d-print-none" v-for="order in orders">
            <div class="goodsbox pr-3">
                <h3 class="mt-3">{{order.order_no}}</h3>
                <div class="lead">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text">品种</span>
                        </div>
                        <input type="text" class="form-control" v-model="goods.title" placeholder="" aria-label="" aria-describedby="basic-addon1">
                        <div class="input-group-middle">
                            <span class="input-group-text">数量</span>
                        </div>
                        <input type="text" class="form-control" v-model="goods.count" placeholder="" aria-label="" aria-describedby="basic-addon1">
                        <select name="" class="form-control">

                        </select>
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary" @click="addGoods" type="button">添加品种</button>
                        </div>
                    </div>
                </div>
                <hr class="my-3"/>
                <div class="btn-group dropright mr-3 mt-3" v-for="good in order.goods">
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
                    </div>
                </div>
            </div>

            <div class="labelbox clearfix">
                <div class="print-page float-left mr-3" v-for="pkg in packages[order.package_id]">
                    <span class="badge badge-secondary labelid">{{pkg.title}}</span>
                    <a class="btn btn-circle btn-delete" title="删除标签" @click="delLabel(pkg.id,order.id)" href="javascript:"><i class="ion-md-close"></i> </a>
                    <a class="btn btn-circle btn-clear" title="清空标签" @click="clearLabel(pkg.id,order.id)" href="javascript:"><i class="ion-md-refresh-circle"></i> </a>
                    <table class="table">
                        <thead class="text-center"><tr><td colspan="2"><h3>{{order.customer_title}}</h3></td></tr></thead>
                        <tbody>
                        <template v-if="pkg.goods.length>3">
                            <template v-for="idx in Math.ceil(pkg.goods.length * .5)">
                                <tr class="middle">
                                    <td class="text-right">
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
                                <td>
                                    {{ formatNumber(good.count)}} {{good.goods_unit}}
                                </td>
                            </tr>
                        </template>
                        <template v-else>
                            <tr v-for="good in pkg.goods">
                                <td>
                                    <div class="row">
                                        <h4 class="col-4 text-right">品名：</h4>
                                        <h4 class="col text-left">{{good.goods_title}}</h4>
                                    </div>
                                    <div class="row">
                                        <h4 class="col-4 text-right">数量：</h4>
                                        <h4 class="col text-left">{{ formatNumber(good.count)}} {{good.goods_unit}}</h4>
                                    </div>
                                </td>
                            </tr>
                        </template>
                        </tbody>
                    </table>
                </div>
                <a  href="javascript:" class="btn btn-outline-primary btn-addlabel mt-3" @click="addLabel(order.id)">增加标签</a>
            </div>
        </div>
        <a  href="javascript:" class="btn btn-outline-primary d-print-none btn-addorder m-3" @click="createOrder()">增加订单</a>
        <div class="d-none d-print-block">
            <template v-for="order in orders">
                <div class="print-page" v-for="pkg in packages[order.package_id]">
                    <table class="table">
                        <thead class="text-center"><tr><td colspan="2"><h3>{{order.customer_title}}</h3></td></tr></thead>
                        <tbody>
                        <template v-if="pkg.goods.length>3">
                            <template v-for="idx in Math.ceil(pkg.goods.length * .5)">
                                <tr class="middle">
                                    <td class="text-right">
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
                                <td>
                                    {{good.count}} {{good.goods_unit}}
                                </td>
                            </tr>
                        </template>
                        <template v-else>
                            <tr v-for="good in pkg.goods">
                                <td>
                                    <div class="row">
                                        <h4 class="col-4 text-right">品名：</h4>
                                        <h4 class="col text-left">{{good.goods_title}}</h4>
                                    </div>
                                    <div class="row">
                                        <h4 class="col-4 text-right">数量：</h4>
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
</block>
<block name="script">
    <script type="text/javascript" src="__STATIC__/js/vue-2.6.min.js"></script>
    <script type="text/javascript">

        function formatNumber(number){
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
        var app = new Vue({
            el: '#page-wrapper',
            data: {
                goods:{
                    title:'',
                    id:0,
                    count:0,
                    unit:''
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
                        customer_title:''
                    };
                    this.orders.push(order);
                    this.packages[order.package_id]=[
                        {
                            id:++item_id,
                            title:1,
                            package_id:order.package_id,
                            goods:[]
                        }
                    ];

                },
                deleteOrder:function(order_id){
                    for(var i=0;i<this.orders.length;i++){
                        if(this.orders[i].id === order_id){
                            this.orders.splice(i,1);
                            delete this.packages[this.orders[i].package_id];
                            break;
                        }
                    }
                },
                addGoods:function(){

                },
                delGoods:function(){

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
                        this.packages[order.package_id]=[];
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
                }
            }
        });
    </script>
</block>