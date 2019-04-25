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
        $isback = $order['parent_order_id']>0;

        $rows = [];
        $total_price=0;
        $goods_ids = array_column($orderGoods,'goods_id');
        $goods = Db::name('goods')->whereIn('id',$goods_ids)->select();
        $goods = array_index($goods, 'id');
        foreach ($orderGoods as $good) {
            if(!$good['goods_id'])continue;
            $goods_id=$good['goods_id'];
            if(!$goods[$goods_id]) throw new Exception('订单中商品未找到');
            $good['weight']=transsymbol(tonumber($good['weight']),$isback?'-':'+');
            $good['count']=transsymbol(tonumber($good['count']),$isback?'-':'+');
            if($good['diy_price']==1){
                $amount = transsymbol(tonumber($good['total_price']),$isback?'-':'+');
            }else {
                $amount = $good['price_type'] == 1 ? ($good['weight'] * $good['price']) : ($good['count'] * $good['price']);
            }
            $total_price +=  $amount;
            $rows[] = [
                'goods_id'=>$goods_id,
                'goods_title'=>$goods[$goods_id]['title'],
                'goods_no'=>$goods[$goods_id]['goods_no'],
                'goods_unit'=>$goods[$goods_id]['unit'],
                'storage_id'=>$good['storage_id']?:$order['storage_id'],
                'count'=>$good['count'],
                'weight'=>$good['weight'],
                'price_type'=>$good['price_type'],
                'price'=>$good['price'],
                'base_price'=>CurrencyModel::exchange($good['price'],$order['currency']),
                'amount'=>$amount
            ];

        }

        $model = new static();
        $order['freight']=transsymbol(tonumber($order['freight']),$isback?'-':'+');
        $total['price']=transsymbol(tonumber($total['price']),$isback?'-':'+');
        if($order['diy_price']==1) {
            $order['amount'] = $total['price'];
        }else {
            $order['amount'] = $total_price;
            if($order['amount'] !== $total['price']){
                throw new Exception('订单总价计算错误：'.$total['price'].',计算总价:'.$order['amount']);
            }
        }
        $order['amount'] = $order['amount']+$order['freight'];
        $order['base_amount']=CurrencyModel::exchange($order['amount'],$order['currency']);
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

    public function updateOrder($goods, $order, $total){
        if($this->status != 0){
            throw new Exception('订单已提交，不能修改');
        }
        $isback = $order['parent_order_id']>0;

        $igoods_ids = array_column($goods,'id');
        Db::name('purchaseOrderGoods')->whereNotIn('id', $igoods_ids)
            ->where('purchase_order_id',$this->id)->delete();

        $time = time();
        $total_price=0;
        foreach ($goods as $good) {
            $good['weight']=transsymbol(tonumber($good['weight']),$isback?'-':'+');
            $good['count']=transsymbol(tonumber($good['count']),$isback?'-':'+');
            if($good['diy_price']==1){
                $amount = transsymbol(tonumber($good['total_price']),$isback?'-':'+');
            }else {
                $amount = $good['price_type'] == 1 ? ($good['weight'] * $good['price']) : ($good['count'] * $good['price']);
            }
            $total_price+=$amount;
            $row = [
                'goods_id'=>$good['goods_id'],
                'goods_title'=>$good['title'],
                'goods_no'=>$good['goods_no'],
                'goods_unit'=>$good['unit'],
                'price_type'=>$good['price_type'],
                'storage_id'=>$good['storage_id']?:$this->storage_id,
                'count'=>$good['count'],
                'weight'=>$good['weight'],
                'price'=>$good['price'],
                'base_price'=>CurrencyModel::exchange($good['price'],$this->currency),
                'amount'=>$amount,
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

        $order['freight']=transsymbol(tonumber($order['freight']),$isback?'-':'+');
        $total['price']=transsymbol(tonumber($total['price']),$isback?'-':'+');
        if($order['diy_price']==1) {
            $order['amount'] = $total['price'];
        }else {
            $order['amount'] = $total_price;
            if($order['amount'] !== $total['price']){
                throw new Exception('订单总价计算错误：'.$total['price'].',计算总价:'.$order['amount']);
            }
        }
        $order['amount'] = $order['amount'] + $order['freight'];
        $order['base_amount']=CurrencyModel::exchange($order['amount'],$order['currency']);

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
                    $goods = Db::name('purchaseOrderGoods')->where('purchase_order_id',$item['id'])->select();
                    StorageModel::updateGoods($item['storage_id'],$goods);
                    break;
            }
        }
    }
}