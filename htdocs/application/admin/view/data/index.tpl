<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="data_index" title="基础数据" />

    <div id="page-wrapper">
        <div class="row">
            <div class="col">
                <div class="card">
                    <div class="card-header">
                        <div class="float-right"><a href="javascript:" class="btn btn-sm btn-outline-primary btn-add-unit" title="添加"><i class="ion-md-add"></i> </a> </div>
                        <h3>商品单位</h3>
                    </div>
                    <table class="table table-hover table-striped">
                        <thead>
                        <tr>
                            <th width="50">编号</th>
                            <th>单位</th>
                            <th>排序</th>
                            <th>备注</th>
                            <th width="160">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <php>$empty=list_empty(6);</php>
                        <volist name="units" id="v" empty="$empty">
                            <tr>
                                <td>{$v.id}</td>
                                <td>{$v.key}</td>
                                <td>{$v.sort}</td>
                                <td>{$v.description}</td>
                                <td class="operations">
                                    <a class="btn btn-outline-primary unitEditBtn" data-id="{$v.id}" title="编辑" href="javascript:"><i class="ion-md-create"></i> </a>
                                    <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('data/unit_delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                                </td>
                            </tr>
                        </volist>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="col">
                <div class="card">
                    <div class="card-header">
                        <div class="float-right"><a href="javascript:" class="btn btn-sm btn-outline-primary btn-add-currency" title="添加"><i class="ion-md-add"></i> </a> </div>
                        <h3>交易币种</h3>
                    </div>
                    <table class="table table-hover table-striped">
                        <thead>
                        <tr>
                            <th width="50">编号</th>
                            <th>标识</th>
                            <th>名称</th>
                            <th>符号</th>
                            <th>排序</th>
                            <th width="160">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <php>$empty=list_empty(6);</php>
                        <volist name="currencies" id="v" empty="$empty">
                            <tr>
                                <td>{$v.id}</td>
                                <td>{$v.key}</td>
                                <td>{$v.title}</td>
                                <td>{$v.symbol}</td>
                                <td>{$v.sort}</td>
                                <td class="operations">
                                    <a class="btn btn-outline-primary currencyEditBtn" data-id="{$v.id}" title="编辑" href="javascript:"><i class="ion-md-create"></i> </a>
                                    <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('data/currency_delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                                </td>
                            </tr>
                        </volist>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>

</block>
<block name="script">
    <script type="text/html" id="unitEdit">
        <div class="row" style="margin:0 10%;">
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">商品单位</span> </div><input type="text" name="key" class="form-control" placeholder="请填写商品单位"/> </div></div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">单位说明</span> </div><input type="text" name="description" class="form-control" placeholder="请填写单位说明"/> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">排序</span> </div><input type="text" name="sort" class="form-control" placeholder="请填写排序"/> </div> </div>
        </div>
    </script>
    <script type="text/html" id="currencyEdit">
        <div class="row" style="margin:0 10%;">
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">币种</span> </div><input type="text" name="key" class="form-control" placeholder="请填写币种"/> </div></div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">币种全称</span> </div><input type="text" name="title" class="form-control" placeholder="请填写币种全称"/> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">币种符号</span> </div><input type="text" name="symbol" class="form-control" placeholder="请填写币种符号"/> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">排序</span> </div><input type="text" name="sort" class="form-control" placeholder="请填写排序"/> </div> </div>
        </div>
    </script>
    <script type="text/javascript">
        jQuery(function ($) {
            $('.btn-add-unit').click(function () {
                editUnit(0);
            });
            $('.unitEditBtn').click(function (e) {
                e.preventDefault();
                editUnit($(this).data('id'));
            });
            $('.btn-add-currency').click(function () {
                editCurrency(0);
            });
            $('.currencyEditBtn').click(function (e) {
                e.preventDefault();
                editCurrency($(this).data('id'));
            });


            var unitTpl = $('#unitEdit').html();
            var unitUrl = '{:url("data/edit_unit",['id'=>'__ID__'])}';
            function editUnit(id) {
                var dlg=new Dialog({
                    onshown:function (body) {
                        if(id>0){
                            $.ajax({
                                url:unitUrl.replace('__ID__',id),
                                dataType:'JSON',
                                success:function (json) {
                                    //console.log(json);
                                    if(json.code==1) {
                                        bindData(body, json.data.unit);
                                    }
                                }
                            })
                        }
                    },
                    onsure:function (body) {
                        $.ajax({
                            url:unitUrl.replace('__ID__',id),
                            type:'POST',
                            dataType:'JSON',
                            data:getData(body),
                            success:function (json) {
                                //console.log(json);
                                dialog.alert(json.msg);
                                if(json.code==1){
                                    location.reload();
                                    dlg.close();
                                }
                            }
                        });
                        return false;
                    }
                }).show(unitTpl,id>0?'编辑商品单位':'添加商品单位');
            }

            var currencyTpl = $('#currencyEdit').html();
            var currencyUrl = '{:url("data/edit_currency",['id'=>'__ID__'])}';
            function editCurrency(id) {
                var dlg=new Dialog({
                    onshown:function (body) {
                        if(id>0){
                            $.ajax({
                                url:currencyUrl.replace('__ID__',id),
                                dataType:'JSON',
                                success:function (json) {
                                    //console.log(json);
                                    if(json.code==1) {
                                        bindData(body, json.data.currency);
                                    }
                                }
                            })
                        }
                    },
                    onsure:function (body) {
                        $.ajax({
                            url:currencyUrl.replace('__ID__',id),
                            type:'POST',
                            dataType:'JSON',
                            data:getData(body),
                            success:function (json) {
                                //console.log(json);
                                dialog.alert(json.msg);
                                if(json.code==1){
                                    location.reload();
                                    dlg.close();
                                }
                            }
                        });
                        return false;
                    }
                }).show(currencyTpl,id>0?'编辑币种':'添加币种');
            }
        })
        
    </script>
</block>