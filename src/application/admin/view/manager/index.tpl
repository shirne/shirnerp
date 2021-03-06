{extend name="public:base" /}

{block name="body"}
{include file="public/bread" menu="manager_index" title="管理员列表" /}

<div id="page-wrapper">
    <div class="row list-header">
        <div class="col-md-6">
            <a href="{:url('manager/add')}" data-tab="timestamp" class="btn btn-outline-primary btn-sm"><i class="ion-md-add"></i> 添加管理员</a>
        </div>
        <div class="col-md-6">
            <form action="{:url('manager/index')}" method="post">
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
        {foreach $lists as $v}
            <tr>
                <td>{$v.id}</td>
                <td>{$v.username}</td>
                <td>{$v.email}</td>
                <td>{$v.create_time|showdate}<br />{$v.update_time|showdate}</td>
                <td>
                    {$v.login_ip}<br />{$v.logintime|showdate}<br />{if !empty($v['logined_count'])}
                    <a href="javascript:" class="login-detail" data-target="div-{$v['id']}">APP端 {$v['logined_count']}个登录</a>
                    <div id="div-{$v.id}" class="hidden">
                        <table class="table table-hover table-striped">
                            <thead>
                                <tr>
                                    <th>设备</th>
                                    <th>登录时间</th>
                                    <th>更新时间</th>
                                    <th>登录ip</th>
                                </tr>
                            </thead>
                            <tbody>
                        {foreach $v['logins'] as $litem}
                            <tr>
                                <td>{$litem['platform']}</td>
                                <td>{$litem.create_time|showdate}</td>
                                <td>{$litem.update_time|showdate}</td>
                                <td>{$litem.login_ip}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                    </table>
                    </div>
                    {/if}
                </td>
                <td>
                    {if $v['type'] == 1} <span class="label label-success">超级管理员</span>
                    {elseif condition="$v['type'] == 2"/}<span class="label label-danger">管理员</span>
                    {/if}
                </td> 
                <td>{if $v['status'] == 1}正常{else/}<span style="color:red">禁用</span>{/if}</td>
                <td class="operations">
                    <a class="btn btn-outline-primary" data-tab="edit-{$v.id}" title="编辑" href="{:url('manager/update',array('id'=>$v['id']))}"><i class="ion-md-create"></i> </a>
                {if $v['type'] != 1}
                    <a class="btn btn-outline-primary" data-tab="permision-{$v.id}" title="权限" href="{:url('manager/permision',array('id'=>$v['id']))}"><i class="ion-md-key"></i> </a>
                {/if}
                {if $v['status'] == 1}	
                    <a class="btn btn-outline-danger link-confirm" title="禁用" data-confirm="禁用后用户将不能登陆后台!\n请确认!!!" href="{:url('manager/delete',array('id'=>$v['id']))}" ><i class="ion-md-close"></i> </a>
            	{else/}
                    <a class="btn btn-outline-success" title="启用" href="{:url('manager/delete',array('id'=>$v['id']))}" ><i class="ion-md-checkmark-circle"></i> </a>
            	{/if}
                </td>
            </tr>
        {/foreach}
        </tbody>
    </table>
</div>

{/block}
{block name="script"}
<script>
    jQuery(function($){
        $('.login-detail').click(function(){
            var did = $(this).data('target');
            var tpl = $('#'+did).html();
            dialog.alert({'content':tpl,'size':'md'},null);
        })
    })
</script>
{/block}