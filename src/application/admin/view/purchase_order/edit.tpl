{extend name="public:base" /}

{block name="body"}

    {include file="public/bread" menu="purchase_order_index" title="编辑采购单" /}

    <div id="page-wrapper">
        <div class="page-header">编辑采购单</div>
        <div class="page-content">
            <form method="post" action="" enctype="multipart/form-data" @submit="onSubmit">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-6 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">供应商</span></div>
                                    <input type="text" class="form-control" @focus="showSupplier" @blur="hideSupplier"   @keyup="loadSupplier" v-model="cKey"/>
                                </div>
                            </div>
                            <div class="col-3 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">客户单号</span></div>
                                    <input type="text" class="form-control" name="supplier_order_no" v-model="order.supplier_order_no"/>
                                </div>
                            </div>
                            <div class="col-3 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">单号</span></div>
                                    <span class="form-control">{{order.order_no}}</span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-4 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">仓库</span></div>
                                    <select class="form-control" v-model="order.storage_id">
                                        <option :value="0">请选择仓库</option>
                                        <option v-for="storage in storages" :key="storage.id" :value="storage.id">[{{storage.storage_no}}]{{storage.title}}</option>
                                    </select>
                                </div>
                            </div>

                            <div class="col-4 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">货币</span></div>
                                    <select class="form-control" v-model="order.currency">
                                        {volist name="currencies" id="cur"}
                                            <option value="{$cur.key}">[{$cur.key}]{$cur.title}</option>
                                        {/volist}
                                    </select>
                                </div>
                            </div>
                            <div class="col-4 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">状态</span></div>
                                    <select name="status" class="form-control" v-model="order.status">
                                        <option :value="0" >待入库</option>
                                        <option :value="1" >已入库</option>
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
                            <th width="160">备注</th>
                            <th width="100">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr v-for="(good,idx) in goods" :key="idx">
                            <td><input type="text" class="form-control form-control-sm isgoods" :data-idx="idx" @focus="showGoods" @blur="hideGoods" @keyup="loadGoods" v-model="good.title"/> </td>
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
                            <td></td>
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
                            <td colspan="3">
                                <div class="input-group input-group-sm w-50">
                                    <div class="input-group-prepend"><span class="input-group-text">运费</span></div>
                                    <input type="text" class="form-control" v-model="order.freight"/>
                                </div>
                            </td>
                        </tr>
                        </tfoot>
                    </table>
                    <div class="card-footer">
                        <a href="javascript:" :class="'btn btn-primary'+(ajaxing?' disabled':'')" @click="onSubmit">提交保存</a>
                    </div>
                </div>
            </form>
        </div>

        <ul class="list-group auto-complete goods-complete" :style="listStyle">
            <li class="list-group-item" v-for="(good,idx) in listGoods" :data-idx="idx" :key="good.id" @click="selectThis" @mouseenter="activeThis">
                [{{good.goods_no}}]{{good.title}}
            </li>
        </ul>
        <ul class="list-group auto-complete supplier-complete" :style="supplierStyle">
            <li class="list-group-item" v-for="(supplier,idx) in suppliers" :data-idx="idx" :key="supplier.id" @click="selectThisSupplier" @mouseenter="activeThisSupplier">
                [{{supplier.id}}]{{supplier.title}}
            </li>
        </ul>
    </div>
{/block}
{block name="script"}
    <script type="text/javascript" src="__STATIC__/js/vue-2.6.min.js"></script>
    <script type="text/javascript">
        var hideTimeout=0;
        var currentInput=null;
        var hideSupplierTimeout=0;
        var lastCustomerKey=null;
        var lastGoodsKey=null;
        window.page_title = '采购单[{$supplier.title}]';
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
                supplierStyle:{
                    display:'none',
                    position:'absolute',
                    left:0,
                    top:0,
                    width:0
                },
                order:{$model|json_encode|raw},
                cKey:'',
                suppliers:[],
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
                    this.updateStorage();
                }
            },
            mounted:function(){
                this.loadStorages();
                this.initData();
                if(this.order.diy_price){
                    this.total.price = this.order.amount;
                }
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
                initData:function () {
                    var supplier={$supplier|json_encode|raw};
                    var goods={$goods|json_encode|raw};
                    this.cKey=this.order.supplier_title=supplier.title;
                    for(var i=0;i<goods.length;i++){
                        this.goods.push({
                            id:goods[i].id,
                            goods_id:goods[i].goods_id,
                            title:goods[i].goods_title,
                            storage:0,
                            orig_title:goods[i].goods_title,
                            diy_price:goods[i].diy_price,
                            price_type:goods[i].price_type,
                            count:goods[i].count,
                            weight:goods[i].weight,
                            unit:goods[i].goods_unit,
                            price:goods[i].price,
                            remark:goods[i].remark,
                            total_price:goods[i].amount
                        });
                    }
                    this.updateStorage();
                    this.totalPrice();
                },

                stopLeftRight:function(e){
                    if(e.keyCode == 37 || e.keyCode == 39) {
                        e.preventDefault()
                    }
                },
                addRow:function(){
                    this.goods.push({
                        id:0,
                        goods_id:0,
                        storage:0,
                        title:'',
                        orig_title:'',
                        count:'',
                        unit:'单位',
                        diy_price:0,
                        price_type:0,
                        weight:0,
                        price:0,
                        remark:'',
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
                            type:'POST',
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
                                storage_id:this.order.storage_id
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
                    importExcel('导入采购订单',$(e.target).attr('href'),function (data) {
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

                //====================== supplier autocomplete
                showSupplier:function (e) {
                    clearTimeout(hideSupplierTimeout);
                    var target=e.target;
                    var offset=$(target).offset();
                    var width=$(target).outerWidth();
                    var height=$(target).outerHeight();
                    this.supplierStyle.top=(offset.top+height)+'px';
                    this.supplierStyle.left=offset.left+'px';
                    this.supplierStyle.width=width+'px';
                    this.supplierStyle.display='block';
                    //this.cKey = $(e.target).val();
                    $(document.body).on('keyup',this.listenSupplierKeyup);
                    this.getSupplierList(e);
                },
                hideSupplier:function (e) {
                    if(e){
                        if(this.cKey != this.order.supplier_title) {
                            this.cKey = this.order.supplier_title;
                        }
                    }
                    var self=this;
                    clearTimeout(hideSupplierTimeout);
                    hideSupplierTimeout=setTimeout(function () {
                        $(document.body).off('keyup',self.listenSupplierKeyup);
                        self.supplierStyle.display='none';
                    },500);
                },
                loadSupplier:function (e) {
                    this.getSupplierList(e);
                },
                activeThisSupplier:function (e) {
                    var self=$(e.target);
                    var parent=self.parents('.list-group').eq(0);
                    parent.find('.list-group-item').removeClass('hover');
                    self.addClass('hover');
                },
                listenSupplierKeyup:function (e) {
                    var lists=$('.supplier-complete .list-group-item');
                    var idx=lists.index($('.supplier-complete .hover'));

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
                            if(this.selectSupplier()) {
                                this.hideSupplier();
                            }
                            break;
                    }
                },
                selectThisSupplier:function (e) {
                    if(this.selectSupplier()) {
                        this.hideSupplier();
                    }
                },
                selectSupplier:function () {
                    var hover=$('.supplier-complete .hover');
                    if(hover.length>0){
                        var idx=hover.data('idx');
                        var supplier = this.suppliers[idx];
                        if(supplier){
                            this.order.supplier_id=supplier.id;
                            this.order.supplier_title=supplier.title;
                            this.cKey = supplier.title;
                            updateThisTitle('采购单['+supplier.title+']');

                            return true;
                        }
                    }
                    return false;
                },
                getSupplierList:function (e) {
                    var self=this;
                    var ckey = this.cKey.toString();
                    if(ckey === lastCustomerKey)return;
                    lastCustomerKey=ckey;

                    $.ajax({
                        url: '{:url("supplier/search")}',
                        type: 'GET',
                        dataType: 'JSON',
                        data: {
                            key: ckey
                        },
                        success: function (json) {
                            if (json.code == 1) {
                                if(ckey===lastCustomerKey)self.suppliers = json.data;
                            }
                        }
                    });
                },

                //======================
                onSubmit:function(e){
                    e.preventDefault();
                    if(this.ajaxing)return false;
                    if(!this.order.storage_id){
                        dialog.error('请选择仓库');
                        return false;
                    }
                    if(!this.order.supplier_id){
                        dialog.error('请选择供应商');
                        return false;
                    }
                    var self=this;
                    this.ajaxing=true;
                    $.ajax({
                        url:'',
                        type:"POST",
                        dataType:'JSON',
                        data:{
                            order:this.order,
                            goods:this.goods,
                            total:this.total
                        },
                        success:function (json) {
                            self.ajaxing=false;
                            if(json.code==1){
                                refreshFromPage();
                                top.dialog.success(json.msg);
                                if(self.order.status==1){
                                    closeThisPage();
                                }else{
                                    location.reload();
                                }
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