<?php

namespace app\admin\controller;


use app\common\model\SaleOrderModel;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use shirne\excel\Excel;
use PhpOffice\PhpSpreadsheet\Cell\DataType;
use think\Db;
use think\Exception;
use think\facade\Log;

class SaleOrderController extends BaseController
{
    public function index($key='',$status='')
    {
        if($this->request->isPost()){
            return redirect(url('',['status'=>$status,'key'=>base64url_encode($key)]));
        }
        $key=empty($key)?"":base64url_decode($key);
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
            $orderids = array_column($lists->items(), 'id');
            $prodata = Db::name('saleOrderGoods')->where('sale_order_id', 'in', $orderids)->select();
            $products=array_index($prodata,'sale_order_id',true);
            $package_ids = array_column($lists->items(), 'package_id');
            $packages= Db::name('salePackageItem')->whereIn('package_id', $package_ids)->field('package_id,count(id) as counts')->group('package_id')->select();
            $packageCounts = array_column($packages, 'counts', 'package_id');
            $lists->each(function($item) use ($products, $packageCounts){
                if(isset($products[$item['id']])){
                    $item['goods']=$products[$item['id']];
                }else {
                    $item['goods'] = [];
                }
                if(!empty($item['package_id'])){
                    $item['package_count'] = $packageCounts[$item['package_id']];
                }else{
                    $item['package_count'] = 0;
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

    public function create($customer_id=0){
        if($this->request->isPost()){
            $order = $this->request->put('order');
            $goods = $this->request->put('goods');
            $total = $this->request->put('total');
            if(is_string($order)){
                $order = json_decode($order,true);
            }
            if(is_string($goods)){
                $goods = json_decode($goods,true);
            }
            if(is_string($total)){
                $total = json_decode($total,true);
            }
            $order['manager_id'] = $this->mid;
            try{
                $result = SaleOrderModel::createOrder($order,$goods,$total);
            }catch (\Exception $e){
                Log::record($e->getMessage());
                $this->error($e->getMessage());
            }
            if($result){
                user_log($this->mid,[SaleOrderModel::ACTION_ADD,$result],1,'????????????','manager');
                $this->success('???????????????',url('detail',['id'=>$result]),['id'=>$result]);
            }else{
                $this->error('????????????');
            }
        }
        $this->assign('units',getGoodsUnits());
        $this->assign('currencies',getCurrencies());
        $this->assign('customer_id',$customer_id);
        return $this->fetch();
    }

    /**
     * ????????????
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
            $this->error('??????????????????????????????');
        }

        $excel=new Excel();
        $excel->setHeader(array(
            '?????????','??????','?????????','????????????','??????','????????????','????????????','??????'
        ));
        $excel->setColumnType('A',DataType::TYPE_STRING);
        $excel->setColumnType('D',DataType::TYPE_STRING);

        foreach ($rows as $row){
            $excel->addRow(array(
                $row['order_no'],date('Y/m/d H:i:s',$row['create_time']),$row['customer_title'],$row['customer_order_no'],
                $row['currency'],$row['amount'],$row['payed_amount'],purchase_order_status($row['status'],false)
            ));
        }
        user_log($this->mid, [SaleOrderModel::ACTION_EXPORT, 0], 1, '????????????:'.implode(',',array_column($rows, 'id')), 'manager');
        $excel->output(date('Y-m-d-H-i').'-???????????????['.count($rows).'???]');
    }

    /**
     * ??????
     * @param $id
     * @return mixed
     */
    public function back($id){
        $model=Db::name('saleOrder')->where('id',$id)->find();
        if(empty($model))$this->error('???????????????');
        if($this->request->isPost()){
            $order = $this->request->put('order');
            $goods = $this->request->put('goods');
            $total = $this->request->put('total');
            if(is_string($order)){
                $order = json_decode($order,true);
            }
            if(is_string($goods)){
                $goods = json_decode($goods,true);
            }
            if(is_string($total)){
                $total = json_decode($total,true);
            }
            try {
                $result = SaleOrderModel::createOrder($order, $goods, $total);
            }catch (Exception $e){
                $this->error($e->getMessage());
            }
            if($result){
                user_log($this->mid,[SaleOrderModel::ACTION_ADD,$result],1,'????????????','manager');
                $this->success('???????????????',url('detail',['id'=>$result]),['id'=>$result]);
            }else{
                $this->error('????????????');
            }
        }
        $customer=Db::name('customer')->find($model['customer_id']);
        $goods = Db::view('saleOrderGoods','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=saleOrderGoods.storage_id','LEFT')
            ->where('sale_order_id',  $id)
            ->order('saleOrderGoods.id ASC')->select();

        $this->assign('units',getGoodsUnits());
        $this->assign('model',$model);
        $this->assign('customer',$customer);
        $this->assign('goods',$goods);
        $this->assign('currencies',getCurrencies());

        return $this->fetch();
    }

    /**
     * ????????????
     * @param $id
     * @param $mode
     * @return \think\Response
     */
    public function detail($id, $mode = 0, $dialog = 0){
        $model=SaleOrderModel::get($id);
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
            if(is_string($order)){
                $order = json_decode($order,true);
            }
            if(is_string($goods)){
                $goods = json_decode($goods,true);
            }
            if(is_string($total)){
                $total = json_decode($total,true);
            }

            $url = url('detail',['id'=>$id,'mode'=>$mode]);
            try {
                $model->updateOrder($goods, $order, $total);
            }catch (Exception $e){
                $this->error($e->getMessage());
            }
            if($order['status'] == 1) {
                $url = url('index');
            }
            user_log($this->mid,[SaleOrderModel::ACTION_EDIT,$id],1,'????????????','manager');
            $this->success('???????????????',$url);
        }
        $customer=Db::name('customer')->find($model['customer_id']);
        $goods = Db::view('saleOrderGoods','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=saleOrderGoods.storage_id','LEFT')
            ->where('sale_order_id',  $id)
            ->order('saleOrderGoods.id ASC')->select();
        if($model['customer_time']){
            $model['customer_time']=date('Y-m-d H:i:s',$model['customer_time']);
        }else{
            $model['customer_time']='';
        }
        $this->assign('units',getGoodsUnits());
        $this->assign('model',$model);
        $this->assign('customer',$customer);
        $this->assign('goods',$goods);
        $this->assign('currencies',getCurrencies());
        $this->assign('logs',SaleOrderModel::getLogs($id));
        if($mode==0) {
            $this->assign('paylog', Db::name('financeLog')->where('type', 'sale')->where('order_id', $id)->select());
        }
        if($dialog){
            return $this->fetch();
        }
        return $mode?$this->fetch($mode==2?($model['parent_order_id']>0?'back_edit':'edit'):'print_one'):$this->fetch();
    }

    public function exportOne($id){
        $model=Db::name('saleOrder')->where('id',$id)->find();
        if(empty($model))$this->error('???????????????');
        $customer=Db::name('customer')->find($model['customer_id']);
        $goods = Db::view('saleOrderGoods','*')
            ->view('storage',['title'=>'storage_title'],'storage.id=saleOrderGoods.storage_id','LEFT')
            ->where('sale_order_id',  $id)
            ->order('saleOrderGoods.id ASC')->select();

        $excel=new Excel();
        $excel->setHeader(array(
            '????????????('.$customer['title'].')'
        ));
        $excel->merge('A1','H1');
        $style = $excel->getCell('A1')->getStyle();
        $style->getFont()->setSize(20);
        $style->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

        $excel->setHeader(array(
            '???????????????'.date('Y-m-d H:i',$model['create_time']),'','','',
            '???????????????'.date('Y-m-d H:i',$model['customer_time'])
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
                $subtotal = $row['price_type']=='1'?"=D{$rownum}*E{$rownum}":"=B{$rownum}*E{$rownum}";
            }
            $excel->addRow(array(
                $row['goods_title'],$row['count'],$row['goods_unit'],
                $row['weight'],$row['price'],
                $subtotal,
                $row['storage_title'],$row['remark']
            ));
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

        user_log($this->mid, [SaleOrderModel::ACTION_EXPORT, $model['id']], 1, '????????????', 'manager');
        $excel->output('?????????['.$model['order_no'].']');
    }

    public function prints($order_ids, $storage_ids='')
    {
        if(empty($order_ids)){
            $this->error('?????????????????????');
        }
        if($this->request->isPost()) {
            $packages = $this->request->put('packages');
            //????????????????????????????????????????????????????????????????????????????????????
            if(!empty($packages)){
                foreach ($packages as $pkg_id=>$items){
                    if($pkg_id > 0 ){
                        if(empty($items)){
                            Db::name('salePackageItem')->where('package_id', $pkg_id)->delete();
                            Db::name('salePackageGoods')->where('package_id', $pkg_id)->delete();
                        }else {
                            $item_ids = array_column($items, 'id');
                            Db::name('salePackageItem')->where('package_id', $pkg_id)
                                ->whereNotIn('id', $item_ids)->delete();
                            foreach ($items as $item){
                                if($item['id']<1){
                                    $item['id'] = Db::name('salePackageItem')->insert([
                                        'title'=>$item['title'],
                                        'package_id' => $pkg_id,
                                        'customer_id' => $item['customer_id'],
                                        'storage_id' => $item['storage_id']
                                    ], false,true);
                                }else{
                                    Db::name('salePackageItem')->where([
                                        'id'=>$item['id'],
                                        'package_id' => $pkg_id
                                    ])->update([
                                        'title'=>$item['title'],
                                        'customer_id' => $item['customer_id'],
                                        'storage_id' => $item['storage_id']
                                    ]);
                                }
                                if(empty($item['goods'])){
                                    Db::name('salePackageGoods')->where('package_id', $pkg_id)
                                        ->where('item_id', $item['id'])->delete();
                                }else {
                                    $goods_id = array_column($item['goods'],'goods_id');
                                    Db::name('salePackageGoods')->where('package_id', $pkg_id)
                                        ->where('item_id', $item['id'])
                                        ->whereNotIn('goods_id', $goods_id)->delete();

                                    foreach ($item['goods'] as $goods) {

                                        Db::name('salePackageGoods')->insert([
                                            'package_id' => $pkg_id,
                                            'item_id' => $item['id'],
                                            'goods_id' => $goods['goods_id'],
                                            'goods_title' => $goods['goods_title'],
                                            'count' => $goods['count'],
                                            'goods_unit' => $goods['goods_unit'],
                                        ],true);
                                    }
                                }
                            }
                        }
                        $order = SaleOrderModel::where('package_id',$pkg_id)->find();
                        if(!empty($order)){
                            user_log($this->mid,[SaleOrderModel::ACTION_PACKAGE,$order['id']],1,'??????????????????','manager');
                        }
                    }
                }
                $this->success('????????????');
            }

            $order_ids = idArr($order_ids);
            $storage_ids = empty($storage_ids) ? [] : idArr($storage_ids);
            $orders = Db::view('saleOrder', '*')
                ->view('customer', ['title' => 'customer_title'], 'saleOrder.customer_id=customer.id', 'LEFT')
                ->view('storage', ['title' => 'storage_title'], 'storage.id=saleOrder.storage_id', 'LEFT')
                ->whereIn('saleOrder.id', $order_ids)->select();
            if (empty($orders)) $this->error('???????????????');

            $goodsModel = Db::view('saleOrderGoods', '*')
                ->view('storage', ['title' => 'storage_title'], 'storage.id=saleOrderGoods.storage_id', 'LEFT')
                ->whereIn('sale_order_id', $order_ids);
            if (!empty($storage_ids)) {
                $goodsModel->whereIn('storage_id', $storage_ids);
            }
            $goods = $goodsModel->order('saleOrderGoods.id ASC')->select();
            $orderGoods = array_index($goods, 'sale_order_id', true);


            //?????????????????????????????????????????????
            foreach ($orders as $k => $order) {
                $orders[$k]['create_date']=date('Y-m-d H:i:s',$order['create_time']);
                $orders[$k]['customer_date']=$order['customer_date']>0?date('Y-m-d H:i:s',$order['customer_date']):'-';
                if (!$order['package_id']) {
                    $package_id = Db::name('salePackage')->insert(['sort' => 1], false, true);
                    $orders[$k]['package_id'] = $package_id;
                    Db::name('saleOrder')->where('id', $order['id'])->update(['package_id' => $package_id]);
                    Db::name('salePackageItem')->insert([
                        'title'=>'1',
                        'package_id' => $package_id,
                        'customer_id' => $order['customer_id'],
                        'storage_id' => $order['storage_id']
                    ]);
                    user_log($this->mid,[SaleOrderModel::ACTION_PACKAGE,$order['id']],1,'???????????????','manager');
                }
            }

            $package_ids = array_column($orders, 'package_id');
            $packages = Db::name('salePackageItem')
                ->whereIn('package_id', $package_ids)
                ->order('id ASC')
                ->select();
            $packages = array_index($packages, 'package_id', true);

            $packageGoods = Db::view('salePackageGoods','*')
                ->view('saleOrder',[],'saleOrder.package_id=salePackageGoods.package_id')
                ->view('saleOrderGoods',['count'=>'total_count'],'saleOrderGoods.sale_order_id=saleOrder.id AND saleOrderGoods.goods_id=salePackageGoods.goods_id')
                ->whereIn('salePackageGoods.package_id', $package_ids)
                ->order('salePackageGoods.id ASC')
                ->select();
            $packageGoods = array_index($packageGoods, 'item_id', true);

            $this->assign('orders', $orders);
            $this->assign('orderGoods', $orderGoods);
            $this->assign('packages', $packages);
            $this->assign('packageGoods', $packageGoods);
        }
        $this->assign('order_ids', $order_ids);
        $this->assign('storage_ids', $storage_ids);
        return $this->fetch();
    }

    public function statics($start_date='',$end_date='',$type='date')
    {
        if($this->request->isPost()){
            if(!in_array($type,['date','week','month','year']))$type='date';
            return redirect(url('',['type'=>$type,'start_date'=>$start_date,'end_date'=>$end_date]));
        }

        $model=new SaleOrderModel();
        $start_date=format_date($start_date,'Y-m-d');
        $end_date=format_date($end_date,'Y-m-d');

        $statics = $model->getStatics(strtotime($start_date),strtotime($end_date),$type);


        $this->assign('statics',$statics);
        $this->assign('static_type',$type);
        $this->assign('start_date',$start_date);
        $this->assign('end_date',$end_date);
        return $this->fetch();
    }

    public function log($id)
    {
        $logs = SaleOrderModel::getLogs($id);

        $this->result($logs,1);
    }

    /**
     * ??????????????????
     * @param $id
     * @param $status
     */
    public function status($id, $status){
        $order = SaleOrderModel::get($id);
        if(empty($id) || empty($order)){
            $this->error('???????????????');
        }
        if($order['status']>=$status){
            $this->error('??????????????????');
        }
        $data=array(
            'status'=>$status
        );
        $remark = '??????????????????';
        if($status==1){
            if($order['parent_order_id']>0){
                $remark = '????????????';
            }else{
                $remark = '????????????';
            }
            $data['confirm_time']=time();
        }
        $order->updateStatus($data);
        user_log($this->mid,[SaleOrderModel::ACTION_AUDIT,$id],1,$remark,'manager');
        $this->success('????????????');
    }

    /**
     * ????????????
     * @param $id
     */
    public function delete($id)
    {
        $ids = idArr($id);
        $model = Db::name('saleOrder');

        $result = $model->whereIn("id",$ids)->where('status',0)->useSoftDelete('delete_time',time())->delete();
        if($result){
            Db::name('saleOrderGoods')->whereIn("sale_order_id",$ids)->useSoftDelete('delete_time',time())->delete();
            user_log($this->mid,[SaleOrderModel::ACTION_DELETE,$ids],1,'????????????' ,'manager');
            $this->success(lang('Delete success!'), url('saleOrder/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}