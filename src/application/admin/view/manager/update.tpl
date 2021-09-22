{extend name="public:base"/}

{block name="body"}

    {include file="public/bread" menu="manager_index" title="管理员信息"/}

    <div id="page-wrapper">
        <div class="page-header">{$model['id']>0?'编辑':'添加'}管理员</div>
        <div id="page-content">
            <div class="row">
                <div class="col col-6">
            <form action="" method="post">
                <div class="form-group">
                    <label>用户名</label>
                    <input class="form-control" type="text" name="username" value="{$model.username}" />
                </div>
                <div class="form-group">
                    <label>真实姓名</label>
                    <input class="form-control" type="text" name="realname" value="{$model.realname}"/>
                </div>
                <div class="form-group">
                    <label>手机号码</label>
                    <input class="form-control" type="text" name="mobile" value="{$model.mobile}"/>
                </div>
                <div class="form-group">
                    <label>邮箱</label>
                    <input class="form-control" type="text" name="email" value="{$model.email}">
                </div>
                {if $model.id > 0}
                    <div class="form-group">
                        <label>新密码</label>
                        <input class="form-control" type="password" name="password" placeholder="不填写则不更改">
                    </div>
                    {else/}
                    <div class="form-group">
                        <label>密码</label>
                        <input class="form-control" type="password" name="password" placeholder="登录密码">
                    </div>
                    <div class="form-group">
                        <label>确认密码</label>
                        <input class="form-control" type="password" name="repassword" placeholder="再次输入确认">
                    </div>
                {/if}
                <div class="form-row">
                    <label class="col-2 col-md-1">用户类型</label>
                    <div class="form-group col-md-2">
                        <div class="btn-group btn-group-toggle" data-toggle="buttons">
                            <label class="btn btn-outline-secondary{$model['type']==1?' active':''}">
                                <input type="radio" name="type" value="1" autocomplete="off" {$model['type']==1?' checked':''}> 超级管理员
                            </label>
                            <label class="btn btn-outline-secondary{$model['type']==2?' active':''}">
                                <input type="radio" name="type" value="2" autocomplete="off"{$model['type']==2?' checked':''}> 管理员
                            </label>
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <label class="col-2 col-md-1">用户状态</label>
                    <div class="form-group col-md-2">
                        <div class="btn-group btn-group-toggle" data-toggle="buttons">
                            <label class="btn btn-outline-secondary{$model['status']==1?' active':''}">
                                <input type="radio" name="status" value="1" autocomplete="off" {$model['status']==1?' checked':''}> 正常
                            </label>
                            <label class="btn btn-outline-secondary{$model['status']==0?' active':''}">
                                <input type="radio" name="status" value="0" autocomplete="off"{$model['status']==0?' checked':''}> 禁用
                            </label>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <input type="hidden" name="id" value="{$model.id}">
                    <button class="btn btn-primary" type="submit">{$model['id']>0?'保存':'添加'}</button>
                </div>


            </form>
        </div>
        <div class="col col-6">
            <table class="table table-hover table-striped">
                <thead>
                    <tr>
                        <th>设备</th>
                        <th>登录时间</th>
                        <th>更新时间</th>
                        <th>登录ip</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    {empty name="logins"}{:list_empty(5)}{/empty}
            {foreach $logins as $litem}
                <tr>
                    <td>{$litem['platform']}</td>
                    <td>{$litem.create_time|showdate}</td>
                    <td>{$litem.update_time|showdate}</td>
                    <td>{$litem.login_ip}</td>
                    <td><a href="{:url('clear',['id'=>$litem['id']])}" class="removeLogin">清除</a></td>
                </tr>
            {/foreach}
        </tbody>
        </table>
        </div>
    </div>
        </div>
    </div>

{/block}