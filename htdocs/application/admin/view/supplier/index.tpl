<extend name="public:base" />

<block name="body">
<include file="public/bread" menu="supplier_index" title="供应商列表" />

<div id="page-wrapper">
    <div class="row list-header">
        <div class="col-md-6">
            <a href="{:url('supplier/add')}" class="btn btn-outline-primary btn-sm"><i class="ion-md-add"></i> 添加供应商</a>
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
                <th>用户名</th>
                <th>邮箱</th>
                <th>注册时间/修改时间</th>
                <th>上次登陆</th>
                <th>类型</th>
                <th>状态</th>
                <th width="160">&nbsp;</th>
            </tr>
        </thead>
        <tbody>
        <foreach name="lists" item="v">
            <tr>
                <td>{$v.id}</td>
                <td>{$v.username}</td>
                <td>{$v.email}</td>
                <td>{$v.create_time|showdate}<br />{$v.update_time|showdate}</td>
                <td>{$v.login_ip}<br />{$v.logintime|showdate}</td>
                <td>
                    <if condition="$v.type eq 1"> <span class="label label-success">超级管理员</span>
                    <elseif condition="$v.type eq 2"/><span class="label label-danger">管理员</span>
                    </if>
                </td> 
                <td><if condition="$v.status eq 1">正常<else/><span style="color:red">禁用</span></if></td>
                <td class="operations">
                    <a class="btn btn-outline-primary" title="编辑" href="{:url('supplier/update',array('id'=>$v['id']))}"><i class="ion-md-create"></i> </a>

                <if condition="$v.status eq 1">	
                    <a class="btn btn-outline-danger link-confirm" title="禁用" data-confirm="禁用后用户将不能登陆后台!\n请确认!!!" href="{:url('supplier/delete',array('id'=>$v['id']))}" ><i class="ion-md-close"></i> </a>
            	<else/>
                    <a class="btn btn-outline-success" title="启用" href="{:url('supplier/delete',array('id'=>$v['id']))}" ><i class="ion-md-checkmark-circle"></i> </a>
            	</if>
                </td>
            </tr>
        </foreach>
        </tbody>
    </table>
</div>

</block>