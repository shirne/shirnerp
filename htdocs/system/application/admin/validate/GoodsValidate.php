<?php

namespace app\admin\validate;


use app\common\validate\BaseUniqueValidate;

/**
 * 商品资料验证
 * Class GoodsValidate
 * @package app\admin\validate
 */
class GoodsValidate extends BaseUniqueValidate
{
    protected $rule=array(
        'title'=>'require|unique:goods,%id%',
        'goods_no'=>'require|unique:goods,%id%'
    );
    protected $message=array(
        'title.require'=>'请填写商品名称',
        'title.unique'=>'商品名称不可重复',
        'goods_no.require'=>'请填写商品编码',
        'goods_no.unique'=>'商品编码不可重复'
    );

}