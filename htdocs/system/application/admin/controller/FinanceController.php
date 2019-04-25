<?php

namespace app\admin\controller;


use app\common\model\FinanceLogModel;
use app\common\model\PurchaseOrderModel;
use app\common\model\SaleOrderModel;
use think\Db;
use think\Exception;

class FinanceController extends BaseController
{
    public function index(){
        $saleModel = new SaleOrderModel();
        $purchaseModel = new PurchaseOrderModel();

        $this->assign('saleOrders',$saleModel->getStatics());

        $this->assign('purchaseOrders',$purchaseModel->getStatics());

        $finance['sales']=$saleModel->getFinance();
        $finance['sales_back']=$saleModel->getFinance(true);
        $finance['purchases']=$purchaseModel->getFinance();
        $finance['purchases_back']=$purchaseModel->getFinance(true);

        $this->assign('finance',$finance);
        return $this->fetch();
    }

    public function receive($key='',$status=''){
        if($this->request->isPost()){
            return redirect(url('',['status'=>$status,'key'=>base64_encode($key)]));
        }
        $key=empty($key)?"":base64_decode($key);
        $model=Db::view('saleOrder','*')
            ->view('customer',['title'=>'customer_title','short','phone','province','city','area'],'customer.id=saleOrder.customer_id','LEFT')
            ->where('saleOrder.payed_time',0)
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
        $this->assign('paytypes',getFinanceTypes(false));
        $this->assign('page',$lists->render());
        return $this->fetch();
    }

    public function receiveLog(){
        if($this->request->isPost()){
            $data = $this->request->only('id,amount,pay_type,remark','post');
            $data['id']=intval($data['id']);

            $order = SaleOrderModel::get($data['id']);
            if(empty($order)){
                $this->error('订单错误！');
            }
            try {

                $result = FinanceLogModel::addLog('sale', $order, $data['amount'], $data['pay_type'], $data['remark']);
            }catch (Exception $e){
                $this->error($e->getMessage());
            }

            if($result){
                $this->success('入账成功！');
            }else{
                $this->error('入账失败！');
            }

        }
        $this->error('请求错误！');
    }

    public function payable($key='',$status=''){
        if($this->request->isPost()){
            return redirect(url('',['status'=>$status,'key'=>base64_encode($key)]));
        }
        $key=empty($key)?"":base64_decode($key);
        $model=Db::view('purchaseOrder','*')
            ->view('supplier',['title'=>'supplier_title','phone','province','city','area'],'supplier.id=purchaseOrder.supplier_id','LEFT')
            ->where('purchaseOrder.payed_time',0)
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
        $this->assign('paytypes',getFinanceTypes(false));
        $this->assign('page',$lists->render());
        return $this->fetch();
    }

    public function payableLog(){
        if($this->request->isPost()){
            $data = $this->request->only('id,amount,pay_type,remark','post');
            $data['id']=intval($data['id']);

            $order = PurchaseOrderModel::get($data['id']);
            if(!$order){
                $this->error('订单错误！');
            }

            try {

                $result = FinanceLogModel::addLog('purchase',$order,$data['amount'],$data['pay_type'],$data['remark']);
            }catch (Exception $e){
                $this->error($e->getMessage());
            }

            if($result){
                $this->success('入账成功！');
            }else{
                $this->error('入账失败！');
            }
        }

        $this->error('请求错误！');
    }

    public function logs($id=0,$from_id=0,$fromdate='',$todate='',$type='all'){
        $model=Db::view('FinanceLog mlog','*')
            ->view('Customer m',['title'=>'customer_title'],'m.id=mlog.customer_id','LEFT')
            ->view('Supplier fm',['title'=>'supplier_title'],'fm.id=mlog.supplier_id','LEFT');


        if($id>0){
            $model->where('mlog.customer_id',$id);
            $this->assign('customer',Db::name('customer')->find($id));
        }
        if($from_id>0){
            $model->where('mlog.supplier_id',$from_id);
            $this->assign('supplier',Db::name('supplier')->find($from_id));
        }
        if(!empty($type) && $type!='all'){
            $model->where('mlog.type',$type);
        }else{
            $type='all';
        }

        if(!empty($todate)){
            $totime=strtotime($todate.' 23:59:59');
            if($totime===false)$todate='';
        }
        if(!empty($fromdate)) {
            $fromtime = strtotime($fromdate);
            if ($fromtime === false) $fromdate = '';
        }
        if(!empty($fromtime)){
            if(!empty($totime)){
                $model->whereBetween('mlog.create_time',array($fromtime,$totime));
            }else{
                $model->where('mlog.create_time','EGT',$fromtime);
            }
        }else{
            if(!empty($totime)){
                $model->where('mlog.create_time','ELT',$totime);
            }
        }

        $logs = $model->order('ID DESC')->paginate(15);

        $types=getOrderTypes();

        $stacrows=$model->group('mlog.type')->field('mlog.type,sum(mlog.amount) as total_amount')->select();
        $statics=[];
        foreach ($stacrows as $row){
            $statics[$row['type']]=$row['total_amount'];
        }
        $statics['sum']=array_sum($statics);

        $this->assign('id',$id);
        $this->assign('from_id',$from_id);
        $this->assign('fromdate',$fromdate);
        $this->assign('todate',$todate);
        $this->assign('type',$type);

        $this->assign('types',$types);
        $this->assign('statics', $statics);
        $this->assign('logs', $logs);
        $this->assign('page',$logs->render());
        return $this->fetch();
    }
}