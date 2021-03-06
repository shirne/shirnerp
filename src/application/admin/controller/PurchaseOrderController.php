<?php

namespace app\admin\controller;


use app\common\model\PurchaseOrderModel;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use shirne\excel\Excel;
use PhpOffice\PhpSpreadsheet\Cell\DataType;
use think\Db;
use think\Exception;

class PurchaseOrderController extends BaseController
{
    public function index($key='',$status='')
    {
        if($this->request->isPost()){
            return redirect(url('',['status'=>$status,'key'=>base64url_encode($key)]));
        }
        $key=empty($key)?"":base64url_decode($key);
        $model=Db::view('purchaseOrder','*')
            ->view('supplier',['title'=>'supplier_title','phone','province','city','area'],'supplier.id=purchaseOrder.supplier_id','LEFT')
            ->view('storage',['title'=>'storage_title'],'storage.id=purchaseOrder.storage_id','LEFT')
            ->where('purchaseOrder.delete_time',0);

        if(!empty($key)){
            $model->whereLike('purchaseOrder.order_no|supplier.title',"%$key%");
        }
        if($status!==''){
            $model->where('purchaseOrder.status',$status);
        }

        $lists=$model->order(Db::raw('purchaseOrder.status ASC,purchaseOrder.create_time DESC'))->paginate(15);
        if(!$lists->isEmpty()) {
            $orderids = array_column($lists->items(), 'id');
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
        $this->assign('lists',$lists->items());
        $this->assign('total',$lists->total());
        $this->assign('total_page',$lists->lastPage());
        $this->assign('page',$this->request->isAjax()?$lists->currentPage() : $lists->render());
        return $this->fetch();
    }

    public function create($supplier_id=0){
        if($this->request->isPost()){
            $order = $this->request->put('order');
            $goods = $this->request->put('goods');
            $total = $this->request->put('total');
            try {
                $result = PurchaseOrderModel::createOrder($order,$goods,$total);
            }catch (Exception $e){
                $this->error($e->getMessage());
            }
            if($result){
                user_log($this->mid,[PurchaseOrderModel::ACTION_ADD,$result],1,'????????????','manager');
                $this->success('???????????????',url('detail',['id'=>$result]),['id'=>$result]);
            }else{
                $this->error('????????????');
            }
        }
        $this->assign('units',getGoodsUnits());
        $this->assign('currencies',getCurrencies());
        $this->assign('supplier_id',$supplier_id);
        return $this->fetch();
    }

    /**
     * ????????????
     * @param $order_ids
     * @param string $key
     * @param string $status
     */
    public function export($order_ids='',$key='',$status=''){
        $key=empty($key)?"":base64_decode($key);
        $model=Db::view('purchaseOrder','*')
            ->view('supplier',['title'=>'supplier_title'],'supplier.id=purchaseOrder.supplier_id','LEFT')
            ->view('storage',['title'=>'storage_title'],'storage.id=purchaseOrder.storage_id','LEFT')
            ->where('purchaseOrder.delete_time',0);
        if(empty($order_ids)){
            if(!empty($key)){
                $model->whereLike('purchaseOrder.order_no|purchaseOrder.supplier_order_no|supplier.title',"%$key%");
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
            $this->error('??????????????????????????????');
        }

        $excel=new Excel();
        $excel->setHeader(array(
            '?????????','??????','?????????','????????????','??????','????????????','????????????','??????'
        ));
        $excel->setColumnType('A',DataType::TYPE_STRING);
        $excel->setColumnType('D',DataType::TYPE_STRING);

        foreach ($rows as $row){
            //$prodata = Db::name('purchaseOrderGoods')->where('purchase_order_id', $row['order_id'])->find();
            $excel->addRow(array(
                $row['order_no'],date('Y/m/d H:i:s',$row['create_time']),$row['supplier_title'],$row['supplier_order_no'],
                $row['currency'],$row['amount'],$row['payed_amount'],purchase_order_status($row['status'],false)
            ));
        }
        user_log($this->mid, [PurchaseOrderModel::ACTION_EXPORT, 0], 1, '????????????:'.implode(',',array_column($rows, 'id')), 'manager');
        $excel->output(date('Y-m-d-H-i').'-???????????????['.count($rows).'???]');
    }

    /**
     * ????????????
     * @param $id
     * @param $mode
     * @return \think\Response
     */
    public function detail($id, $mode = 0, $dialog = 0){
        $model=PurchaseOrderModel::get($id);
        if(empty($model))$this->error('???????????????');
        if($mode==0 && $model['status']==0)$mode=2;
        if($mode==2 && $model['status']==1)$mode=0;
        if($this->request->isPost()){
            //????????????
            if($model['status'] == 1){
                $this->error('??????????????????????????????');
            }
            $goods = $this->request->put('goods');
            $order = $this->request->put('order');
            $total = $this->request->put('total');

            $url = url('detail',['id'=>$id,'mode'=>$mode]);
            try {
                $model->updateOrder($goods, $order, $total);
            }catch (Exception $e){
                $this->error($e->getMessage());
            }
            if($order['status'] == 1) {
                $url = url('index');
            }
            user_log($this->mid,[PurchaseOrderModel::ACTION_EDIT,$id],1,'????????????','manager');
            $this->success('???????????????',$url);
        }
        $supplier=Db::name('supplier')->find($model['supplier_id']);
        $goods = Db::view('purchaseOrderGoods','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=purchaseOrderGoods.storage_id','LEFT')
            ->where('purchase_order_id',  $id)
            ->order('purchaseOrderGoods.id ASC')->select();

        $this->assign('model',$model);
        $this->assign('supplier',$supplier);
        $this->assign('goods',$goods);
        $this->assign('units',getGoodsUnits());
        $this->assign('currencies',getCurrencies());
        $this->assign('logs',PurchaseOrderModel::getLogs($id));
        if($mode==0) {
            $this->assign('paylog', Db::name('financeLog')->where('type', 'purchase')->where('order_id', $id)->select());
        }
        if($dialog){
            return $this->fetch();
        }

        return $mode?$this->fetch($mode==2?($model['parent_order_id']?'back_edit':'edit'):'print_one'):$this->fetch();
    }

    /**
     * ??????
     * @param $id
     * @return mixed
     */
    public function back($id){
        $model=Db::name('purchaseOrder')->where('id',$id)->find();
        if(empty($model))$this->error('???????????????');
        if($this->request->isPost()){
            $order = $this->request->put('order');
            $goods = $this->request->put('goods');
            $total = $this->request->put('total');
            try{
                $result = PurchaseOrderModel::createOrder($order,$goods,$total);
            }catch (Exception $e){
                $this->error($e->getMessage());
            }
            if($result){
                user_log($this->mid,[PurchaseOrderModel::ACTION_ADD,$result],1,'???????????????','manager');
                $this->success('???????????????',url('detail',['id'=>$result]),['id'=>$result]);
            }else{
                $this->error('????????????');
            }
        }

        $supplier=Db::name('supplier')->find($model['supplier_id']);
        $goods = Db::view('purchaseOrderGoods','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=purchaseOrderGoods.storage_id','LEFT')
            ->where('purchase_order_id',  $id)
            ->order('purchaseOrderGoods.id ASC')->select();

        $this->assign('model',$model);
        $this->assign('supplier',$supplier);
        $this->assign('goods',$goods);
        $this->assign('units',getGoodsUnits());
        $this->assign('currencies',getCurrencies());

        return $this->fetch();
    }

    /**
     * @param $id
     * @throws \PhpOffice\PhpSpreadsheet\Exception
     * @throws \think\db\exception\DataNotFoundException
     * @throws \think\db\exception\ModelNotFoundException
     * @throws \think\exception\DbException
     */
    public function exportOne($id){
        $model=Db::name('purchaseOrder')->where('id',$id)->find();
        if(empty($model))$this->error('???????????????');
        $supplier=Db::name('supplier')->find($model['supplier_id']);
        $goods = Db::view('purchaseOrderGoods','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=purchaseOrderGoods.storage_id','LEFT')
            ->where('purchase_order_id',  $id)
            ->order('purchaseOrderGoods.id ASC')->select();

        $excel=new Excel();
        $excel->setHeader(array(
            '????????????('.$supplier['title'].')'
        ));
        $excel->merge('A1','H1');
        $style = $excel->getCell('A1')->getStyle();
        $style->getFont()->setSize(20);
        $style->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

        $excel->setHeader(array(
            '???????????????'.date('Y-m-d H:i',$model['create_time']),'','','',
            '???????????????'.date('Y-m-d H:i',$model['confirm_time'])
        ));
        $excel->merge('A2','D2');
        $excel->merge('E2','H2');
        $style = $excel->getCell('E2')->getStyle();
        $style->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);

        $excel->setHeader(array(
            '??????','??????','??????','??????','??????','??????','?????????','??????'
        ));
        $style = $excel->getCell('A3')->getStyle();
        $style->getFont()->setBold(true);
        $excel->getSheet()->duplicateStyle($style,'B3:H3');

        //$excel->setColumnType('B',DataType::TYPE_STRING);
        //$excel->setColumnType('D',DataType::TYPE_STRING);
        $excel->setColumnType('F',DataType::TYPE_FORMULA);
        $firstrow=0;
        foreach ($goods as $row){
            $rownum = $excel->getRownum();
            if(!$firstrow)$firstrow=$rownum;
            if($row['diy_price']==1){
                $subtotal = $row['amount'];
            }else {
                $subtotal = $row['price_type'] == '1' ? "=D{$rownum}*E{$rownum}" : "=B{$rownum}*E{$rownum}";
            }
            $excel->addRow([
                $row['goods_title'],$row['count'],$row['goods_unit'],
                $row['weight'],$row['price'],
                $subtotal,
                $row['storage_title'],$row['remark']
            ]);
        }
        $excel->addRow([
            '??????','','','','',[$model['freight'],DataType::TYPE_NUMERIC]
        ]);
        $rownum = $excel->getRownum()-1;
        if($model['diy_price']==1){
            $total = [$model['amount'],DataType::TYPE_NUMERIC];
        }else {
            $total = "=SUM(F{$firstrow}:F{$rownum})";
        }
        $excel->addRow(array(
            '??????',["=SUM(B{$firstrow}:B{$rownum})",DataType::TYPE_FORMULA],'',
            ["=SUM(D{$firstrow}:D{$rownum})",DataType::TYPE_FORMULA],
            [$model['currency'],DataType::TYPE_STRING],$total,
            '',''
        ));
        $excel->setRangeAlign('E'.($rownum+1),Alignment::HORIZONTAL_RIGHT);
        if($model['remark']){
            $excel->addRow([
                '?????????',$model['remark']
            ]);
        }

        $excel->setRangeBorder('A1:H'.($rownum+1),'FF000000');
        user_log($this->mid, [PurchaseOrderModel::ACTION_EXPORT, $model['id']], 1, '????????????', 'manager');
        $excel->output('?????????['.$model['order_no'].']');
    }

    public function log($id)
    {
        $logs = PurchaseOrderModel::getLogs($id);

        $this->result($logs,1);
    }

    /**
     * ??????????????????
     * @param $id
     * @param $status
     */
    public function status($id, $status){
        $order = PurchaseOrderModel::get($id);
        if(empty($id) || empty($order)){
            $this->error('???????????????');
        }
        if($order['status']>=$status){
            $this->error('??????????????????');
        }
        $data=array(
            'status'=>$status
        );
        $remark='????????????';
        if($status==1){
            if($order['parent_order_id']>0){
                $remark = '????????????';
            }else{
                $remark = '????????????';
            }
            $data['confirm_time']=time();
        }
        $order->updateStatus($data);
        user_log($this->mid,[PurchaseOrderModel::ACTION_AUDIT,$id],1,$remark,'manager');
        $this->success('????????????');
    }

    /**
     * ????????????
     * @param $id
     * @throws \Exception
     */
    public function delete($id)
    {
        $ids = idArr($id);
        $model = Db::name('purchaseOrder');
        $result = $model->whereIn("id",$ids)->where('status',0)->useSoftDelete('delete_time',time())->delete();
        if($result){
            Db::name('purchaseOrderGoods')->whereIn("purchase_order_id",$ids)->useSoftDelete('delete_time',time())->delete();
            user_log($this->mid,[PurchaseOrderModel::ACTION_DELETE,$ids],1,'????????????' ,'manager');
            $this->success(lang('Delete success!'), url('purchaseOrder/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }

    public function statics($start_date='', $end_date='', $type='day'){
        if($this->request->isPost()){
            if(!in_array($type,['date','week','month','year']))$type='date';
            return redirect(url('',['type'=>$type,'start_date'=>$start_date,'end_date'=>$end_date]));
        }
        $start_date=format_date($start_date,'Y-m-d');
        $end_date=format_date($end_date,'Y-m-d');
        $purchaseModel = new PurchaseOrderModel();
        $statics = $purchaseModel->getStatics(strtotime($start_date), strtotime($end_date), $type);
        $this->assign('statics',$statics);
        $this->assign('static_type',$type);
        $this->assign('start_date',$start_date);
        $this->assign('end_date',$end_date);
        return $this->fetch();
    }
}