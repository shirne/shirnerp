<?php

namespace app\admin\validate;


use app\common\validate\BaseUniqueValidate;

class UnitValidate extends BaseUniqueValidate
{
    protected $rule=array(
        'key'=>'require|unique:unit,%id%'
    );
    protected $message = array(
        'key.require'=>'请填写单位！',
        'key.unique'=>'单位已存在！'
    );
}