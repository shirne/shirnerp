<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="storage_index" title="仓库盘点" />

    <div id="page-wrapper">
        <div class="page-header">仓库盘点</div>
        <div class="page-content">
            <form method="post" action="" enctype="multipart/form-data" @submit="onSubmit">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">仓库</span></div>
                                    <span class="form-control">{{storage.title}}</span>
                                </div>
                            </div>
                            <div class="col">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">单号</span></div>
                                    <input type="text" class="form-control" placeholder="不填写将由系统自动生成" name="order_no" v-model="order.order_no"/>
                                </div>
                            </div>
                            <div class="col">
                                <div class="input-group">
                                    <div class="input-group-prepend"><span class="input-group-text">状态</span></div>
                                    <select name="status" class="form-control" v-model="order.status">
                                        <option :value="0" >待盘点</option>
                                        <option :value="1" >已盘点</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                    <table class="table">
                        <thead>
                        <tr>
                            <th>产品</th>
                            <th>当前库存</th>
                            <th>盘点库存</th>
                            <th>操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr v-for="(good,idx) in goods" :key="idx">
                            <td><input type="text" class="form-control form-control-sm" :data-idx="idx" @focus="showGoods" @blur="hideGoods" @keyup="loadGoods" v-model="good.title"/> </td>
                            <td>{{good.count}}</td>
                            <td class="counttd">
                                <div class="input-group input-group-sm">
                                    <input type="text" class="form-control" v-model="good.new_count"/>
                                    <div class="input-group-append"><span class="input-group-text">{{good.unit}}</span></div>
                                </div>
                            </td>
                            <td class="operations">
                                <a href="javascript:" class="btn btn-sm btn-outline-danger" title="删除" @click="delGoods(idx)"><i class="ion-md-close"></i> </a>
                            </td>
                        </tr>
                        </tbody>
                        <tfoot>
                        <tr>
                            <td colspan="4"><a href="javascript:" @click="addRow" class="btn btn-outline-primary btn-sm btn-addrow"><i class="ion-md-add"></i> 添加行</a> </td>
                        </tr>
                        </tfoot>
                    </table>
                    <div class="card-footer">
                        <a href="javascript:" class="btn btn-primary" @click="onSubmit">提交保存</a>
                    </div>
                </div>
            </form>
        </div>

        <ul class="list-group auto-complete" :style="listStyle">
            <li class="list-group-item" v-for="(good,idx) in listGoods" :data-idx="idx" :key="good.id" @click="selectThis" @mouseenter="activeThis">
                [{{good.goods_no}}]{{good.title}}
            </li>
        </ul>
    </div>
</block>
<block name="script">
    <script type="text/javascript" src="__STATIC__/js/vue-2.6.min.js"></script>
    <script type="text/javascript">
        var hideTimeout=0;
        var currentInput=null;
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
                order:{
                    storage_id:'{$storage.id}',
                    status:0,
                    order_no:''
                },
                storages:[],
                emptyGoods:[],
                key:'',
                listGoods:[],
                storage:{
                    'id':'{$storage.id}',
                    'title':'{$storage.title}'
                }
            },
            computed:{
                goods_ids:function () {
                    var ids=[];
                    for(var i=0;i<this.goods.length;i++){
                        if(this.goods[i].goods_id)ids.push(this.goods[i].goods_id);
                    }
                    return ids;
                }
            },
            mounted:function(){
                this.initData();
                this.addRow();
                this.loadStorages();
            },
            methods:{
                initData:function () {
                    var goods={$goods|json_encode|raw};
                    for(var i=0;i<goods.length;i++){
                        this.goods.push({
                            goods_id:goods[i].goods_id,
                            title:goods[i].title,
                            orig_title:goods[i].title,
                            count:goods[i].count,
                            new_count:goods[i].count,
                            unit:goods[i].unit
                        });
                    }
                },
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
                        goods_id:0,
                        title:'',
                        orig_title:'',
                        count:'',
                        new_count:'',
                        unit:''
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
                    var lists=$('.auto-complete .list-group-item');
                    var idx=lists.index($('.auto-complete .hover'));

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
                    var hover=$('.auto-complete .hover');
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
                            this.goods[idx].count=good.storage?good.storage:0;
                            this.goods[idx].new_count=this.goods[idx].count;
                            this.goods[idx].unit=good.unit;
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
                onSubmit:function(e){
                    e.preventDefault();
                    if(!this.order.storage_id){
                        dialog.error('请选择仓库');
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
                                dialog.success('创建成功！');
                                location.href=json.url;
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