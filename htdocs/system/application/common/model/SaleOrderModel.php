<?php

namespace app\common\model;


use think\Db;
use think\Exception;

class SaleOrderModel extends BaseFinanceModel
{
    protected $autoWriteTimestamp = true;

    const ACTION_ADD = 'addsaleorder';
    const ACTION_EDIT = 'editsaleorder';
    const ACTION_AUDIT = 'auditsaleorder';
    const ACTION_DELETE = 'deletesaleorder';

    public static function getActions()
    {
        return [self::ACTION_ADD,self::ACTION_EDIT,self::ACTION_AUDIT,self::ACTION_DELETE];
    }

    public static function getGoodsChanges($start_time, $storage_ids='')
    {
        $model= Db::name('saleOrderGoods')->alias('saleOrderGoods')
            ->join('saleOrder saleOrder','saleOrder.id=saleOrderGoods.sale_order_id','LEFT');

        if(!empty($storage_ids)){
            $model->whereIn('saleOrderGoods.storage_id',idArr($storage_ids));
        }
        if(is_array($start_time)){
            $model->whereBetween('saleOrder.confirm_time',$start_time);
        }else{
            $model->where('saleOrder.confirm_time','GT',$start_time);
        }
        $datas =$model->where('saleOrder.status',1)
            ->group('goods_id')
            ->field('goods_id, sum(count) as count, sum(saleOrderGoods.base_amount) as total_amount, avg(base_price) as avg_price,min(base_price) as min_price,max(base_price) as max_price')
            ->select();

        return array_index($datas,'goods_id');
    }

    public static function createOrder($order, $orderGoods, $total)
    {
        if(empty($order['order_no'])){
            $order['order_no']=self::create_no();
        }
        if($order['customer_time']){
            $order['customer_time']=strtotime($order['customer_time']);
        }else{
            $order['customer_time']=0;
        }

        try {
            static::fixOrderDatas($order, $orderGoods, $total);
        }catch (Exception $e){
            throw $e;
        }

        $rows = [];
        foreach ($orderGoods as $good) {
            if(!$good['goods_id'])continue;
            $goods_id=$good['goods_id'];

            $rows[] = [
                'goods_id'=>$goods_id,
                'goods_title'=>$good['goods_title'],
                'goods_no'=>$good['goods_no'],
                'goods_unit'=>$good['goods_unit'],
                'price_type'=>$good['price_type'],
                'storage_id'=>$good['storage_id'],
                'count'=>$good['count'],
                'weight'=>$good['weight'],
                'price'=>$good['price'],
                'base_price'=>$good['base_price'],
                'remark'=>$good['remark'],
                'amount'=>$good['amount'],
            ];

        }

        $model = new static();
        if($model->allowField(true)->save($order)) {
            foreach ($rows as &$row) {
                $row['sale_order_id']=$model['id'];
                $row['create_time']=$model['create_time'];
                $row['update_time']=$model['update_time'];
            }
            Db::name('saleOrderGoods')->insertAll($rows);

            $data = $model->getOrigin();
            $model->triggerStatus($data,$order['status']);
            return $model['id'];
        }
        return false;
    }

    public function updateOrder($orderGoods, $order, $total){
        if($this->status != 0){
            throw new Exception('订单已提交，不能修改');
        }
        try {
            static::fixOrderDatas($order, $orderGoods, $total);
        }catch (Exception $e){
            throw $e;
        }

        $igoods_ids = array_column($orderGoods,'id');
        Db::name('saleOrderGoods')->whereNotIn('id', $igoods_ids)
            ->where('sale_order_id',$this->id)->delete();

        $time = time();

        foreach ($orderGoods as $good) {
            if(!$good['goods_id'])continue;
            $goods_id=$good['goods_id'];

            $row = [
                'goods_id'=>$goods_id,
                'goods_title'=>$good['goods_title'],
                'goods_no'=>$good['goods_no'],
                'goods_unit'=>$good['goods_unit'],
                'price_type'=>$good['price_type'],
                'storage_id'=>$good['storage_id'],
                'count'=>$good['count'],
                'weight'=>$good['weight'],
                'price'=>$good['price'],
                'base_price'=>$good['base_price'],
                'amount'=>$good['amount'],
                'remark'=>$good['remark'],
                'update_time'=>$time
            ];
            if($good['id']) {
                Db::name('saleOrderGoods')->where('id', $good['id'])->where('sale_order_id', $this->id)
                    ->update($row);
            }else{
                $row['sale_order_id'] = $this->id;
                $row['create_time'] = $time;
                Db::name('saleOrderGoods')->insert($row);
            }
        }

        if($order['status']>0){
            $order['confirm_time']=$time;
            $this->updateStatus($order);
        }else{
            $this->save($order);
        }
        return true;
    }

    protected function triggerStatus($item,$status)
    {
        if($status>$item['status']){
            switch ($status){
                case 1:
                    $goods = Db::name('saleOrderGoods')->where('sale_order_id',$item['id'])->select();
                    StorageModel::updateGoods($item['storage_id'],$goods,'-');
                    break;
            }
        }
    }
}