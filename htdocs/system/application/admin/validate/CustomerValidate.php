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
        'title'=>'require|unique:customer,%id%'
    );
    protected $message=array(
        'title.require'=>'请填写供应商名称'
    );

}