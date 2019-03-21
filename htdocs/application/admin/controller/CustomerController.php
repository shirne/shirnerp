<?php

namespace app\admin\controller;


class CustomerController extends BaseController
{
    public function index($key='')
    {
        return $this->fetch();
    }
}