<?php

namespace app\common\model;


use think\Db;
use think\Exception;

class PurchaseOrderModel extends BaseFinanceModel
{
    protected $autoWriteTimestamp = true;

    public static function createOrder($order, $orderGoods, $total)
    {
        if(empty($order['order_no'])){
            $order['order_no']=self::create_no();
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
                'storage_id'=>$good['storage_id'],
                'count'=>$good['count'],
                'weight'=>$good['weight'],
                'price_type'=>$good['price_type'],
                'price'=>$good['price'],
                'base_price'=>$good['base_price'],
                'amount'=>$good['amount']
            ];

        }

        $model = new static();
        if($model->allowField(true)->save($order)) {
            foreach ($rows as &$row) {
                $row['purchase_order_id']=$model['id'];
                $row['create_time']=$model['create_time'];
                $row['update_time']=$model['update_time'];
            }
            Db::name('purchaseOrderGoods')->insertAll($rows);

            $data = $model->getOrigin();
            $model->triggerStatus($data,$order['status']);
            return true;
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
        Db::name('purchaseOrderGoods')->whereNotIn('id', $igoods_ids)
            ->where('purchase_order_id',$this->id)->delete();

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
                'update_time'=>$time
            ];
            if($good['id']) {
                Db::name('purchaseOrderGoods')->where('id', $good['id'])->where('purchase_order_id', $this->id)
                    ->update($row);
            }else{
                $row['purchase_order_id'] = $this->id;
                $row['create_time'] = $time;
                Db::name('purchaseOrderGoods')->insert($row);
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
                    $goods = Db::name('purchaseOrderGoods')->where('purchase_order_id',$item['id'])->select();
                    StorageModel::updateGoods($item['storage_id'],$goods);
                    break;
            }
        }
    }
}