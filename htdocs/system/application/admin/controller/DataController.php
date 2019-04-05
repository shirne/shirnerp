<?php

namespace app\admin\controller;


use app\admin\validate\CurrencyValidate;
use app\admin\validate\UnitValidate;
use app\common\model\CurrencyModel;
use think\Db;

class DataController extends BaseController
{
    public function index(){
        $units = Db::name('unit')->order('sort ASC,id ASC')->select();
        $currencies= Db::name('currency')->order('sort ASC,id ASC')->select();

        $this->assign(compact('units','currencies'));
        return $this->fetch();
    }

    public function edit_unit($id){
        if($this->request->isPost()){
            $data = $this->request->post();
            $validate=new UnitValidate();
            $validate->setId($id);
            if(!$validate->check($data)){
                $this->error($validate->getError());
            }
            if($id>0){
                $result=Db::name('unit')->where('id',$id)->update($data);
                if($result){
                    $this->success('编辑成功');
                }
            }else{
                $result=Db::name('unit')->insert($data);
                if($result){
                    $this->success('添加成功');
                }
            }
            $this->error('保存失败');
        }
        $unit = Db::name('unit')->where('id',$id)->find();
        $this->assign('unit',$unit);
        return $this->fetch();
    }

    public function edit_currency($id){
        if($this->request->isPost()){
            $data = $this->request->post();
            $validate=new CurrencyValidate();
            $validate->setId($id);
            if(!$validate->check($data)){
                $this->error($validate->getError());
            }
            if($id>0){
                $result=Db::name('currency')->where('id',$id)->update($data);
                if($result){
                    $this->success('编辑成功');
                }
            }else{
                $result=Db::name('currency')->insert($data);
                if($result){
                    $this->success('添加成功');
                }
            }
            $this->error('保存失败');
        }
        $unit = Db::name('currency')->where('id',$id)->find();
        $this->assign('currency',$unit);
        return $this->fetch();
    }

    public function setBaseCurrency($key){
        CurrencyModel::update(['is_base'=>1],['key'=>$key]);
        $this->success('设置成功');
    }
    public function updateCurrencyExchange($key, $rate){
        //$currency = CurrencyModel::getCurrency($key);

        CurrencyModel::update(['exchange_rate'=>$rate],['key'=>$key]);

        Db::name('currencyRate')->insert([
            'currency'=>$key,
            'exchange_rate'=>$rate,
            'create_time'=>time()
        ]);
        $this->success('设置成功');
    }
}