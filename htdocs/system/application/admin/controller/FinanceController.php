<?php

namespace app\admin\controller;


use app\common\model\FinanceLogModel;
use app\common\model\PurchaseOrderModel;
use app\common\model\SaleOrderModel;
use app\common\model\StorageInventoryModel;
use app\common\model\StorageModel;
use shirne\excel\Excel;
use think\Db;
use think\Exception;

class FinanceController extends BaseController
{
    public function index(){
        $saleModel = new SaleOrderModel();
        $purchaseModel = new PurchaseOrderModel();

        $this->assign('saleOrders',$saleModel->getStatics(strtotime('today -6 days'),time()));

        $this->assign('purchaseOrders',$purchaseModel->getStatics(strtotime('today -6 days'),time()));

        $finance['sales']=$saleModel->getFinance();
        $finance['sales_back']=$saleModel->getFinance(true);
        $finance['purchases']=$purchaseModel->getFinance();
        $finance['purchases_back']=$purchaseModel->getFinance(true);

        $this->assign('finance',$finance);
        return $this->fetch();
    }

    public function accounting($start_date='', $end_date='', $export = false)
    {
        $finance=[];
        if(!empty($start_date) && !empty($end_date)){
            $start_time=strtotime($start_date);
            $end_time=strtotime($end_date);
            if(empty($start_time) || empty($end_time)){
                $this->error('日期参数错误');
            }

            //销售
            $saleModel=new SaleOrderModel();
            $saleData = $saleModel->getTotal($start_time,$end_time);

            //采购
            $purchaseModel=new PurchaseOrderModel();
            $purchaseData = $purchaseModel->getTotal($start_time,$end_time);

            $goods = StorageModel::getGoods();

            $start_inventery_goods = StorageInventoryModel::getGoodsChanges($start_time);
            $end_inventery_goods = StorageInventoryModel::getGoodsChanges($end_time);

            $purchase_goods = PurchaseOrderModel::getGoodsChanges([$start_time,$end_time]);
            $end_purchase_goods = PurchaseOrderModel::getGoodsChanges($end_time);

            $sale_goods = SaleOrderModel::getGoodsChanges([$start_time,$end_time]);
            $end_sale_goods = SaleOrderModel::getGoodsChanges($end_time);

            foreach ($goods as &$good)
            {
                $goods_id=$good['id'];

                if(!isset($start_inventery_goods[$goods_id])){
                    $start_inventery_goods[$goods_id]=['goods_id'=>$goods_id,'count'=>0];
                }
                if(!isset($end_inventery_goods[$goods_id])){
                    $end_inventery_goods[$goods_id]=['goods_id'=>$goods_id,'count'=>0];
                }

                if(!isset($purchase_goods[$goods_id])){
                    $purchase_goods[$goods_id]=['goods_id'=>$goods_id,'count'=>0];
                }
                if(!isset($end_purchase_goods[$goods_id])){
                    $end_purchase_goods[$goods_id]=['goods_id'=>$goods_id,'count'=>0];
                }

                if(!isset($sale_goods[$goods_id])){
                    $sale_goods[$goods_id]=['goods_id'=>$goods_id,'count'=>0];
                }
                if(!isset($end_sale_goods[$goods_id])){
                    $end_sale_goods[$goods_id]=['goods_id'=>$goods_id,'count'=>0];
                }

                $good['end_count'] = $good['count']
                    - $start_inventery_goods[$goods_id]['count']
                    + $end_sale_goods[$goods_id]['count']
                    - $end_purchase_goods[$goods_id]['count'];

                $good['start_count'] = $good['count']
                    - $start_inventery_goods[$goods_id]['count']
                    + $sale_goods[$goods_id]['count']
                    + $end_sale_goods[$goods_id]['count']
                    - $purchase_goods[$goods_id]['count']
                    - $end_purchase_goods[$goods_id]['count'];

                $good['inventery_count']=$good['end_count'] +
                    ($start_inventery_goods[$goods_id]['count']-$end_inventery_goods[$goods_id]['count']);
                $good['purchase']=$purchase_goods[$goods_id];
                $good['sale']=$sale_goods[$goods_id];

                //销售成本

                //毛利润

                //损耗率
            }
            $goods = array_filter($goods,function($item){
                return !empty($item['start_count']) || !empty($item['end_count']) ||
                    !empty($item['purchase']['count']) || !empty($item['sale']['count']) || !empty($item['inventery_count']);
            });

            $finance['goods']=$goods;

            if($export){
                return $this->exportAccounting($goods,$start_time, $end_time);
            }


            $this->assign('sale_total',$saleData);
            $this->assign('purchase_total',$purchaseData);
            $this->assign('finance',$finance);
        }else{
            $this->assign('finance',$finance);
        }
        $this->assign('start_date',$start_date);
        $this->assign('end_date',$end_date);
        return $this->fetch();
    }

