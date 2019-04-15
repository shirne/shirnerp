<?php

namespace app\common\model;


use think\Db;
use think\Exception;

class StorageInventoryModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    public static function createOrder($order, $orderGoods){
        if(empty($order['order_no'])){
            $order['order_no']=self::create_no();
        }

        $rows = [];
        $total_price=0;
        $goods_ids = array_column($orderGoods,'goods_id');
        $goods = Db::name('goods')->whereIn('id',$goods_ids)->select();
        $goods = array_index($goods, 'id');
        foreach ($orderGoods as $good) {
            if(!$good['goods_id'])continue;
            $goods_id=$good['goods_id'];
            if(!$goods[$goods_id]) throw new Exception('商品数据未找到');
            $total_price +=  $good['count'] * $good['price'];
            $rows[] = [
                'goods_id'=>$goods_id,
                'count'=>$good['count'],
                'new_count'=>$good['count'],
                //'price'=>$good['price'],
                //'amount'=>$good['count'] * $good['price']
            ];

        }

        $model = new static();
        $order['amount']=$total_price;
        if($model->allowField(true)->save($order)) {
            foreach ($rows as &$row) {
                $row['inventory_id']=$model['id'];
                $row['create_time']=$model['create_time'];
                $row['update_time']=$model['update_time'];
            }
            Db::name('storageInventoryGoods')->insertAll($rows);

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
                    $goods = Db::name('storageInventoryGoods')->where('inventory_id',$item['id'])->select();
                    $newgoods=[];
                    foreach ($goods as $good){
                        if($good['new_count'] != $good['count']){
                            $newgoods[]=[
                                'goods_id'=>$good['goods_id'],
                                'count'=>$good['new_count'] - $good['count']
                            ];
                        }
                    }
                    if((!empty($newgoods))) {
                        StorageModel::updateGoods($item['storage_id'], $newgoods);
                    }
                    break;
            }
        }
    }
}