<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="purchase_order_index" title="采购入库" />

    <div id="page-wrapper">
        <div class="page-header">采购入库</div>
        <div class="page-content">
            <form method="post" action="" enctype="multipart/form-data" @submit="onSubmit">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-6 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">供应商</span></div>
                                    <input type="text" class="form-control" @focus="showSupplier" @blur="hideSupplier" v-model="cKey"/>
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
                                    <input type="text" class="form-control" placeholder="不填写将由系统自动生成" name="order_no" v-model="order.order_no"/>
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
                                    <select class="form-control" v-model="order.curency">
                                        <volist name="currencies" id="cur">
                                            <option value="{$cur.key}">[{$cur.key}]{$cur.title}</option>
                                        </volist>
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
                    <table class="table">
                        <thead>
                        <tr>
                            <th>产品</th>
                            <th>库存</th>
                            <th>数量</th>
                            <th>单位</th>
                            <th>单价</th>
                            <th>总价</th>
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
                            <td><a href="javascript:" class="btn btn-sm btn-outline-danger" title="删除" @click="delGoods(idx)"><i class="ion-md-close "></i> </a> </td>
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
                            <td></td>
                        </tr>
                        <tr>
                            <td colspan="7"><a href="javascript:" @click="addRow" class="btn btn-outline-primary btn-addrow">添加行</a> </td>
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
</block>
<block name="script">
    <script type="text/javascript" src="__STATIC__/js/vue-2.6.min.js"></script>
    <script type="text/javascript">
        var hideTimeout=0;
        var currentInput=null;
        var hideSupplierTimeout=0;
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
                order:{
                    supplier_id:0,
                    storage_id:0,
                    currency:"{:current($currencies)['key']}",
                    status:0,
                    order_no:'',
                    supplier_order_no:''
                },
                cKey:'',
                suppliers:[],
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
                    this.updateStorage();
                },
                cKey:function (val, oVal) {
                    this.getSupplierList();
                }
            },
            mounted:function(){
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
                    this.goods[idx].total_price=(good.count * good.price).format(2);
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
                /*loadSupplier:function (e) {
                    //var ckey = $(e.target).val();
                    if(ckey == this.cKey)return;
                    this.cKey = ckey;
                    this.getSupplierList(e);
                },*/
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
                            return true;
                        }
                    }
                    return false;
                },
                getSupplierList:function (e) {
                    var self=this;
                    var ckey = this.cKey;

                    $.ajax({
                        url: '{:url("supplier/search")}',
                        type: 'GET',
                        dataType: 'JSON',
                        data: {
                            key: ckey
                        },
                        success: function (json) {
                            if (json.code == 1) {
                                self.suppliers = json.data;
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
                        dialog.error('请选择客户');
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
                            goods:this.goods
                        },
                        success:function (json) {
                            self.ajaxing=false;
                            if(json.code==1){
                                dialog.success('开单成功！');
                                location.reload();
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
</block>