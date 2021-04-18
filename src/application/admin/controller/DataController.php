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
                    getGoodsUnits(true);
                    $this->success('编辑成功');
                }
            }else{
                $result=Db::name('unit')->insert($data);
                if($result){
                    getGoodsUnits(true);
                    $this->success('添加成功');
                }
            }
            $this->error('保存失败');
        }
        $unit = Db::name('unit')->where('id',$id)->find();
        $this->assign('unit',$unit);
        return $this->fetch();
    }

    public function unit_delete($id){
        $unit = Db::name('unit')->where('id',$id)->find();
        if(empty($unit)){
            $this->error('参数错误');
        }
        $count = Db::name('goods')->where('unit',$unit['key'])->count();
        if($count>0){
            $this->error('目前有 '.$count.' 条商品信息使用此单位，不可删除');
        }
        Db::name('unit')->where('id',$id)->delete();
        getGoodsUnits(true);
        $this->success('删除成功');
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
                    CurrencyModel::clearCache();
                    $this->success('编辑成功');
                }
            }else{
                $result=Db::name('currency')->insert($data);
                if($result){
                    CurrencyModel::clearCache();
                    $this->success('添加成功');
                }
            }
            $this->error('保存失败');
        }
        $unit = Db::name('currency')->where('id',$id)->find();
        $this->assign('currency',$unit);
        return $this->fetch();
    }

    public function currency_delete($id){
        $currency = Db::name('currency')->where('id',$id)->find();
        if(empty($currency)){
            $this->error('参数错误');
        }
        $count1 = Db::name('saleOrder')->where('currency',$currency['key'])->count();
        $count2 = Db::name('purchaseOrder')->where('currency',$currency['key'])->count();
        if($count1+$count2>0){
            $this->error('目前有 '.($count1+$count2).' 条订单信息使用此货币，不可删除');
        }
        Db::name('currency')->where('id',$id)->delete();
        CurrencyModel::clearCache();
        $this->success('删除成功');
    }

    public function setBaseCurrency($key){
        CurrencyModel::update(['is_base'=>1],['key'=>$key]);
        $this->success('设置成功');
    }
    public function setCurrencyRate($key, $rate){
        //$currency = CurrencyModel::getCurrency($key);

        $updated=CurrencyModel::update(['exchange_rate'=>$rate],['key'=>$key]);
        if($updated){
            Db::name('currencyRate')->insert([
                'currency'=>$key,
                'exchange_rate'=>$rate,
                'create_time'=>time()
            ]);
            $this->success('设置成功');
        }
        $this->success('设置失败');
    }
}