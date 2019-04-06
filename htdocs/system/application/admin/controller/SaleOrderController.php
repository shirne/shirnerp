<?php

namespace app\admin\controller;


use app\common\model\SaleOrderModel;
use shirne\excel\Excel;
use PhpOffice\PhpSpreadsheet\Cell\DataType;
use think\Db;

class SaleOrderController extends BaseController
{
    public function index($key='',$status='')
    {
        if($this->request->isPost()){
            return redirect(url('',['status'=>$status,'key'=>base64_encode($key)]));
        }
        $key=empty($key)?"":base64_decode($key);
        $model=Db::view('saleOrder','*')
            ->view('customer',['title'=>'customer_title','short','phone','province','city','area'],'customer.id=saleOrder.customer_id','LEFT')
            ->view('storage',['title'=>'storage_title'],'storage.id=saleOrder.storage_id','LEFT')
            ->where('saleOrder.delete_time',0);

        if(!empty($key)){
            $model->whereLike('saleOrder.order_no|customer.title',"%$key%");
        }
        if($status!==''){
            $model->where('saleOrder.status',$status);
        }

        $lists=$model->order(Db::raw('saleOrder.status ASC,saleOrder.create_time DESC'))->paginate(15);
        if(!$lists->isEmpty()) {
            $orderids = array_column($lists->items(), 'order_id');
            $prodata = Db::name('saleOrderGoods')->where('sale_order_id', 'in', $orderids)->select();
            $products=array_index($prodata,'sale_order_id',true);
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
            $result = SaleOrderModel::createOrder($order,$goods);
            if($result){
                $this->success('开单成功！');
            }else{
                $this->error('开单失败');
            }
        }
        $this->assign('currencies',getCurrencies());
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
        $model=Db::view('saleOrder','*')
            ->view('customer',['title'=>'customer_title'],'customer.id=saleOrder.customer_id','LEFT')
            ->where('saleOrder.delete_time',0);
        if(empty($order_ids)){
            if(!empty($key)){
                $model->whereLike('saleOrder.order_no|saleOrder.customer_order_no|customer.title',"%$key%");
            }
            if($status!==''){
                $model->where('saleOrder.status',$status);
            }
        }elseif($order_ids=='status') {
            $model->where('status',1);
        }else{
            $model->whereIn('saleOrder.id',idArr($order_ids));
        }


        $rows=$model->order('saleOrder.create_time DESC')->select();
        if(empty($rows)){
            $this->error('没有选择要导出的项目');
        }

        $excel=new Excel();
        $excel->setHeader(array(
            '订单号','日期','供应商','客户单号','币种','订单金额','已付金额','状态'
        ));
        $excel->setColumnType('A',DataType::TYPE_STRING);
        $excel->setColumnType('D',DataType::TYPE_STRING);

        foreach ($rows as $row){
            $excel->addRow(array(
                $row['order_no'],date('Y/m/d H:i:s',$row['create_time']),$row['customer_title'],$row['customer_order_no'],
                $row['currency'],$row['amount'],$row['payed_amount'],purchase_order_status($row['status'],false)
            ));
        }

        $excel->output(date('Y-m-d-H-i').'-销售单导出['.count($rows).'条]');
    }

    /**
     * 订单详情
     * @param $id
     * @param $is_print
     * @return \think\Response
     */
    public function detail($id, $is_print=0){
        $model=Db::name('saleOrder')->where('id',$id)->find();
        if(empty($model))$this->error('订单不存在');
        $customer=Db::name('customer')->find($model['customer_id']);
        $goods = Db::view('saleOrderGoods','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=saleOrderGoods.storage_id','LEFT')
            ->where('sale_order_id',  $id)
            ->order('saleOrderGoods.id ASC')->select();
        $this->assign('model',$model);
        $this->assign('customer',$customer);
        $this->assign('goods',$goods);
        if(!$is_print) {
            $this->assign('paylog', Db::name('financeLog')->where('type', 'sale')->where('order_id', $id)->select());
        }
        return $is_print?$this->fetch('print_one'):$this->fetch();
    }

