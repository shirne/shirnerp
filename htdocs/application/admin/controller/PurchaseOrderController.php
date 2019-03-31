<?php

namespace app\admin\controller;


use app\common\model\PurchaseOrderModel;
use excel\Excel;
use PhpOffice\PhpSpreadsheet\Cell\DataType;
use think\Db;

class PurchaseOrderController extends BaseController
{
    public function index($key='',$status='')
    {
        if($this->request->isPost()){
            return redirect(url('',['status'=>$status,'key'=>base64_encode($key)]));
        }
        $key=empty($key)?"":base64_decode($key);
        $model=Db::view('purchaseOrder','*')
            ->view('supplier',['title'=>'supplier_title','phone','province','city','area'],'supplier.id=purchaseOrder.supplier_id','LEFT')
            ->where('purchaseOrder.delete_time',0);

        if(!empty($key)){
            $model->whereLike('purchaseOrder.order_no|supplier.title',"%$key%");
        }
        if($status!==''){
            $model->where('purchaseOrder.status',$status);
        }

        $lists=$model->order(Db::raw('purchaseOrder.status ASC,purchaseOrder.create_time DESC'))->paginate(15);
        if(!$lists->isEmpty()) {
            $orderids = array_column($lists->items(), 'order_id');
            $prodata = Db::name('purchaseOrderGoods')->where('purchase_order_id', 'in', $orderids)->select();
            $products=array_index($prodata,'purchase_order_id',true);
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

    public function create($customer_id=0){
        if($this->request->isPost()){
            $order = $this->request->put('order');
            $goods = $this->request->put('goods');
            $result = PurchaseOrderModel::createOrder($order,$goods);
            if($result){
                $this->success('开单成功！');
            }else{
                $this->error('开单失败');
            }
        }
        $this->assign('customer_id',$customer_id);
        return $this->fetch();
    }

    /**
     * 导出订单
     * @param $order_ids
     * @param string $key
     * @param string $status
     * @param string $audit
     */
    public function export($order_ids='',$key='',$status='',$audit=''){
        $key=empty($key)?"":base64_decode($key);
        $model=Db::view('purchaseOrder','*')
            ->view('supplier',['username','realname','avatar','level_id'],'supplier.id=order.supplier_id','LEFT')
            ->where('purchaseOrder.delete_time',0);
        if(empty($order_ids)){
            if(!empty($key)){
                $model->whereLike('purchaseOrder.order_no|supplier.title',"%$key%");
            }
            if($status!==''){
                $model->where('purchaseOrder.status',$status);
            }
        }elseif($order_ids=='status') {
            $model->where('status',1);
        }else{
            $model->whereIn('purchaseOrder.id',idArr($order_ids));
        }


        $rows=$model->order('purchaseOrder.create_time DESC')->select();
        if(empty($rows)){
            $this->error('没有选择要导出的项目');
        }

        $excel=new Excel();
        $excel->setHeader(array(
            '编号','状态','时间','会员ID','会员账号','购买产品','购买价格','收货人','电话','省','市','区','地址'
        ));
        $excel->setColumnType('A',DataType::TYPE_STRING);
        $excel->setColumnType('D',DataType::TYPE_STRING);
        $excel->setColumnType('I',DataType::TYPE_STRING);

        foreach ($rows as $row){
            $prodata = Db::name('purchaseOrderGoods')->where('order_id', $row['order_id'])->find();
            $excel->addRow(array(
                $row['id'],order_status($row['status'],false),date('Y/m/d H:i:s',$row['create_at']),$row['member_id'],$row['username'],
                $prodata['product_title'],$row['payamount'],$row['recive_name'],$row['mobile'],$row['province'],$row['city'],$row['area'],$row['address']
            ));
        }

        $excel->output(date('Y-m-d-H-i').'-入库单导出['.count($rows).'条]');
    }

    /**
     * 订单详情
     * @param $id
     * @return \think\Response
     */
    public function detail($id){
        $model=Db::name('purchaseOrder')->where('order_id',$id)->find();
        if(empty($model))$this->error('订单不存在');
        $customer=Db::name('supplier')->find($model['supplier_id']);
        $goods = Db::name('purchaseOrderGoods')->where('id',  $id)->select();
        $this->assign('model',$model);
        $this->assign('customer',$customer);
        $this->assign('goods',$goods);
        return $this->fetch();
    }

    /**
     * 订单进度修改
     * @param $id
     */
    public function status($id){
        $order = PurchaseOrderModel::get($id);
        if(empty($id) || empty($order)){
            $this->error('订单不存在');
        }
        $audit=$this->request->post('status/d');
        $data=array(
            'status'=>$audit
        );
        $order->save($data);
        user_log($this->mid,'auditpurchaseorder',1,'更新订单 '.$id .' '.$audit,'manager');
        $this->success('操作成功');
    }

    /**
     * 删除订单
     * @param $id
     */
    public function delete($id)
    {
        $model = Db::name('purchaseOrder');
        $result = $model->whereIn("id",idArr($id))->where('status',0)->useSoftDelete('delete_time',time())->delete();
        if($result){
            Db::name('purchaseOrderGoods')->whereIn("purchase_order_id",idArr($id))->useSoftDelete('delete_time',time())->delete();
            user_log($this->mid,'deletepurchaseorder',1,'删除订单 '.$id ,'manager');
            $this->success(lang('Delete success!'), url('Order/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}