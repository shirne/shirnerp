<?php

namespace app\admin\controller;


use app\admin\validate\AdvGroupValidate;
use app\admin\validate\AdvItemValidate;
use think\Db;
use think\Exception;

/**
 * 广告功能
 * Class AdvController
 * @package app\admin\controller
 */
class AdvController extends BaseController
{
    /**
     * 管理
     * @param $key
     * @throws Exception
     * @return mixed
     */
    public function index($key=''){
        if($this->request->isPost()){
            return redirect(url('',['key'=>base64url_encode($key)]));
        }
        $key=empty($key)?"":base64url_decode($key);
        $model = Db::name('AdvGroup');
        if(!empty($key)){
            $model->whereLike('title|flag',"%$key%");
        }
        $lists=$model->order('id DESC')->paginate(15);
        $this->assign('lists',$lists->items());
        $this->assign('total',$lists->total());
        $this->assign('total_page',$lists->lastPage());
        $this->assign('page',$this->request->isAjax()?$lists->currentPage() : $lists->render());
        return $this->fetch();
    }

    /**
     * 添加
     * @return mixed
     */
    public function add(){
        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new AdvGroupValidate();
            $validate->setId();
            if (!$validate->check($data)) {
                $this->error($validate->getError());
            }else{
                if (Db::name("AdvGroup")->insert($data)) {
                    $this->success(lang('Add success!'), url('adv/index'));
                } else {
                    $this->error(lang('Add failed!'));
                }
            }
        }
        $model=array('status'=>1);
        $this->assign('model',$model);
        $this->assign('id',0);
        return $this->fetch('update');
    }

    /**
     * 修改
     */
    public function update($id)
    {
        $id = intval($id);

        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new AdvGroupValidate();
            $validate->setId($id);

            if (!$validate->check($data)) {
                $this->error($validate->getError());
            }else{
                $model = Db::name("AdvGroup");

                $data['id']=$id;
                if ($model->update($data)) {
                    $this->success(lang('Update success!'), url('adv/index'));
                } else {
                    $this->error(lang('Update failed!'));
                }
            }
        }

        $model = Db::name('AdvGroup')->where('id', $id)->find();
        if(empty($model)){
            $this->error('广告组不存在');
        }
        $this->assign('model',$model);
        $this->assign('id',$id);
        return $this->fetch();
    }

    /**
     * 删除广告位
     * @param $id
     * @throws Exception
     * @return void
     */
    public function delete($id)
    {
        $id = intval($id);
        $force=$this->request->post('force/d',0);
        $model = Db::name('AdvGroup');
        $count=Db::name('AdvItem')->where('group_id',$id)->count();
        if($count<1 || $force!=0) {
            $result = $model->delete($id);
        }else{
            $result=false;
            $this->error("广告位中还有广告项目");
        }
        if($result){
            if($count>0){
                Db::name('AdvItem')->where('group_id',$id)->delete();
            }
            $this->success(lang('Delete success!'), url('adv/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }

    public function itemlist($gid){
        $model = Db::name('AdvItem');
        $group=Db::name('AdvGroup')->find($gid);
        if(empty($group)){
            $this->error('广告位不存在');
        }
        $where=array('group_id'=>$gid);
        if(!empty($key)){
            $where[] = array('title|url','like',"%$key%");
        }
        $lists=$model->where($where)->order('sort ASC,id DESC')->paginate(15);
        $this->assign('lists',$lists->items());
        $this->assign('total',$lists->total());
        $this->assign('total_page',$lists->lastPage());
        $this->assign('page',$this->request->isAjax()?$lists->currentPage() : $lists->render());
        $this->assign('gid',$gid);
        return $this->fetch();
    }

    /**
     * 添加
     * @param $gid
     * @return mixed
     */
    public function itemadd($gid){
        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new AdvItemValidate();

            if (!$validate->check($data)) {
                $this->error($validate->getError());
            }else{
                $uploaded=$this->upload('adv','upload_image');
                if(!empty($uploaded)){
                    $data['image']=$uploaded['url'];
                }elseif($this->uploadErrorCode>102){
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }
                $model = Db::name("AdvItem");
                $url=url('adv/itemlist',array('gid'=>$gid));
                $data['start_date']=empty($data['start_date'])?0:strtotime($data['start_date']);
                $data['end_date']=empty($data['end_date'])?0:strtotime($data['end_date']);
                if ($model->insert($data)) {
                    $this->success(lang('Add success!'),$url);
                } else {
                    delete_image($data['image']);
                    $this->error(lang('Add failed!'));
                }
            }
        }
        $model=array('status'=>1,'group_id'=>$gid);
        $this->assign('model',$model);
        $this->assign('id',0);
        return $this->fetch('itemupdate');
    }

    /**
     * 修改
     */
    public function itemupdate($id)
    {
        $id = intval($id);

        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new AdvItemValidate();

            if (!$validate->check($data)) {
                $this->error($validate->getError());
            }else{
                $model = Db::name("AdvItem");
                $url=url('adv/itemlist',array('gid'=>$data['group_id']));
                $delete_images=[];
                $uploaded=$this->upload('adv','upload_image');
                if(!empty($uploaded)){
                    $data['image']=$uploaded['url'];
                    $delete_images[]=$data['delete_image'];
                }elseif($this->uploadErrorCode>102){
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }
                unset($data['delete_image']);
                $data['start_date']=empty($data['start_date'])?0:strtotime($data['start_date']);
                $data['end_date']=empty($data['end_date'])?0:strtotime($data['end_date']);
                $data['id']=$id;
                if ($model->update($data)) {
                    delete_image($delete_images);
                    $this->success(lang('Update success!'), $url);
                } else {
                    delete_image($data['image']);
                    $this->error(lang('Update failed!'));
                }
            }
        }
        $model = Db::name('AdvItem')->where('id', $id)->find();
        if(empty($model)){
            $this->error('广告项不存在');
        }

        $this->assign('model',$model);
        $this->assign('id',$id);
        return $this->fetch();

    }
    /**
     * 删除广告
     */
    public function itemdelete($gid,$id)
    {
        $id = intval($id);
        $model = Db::name('AdvItem');
        $result = $model->delete($id);
        if($result){
            $this->success(lang('Delete success!'), url('adv/itemlist',array('gid'=>$gid)));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}