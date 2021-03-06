{extend name="public:base" /}

{block name="body"}

    {include file="public/bread" menu="sale_order_index" title="销售开单" /}

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
                                    <input type="text" class="form-control isautocomplete" @focus="showCustomer" @blur="hideCustomer" @keyup="loadCustomer" v-model="cKey"/>
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
                                    <input type="text" class="form-control customer_date" @blur="setDate" data-format="YYYY-MM-DD hh:mm"  name="customer_time" v-model="order.customer_time"/>
                                </div>
                            </div>
                            <div class="col mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">货币</span></div>
                                    <select class="form-control" v-model="order.currency">
                                        {volist name="currencies" id="cur"}
                                            <option value="{$cur.key}">[{$cur.key}]{$cur.title}</option>
                                        {/volist}
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
                    <table class="table excel">
                        <thead>
                        <tr>
                            <th width="240">产品</th>
                            <th width="100">库存</th>
                            <th width="160">数量</th>
                            <th width="160">重量</th>
                            <th width="200">单价</th>
                            <th width="160">总价</th>
                            <th width="160">出库仓</th>
                            <th width="160">备注</th>
                            <th width="100">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(good,idx) in goods" :key="idx">
                                <td><input type="text" class="form-control form-control-sm isautocomplete" :data-idx="idx" @focus="showGoods" @blur="hideGoods" @keyup="loadGoods" v-model="good.title"/> </td>
                                <td>{{good.storage}}</td>
                                <td class="counttd">
                                    <div class="input-group input-group-sm">
                                        <input type="text" class="form-control" @change="updateRow(idx)" v-model="good.count"/>
                                        <select v-model="good.unit" style="flex:0;width: 50px;" @keydown="stopLeftRight" class="form-control">
                                            {volist name="units" id="unit"}
                                                <option value="{$unit.key}">{$unit.key}</option>
                                            {/volist}
                                        </select>
                                    </div>
                                </td>
                                <td>
                                    <div class="input-group input-group-sm">
                                        <input type="text" class="form-control" @change="updateRow(idx)" v-model="good.weight"/>
                                        <div class="input-group-append"><span class="input-group-text">{:getSetting('weight_unit')}</span></div>
                                    </div>
                                </td>
                                <td>
                                    <div class="input-group input-group-sm">
                                        <input type="text" class="form-control" @change="updateRow(idx)" v-model="good.price"/>
                                        <div class="input-group-middle">
                                            <span class="input-group-text" >/</span>
                                        </div>
                                        <select v-model="good.price_type" @keydown="stopLeftRight" @change="updateRow(idx)" class="form-control">
                                            <option :value="0">{{good.unit}}</option>
                                            <option :value="1">{:getSetting('weight_unit')}</option>
                                        </select>
                                    </div>
                                </td>
                                <td>
                                    <div class="input-group input-group-sm" v-if="good.diy_price">
                                        <input type="text" v-model="good.total_price" @change="totalPrice" class="form-control" />
                                        <div class="input-group-append">
                                            <a href="javascript:" class="btn btn-outline-primary" @click="changePricetype(idx,0)" title="自动计算"><i class="ion-md-undo"></i> </a>
                                        </div>
                                    </div>
                                    <div v-else>
                                        {{good.total_price}}
                                        <a href="javascript:" @click="changePricetype(idx,1)" title="改价"><i class="ion-md-create"></i> </a>
                                    </div>
                                </td>
                                <td>
                                    <select class="form-control form-control-sm" @keydown="stopLeftRight" @change="updateStorage" v-model="good.storage_id">
                                        <option :value="0">请选择仓库</option>
                                        <option v-for="storage in storages" :key="storage.id" :value="storage.id">[{{storage.storage_no}}]{{storage.title}}</option>
                                    </select>
                                </td>
                                <td>
                                    <div class="input-group input-group-sm">
                                        <input type="text" class="form-control" v-model="good.remark"/>
                                    </div>
                                </td>
                                <td class="operations"><a href="javascript:" class="btn btn-sm btn-outline-danger" title="删除" @click="delGoods(idx)"><i class="ion-md-close "></i> </a> </td>
                            </tr>
                        </tbody>
                        <tfoot>
                        <tr>
                            <th>汇总: {{total.number}}</th>
                            <td></td>
                            <td>{{total.count}}</td>
                            <td>{{total.weight}} {:getSetting('weight_unit')}</td>
                            <td></td>
                            <td>
                                <div class="input-group input-group-sm" v-if="order.diy_price">
                                    <input type="text" v-model="total.price" class="form-control" />
                                    <div class="input-group-append">
                                        <a href="javascript:" class="btn btn-outline-primary" @click="changeOrderPricetype(0)" title="自动计算"><i class="ion-md-undo"></i> </a>
                                    </div>
                                </div>
                                <div v-else>
                                    {{total.price}}
                                    <a href="javascript:" @click="changeOrderPricetype(1)" title="改价"><i class="ion-md-create"></i> </a>
                                </div>
                            </td>
                            <td>

                            </td>
                            <td>

                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td colspan="5">
                                <div class="input-group input-group-sm w-50 float-right">
                                    <div class="input-group-prepend"><span class="input-group-text">订单备注</span></div>
                                    <input type="text" class="form-control" v-model="order.remark"/>
                                </div>
                                <a href="javascript:" @click="addRow" class="btn btn-outline-primary btn-sm btn-addrow"><i class="ion-md-add"></i> 添加行</a>
                                <a href="{:url('goods/importOrder')}" @click="importOrder" class="btn btn-outline-primary btn-sm btn-import"><i class="ion-md-cloud-upload"></i> 导入订单</a>
                            </td>
                            <td colspan="4">
                                <div class="input-group input-group-sm w-50">
                                    <div class="input-group-prepend"><span class="input-group-text">运费</span></div>
                                    <input type="text" class="form-control" v-model="order.freight"/>
                                </div>
                            </td>
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
{/block}
{block name="script"}
    <script type="text/javascript" src="__STATIC__/js/vue-2.6.min.js"></script>
    <script type="text/javascript">
        var hideTimeout=0;
        var currentInput=null;
        var hideCustomerTimeout=0;
        var lastCustomerKey=null;
        var lastGoodsKey=null;

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
                    diy_price:0,
                    order_no:'',
                    freight:0,
                    remark:'',
                    customer_order_no:''
                },
                cKey:'',
                customers:[],
                storages:[],
                emptyGoods:[],
                key:'',
                listGoods:[],
                total:{
                    number: 0,
                    count:0,
                    weight:0,
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
                        storage:0,
                        storage_id:this.order.storage_id,
                        count:'',
                        diy_price:0,
                        price_type:0,
                        unit:'单位',
                        weight:0,
                        price:0,
                        remark:'',
                        total_price:0
                    });
                },
                stopLeftRight:function(e){
                    if(e.keyCode == 37 || e.keyCode == 39) {
                        e.preventDefault()
                    }
                },
                updateStorage:function(){
                    var storage_map={ };
                    var storage_id=0;
                    for(var i=0;i<this.goods.length;i++){
                        if( this.goods[i].goods_id>0) {
                            storage_id=this.goods[i].storage_id;
                            if(storage_id>0 ) {
                                if (!storage_map[storage_id])
                                    storage_map[storage_id] = [];
                                storage_map[storage_id].push(this.goods[i].goods_id);
                            }
                        }
                    }

                    if(storage_id>0){
                        var self=this;
                        $.ajax({
                            url:'{:url("storage/getStorage")}',
                            type:'POST',
                            dataType:'JSON',
                            data:{
                                storage_id:storage_map
                            },
                            success:function (json) {
                                if(json.code==1) {
                                    var storages=json.data;
                                    for(var i=0;i<self.goods.length;i++){
                                        var storage_id=self.goods[i].storage_id;
                                        if(storage_id>0 && storages[storage_id]
                                        && storages[storage_id][self.goods[i].goods_id]) {
                                            self.goods[i].storage = storages[storage_id][self.goods[i].goods_id];
                                        }else{
                                            self.goods[i].storage = 0;
                                        }
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
                setDate:function (e) {
                    this.order.customer_time= e.target.value;
                },
                updateRow:function (idx) {
                    var good = this.goods[idx];
                    if(good.diy_price==0) {
                        this.goods[idx].total_price = (good.price_type == 1 ? (good.weight * good.price) : (good.count * good.price)).format(2);

                        this.totalPrice();
                    }
                },
                changePricetype:function (idx, type) {
                    var good = this.goods[idx];
                    this.goods[idx].diy_price=type;
                    if(type==0){
                        this.updateRow(idx);
                    }
                },
                changeOrderPricetype:function (type) {

                    this.order.diy_price=type;
                    if(type==0){
                        this.totalPrice();
                    }
                },
                totalPrice:function () {
                    this.total.number = 0;
                    this.total.count = 0;
                    this.total.weight = 0;
                    var total_price = 0;
                    for (var i = 0; i < this.goods.length; i++) {
                        if(this.goods[i].goods_id>0)this.total.number+=1;
                        if (this.goods[i].count) this.total.count += parseFloat(this.goods[i].count);
                        if (this.goods[i].weight) this.total.weight += parseFloat(this.goods[i].weight);
                        if (this.goods[i].total_price) total_price += parseFloat(this.goods[i].total_price.toString().replace(',', ''));
                    }
                    if(this.order.diy_price==0) {
                        this.total.price = total_price.format(2);
                    }
                    this.total.weight = (Math.round(this.total.weight*10000)*0.0001).toFixed(4)
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
                            for(var i=0;i<this.goods.length;i++){
                                if(i != idx && this.goods[i].goods_id == good.id){
                                    dialog.alert('商品重复');
                                    return false;
                                }
                            }
                            idx = $(currentInput).data('idx');
                            this.goods[idx].goods_id=good.id;
                            this.goods[idx].title=good.title;
                            this.goods[idx].orig_title=good.title;
                            this.goods[idx].storage=good.storage?good.storage:0;
                            this.goods[idx].unit=good.unit;
                            this.goods[idx].price_type=good.price_type;
                            $(currentInput).parents('tr').find('.counttd input').focus();
                            this.updateStorage();
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

                importOrder:function (e) {
                    e.preventDefault();

                    var self=this;
                    importExcel('导入销售订单',$(e.target).attr('href'),function (data) {
                        if(data.errors && data.errors.length){
                            dialog.alert(data.errors.join("<br />"));
                        }
                        for(var j=0;j<data.goods.length;j++) {
                            var good = data.goods[j];
                            var is_break=false;
                            for (var i = 0; i < self.goods.length; i++) {
                                if (self.goods[i].goods_id == good.goods_id) {
                                    dialog.warning('商品【'+good.title+'】重复');
                                    is_break=true;
                                    break;
                                }
                            }
                            if(is_break)continue;
                            self.goods.push({
                                id:0,
                                goods_id:good.goods_id,
                                storage_id:self.order.storage_id,
                                title:good.title,
                                orig_title:good.title,
                                count:good.count,
                                unit:good.unit,
                                price_type:good.price_type,
                                weight:good.weight,
                                price:good.price,
                                remark:good.remark,
                                total_price:0
                            });
                            self.updateRow(self.goods.length-1);
                        }

                        self.totalPrice();
                        self.updateStorage();

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
                            this.order.customer_id=customer.id;
                            this.order.customer_title=customer.title;
                            this.cKey = customer.title;
                            updateThisTitle('销售单['+customer.title+']');
                            return true;
                        }
                    }
                    return false;
                },
                getCustomerList:function (e) {
                    var self=this;
                    var ckey = this.cKey.toString();
                    if(ckey === lastCustomerKey)return;
                    lastCustomerKey=ckey;

                    $.ajax({
                        url: '{:url("customer/search")}',
                        type: 'GET',
                        dataType: 'JSON',
                        data: {
                            key: ckey
                        },
                        success: function (json) {
                            if (json.code == 1) {
                                if(ckey===lastCustomerKey)self.customers = json.data;
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
                    var goods_count=0;
                    for(var i=0;i<this.goods.length;i++){
                        if(this.goods[i].goods_id)goods_count++;
                    }
                    if(goods_count < 1){
                        dialog.error('请至少录入一条产品');
                        return false;
                    }
                    var self=this;
                    this.ajaxing=true;
                    $.ajax({
                        url:'',
                        type:"POST",
                        dataType:'JSON',
                        data:{
                            order:JSON.stringify(this.order),
                            goods:JSON.stringify(this.goods),
                            total:JSON.stringify(this.total)
                        },
                        success:function (json) {
                            self.ajaxing=false;
                            if(json.code==1){
                                refreshFromPage();
                                dialog.confirm({
                                    btns:[
                                        { 'text' : '关闭本页','type':'secondary' },
                                        { 'text' : '留在本页','isdefault':true,'type':'primary' }
                                    ],
                                    content:json.msg
                                },function () {
                                    updateThisTitle({ key:'sale_order_index_edit-'+json.data.id });
                                    if (json.url) {
                                        location.href = json.url;
                                    } else {
                                        location.reload();
                                    }
                                },function () {
                                    closeThisPage()
                                });
                            }else{
                                dialog.error(json.msg);
                            }
                        }
                    });

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
{/block}