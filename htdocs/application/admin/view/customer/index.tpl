<extend name="public:base" />

<block name="body">
<include file="public/bread" menu="customer_index" title="客户列表" />

<div id="page-wrapper">
    <div class="row list-header">
        <div class="col-md-6">
            <a href="{:url('customer/add')}" class="btn btn-outline-primary btn-sm btn-add-customer"><i class="ion-md-add"></i> 添加客户</a>
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
                <th>状态</th>
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
                <td>
                    <if condition="$v.status eq 1">正常<else/><span style="color:red">禁用</span></if>
                </td>
                <td class="operations">
                    <a class="btn btn-outline-primary btn-edit-customer" data-id="{$v.id}" title="编辑" href="{:url('customer/update',array('id'=>$v['id']))}"><i class="ion-md-create"></i> </a>

                <if condition="$v.status eq 1">	
                    <a class="btn btn-outline-danger link-confirm" title="禁用" data-confirm="禁用后用户将不能登陆后台!\n请确认!!!" href="{:url('customer/delete',array('id'=>$v['id']))}" ><i class="ion-md-close"></i> </a>
            	<else/>
                    <a class="btn btn-outline-success" title="启用" href="{:url('customer/delete',array('id'=>$v['id']))}" ><i class="ion-md-checkmark-circle"></i> </a>
            	</if>
                </td>
            </tr>
        </foreach>
        </tbody>
    </table>
</div>

</block>
<block name="script">
<script type="text/html" id="customerEdit">
    <div class="row" style="margin:0 10%;">
        <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">客户名称</span> </div><input type="text" name="title" class="form-control" placeholder="请填写客户名称"/> </div></div>
        <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">客户简称</span> </div><input type="text" name="short" class="form-control" placeholder="请填写客户简称"/> </div> </div>
        <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">所在地区</span> </div><input type="text" name="province" class="form-control" /> </div> </div>
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

            function bindData(body,data) {
                for(var i in data){
                    body.find('[name='+i+']').val(data[i]);
                }
            }

            function getData(body) {
                var data=new Object();
                var fields=body.find('[name]');
                for(var i=0;i<fields.length;i++){
                    data[fields.eq(i).attr('name')]=fields.eq(i).val();
                }
                return data;
            }

            var customerTpl = $('#customerEdit').html();
            var customerUrl = '{:url("customer/edit",['id'=>'__ID__'])}';
            function editCustomer(id) {
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
                            url:id>0?unitUrl.replace('__ID__',id):'{:url("customer/add")}',
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