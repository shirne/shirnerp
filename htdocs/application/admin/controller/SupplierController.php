<?php

namespace app\admin\controller;


use app\admin\validate\SupplierValidate;
use app\common\model\SupplierModel;
use think\Db;

class SupplierController extends BaseController
{
    /**
     * 供应商列表
     * @param string $key
     * @return mixed|\think\response\Redirect
     */
    public function index($key="")
    {
        if($this->request->isPost()){
            return redirect(url('',['key'=>base64_encode($key)]));
        }
        $key=empty($key)?"":base64_decode($key);
        $model = Db::name('supplier');
        $where=array();
        if(!empty($key)){
            $where[] = array('title|short','like',"%$key%");
        }
        $lists=$model->where($where)->order('ID DESC')->paginate(15);
        $this->assign('lists',$lists);
        $this->assign('page',$lists->render());
        return $this->fetch();
    }

    /**
     * 添加供应商
     * @return mixed
     */
    public function add(){
        if ($this->request->isPost()) {
            //如果用户提交数据
            $data = $this->request->post();
            $validate=new SupplierValidate();
            $validate->setId(0);
            if (!$validate->check($data)) {
                $this->error($validate->getError());
            } else {
                $uploaded=$this->upload('links','upload_logo');
                if(!empty($uploaded)){
                    $data['logo']=$uploaded['url'];
                }elseif($this->uploadErrorCode>102){
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }

                $result = SupplierModel::create($data);
                if ($result['id']) {
                    $this->success(lang('Add success!'), url('supplier/index'));
                } else {
                    $this->error(lang('Add failed!'));
                }
            }
        }
        $model=array('sort'=>99);
        $this->assign('model',$model);
        $this->assign('id',0);
        return $this->fetch('edit');
    }

    /**
     * 编辑供应商
     * @param $id
     * @return mixed
     */
    public function edit($id)
    {
        if ($this->request->isPost()) {
            //如果用户提交数据
            $data = $this->request->post();
            $validate=new SupplierValidate();
            $validate->setId($id);
            if (!$validate->check($data)) {
                $this->error($validate->getError());
            } else {
                $delete_images=[];
                $uploaded=$this->upload('adv','upload_logo');
                if(!empty($uploaded)){
                    $data['logo']=$uploaded['url'];
                    $delete_images[]=$data['delete_logo'];
                }elseif($this->uploadErrorCode>102){
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }
                unset($data['delete_image']);

                $result = SupplierModel::update($data,['id'=>$id]);
                if ($result) {
                    delete_image($delete_images);
                    $this->success(lang('Update success!'), url('supplier/index'));
                } else {
                    $this->error(lang('Update failed!'));
                }
            }
        }

        $model = Db::name('supplier')->find($id);
        if(empty($model)){
            $this->error('信息不存在');
        }
        $this->assign('model',$model);
        $this->assign('id',$id);
        return $this->fetch();
    }

    /**
     * 删除供应商
     * @param $id
     */
    public function delete($id)
    {
        $id = intval($id);
        $hasOrder = Db::name('purchaseOrder')->where('supplier_id',$id)->count();
        if($hasOrder){
            $this->error('已有订单，无法删除');
        }
        $model = Db::name('supplier');
        $result = $model->delete($id);
        if($result){
            $this->success(lang('Delete success!'), url('supplier/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}