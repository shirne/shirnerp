<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="sale_order_index" title="销售开单" />

    <div id="page-wrapper">
        <div class="page-header">销售开单</div>
        <div class="page-content">
            <form method="post" action="" enctype="multipart/form-data" @submit="onSubmit">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-6 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">客户</span></div>
                                    <input type="text" class="form-control" @focus="showCustomer" @blur="hideCustomer" v-model="cKey"/>
                                </div>
                            </div>
                            <div class="col-3 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">客户单号</span></div>
                                    <input type="text" class="form-control" name="customer_order_no" v-model="order.customer_order_no"/>
                                </div>
                            </div>
                            <div class="col-3 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">单号</span></div>
                                    <input type="text" class="form-control" placeholder="不填写将由系统自动生成" name="order_no" v-model="order.order_no"/>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">仓库</span></div>
                                    <select class="form-control" v-model="order.storage_id">
                                        <option :value="0">请选择仓库</option>
                                        <option v-for="storage in storages" :key="storage.id" :value="storage.id">[{{storage.storage_no}}]{{storage.title}}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-3 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">交货时间</span></div>
                                    <input type="text" class="form-control customer_date" data-format="YYYY-MM-DD hh:mm"  name="customer_time" v-model="order.customer_time"/>
                                </div>
                            </div>
                            <div class="col mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">货币</span></div>
                                    <select class="form-control" v-model="order.currency">
                                        <volist name="currencies" id="cur">
                                            <option value="{$cur.key}">[{$cur.key}]{$cur.title}</option>
                                        </volist>
                                    </select>
                                </div>
                            </div>
                            <div class="col mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">状态</span></div>
                                    <select name="status" class="form-control" v-model="order.status">
                                        <option :value="0" >待出库</option>
                                        <option :value="1" >已出库</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                    <table class="table">
                        <thead>
                        <tr>
                            <th>产品</th>
                            <th>库存</th>
                            <th>数量</th>
                            <th>单位</th>
                            <th>单价</th>
                            <th>总价</th>
                            <th>出库仓</th>
                            <th>操作</th>
                        </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(good,idx) in goods" :key="idx">
                                <td><input type="text" class="form-control" :data-idx="idx" @focus="showGoods" @blur="hideGoods" @keyup="loadGoods" v-model="good.title"/> </td>
                                <td>{{good.storage}}</td>
                                <td class="counttd"><input type="text" class="form-control" @change="updateRow(idx)" v-model="good.count"/> </td>
                                <td>{{good.unit}} </td>
                                <td><input type="text" class="form-control" @change="updateRow(idx)" v-model="good.price"/> </td>
                                <td>{{good.total_price}} </td>
                                <td>
                                    <select class="form-control" v-model="good.storage_id">
                                        <option :value="0">请选择仓库</option>
                                        <option v-for="storage in storages" :key="storage.id" :value="storage.id">[{{storage.storage_no}}]{{storage.title}}</option>
                                    </select>
                                </td>
                                <td><a href="javascript:" class="btn btn-outline-primary" @click="delGoods(idx)">删除</a> </td>
                            </tr>
                        </tbody>
                        <tfoot>
                        <tr>
                            <th>汇总</th>
                            <td></td>
                            <td>{{total.count}}</td>
                            <td></td>
                            <td></td>
                            <td>{{total.price}}</td>
                            <td>

                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td colspan="8"><a href="javascript:" @click="addRow" class="btn btn-outline-primary btn-addrow">添加行</a> </td>
                        </tr>
                        </tfoot>
                    </table>
                    <div class="card-footer">
                        <a href="javascript:" class="btn btn-primary" @click="onSubmit">提交保存</a>
                    </div>
                </div>
            </form>
        </div>

        <ul class="list-group auto-complete goods-complete" :style="listStyle">
            <li class="list-group-item" v-for="(good,idx) in listGoods" :data-idx="idx" :key="good.id" @click="selectThis" @mouseenter="activeThis">
                [{{good.goods_no}}]{{good.title}}
            </li>
        </ul>
        <ul class="list-group auto-complete customer-complete" :style="customerStyle">
            <li class="list-group-item" v-for="(customer,idx) in customers" :data-idx="idx" :key="customer.id" @click="selectThisCustomer" @mouseenter="activeThisCustomer">
                [{{customer.id}}]{{customer.title}}
            </li>
        </ul>
    </div>
