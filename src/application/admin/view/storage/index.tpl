{extend name="public:base" /}

{block name="body"}

{include file="public/bread" menu="storage_index" title="仓库列表" /}

<div id="page-wrapper">
    
    <div class="row list-header">
        <div class="col-6">
            <a href="{:url('storage/add')}" class="btn btn-outline-primary btn-sm btn-add-storage"><i class="ion-md-add"></i> 添加仓库</a>
            <a href="{:url('transOrder/create')}" data-tab="timestamp" class="btn btn-outline-primary btn-sm btn-trans-goods"><i class="ion-md-swap"></i> 商品转库</a>
        </div>
        <div class="col-6">
        </div>
    </div>
    <table class="table table-hover table-striped">
        <thead>
            <tr>
                <th width="50">编号</th>
                <th>名称</th>
                <th>地区</th>
                <th>地址</th>
                <th width="160">&nbsp;</th>
            </tr>
        </thead>
        <tbody>
        {php}$empty=list_empty(6);{/php}
        {volist name="lists" id="v" empty="$empty"}
            <tr>
                <td>{$v.id}</td>
                <td><span class="badge badge-info">{$v.storage_no}</span> {$v.title}</td>
                <td>{$v.province}/{$v.city}/{$v.area}</td>
                <td>{$v.address}</td>
                <td class="operations">
                    <a class="btn btn-outline-primary" title="盘点" data-tab="inventory-{$v.id}" href="{:url('storage/inventory',array('storage_id'=>$v['id']))}"><i class="ion-md-today"></i> </a>
                    <a class="btn btn-outline-primary" title="库存" data-tab="goods-{$v.id}" href="{:url('storage/goods',array('id'=>$v['id']))}"><i class="ion-md-grid"></i> </a>
                    <a class="btn btn-outline-primary btn-edit-storage" data-id="{$v.id}" title="编辑" href="{:url('storage/edit',array('id'=>$v['id']))}"><i class="ion-md-create"></i> </a>
                    <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('storage/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                </td>
            </tr>
        {/volist}
        </tbody>
    </table>
    {$page|raw}
</div>
{/block}
{block name="script"}
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
{/block}