<?php

namespace app\admin\controller;


use app\common\model\TransOrderModel;
use think\Db;

class TransOrderController extends BaseController
{
    public function index($key='',$status='')
    {
        if($this->request->isPost()){
            return redirect(url('',['status'=>$status,'key'=>base64_encode($key)]));
        }
        $key=empty($key)?"":base64_decode($key);
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
            $prodata = Db::name('transOrderGoods')->where('sale_order_id', 'in', $orderids)->select();
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
        $this->assign('lists',$lists);
        $this->assign('page',$lists->render());
        return $this->fetch();
    }

    public function create($storage_id=0){
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
        $this->assign('storage_id',$storage_id);
        return $this->fetch();
    }

    /**
     * 订单详情
     * @param $id
     * @return \think\Response
     */
    public function detail($id){
        $model=Db::name('transOrder')->where('id',$id)->find();
        if(empty($model))$this->error('订单不存在');
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
     * 订单进度修改
     * @param $id
     * @param $status
     */
    public function status($id, $status){
        $order = TransOrderModel::get($id);
        if(empty($id) || empty($order)){
            $this->error('订单不存在');
        }
        if($order['status']>=$status){
            $this->error('订单状态错误');
        }
        $data=array(
            'status'=>$status
        );
        $order->updateStatus($data);
        user_log($this->mid,'audittransorder',1,'更新订单 '.$id .' '.$audit,'manager');
        $this->success('操作成功');
    }

    /**
     * 删除订单
     * @param $id
     */
    public function delete($id)
    {
        $model = Db::name('transOrder');

        $result = $model->whereIn("id",idArr($id))->where('status',0)->useSoftDelete('delete_time',time())->delete();
        if($result){
            Db::name('transOrderGoods')->whereIn("trans_order_id",idArr($id))->useSoftDelete('delete_time',time())->delete();
            user_log($this->mid,'deletetransorder',1,'删除订单 '.$id ,'manager');
            $this->success(lang('Delete success!'), url('saleOrder/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}