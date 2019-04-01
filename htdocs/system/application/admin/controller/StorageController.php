<?php

namespace app\admin\controller;


use app\admin\validate\StorageValidate;
use app\common\model\TransOrderModel;
use shirne\excel\Excel;
use PhpOffice\PhpSpreadsheet\Cell\DataType;
use think\Db;

class StorageController extends BaseController
{
    public function search($key=''){
        $model=Db::name('storage');
        if(!empty($key)){
            $model->where('id|title|fullname|storage_no','like',"%$key%");
        }

        $lists=$model->field('id,title,fullname,storage_no,create_time')
            ->order('id ASC')->limit(20)->select();


        return json(['data'=>$lists,'code'=>1]);
    }

    public function getStorage($storage_id, $goods_id){
        $stores = Db::name('goodsStorage')->where('storage_id',$storage_id)->whereIn('goods_id',$goods_id)->select();
        $storages = array_index($stores, 'goods_id,count');
        return json(['data'=>$storages,'code'=>1]);
    }

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

    public function goods($id){
        $goods = Db::view('goodsStorage','*')
            ->join('goods','goods.id=goodsStorage.goods_id','LEFT')
            ->where('storage_id',$id)->select();

        $storage = Db::name('storage')->find($id);
        $this->assign('storage',$storage);
        $this->assign('goods',$goods);
        $this->assign('id',$id);
        return $this->fetch();
    }

    public function prints($id){
        $goods = Db::view('goodsStorage','*')
            ->join('goods','goods.id=goodsStorage.goods_id','LEFT')
            ->where('storage_id',$id)->select();
        $storage = Db::name('storage')->find($id);
        $this->assign('storage',$storage);
        $this->assign('goods',$goods);
        $this->assign('id',$id);
        return $this->fetch();
    }

    public function export($id){
        $storage = Db::name('storage')->find($id);

        $goods = Db::view('goodsStorage','*')
            ->join('goods','goods.id=goodsStorage.goods_id','LEFT')
            ->where('storage_id',$id)->select();
        if(empty($goods)){
            $this->error('没有要导出的项');
        }

        $excel=new Excel();
        $excel->setHeader(array(
            '品名','库存','单位','对账','备注'
        ));
        $excel->setColumnType('A',DataType::TYPE_STRING);

        foreach ($goods as $row){
            $excel->addRow(array(
                $row['title'],$row['count'],$row['unit'],'',''
            ));
        }

        $excel->output($storage['title'].'-库存-'.date('Y-m-d-H-i'));
    }

    /**
     * 转库
     * @return mixed
     */
    public function trans($id=0,$from_id=0,$goods=''){
        if($this->request->isPost()){
            $order = $this->request->put('order');
            $goods = $this->request->put('goods');
            $result = TransOrderModel::createOrder($order,$goods);
            if($result){
                $this->success('开单成功！');
            }else{
                $this->error('开单失败');
            }
        }
        $this->assign('storage_id',$id);
        $this->assign('from_storage_id',$from_id);
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