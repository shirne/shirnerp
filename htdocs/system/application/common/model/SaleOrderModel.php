<?php

namespace app\common\model;


use think\Db;
use think\Exception;

class SaleOrderModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    public static function createOrder($order, $orderGoods)
    {
        if(empty($order['order_no'])){
            $order['order_no']=self::create_no();
        }
        if($order['customer_time']){
            $order['customer_time']=strtotime($order['customer_time']);
        }else{
            $order['customer_time']=0;
        }

        $rows = [];
        $total_price=0;
        $goods_ids = array_column($orderGoods,'goods_id');
        $goods = Db::name('goods')->whereIn('id',$goods_ids)->select();
        $goods = array_index($goods, 'id');
        foreach ($orderGoods as $good) {
            if(!$good['goods_id'])continue;
            $goods_id=$good['goods_id'];
            if(!$goods[$goods_id]) throw new Exception('订单中商品未找到');
            $total_price +=  $good['count'] * $good['price'];
            $rows[] = [
                'goods_id'=>$goods_id,
                'goods_title'=>$goods[$goods_id]['title'],
                'goods_no'=>$goods[$goods_id]['goods_no'],
                'goods_unit'=>$goods[$goods_id]['unit'],
                'price_type'=>$good['price_type'],
                'storage_id'=>$good['storage_id']?:$order['storage_id'],
                'count'=>$good['count'],
                'price'=>$good['price'],
                'base_price'=>CurrencyModel::exchange($good['price'],$order['currency']),
                'amount'=>$good['count'] * $good['price'],
            ];

        }

        $model = new static();
        $order['amount']=$total_price + $order['freight'];
        $order['base_amount']=CurrencyModel::exchange($order['amount'],$order['currency']);
        if($model->allowField(true)->save($order)) {
            foreach ($rows as &$row) {
                $row['sale_order_id']=$model['id'];
                $row['create_time']=$model['create_time'];
                $row['update_time']=$model['update_time'];
            }
            Db::name('saleOrderGoods')->insertAll($rows);

            $data = $model->getOrigin();
            $model->triggerStatus($data,$order['status']);
            return true;
        }
        return false;
    }

    public function updateOrder($goods, $order){
        if($this->status != 0){
            throw new Exception('订单已提交，不能修改');
        }

        $igoods_ids = array_column($goods,'id');
        Db::name('saleOrderGoods')->whereNotIn('id', $igoods_ids)
            ->where('sale_order_id',$this->id)->delete();

        $time = time();
        foreach ($goods as $good) {
            $row = [
                'goods_id'=>$good['goods_id'],
                'goods_title'=>$good['title'],
                'goods_no'=>$good['goods_no'],
                'goods_unit'=>$good['unit'],
                'price_type'=>$good['price_type'],
                'storage_id'=>$good['storage_id']?:$this->storage_id,
                'count'=>$good['count'],
                'price'=>$good['price'],
                'base_price'=>CurrencyModel::exchange($good['price'],$this->currency),
                'amount'=>$good['count'] * $good['price'],
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


        if($order['status']){
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