</block>
<block name="script">
    <script type="text/javascript" src="__STATIC__/js/vue-2.6.min.js"></script>
    <script type="text/javascript">
        var hideTimeout=0;
        var currentInput=null;
        var hideCustomerTimeout=0;
        var app = new Vue({
            el: '#page-wrapper',
            data: {
                goods:[],
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
                order:{
                    customer_id:0,
                    storage_id:0,
                    currency:'{:current($currencies)['key']}',
                    customer_time:'',
                    status:0,
                    order_no:'',
                    customer_order_no:''
                },
                cKey:'',
                customers:[],
                storages:[],
                emptyGoods:[],
                key:'',
                listGoods:[],
                total:{
                    count:0,
                    price:0
                },
                ajaxing:false
            },
            watch:{
                'order.storage_id':function (val, oVal) {
                    this.listGoods=[];
                    this.emptyGoods=[];
                    if(val){
                        for(var i=0;i<this.goods.length;i++){
                            if(!this.goods[i].storage_id){
                                this.goods[i].storage_id = val;
                            }
                        }
                    }
                    this.updateStorage();
                },
                cKey:function (val, oVal) {
                    this.getCustomerList();
                }
            },
            mounted:function(){
                var config=$.extend({
                    tooltips:tooltips,
                    format: 'YYYY-MM-DD',
                    locale: 'zh-cn',
                    showClear:true,
                    showTodayButton:true,
                    showClose:true,
                    keepInvalid:true
                },transOption($('.customer_date').data()));

                $('.customer_date').datetimepicker(config);

                this.addRow();
                this.loadStorages();
            },
            methods:{
                loadStorages:function () {
                    var self=this;
                    $.ajax({
                        url:'{:url("storage/search")}',
                        type:'GET',
                        dataType:'JSON',
                        data:{
                            key:''
                        },
                        success:function (json) {
                            if(json.code==1) {
                                self.storages = json.data;
                            }
                        }
                    })
                },
                addRow:function(){
                    this.goods.push({
                        id:0,
                        title:'',
                        orig_title:'',
                        storage_id:this.order.storage_id,
                        count:'',
                        unit:'',
                        price:0,
                        total_price:0
                    });
                },
                updateStorage:function(){
                    if(this.order.storage_id){
                        var goods_ids=[];
                        for(var i=0;i<this.goods.length;i++){
                            goods_ids.push(this.goods[i].goods_id);
                        }
                        var self=this;
                        $.ajax({
                            url:'{:url("storage/getStorage")}',
                            type:'GET',
                            dataType:'JSON',
                            data:{
                                storage_id:self.order.storage_id,
                                goods_id:goods_ids.join(',')
                            },
                            success:function (json) {
                                if(json.code==1) {
                                    var storages=json.data;
                                    for(var i=0;i<self.goods.length;i++){
                                        self.goods[i].storage=storages[self.goods[i].goods_id]?storages[self.goods[i].goods_id]:0;
                                    }
                                }
                            }
                        })
                    }else{
                        for(var i=0;i<this.goods.length;i++){
                            this.goods[i].storage=0;
                        }
                    }
                },
                updateRow:function (idx) {
                    var good = this.goods[idx];
                    this.goods[idx].total_price=(good.count * good.price ).format(2);
                    this.totalPrice();
                },
                totalPrice:function () {
                    this.total.count=0;
                    this.total.price=0;
                    for(var i=0;i<this.goods.length;i++){
                        if(this.goods[i].count)this.total.count+=parseFloat(this.goods[i].count);
                        if(this.goods[i].total_price)this.total.price+=parseFloat(this.goods[i].total_price);
                    }
                    this.total.price = this.total.price.format(2);
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
                    this.key = $(e.target).val();
                    $(document.body).on('keyup',this.listenKeyup);
                    this.getGoodsList(e);
                },
                hideGoods:function (e) {
                    if(e){
                        var target=e.target;
                        var idx = $(target).data('idx');
                        if(this.goods[idx]) {
                            this.goods[idx].title = this.goods[idx].orig_title;
                        }
                    }
                    var self=this;
                    hideTimeout=setTimeout(function () {
                        currentInput=null;
                        $(document.body).off('keyup',self.listenKeyup);
                        self.listStyle.display='none';
                    },500);
                },
                loadGoods:function (e) {
                    var key = $(e.target).val();
                    if(key == this.key)return;
                    this.key = key;
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
                        var good = this.listGoods[idx];
                        if(good){
                            idx = $(currentInput).data('idx');
                            this.goods[idx].goods_id=good.id;
                            this.goods[idx].title=good.title;
                            this.goods[idx].orig_title=good.title;
                            this.goods[idx].storage=good.storage?good.storage:0;
                            this.goods[idx].unit=good.unit;
                            $(currentInput).parents('tr').find('.counttd input').focus();
                            return true;
                        }
                    }
                    return false;
                },
                getGoodsList:function (e) {
                    var self=this;
                    var key = this.key;
                    if(key=='' && self.emptyGoods && self.emptyGoods.length>0){
                        self.listGoods = self.emptyGoods;
                    }else {
                        $.ajax({
                            url: '{:url("goods/search")}',
                            type: 'GET',
                            dataType: 'JSON',
                            data: {
                                key: key,
                                storage_id:this.order.from_storage_id
                            },
                            success: function (json) {
                                if (json.code == 1) {
                                    if (key == self.key) self.listGoods = json.data;
                                    if (key == '') {
                                        self.emptyGoods = json.data;
                                    }
                                }
                            }
                        });
                    }
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
                    this.cKey = $(e.target).val();
                    $(document.body).on('keyup',this.listenCustomerKeyup);
                    this.getCustomerList(e);
                },
                hideCustomer:function (e) {
                    if(e){
                        if(this.cKey != this.order.customer_title) {
                            this.cKey = this.order.customer_title;
                        }
                    }
                    var self=this;
                    clearTimeout(hideCustomerTimeout);
                    hideCustomerTimeout=setTimeout(function () {
                        $(document.body).off('keyup',self.listenCustomerKeyup);
                        self.customerStyle.display='none';
                    },500);
                },
                /*loadCustomer:function (e) {
                    var ckey = $(e.target).val();
                    if(ckey == this.cKey)return;
                    this.cKey = ckey;
                    this.getCustomerList(e);
                },*/
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
                            this.order.customer_id=customer.id;
                            this.order.customer_title=customer.title;
                            this.cKey = customer.title;
                            return true;
                        }
                    }
                    return false;
                },
                getCustomerList:function (e) {
                    var self=this;
                    var ckey = this.cKey;

                    $.ajax({
                        url: '{:url("customer/search")}',
                        type: 'GET',
                        dataType: 'JSON',
                        data: {
                            key: ckey
                        },
                        success: function (json) {
                            if (json.code == 1) {
                                self.customers = json.data;
                            }
                        }
                    });
                },

                //======================
                onSubmit:function(e){
                    e.preventDefault();
                    if(!this.order.storage_id){
                        dialog.error('请选择仓库');
                        return false;
                    }
                    if(!this.order.customer_id){
                        dialog.error('请选择客户');
                        return false;
                    }

                    $.ajax({
                        url:'',
                        type:"POST",
                        dataType:'JSON',
                        data:{
                            order:this.order,
                            goods:this.goods
                        },
                        success:function (json) {
                            if(json.code==1){
                                dialog.success('开单成功！');
                                location.reload();
                            }else{
                                dialog.error(json.msg);
                            }
                        }
                    })

                    return false;
                },
                delGoods:function (id) {
                    var self=this;
                    dialog.confirm('确定删除该行？',function () {
                        self.goods.splice(id,1);
                    })
                }
            }
        })
    </script>
</block>