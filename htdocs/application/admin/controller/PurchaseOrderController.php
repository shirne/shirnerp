<?php

namespace app\admin\controller;


class PurchaseOrderController extends BaseController
{
    public function index($key='')
    {
        return $this->fetch();
    }
}