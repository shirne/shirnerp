{extend name="public:base" /}

{block name="body"}
{include file="public/bread" menu="supplier_index" title="供应商列表" /}

<div id="page-wrapper">
    <div class="row list-header">
        <div class="col-md-6">
            <a href="{:url('supplier/add')}" class="btn btn-outline-primary btn-sm btn-add-supplier"><i class="ion-md-add"></i> 添加供应商</a>
            <a href="{:url('supplier/import')}" class="btn btn-outline-primary btn-sm btn-import"><i class="ion-md-cloud-upload"></i> 导入供应商</a>
            <a href="{:url('rank')}" data-tab="stat" class="btn btn-outline-primary btn-sm"><i class="ion-md-stats"></i> 供应商统计</a>
        </div>
        <div class="col-md-6">
            <form action="{:url('supplier/index')}" method="post">
                <div class="input-group input-group-sm">
                    <input type="text" class="form-control" name="key" placeholder="输入用户名或者邮箱关键词搜索">
                    <div class="input-group-append">
                      <button class="btn btn-outline-secondary" type="submit"><i class="ion-md-search"></i></button>
                    </div>
                </div>
            </form>
        </div>
    </div>
    <table class="table table-hover table-striped">
        <thead>
            <tr>
                <th width="50">编号</th>
                <th>名称</th>
                <th>简称</th>
                <th>地区</th>
                <th>地址</th>
                <th>电话</th>
                <th>注册时间/修改时间</th>
                <th width="160">&nbsp;</th>
            </tr>
        </thead>
        <tbody>
        {empty name="lists"}{:list_empty(8)}{/empty}
        {foreach $lists as $v}
            <tr>
                <td>{$v.id}</td>
                <td>{$v.title}</td>
                <td>{$v.short}</td>
                <td>{$v.province}/{$v.city}/{$v.area}</td>
                <td>{$v.address}</td>
                <td>{$v.phone}</td>
                <td>{$v.create_time|showdate}<br />{$v.update_time|showdate}</td>
                <td class="operations">
                        <a href="{:url('statics',['supplier_id'=>$v['id']])}" data-tab="stat-{$v.id}" title="供应商统计" class="btn btn-outline-primary btn-sm"><i class="ion-md-stats"></i></a>
                    <a class="btn btn-outline-primary btn-edit-supplier" data-id="{$v.id}"  title="编辑" href="{:url('supplier/update',array('id'=>$v['id']))}"><i class="ion-md-create"></i> </a>

                    <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="删除后将不能恢复!\n请确认!!!" href="{:url('supplier/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                </td>
            </tr>
        {/foreach}
        </tbody>
    </table>
    <div class="clearfix"></div>
    {$page|raw}
</div>

{/block}
{block name="script"}
    <script type="text/javascript" src="__STATIC__/js/location.min.js"></script>
    <script type="text/html" id="supplierEdit">
        <div class="row" style="margin:0 10%;">
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">供应商名称</span> </div><input type="text" name="title" class="form-control" placeholder="请填写供应商名称"/> </div></div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">供应商简称</span> </div><input type="text" name="short" class="form-control" placeholder="请填写供应商简称"/> </div> </div>
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
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">供应商电话</span> </div><input type="text" name="phone" class="form-control" placeholder="请填写供应商电话"/> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">供应商邮箱</span> </div><input type="text" name="email" class="form-control" /> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">供应商网站</span> </div><input type="text" name="website" class="form-control" /> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">供应商传真</span> </div><input type="text" name="fax" class="form-control" /> </div> </div>
        </div>
    </script>
    <script type="text/javascript">
        jQuery(function ($) {
            $('.btn-add-supplier').click(function (e) {
                e.preventDefault();
                editSupplier(0);
            });
            $('.btn-edit-supplier').click(function (e) {
                e.preventDefault();
                editSupplier($(this).data('id'));
            });

            $('.btn-import').click(function (e) {
                e.preventDefault();
                importExcel('导入供应商',$(this).attr('href'));
            });

            var supplierTpl = $('#supplierEdit').html();
            var supplierUrl = '{:url("supplier/edit",['id'=>'__ID__'])}';
            function editSupplier(id) {
                var dlg=new Dialog({
                    onshown:function (body) {
                        if(id>0){
                            $.ajax({
                                url:supplierUrl.replace('__ID__',id),
                                dataType:'JSON',
                                success:function (json) {
                                    //console.log(json);
                                    if(json.code==1) {
                                        var supplier = json.data.model;
                                        bindData(body, supplier);
                                        body.find(".area-box").jChinaArea({
                                            aspnet:true,
                                            s1:supplier.province,
                                            s2:supplier.city,
                                            s3:supplier.area
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
                            url:id>0?supplierUrl.replace('__ID__',id):'{:url("supplier/add")}',
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
                }).show(supplierTpl,id>0?'编辑供应商':'添加供应商');
            }

        })

    </script>
{/block}