{extend name="public:base" /}

{block name="body"}

    {include file="public/bread" menu="produce_index" title="生产流程" /}

    <div id="page-wrapper">
        <div class="page-header">加工生产</div>
        <div class="page-content">
            <form method="post" action="" enctype="multipart/form-data" @submit="onSubmit">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-4 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">成品</span></div>
                                    <input type="text" class="form-control isautocomplete" @focus="showGoods" @blur="hideGoods" @keyup="loadGoods" v-model="cKey"/>
                                </div>
                            </div>
                            <div class="col-4 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">名称</span></div>
                                    <input type="text" class="form-control" name="title" v-model="model.title"/>
                                </div>
                            </div>
                            <div class="col-4 mt-3">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">状态</span></div>
                                    <select name="status" class="form-control" v-model="model.status">
                                        <option :value="1" >正常</option>
                                        <option :value="0" >禁用</option>
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
                            <th width="200">成本比重</th>
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
                                        <input type="text" class="form-control" v-model="good.count"/>
                                        <select v-model="good.unit" style="flex:0;width: 50px;" @keydown="stopLeftRight" class="form-control">
                                            {volist name="units" id="unit"}
                                                <option value="{$unit.key}">{$unit.key}</option>
                                            {/volist}
                                        </select>
                                    </div>
                                </td>
                                <td>
                                    <div class="input-group input-group-sm">
                                        <input type="text" class="form-control" v-model="good.weight"/>
                                        <div class="input-group-append"><span class="input-group-text">{:getSetting('weight_unit')}</span></div>
                                    </div>
                                </td>
                                <td>
                                    <div class="input-group input-group-sm">
                                        <input type="text" class="form-control" v-model="good.proportion"/>
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
                                    
                                </td>
                                <td></td>
                                <td></td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <div class="input-group input-group-sm w-50 float-right">
                                        <div class="input-group-prepend"><span class="input-group-text">流程备注</span></div>
                                        <input type="text" class="form-control" v-model="model.remark"/>
                                    </div>
                                    <a href="javascript:" @click="addRow" class="btn btn-outline-primary btn-sm btn-addrow"><i class="ion-md-add"></i> 添加行</a>
                                    <a href="{:url('goods/importOrder')}" @click="importOrder" class="btn btn-outline-primary btn-sm btn-import"><i class="ion-md-cloud-upload"></i> 导入流程</a>
                                </td>
                                <td colspan="3">
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
    </div>
{/block}
{block name="script"}
    <script type="text/javascript" src="__STATIC__/js/vue-2.6.min.js"></script>
    <script type="text/javascript">
        var hideTimeout=0;
        var currentInput=null;
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
                model:{
                    produce_id:0,
                    storage_id:0,
                    status:0,
                    title:'',
                    freight:0,
                    remark:'',
                    produce_order_no:''
                },
                cKey:'',
                storages:[],
                emptyGoods:[],
                key:'',
                listGoods:[],
                total:{
                    number: 0,
                    count:0,
                    weight:0
                },
                ajaxing:false
            },
            mounted:function(){
                this.addRow();
            },
            methods:{
                addRow:function(){
                    this.goods.push({
                        id:0,
                        goods_id:0,
                        title:'',
                        orig_title:'',
                        count:'',
                        unit:'单位',
                        proportion:0,
                        weight:0,
                        remark:''
                    });
                },
                stopLeftRight:function(e){
                    if(e.keyCode == 37 || e.keyCode == 39) {
                        e.preventDefault()
                    }
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
                            var tr = $(currentInput).parents('tr');
                            if(tr.length > 0){
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
                                tr.find('.counttd input').focus();
                                //this.updateStorage();
                            }else{
                                this.model.goods_id = good.id;
                                this.cKey = good.title;
                            }
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
                                key: key
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
                    importExcel('导入生产流程',$(e.target).attr('href'),function (data) {
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
                            //self.updateRow(self.goods.length-1);
                        }

                        //self.updateStorage();

                    });
                },

                onSubmit:function(e){
                    e.preventDefault();
                    if(this.ajaxing)return false;
                    if(!this.model.goods_id){
                        dialog.error('请选择成品');
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
                            model:this.model,
                            goods:this.goods,
                            total:this.total
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
                                    updateThisTitle({ key:'purchase_order_index_edit-'+json.data.id });
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
