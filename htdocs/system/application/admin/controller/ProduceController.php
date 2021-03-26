<?php

namespace app\admin\controller;


use app\admin\validate\PermissionValidate;
use think\Db;

/**
 * 菜单管理
 * Class PermissionController
 * @package app\admin\controller
 */
class PermissionController extends BaseController
{
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

}

