<?php

namespace app\admin\controller;

use Exception;
use think\Db;
use think\exception\HttpResponseException;

/**
 * 菜单管理
 * Class ProduceController
 * @package app\admin\controller
 */
class ProduceController extends BaseController
{
    public function search($key=''){
        $model=Db::view('produce','*')->view('goods', ['title'=>'goods_title','fullname'=>'goods_fullname','goods_no'], 'goods.id = produce.goods_id','LEFT');
        if(!empty($key)){
            $model->where('id|produce.title|goods_title|goods_no','like',"%$key%");
        }

        $lists=$model->order('produce.id ASC')->limit(10)->select();

        return json(['data'=>$lists,'code'=>1]);
    }

    /**
     * 生产流程
     */
    public function index($key="")
    {
        if($this->request->isPost()){
            return redirect(url('',['key'=>base64url_encode($key)]));
        }
        $key=empty($key)?"":base64url_decode($key);

        $model = Db::name('Produce');
        
        if(!empty($key )){
            $model->where('title|remark',$key);
        }

        $lists=$model->order('ID DESC')->paginate(15);

        $this->assign('lists',$lists);
        $this->assign('page',$lists->render());
        return $this->fetch();
    }

    public function create(){
        if($this->request->isPost()){
            $data = $this->request->put('model');
            $goods = $this->request->put('goods');
            
        }
        
        $model = [];
        $this->assign('model', $model);
        return $this->fetch();
    }
}

