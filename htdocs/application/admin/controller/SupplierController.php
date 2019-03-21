<?php

namespace app\admin\controller;


class SupplierController extends BaseController
{
    public function index($key='')
    {
        return $this->fetch();
    }
}