    public function exportOne($id){
        $model=Db::name('saleOrder')->where('id',$id)->find();
        if(empty($model))$this->error('订单不存在');
        $customer=Db::name('customer')->find($model['customer_id']);
        $goods = Db::view('saleOrderGoods','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=saleOrderGoods.storage_id','LEFT')
            ->where('sale_order_id',  $id)
            ->order('saleOrderGoods.id ASC')->select();

        $excel=new Excel();
        $excel->setHeader(array(
            '出货清单('.$customer['title'].')'
        ));
        $excel->setHeader(array(
            '订单日期：'.date('Y-m-d',$model['create_time'])
        ));

        $excel->setHeader(array(
            '品种','件数','单位','重量','单价','总价','出库仓','备注'
        ));
        $excel->setColumnType('B',DataType::TYPE_STRING);
        $excel->setColumnType('D',DataType::TYPE_STRING);

        foreach ($goods as $row){
            $excel->addRow(array(
                $row['goods_title'],$row['count'],$row['goods_unit'],
                '',$row['price'],$row['amount'],$row['storage_title'],''
            ));
        }

        $excel->output('订单['.$model['order_no'].']');
    }

    public function prints($order_ids, $storage_ids='')
    {
        if(empty($order_ids)){
            $this->error('请选择订单打印');
        }
        $order_ids = idArr($order_ids);
        $storage_ids = idArr($storage_ids);
        $orders=Db::view('saleOrder','*')
            ->view('customer',['title'=>'customer_title'],'saleOrder.customer_id=customer.id','LEFT')
            ->whereIn('saleOrder.id',$order_ids)->select();
        if(empty($orders))$this->error('订单不存在');

        $goodsModel=Db::view('saleOrderGoods','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=saleOrderGoods.storage_id','LEFT')
            ->whereIn('sale_order_id',  $order_ids);
        if(!empty($storage_ids)){
            $goodsModel->whereIn('storage_id',$storage_ids);
        }
        $goods =$goodsModel->order('saleOrderGoods.id ASC')->select();
        $orderGoods = array_index($goods,'sale_order_id',true);

        $this->assign('orders',$orders);
        $this->assign('orderGoods',$orderGoods);
        $this->assign('storage_ids',$storage_ids);
        return $this->fetch();
    }

    public function statics($type='date',$start_date='',$end_date='')
    {
        if($this->request->isPost()){
            if(!in_array($type,['date','month','year']))$type='date';
            return redirect(url('',['type'=>$type,'start_date'=>$start_date,'end_date'=>$end_date]));
        }

        $format="'%Y-%m-%d'";

        if($type=='month'){
            $format="'%Y-%m'";
        }elseif($type=='year'){
            $format="'%Y'";
        }

        $model=Db::name('saleOrder')->field('count(id) as order_count,sum(amount) as order_amount,date_format(from_unixtime(create_time),' . $format . ') as awdate');
        $start_date=format_date($start_date,'Y-m-d');
        $end_date=format_date($end_date,'Y-m-d');
        if(!empty($start_date)){
            if(!empty($end_date)){
                $model->whereBetween('create_time',[strtotime($start_date),strtotime($end_date.' 23:59:59')]);
            }else{
                $model->where('create_time','GT',strtotime($start_date));
            }
        }else{
            if(!empty($end_date)){
                $model->where('create_time','LT',strtotime($end_date.' 23:59:59'));
            }
        }

        $statics=$model->where('status','GT',0)->group('awdate')->select();

        $this->assign('statics',$statics);
        $this->assign('static_type',$type);
        $this->assign('start_date',$start_date);
        $this->assign('end_date',$end_date);
        return $this->fetch();
    }

    /**
     * 订单进度修改
     * @param $id
     * @param $status
     */
    public function status($id, $status){
        $order = SaleOrderModel::get($id);
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
        user_log($this->mid,'auditsaleorder',1,'更新订单 '.$id .' '.$status,'manager');
        $this->success('操作成功');
    }

    /**
     * 删除订单
     * @param $id
     */
    public function delete($id)
    {
        $model = Db::name('saleOrder');

        $result = $model->whereIn("id",idArr($id))->where('status',0)->useSoftDelete('delete_time',time())->delete();
        if($result){
            Db::name('saleOrderGoods')->whereIn("sale_order_id",idArr($id))->useSoftDelete('delete_time',time())->delete();
            user_log($this->mid,'deletesaleorder',1,'删除订单 '.$id ,'manager');
            $this->success(lang('Delete success!'), url('saleOrder/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}