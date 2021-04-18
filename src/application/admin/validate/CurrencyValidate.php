<?php

namespace app\admin\validate;


use app\common\validate\BaseUniqueValidate;

class CurrencyValidate extends BaseUniqueValidate
{
    protected $rule=array(
        'key'=>'require|alpha|unique:currency,%id%',
        'symbol'=>'require|unique:currency,%id%',
        'title'=>'require|unique:currency,%id%'
    );
    protected $message = array(
        'key.require'=>'请填写币种！',
        'key.alpha'=>'币种应该是全字母，如：RMB, USD, JPY！',
        'key.unique'=>'币种已存在！',
        'symbol.require'=>'请填写币种符号！',
        'symbol.unique'=>'币种符号已存在！',
        'title.require'=>'请填写币种名称！',
        'title.unique'=>'币种名称已存在！'
    );
}