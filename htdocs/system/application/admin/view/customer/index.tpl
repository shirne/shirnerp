<extend name="public:base" />

<block name="body">
<include file="public/bread" menu="customer_index" title="客户列表" />

<div id="page-wrapper">
    <div class="row list-header">
        <div class="col-md-6">
            <a href="{:url('customer/add')}" class="btn btn-outline-primary btn-sm btn-add-customer"><i class="ion-md-add"></i> 添加客户</a>
            <a href="{:url('customer/import')}" class="btn btn-outline-primary btn-sm btn-import"><i class="ion-md-cloud-upload"></i> 导入客户</a>
            <a href="{:url('rank')}" data-tab="stat" class="btn btn-outline-primary btn-sm"><i class="ion-md-stats"></i> 客户统计</a>
        </div>
        <div class="col-md-6">
            <form action="{:url('customer/index')}" method="post">
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
                <th>区域</th>
                <th>地址</th>
                <th>电话</th>
                <th>注册时间/修改时间</th>
                <th width="160">&nbsp;</th>
            </tr>
        </thead>
        <tbody>
        <foreach name="lists" item="v">
            <tr>
                <td>{$v.id}</td>
                <td>{$v.title}</td>
                <td>{$v.short}</td>
                <td>{$v.province}/{$v.city}/{$v.area}</td>
                <td>{$v.address}</td>
                <td>{$v.phone}</td>
                <td>{$v.create_time|showdate}<br />{$v.update_time|showdate}</td>
                <td class="operations">
                        <a href="{:url('statics',['customer_id'=>$v['id']])}" data-tab="stat-{$v.id}" title="供应商统计" class="btn btn-outline-primary btn-sm"><i class="ion-md-stats"></i></a>
                    <a class="btn btn-outline-primary btn-edit-customer" data-id="{$v.id}" title="编辑" href="{:url('customer/update',array('id'=>$v['id']))}"><i class="ion-md-create"></i> </a>
                    <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="删除后将无法恢复!\n请确认!!!" href="{:url('customer/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                </td>
            </tr>
        </foreach>
        </tbody>
    </table>
    <div class="clearfix"></div>
    {$page|raw}
</div>

</block>
<block name="script">
    <script type="text/javascript" src="__STATIC__/js/location.min.js"></script>
    <script type="text/html" id="customerEdit">
        <div class="row" style="margin:0 10%;">
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">客户名称</span> </div><input type="text" name="title" class="form-control" placeholder="请填写客户名称"/> </div></div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">客户简称</span> </div><input type="text" name="short" class="form-control" placeholder="请填写客户简称"/> </div> </div>
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
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">客户电话</span> </div><input type="text" name="phone" class="form-control" placeholder="请填写客户电话"/> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">客户邮箱</span> </div><input type="text" name="email" class="form-control" /> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">客户网站</span> </div><input type="text" name="website" class="form-control" /> </div> </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">客户传真</span> </div><input type="text" name="fax" class="form-control" /> </div> </div>
        </div>
    </script>
    <script type="text/javascript">
        jQuery(function ($) {
            $('.btn-add-customer').click(function (e) {
                e.preventDefault();
                editCustomer(0);
            });
            $('.btn-edit-customer').click(function (e) {
                e.preventDefault();
                editCustomer($(this).data('id'));
            });


            $('.btn-import').click(function (e) {
                e.preventDefault();
                importExcel('导入客户',$(this).attr('href'));
            });

            var customerTpl = $('#customerEdit').html();
            var customerUrl = '{:url("customer/edit",['id'=>'__ID__'])}';
            function editCustomer(id) {
                var dlg=new Dialog({
                    onshown:function (body) {
                        if(id>0){
                            $.ajax({
                                url:customerUrl.replace('__ID__',id),
                                dataType:'JSON',
                                success:function (json) {
                                    //console.log(json);
                                    if(json.code==1) {
                                        var customer = json.data.model;
                                        bindData(body, customer);
                                        body.find(".area-box").jChinaArea({
                                            aspnet:true,
                                            s1:customer.province,
                                            s2:customer.city,
                                            s3:customer.area
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
                            url:id>0?customerUrl.replace('__ID__',id):'{:url("customer/add")}',
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
                }).show(customerTpl,id>0?'编辑客户':'添加客户');
            }


        })

    </script>
</block>