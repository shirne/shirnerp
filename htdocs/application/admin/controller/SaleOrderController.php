<?php

namespace app\admin\controller;


class SaleOrderController extends BaseController
{
    public function index($key='')
    {
        return $this->fetch();
    }
}