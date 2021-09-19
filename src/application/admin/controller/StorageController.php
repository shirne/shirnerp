<?php

namespace app\admin\controller;


use app\admin\validate\StorageValidate;
use app\common\model\StorageInventoryModel;
use app\common\model\TransOrderModel;
use shirne\excel\Excel;
use PhpOffice\PhpSpreadsheet\Cell\DataType;
use think\Db;

class StorageController extends BaseController
{
    public function search($key='')
    {
        $model=Db::name('storage');
        if(!empty($key)){
            $model->where('id|title|fullname|storage_no','like',"%$key%");
        }

        $limit = $this->request->get('limit',20);
        $lists=$model->field('id,title,fullname,storage_no,create_time')
            ->order('id ASC')->limit($limit)->select();


        return json(['data'=>$lists,'code'=>1]);
    }

    public function getStorage($storage_id, $goods_id=''){
        if(is_array($storage_id)){
            $storages=[];
            foreach ($storage_id as $sid=>$goods_id){
                $stores = Db::name('goodsStorage')->where('storage_id', $sid)->whereIn('goods_id', idArr($goods_id))->select();
                $storages[$sid]=array_index($stores, 'goods_id,count');
            }
        }else {
            $stores = Db::name('goodsStorage')->where('storage_id', $storage_id)->whereIn('goods_id', idArr($goods_id))->select();
            $storages = array_index($stores, 'goods_id,count');
        }
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
        $this->assign('lists',$lists->items());
        $this->assign('total',$lists->total());
        $this->assign('total_page',$lists->lastPage());
        $this->assign('page',$this->request->isAjax()?$lists->currentPage() : $lists->render());
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

                $result = Db::name('storage')->insert($data,false,true);
                if ($result) {
                    user_log($this->mid,['addstorage',$result],1,'添加仓库','manager');
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
                    user_log($this->mid,['editstorage',$id],1,'编辑仓库','manager');
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

    public function createInventory($storage_id){

        $storage = Db::name('storage')->where('id',$storage_id)->find();
        if($this->request->isPost()){
            $order = $this->request->put('order');
            $goods = $this->request->put('goods');
            $exists = StorageInventoryModel::where('storage_id',$order['storage_id'])
                ->where('delete_time',0)
                ->where('status',0)
                ->find();

            if(!empty($exists)){
                $this->error('该仓库正在盘点中.');
            }

            $result = StorageInventoryModel::createOrder($order,$goods);
            if($result){
                user_log($this->mid,['addinventory',$result],1,'创建盘点单','manager');
                $this->success('创建盘点数据成功！',url('inventory',['storage_id'=>$storage_id]));
            }else{
                $this->error('创建失败');
            }
        }
        $goods = Db::view('goodsStorage','*')
            ->view('goods',['title','unit'],'goodsStorage.goods_id = goods.id','LEFT')
            ->where('goodsStorage.storage_id',$storage_id)->select();
        $this->assign('goods',$goods);
        $this->assign('storage',$storage);
        return $this->fetch();
    }

    public function inventory($storage_id){

        $storage = Db::name('storage')->where('id',$storage_id)->find();
        $lists = Db::view('storageInventory','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=storageInventory.storage_id')
            ->where('storageInventory.delete_time',0)
            ->order('storageInventory.create_time DESC')
            ->paginate(10);

        $this->assign('lists',$lists);
        $this->assign('storage',$storage);
        $this->assign('storage_id',$storage_id);
        return $this->fetch();
    }

    /**
     * @param $id
     * @param int $is_edit
     * @return mixed
     */
    public function inventoryDetail($id, $is_edit=0){
        $inventory = Db::name('storageInventory')->where('id',$id)->where('delete_time',0)->find();
        if(empty($inventory)){
            $this->error('盘点单不存在');
        }
        $storage = Db::name('storage')->where('id',$inventory['storage_id'])->find();


        if($this->request->isPost()){
            if($inventory['status'] == 1){
                $this->error('盘点单已提交');
            }
            $goods = $this->request->put('goods');
            $status = $this->request->put('status');

            $order = StorageInventoryModel::get($id);

            $url = url('inventoryDetail',['id'=>$id,'is_edit'=>$is_edit]);
            $order->updateOrder($goods,$status);
            if($status == 1) {
                $url = url('inventoryDetail',['id'=>$id]);
            }
            user_log($this->mid,['editinventory',$id],1,'编辑盘点单','manager');
            $this->success('处理成功！',$url);
        }
        $goods = Db::view('storageInventoryGoods','*')
            ->view('goods',['title','unit'],'goods.id=storageInventoryGoods.goods_id','LEFT')
            ->where('inventory_id',$id)->select();

        $this->assign('inventory',$inventory);
        $this->assign('goods',$goods);
        $this->assign('storage',$storage);
        return $is_edit?$this->fetch('inventory_edit'):$this->fetch();
    }

    public function deleteInventory($id, $storage_id){
        $model = Db::name('storageInventory');
        $ids = idArr($id);
        $result = $model->whereIn("id",$ids)->where('status',0)->useSoftDelete('delete_time',time())->delete();
        if($result){
            Db::name('storageInventoryGoods')->whereIn("inventory_id",$ids)->useSoftDelete('delete_time',time())->delete();
            user_log($this->mid,['deleteinventory',$ids],1,'删除盘点 '.$id ,'manager');
            $this->success(lang('Delete success!'), url('storage/inventory',['storage_id'=>$storage_id]));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }

    public function goods($id){
        $goods = Db::view('goodsStorage','*')
            ->view('goods','*','goods.id=goodsStorage.goods_id','LEFT')
            ->view('goodsCategory',['title'=>'category_title'],'goods.cate_id=goodsCategory.id','LEFT')
            ->where('storage_id',$id)->select();

        $storage = Db::name('storage')->find($id);
        $this->assign('storage',$storage);
        $this->assign('goods',$goods);
        $this->assign('id',$id);
        return $this->fetch();
    }

    public function prints($id){
        $goods = Db::view('goodsStorage','*')
            ->view('goods','*','goods.id=goodsStorage.goods_id','LEFT')
            ->view('goodsCategory',['title'=>'category_title'],'goods.cate_id=goodsCategory.id','LEFT')
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
            ->view('goods','*','goods.id=goodsStorage.goods_id','LEFT')
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
                user_log($this->mid,['addtransorder',$result],1,'转库开单 '.$result ,'manager');
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
            user_log($this->mid,['deletestorage',$id],1,'删除仓库 '.$result ,'manager');
            $this->success(lang('Delete success!'), url('storage/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}