<?php

namespace app\admin\validate;


use app\common\validate\BaseUniqueValidate;

/**
 * 客户资料验证
 * Class GoodsValidate
 * @package app\admin\validate
 */
class CustomerValidate extends BaseUniqueValidate
{
    protected $rule=array(
        'title'=>'require|unique:customer,%id%',
        'short'=>'require|unique:customer,%id%'
    );
    protected $message=array(
        'title.require'=>'请填写客户名称',
        'title.unique'=>'客户名称不可重复',
        'short.require'=>'请填写客户简称',
        'short.unique'=>'客户简称不可重复'
    );

}