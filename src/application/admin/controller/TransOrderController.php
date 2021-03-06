<?php

namespace app\admin\controller;


use app\common\model\TransOrderModel;
use think\Db;

class TransOrderController extends BaseController
{
    public function index($key='',$status='')
    {
        if($this->request->isPost()){
            return redirect(url('',['status'=>$status,'key'=>base64url_encode($key)]));
        }
        $key=empty($key)?"":base64url_decode($key);
        $model=Db::view('transOrder','*')
            ->view('storage fromStorage',['title'=>'from_storage_title'],'fromStorage.id=transOrder.from_storage_id','LEFT')
            ->view('storage',['title'=>'storage_title'],'storage.id=transOrder.storage_id','LEFT')
            ->where('transOrder.delete_time',0);

        if(!empty($key)){
            $model->whereLike('transOrder.order_no|fromStorage.title|storage.title',"%$key%");
        }
        if($status!==''){
            $model->where('transOrder.status',$status);
        }

        $lists=$model->order(Db::raw('transOrder.status ASC,transOrder.create_time DESC'))->paginate(15);
        if(!$lists->isEmpty()) {
            $orderids = array_column($lists->items(), 'order_id');
            $prodata = Db::name('transOrderGoods')->where('trans_order_id', 'in', $orderids)->select();
            $products=array_index($prodata,'trans_order_id',true);
            $lists->each(function($item) use ($products){
                if(isset($products[$item['id']])){
                    $item['goods']=$products[$item['id']];
                }else {
                    $item['goods'] = [];
                }
                return $item;
            });
        }

        $this->assign('key',$key);
        $this->assign('status',$status);
        $this->assign('orderids',empty($orderids)?0:implode(',',$orderids));
        $this->assign('lists',$lists->items());
        $this->assign('total',$lists->total());
        $this->assign('total_page',$lists->lastPage());
        $this->assign('page',$this->request->isAjax()?$lists->currentPage() : $lists->render());
        return $this->fetch();
    }

    public function create($storage_id=0){
        if($this->request->isPost()){
            $order = $this->request->put('order');
            $goods = $this->request->put('goods');
            $result = TransOrderModel::createOrder($order,$goods);
            if($result){
                user_log($this->mid,['addtransorder',$result],1,'????????????','manager');
                $this->success('???????????????');
            }else{
                $this->error('????????????');
            }
        }
        $this->assign('storage_id',$storage_id);
        return $this->fetch();
    }

    /**
     * ????????????
     * @param $id
     * @return \think\Response
     */
    public function detail($id){
        $model=Db::name('transOrder')->where('id',$id)->find();
        if(empty($model))$this->error('???????????????');
        $from_storage = Db::name('storage')->where('id',$model['from_storage_id'])->find();
        $storage = Db::name('storage')->where('id',$model['storage_id'])->find();
        $goods = Db::name('transOrderGoods')->where('trans_order_id',  $id)->order('id ASC')->select();
        $this->assign('model',$model);
        $this->assign('from_storage',$from_storage);
        $this->assign('storage',$storage);
        $this->assign('goods',$goods);
        return $this->fetch();
    }

    /**
     * ??????????????????
     * @param $id
     * @param $status
     */
    public function status($id, $status){
        $order = TransOrderModel::get($id);
        if(empty($id) || empty($order)){
            $this->error('???????????????');
        }
        if($order['status']>=$status){
            $this->error('??????????????????');
        }
        $data=array(
            'status'=>$status
        );
        $order->updateStatus($data);
        user_log($this->mid,['audittransorder',$id],1,'???????????? '.$id ,'manager');
        $this->success('????????????');
    }

    /**
     * ????????????
     * @param $id
     */
    public function delete($id)
    {
        $model = Db::name('transOrder');

        $ids = idArr($id);
        $result = $model->whereIn("id",$ids)->where('status',0)->useSoftDelete('delete_time',time())->delete();
        if($result){
            Db::name('transOrderGoods')->whereIn("trans_order_id",$ids)->useSoftDelete('delete_time',time())->delete();
            user_log($this->mid,['deletetransorder',$ids],1,'???????????? '.$id ,'manager');
            $this->success(lang('Delete success!'), url('saleOrder/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}