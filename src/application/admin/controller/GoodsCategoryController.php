<?php

namespace app\admin\controller;


use app\admin\validate\GoodsCategoryValidate;
use app\common\facade\GoodsCategoryFacade;
use think\Db;

class GoodsCategoryController extends BaseController
{
    /**
     * 分类列表
     */
    public function index()
    {

        $this->assign('model',GoodsCategoryFacade::getCategories(true));
        return $this->fetch();
    }

    /**
     * 添加
     * @param int $pid
     * @return mixed
     */
    public function add($pid=0){
        $pid=intval($pid);
        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new GoodsCategoryValidate();
            $validate->setId();

            if (!$validate->check($data)) {
                $this->error($validate->getError());
            } else {
                $iconupload=$this->upload('category','upload_icon');
                if(!empty($iconupload))$data['icon']=$iconupload['url'];
                elseif($this->uploadErrorCode>102){
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }
                $uploaded=$this->upload('category','upload_image');
                if(!empty($uploaded))$data['image']=$uploaded['url'];
                elseif($this->uploadErrorCode>102){
                    delete_image($data['icon']);
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }

                $result=Db::name('goodsCategory')->insert($data,false,true);
                if ($result) {
                    GoodsCategoryFacade::clearCache();
                    user_log($this->mid,['addgoodscategory',$result],1,'添加商品分类 ' ,'manager');
                    $this->success(lang('Add success!'), url('goodsCategory/index'));
                } else {
                    delete_image([$data['icon'],$data['image']]);
                    $this->error(lang('Add failed!'));
                }
            }
        }
        $cate = GoodsCategoryFacade::getCategories();
        $model=array('sort'=>99,'pid'=>$pid);
        $this->assign('cate',$cate);
        $this->assign('model',$model);
        $this->assign('id',0);
        return $this->fetch('edit');
    }

    /**
     * 编辑
     * @param $id
     * @return mixed
     */
    public function edit($id)
    {
        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new GoodsCategoryValidate();
            $validate->setId($id);

            if (!$validate->check($data)) {
                $this->error($validate->getError());
            } else {
                $delete_images=[];
                $iconupload=$this->upload('category','upload_icon');
                if(!empty($iconupload)){
                    $data['icon']=$iconupload['url'];
                    $delete_images[]=$data['delete_icon'];
                }
                $uploaded=$this->upload('category','upload_image');
                if(!empty($uploaded)){
                    $data['image']=$uploaded['url'];
                    $delete_images[]=$data['delete_image'];
                }
                unset($data['delete_icon']);
                unset($data['delete_image']);

                $result=Db::name('goodsCategory')->where('id',$id)->update($data);

                if ($result) {
                    delete_image($delete_images);
                    GoodsCategoryFacade::clearCache();
                    user_log($this->mid,['addgoodscategory',$id],1,'修改商品分类 ' ,'manager');
                    $this->success(lang('Update success!'), url('goodsCategory/index'));
                } else {
                    delete_image([$data['icon'],$data['image']]);
                    $this->error(lang('Update failed!'));
                }
            }
        }

        $model = Db::name('goodsCategory')->find($id);
        if(empty($model)){
            $this->error('分类不存在');
        }
        $cate = GoodsCategoryFacade::getCategories();

        $this->assign('cate',$cate);
        $this->assign('model',$model);
        $this->assign('id',$id);
        return $this->fetch();
    }

    /**
     * 删除分类
     * @param $id
     */
    public function delete($id)
    {
        $id = idArr($id);
        //查询属于这个分类的商品
        $posts = Db::name('Goods')->where('cate_id','in',$id)->count();
        if($posts){
            $this->error("禁止删除含有文章的分类");
        }
        //禁止删除含有子分类的分类
        $hasChild = Db::name('goodsCategory')->where('pid','in',$id)->count();
        if($hasChild){
            $this->error("禁止删除含有子分类的分类");
        }
        //验证通过
        $result = Db::name('goodsCategory')->where('id','in',$id)->delete();
        if($result){
            GoodsCategoryFacade::clearCache();
            user_log($this->mid,['deletegoodscategory',$id],1,'删除商品分类 ' ,'manager');
            $this->success(lang('Delete success!'), url('goodsCategory/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}