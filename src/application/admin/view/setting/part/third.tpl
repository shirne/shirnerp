<div class="form-row form-group">
    <label for="v-wechat_autologin" class="col-3 col-md-2 text-right align-middle">微信自动登录</label>
    <div class="col-9 col-md-8 col-lg-6">
        <div class="btn-group btn-group-toggle" data-toggle="buttons">
            {foreach $setting['wechat_autologin']['data'] as $k => $value}
                {if $k==$setting['wechat_autologin']['value']}
                    <label class="btn btn-outline-secondary active">
                        <input type="radio" name="v-wechat_autologin" value="{$k}" autocomplete="off" checked> {$value}
                    </label>
                    {else /}
                    <label class="btn btn-outline-secondary">
                        <input type="radio" name="v-wechat_autologin" value="{$k}" autocomplete="off"> {$value}
                    </label>
                {/if}
            {/foreach}
        </div>
    </div>
</div>
<div class="form-row mb-3">
    <div class="col-12 col-lg-6">
        <div class="card">
            <div class="card-header">验证码<span class="float-right"><a href="https://www.geetest.com/" target="_blank">极验</a></span></div>
            <div class="card-body">
                <div class="form-row form-group">
                    <label for="v-captcha_mode" class="col-3 col-md-2 text-right align-middle">验证码模式</label>
                    <div class="col">
                        <div class="btn-group btn-group-toggle" data-toggle="buttons">
                            {foreach $setting['captcha_mode']['data'] as $k => $value}
                                {if $k==$setting['captcha_mode']['value']}
                                    <label class="btn btn-outline-secondary active">
                                        <input type="radio" name="v-captcha_mode" value="{$k}" autocomplete="off" checked> {$value}
                                    </label>
                                    {else /}
                                    <label class="btn btn-outline-secondary">
                                        <input type="radio" name="v-captcha_mode" value="{$k}" autocomplete="off"> {$value}
                                    </label>
                                {/if}
                            {/foreach}
                        </div>
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-captcha_geeid" class="col-3 col-md-2 text-right align-middle">极验ID</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-captcha_geeid" value="{$setting['captcha_geeid']['value']}" placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-captcha_geekey" class="col-3 col-md-2 text-right align-middle">极验密钥</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-captcha_geekey" value="{$setting['captcha_geekey']['value']}" placeholder="">
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-12 col-lg-6">
        <div class="card">
            <div class="card-header">快递鸟 <span class="float-right"><a href="http://www.kdniao.com/" target="_blank">快递鸟</a></span> </div>
            <div class="card-body">
                <div class="form-row form-group">
                    <label for="v-kd_userid" class="col-3 col-md-2 text-right align-middle">用户ID</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-kd_userid" value="{$setting['kd_userid']['value']}" placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-kd_apikey" class="col-3 col-md-2 text-right align-middle">API Key</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-kd_apikey" value="{$setting['kd_apikey']['value']}" placeholder="">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="form-row mb-3">
    <div class="col-12 col-lg-6">
        <div class="card">
            <div class="card-header">短信</div>
            <div class="card-body">
                <div class="form-row form-group">
                    <label for="v-sms_code" class="col-3 col-md-2 text-right align-middle">短信验证</label>
                    <div class="col">
                        <div class="btn-group btn-group-toggle" data-toggle="buttons">
                            {foreach $setting['sms_code']['data'] as $k => $value}
                                {if $k==$setting['sms_code']['value']}
                                    <label class="btn btn-outline-secondary active">
                                        <input type="radio" name="v-sms_code" value="{$k}" autocomplete="off" checked> {$value}
                                    </label>
                                    {else /}
                                    <label class="btn btn-outline-secondary">
                                        <input type="radio" name="v-sms_code" value="{$k}" autocomplete="off"> {$value}
                                    </label>
                                {/if}
                            {/foreach}
                        </div>
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-sms_spcode" class="col-3 col-md-2 text-right align-middle">企业编号</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-sms_spcode" value="{$setting['sms_spcode']['value']}" placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-sms_loginname" class="col-3 col-md-2 text-right align-middle">登录名称</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-sms_loginname" value="{$setting['sms_loginname']['value']}" placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-sms_password" class="col-3 col-md-2 text-right align-middle">登录密码</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-sms_password" value="{$setting['sms_password']['value']}" placeholder="">
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-12 col-lg-6">
        <div class="card">
            <div class="card-header">地图</div>
            <div class="card-body">
                <div class="form-row form-group">
                    <label for="v-mapkey_baidu" class="col-3 col-md-2 text-right align-middle">百度地图</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-mapkey_baidu" value="{$setting['mapkey_baidu']['value']}" placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-mapkey_google" class="col-3 col-md-2 text-right align-middle">谷哥地图</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-mapkey_google" value="{$setting['mapkey_google']['value']}"
                               placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-mapkey_tencent" class="col-3 col-md-2 text-right align-middle">腾讯地图</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-mapkey_tencent" value="{$setting['mapkey_tencent']['value']}"
                               placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-mapkey_gaode" class="col-3 col-md-2 text-right align-middle">高德地图</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-mapkey_gaode" value="{$setting['mapkey_gaode']['value']}"
                               placeholder="">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="form-row mb-3">
    <div class="col-12 col-lg-6">
        <div class="card">
            <div class="card-header">邮箱</div>
            <div class="card-body">
                <div class="form-row form-group">
                    <label for="v-mail_host" class="col-3 col-md-2 text-right align-middle">邮箱主机</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-mail_host" value="{$setting['mail_host']['value']}" placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-mail_port" class="col-3 col-md-2 text-right align-middle">邮箱端口</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-mail_port" value="{$setting['mail_port']['value']}" placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-mail_user" class="col-3 col-md-2 text-right align-middle">邮箱账户</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-mail_user" value="{$setting['mail_user']['value']}" placeholder="">
                    </div>
                </div>
                <div class="form-row form-group">
                    <label for="v-mail_pass" class="col-3 col-md-2 text-right align-middle">邮箱密码</label>
                    <div class="col">
                        <input type="text" class="form-control" name="v-mail_pass" value="{$setting['mail_pass']['value']}" placeholder="">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


