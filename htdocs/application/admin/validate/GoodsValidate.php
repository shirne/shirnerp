<?php

namespace app\admin\validate;


use think\Validate;

/**
 * 商品资料验证
 * Class GoodsValidate
 * @package app\admin\validate
 */
class GoodsValidate extends Validate
{
    protected $rule=array(
        'title'=>'require'
    );
    protected $message=array(
        'title.require'=>'请填写商品名称'
    );

}