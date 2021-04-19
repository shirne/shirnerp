<?php

namespace app\admin\controller;


use Exception;
use think\Db;
use think\exception\HttpResponseException;

/**
 * 生产单管理
 * Class ProduceOrderController
 * @package app\admin\controller
 */
class ProduceOrderController extends BaseController
{

    /**
     * 生产单
     * @return mixed 
     * @throws HttpResponseException 
     * @throws Exception 
     */
    public function index(){
        return $this->fetch();
    }

    public function create(){
        return $this->fetch();
    }

    /**
     * 生产统计
     * @return mixed 
     * @throws HttpResponseException 
     * @throws Exception 
     */
    public function statics(){
        return $this->fetch();
    }

}

