<?php

namespace app\common\model;


use think\Db;
use think\Exception;

class PurchaseModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    const ACTION_ADD = 'addproduce';
    const ACTION_EDIT = 'editproduce';
    const ACTION_AUDIT = 'auditproduce';
    const ACTION_EXPORT = 'exportproduce';
    const ACTION_PRINT = 'printproduce';
    const ACTION_DELETE = 'deleteproduce';

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