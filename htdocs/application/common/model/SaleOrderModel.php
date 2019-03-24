<?php

namespace app\common\model;


class SaleOrderModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    protected function triggerStatus($item,$status)
    {}
}