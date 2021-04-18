<?php

namespace app\admin\validate;


use app\common\validate\BaseUniqueValidate;

/**
 * 供应商资料验证
 * Class GoodsValidate
 * @package app\admin\validate
 */
class SupplierValidate extends BaseUniqueValidate
{
    protected $rule=array(
        'title'=>'require|unique:supplier,%id%',
        'short'=>'require|unique:supplier,%id%'
    );
    protected $message=array(
        'title.require'=>'请填写供应商名称',
        'title.unique'=>'供应商名称不可重复',
        'short.require'=>'请填写供应商简称',
        'short.unique'=>'供应商简称不可重复'
    );

}