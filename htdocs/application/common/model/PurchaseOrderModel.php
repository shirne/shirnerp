<?php

namespace app\common\model;


class PurchaseOrderModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    public static function createOrder($customer_id, $storage_id, $goods, $currency='', $status=0)
    {

    }

    protected function triggerStatus($item,$status)
    {}
}