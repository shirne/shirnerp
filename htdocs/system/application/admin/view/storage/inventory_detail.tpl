<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="storage_index" title="仓库盘点" />

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">
                <a href="{:url('storage/inventory',['storage_id'=>$storage_id])}" class="btn btn-outline-primary btn-sm btn-add-storage"><i class="ion-md-arrow-back"></i> 返回</a>
            </div>
            <div class="col-6">
            </div>
        </div>
        <div class="row">
            <div class="col">仓库：{$storage.title}</div>
            <div class="col">单号：{$inventory.order_no}</div>
            <div class="col">盘点日期：{$inventory.inventory_time|showdate}</div>
        </div>
        <table class="table table-hover table-striped">
            <thead>
            <tr>
                <th width="50">编号</th>
                <th>品名</th>
                <th>初始库存</th>
                <th>盘点库存</th>
                <th>盈亏</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <php>$empty=list_empty(6);</php>
            <volist name="goods" id="v" empty="$empty">
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.title}</td>
                    <td>{$v.count}</td>
                    <td>{$v.new_count}</td>
                    <td>
                        <if condition="$v['new_count'] GT $v['count']">
                            <span class="badge badge-success">+ {$v['new_count']-$v['count']}</span>
                            <elseif condition="$v['new_count'] LT $v['count']" />
                            <span class="badge badge-error">- {$v['count']-$v['new_count']}</span>
                            <else/>
                            <span class="badge badge-secondary"> - </span>
                        </if>
                    </td>
                    <td class="operations">

                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
        {$page|raw}
    </div>
</block>
<block name="script">
    <script type="text/javascript" src="__STATIC__/js/location.min.js"></script>
    <script type="text/html" id="storageEdit">
        <div class="row" style="margin:0 10%;">
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">仓库名称</span> </div><input type="text" name="title" class="form-control" placeholder="请填写仓库名称"/> </div></div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">仓库全称</span> </div><input type="text" name="fullname" class="form-control" placeholder="请填写仓库全称"/> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">仓库编码</span> </div><input type="text" name="storage_no" class="form-control" placeholder="请填写仓库编码"/> </div> </div>
            <div class="col-12 form-group area-box">
                <div class="input-group">
                    <div class="input-group-prepend"><span class="input-group-text">所在地区</span> </div>
                    <select class="form-control" ></select>
                    <select class="form-control" ></select>
                    <select class="form-control" ></select>
                </div>
                <input type="hidden" name="province" />
                <input type="hidden" name="city" />
                <input type="hidden" name="area" />
            </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">仓库地址</span> </div><input type="text" name="address" class="form-control" placeholder="请填写仓库地址"/> </div> </div>
        </div>
    </script>
    <script type="text/javascript">
        jQuery(function ($) {
            $('.btn-add-storage').click(function (e) {
                e.preventDefault();
                editStorage(0);
            });
            $('.btn-edit-storage').click(function (e) {
                e.preventDefault();
                editStorage($(this).data('id'));
            });

            var storageTpl = $('#storageEdit').html();
            var storageUrl = '{:url("storage/edit",['id'=>'__ID__'])}';
            function editStorage(id) {
                var dlg=new Dialog({
                    onshown:function (body) {
                        if(id>0){
                            $.ajax({
                                url:storageUrl.replace('__ID__',id),
                                dataType:'JSON',
                                success:function (json) {
                                    //console.log(json);
                                    if(json.code==1) {
                                        var storage = json.data.model
                                        bindData(body, storage);
                                        body.find(".area-box").jChinaArea({
                                            aspnet:true,
                                            s1:storage.province,
                                            s2:storage.city,
                                            s3:storage.area
                                        });
                                    }
                                }
                            })
                        }else{
                            body.find(".area-box").jChinaArea({
                                aspnet:true,
                                s1:"",
                                s2:"",
                                s3:""
                            });
                        }
                    },
                    onsure:function (body) {
                        $.ajax({
                            url:id>0?storageUrl.replace('__ID__',id):'{:url("storage/add")}',
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
                }).show(storageTpl,id>0?'编辑仓库':'添加仓库');
            }

        })
    </script>
</block>