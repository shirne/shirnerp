<?php

namespace app\common\model;


use think\Db;

class PurchaseOrderModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    public static function createOrder($order, $orderGoods)
    {
        if(empty($order['order_no'])){
            $order['order_no']=self::create_no();
        }

        $rows = [];
        $total_price=0;
        $goods_ids = array_column($orderGoods,'goods_ids');
        $goods = Db::name('goods')->whereIn('id',$goods_ids)->select();
        $goods = array_index($goods, 'id');
        foreach ($orderGoods as $good) {
            if(!$good['goods_id'])continue;
            $goods_id=$good['goods_id'];
            $total_price +=  $good['count'] * $good['price'];
            $rows[] = [
                'goods_id'=>$goods_id,
                'goods_title'=>$goods[$goods_id]['title'],
                'goods_no'=>$goods[$goods_id]['goods_no'],
                'goods_unit'=>$goods[$goods_id]['unit'],
                'count'=>$good['count'],
                'price'=>$good['price'],
                'amount'=>$good['count'] * $good['price']
            ];

        }

        $model = new static();
        $order['amount']=$total_price;
        if($model->allowField(true)->save($order)) {
            foreach ($rows as &$row) {
                $row['purchase_order_id']=$model['id'];
            }
            Db::name('purchaseOrderGoods')->insertAll($rows);

            $data = $model->getOrigin();
            $model->triggerStatus($data,$order['status']);
            return true;
        }

        return false;
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