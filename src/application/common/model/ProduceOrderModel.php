<?php

namespace app\common\model;


use think\Db;
use think\Exception;

class PurchaseOrderModel extends BaseFinanceModel
{
    protected $autoWriteTimestamp = true;

    const ACTION_ADD = 'addproduceorder';
    const ACTION_EDIT = 'editproduceorder';
    const ACTION_AUDIT = 'auditproduceorder';
    const ACTION_EXPORT = 'exportproduceorder';
    const ACTION_PRINT = 'printproduceorder';
    const ACTION_DELETE = 'deleteproduceorder';

    public static function getActions()
    {
        return [
            self::ACTION_ADD,
            self::ACTION_EDIT,
            self::ACTION_AUDIT,
            self::ACTION_EXPORT,
            self::ACTION_PRINT,
            self::ACTION_DELETE
        ];
    }
}