    protected function exportAccounting($goods,$start_time, $end_time){
        $excel=new Excel('Xlsx');

        $excel->setHeader([
            '编号','品名','期初数量','采购','','','销售','','','账面结存数量','盘点结存数量','差异','','销售成本','毛利润','毛利率%','损耗率%'
        ]);
        $excel->merge('D1','F1');
        $excel->merge('G1','I1');
        $excel->merge('L1','M1');
        $excel->setHeader([
            '','','','数量','单价','金额','数量','单价','金额','','','差异数量','差异金额'
        ]);
        foreach (['A','B','C','J','K','N','O','P','Q'] as $col){
            $excel->merge($col.'1',$col.'2');
        }
        foreach ($goods as $good){
            $excel->addRow([
                $good['id'],$good['title'],$good['start_count'],
                $good['purchase']['count'],$good['purchase']['avg_price'],$good['purchase']['total_amount'],
                $good['sale']['count'],$good['sale']['avg_price'],$good['sale']['total_amount'],
            ]);
        }

        $excel->output('生产成本表['.date('Y-m-d',$start_time).'-'.date('Y-m-d',$end_time).']');
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

    public function receiveFix(){
        Db::name('saleOrder')
            ->where('parent_order_id',0)
            ->where('payed_time',0)
            ->whereExp('payed_amount',' >= amount')->update(['payed_time'=>time()]);
        Db::name('saleOrder')
            ->where('parent_order_id','GT',0)
            ->where('payed_time',0)
            ->whereExp('payed_amount',' <= amount')->update(['payed_time'=>time()]);

        Db::name('saleOrder')
            ->where('parent_order_id',0)
            ->where('payed_time','GT',0)
            ->whereExp('payed_amount',' < amount')->update(['payed_time'=>0]);
        Db::name('saleOrder')
            ->where('parent_order_id','GT',0)
            ->where('payed_time','GT',0)
            ->whereExp('payed_amount',' > amount')->update(['payed_time'=>0]);

        $this->success('修复完成');
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

    public function payableFix(){
        Db::name('purchaseOrder')
            ->where('parent_order_id',0)
            ->where('payed_time',0)
        ->whereExp('payed_amount',' >= amount')->update(['payed_time'=>time()]);
        Db::name('purchaseOrder')
            ->where('parent_order_id','GT',0)
            ->where('payed_time',0)
            ->whereExp('payed_amount',' <= amount')->update(['payed_time'=>time()]);

        Db::name('purchaseOrder')
            ->where('parent_order_id',0)
            ->where('payed_time','GT',0)
            ->whereExp('payed_amount',' < amount')->update(['payed_time'=>0]);
        Db::name('purchaseOrder')
            ->where('parent_order_id','GT',0)
            ->where('payed_time','GT',0)
            ->whereExp('payed_amount',' > amount')->update(['payed_time'=>0]);

        $this->success('修复完成');
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