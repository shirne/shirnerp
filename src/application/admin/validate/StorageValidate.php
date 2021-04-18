<?php

namespace app\admin\validate;


use app\common\validate\BaseUniqueValidate;

/**
 * 商品资料验证
 * Class GoodsValidate
 * @package app\admin\validate
 */
class StorageValidate extends BaseUniqueValidate
{
    protected $rule=array(
        'title'=>'require|unique:storage,%id%'
    );
    protected $message=array(
        'title.require'=>'请填写仓库名称'
    );

}