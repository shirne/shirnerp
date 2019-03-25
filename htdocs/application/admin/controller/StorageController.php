<?php

namespace app\admin\controller;


use app\admin\validate\StorageValidate;
use think\Db;

class StorageController extends BaseController
{
    /**
     * 仓库列表
     * @param string $key
     * @return mixed|\think\response\Redirect
     */
    public function index($key="")
    {
        if($this->request->isPost()){
            return redirect(url('',['key'=>base64_encode($key)]));
        }
        $key=empty($key)?"":base64_decode($key);
        $model = Db::name('storage');
        $where=array();
        if(!empty($key)){
            $where[] = array('title|url','like',"%$key%");
        }
        $lists=$model->where($where)->order('ID DESC')->paginate(15);
        $this->assign('lists',$lists);
        $this->assign('page',$lists->render());
        return $this->fetch();
    }

    /**
     * 添加仓库
     * @return mixed
     */
    public function add(){
        if ($this->request->isPost()) {
            //如果用户提交数据
            $data = $this->request->post();
            $validate=new StorageValidate();
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

                if (Db::name('storage')->insert($data)) {
                    $this->success(lang('Add success!'), url('storage/index'));
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
     * 编辑仓库
     * @param $id
     * @return mixed
     */
    public function edit($id)
    {
        if ($this->request->isPost()) {
            //如果用户提交数据
            $data = $this->request->post();
            $validate=new StorageValidate();
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

                $data['id']=$id;
                if (Db::name('storage')->update($data)) {
                    delete_image($delete_images);
                    $this->success(lang('Update success!'), url('storage/index'));
                } else {
                    $this->error(lang('Update failed!'));
                }
            }
        }

        $model = Db::name('storage')->find($id);
        if(empty($model)){
            $this->error('信息不存在');
        }
        $this->assign('model',$model);
        $this->assign('id',$id);
        return $this->fetch();
    }

    /**
     * 删除仓库
     * @param $id
     */
    public function delete($id)
    {
        $id = intval($id);
        $hasGoods = Db::name('goodsStorage')->where('storage_id',$id)->where('count','NEQ',0)->count();
        if($hasGoods){
            $this->error('尚有库存，无法删除');
        }
        $hasOrder = Db::name('saleOrder')->where('storage_id',$id)->count();
        if(!$hasOrder)$hasOrder = Db::name('purchaseOrder')->where('storage_id',$id)->count();
        if(!$hasOrder)$hasOrder = Db::name('transOrder')->where('storage_id',$id)->whereOr('from_storage_id',$id)->count();
        if($hasOrder){
            $this->error('已有关联订单，无法删除');
        }
        $model = Db::name('storage');
        $result = $model->delete($id);
        if($result){
            $this->success(lang('Delete success!'), url('storage/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}