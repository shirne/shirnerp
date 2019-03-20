<?php

namespace app\admin\validate;


use app\common\validate\BaseUniqueValidate;

/**
 * 商品分类数据验证
 * Class GoodsCategoryValidate
 * @package app\admin\validate
 */
class GoodsCategoryValidate extends BaseUniqueValidate
{
    protected $rule=array(
        'title'=>'require|unique:goodsCategory,%id%',
        'short'=>'max:20',
        'name'=>'require|unique:goodsCategory,%id%'
    );
    protected $message=array(
        'title.require'=>'请填写分类标题',
        'name.require'=>'请填写分类别名',
        'name.unique'=>'分类别名已存在',
        'short.max'=>'简称长度不能超过20'
    );
}