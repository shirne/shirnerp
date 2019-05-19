<?php

namespace app\common\model;


use think\Db;
use think\Exception;

class StorageInventoryModel extends BaseModel
{
    protected $autoWriteTimestamp = true;


    public static function getGoodsChanges($start_time, $storage_ids='')
    {
        $model= Db::name('storageInventoryGoods')->alias('storageInventoryGoods')
            ->join('storageInventory storageInventory','storageInventory.id=storageInventoryGoods.inventory_id','LEFT');

        if(!empty($storage_ids)){
            $model->whereIn('storageInventory.storage_id',idArr($storage_ids));
        }
        $datas =$model->where('storageInventory.status',1)
            ->where('storageInventory.inventory_time','GT',$start_time)
            ->group('goods_id')
            ->field('goods_id, sum(new_count-count) as count')
            ->select();

        return array_index($datas,'goods_id');
    }

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
                'new_count'=>$good['count']
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
            return $model['id'];
        }
        return false;
    }

    public function updateOrder($goods, $status=0){
        if($this->status != 0){
            throw new Exception('订单已提交，不能修改');
        }

        $igoods_ids = array_column($goods,'id');
        Db::name('storageInventoryGoods')->whereNotIn('id', $igoods_ids)
            ->where('inventory_id',$this->id)->delete();

        foreach ($goods as $good) {
            if($good['id']) {
                Db::name('storageInventoryGoods')->where('id', $good['id'])->where('goods_id', $good['goods_id'])
                    ->update(['new_count' => $good['new_count']]);
            }else{
                Db::name('storageInventoryGoods')->insert([
                    'goods_id'=>$good['goods_id'],
                    'count'=>$good['count'],
                    'new_count'=>$good['new_count'],
                    'inventory_id'=>$this->id,
                    'create_time'=>time(),
                    'update_time'=>time()
                ]);
            }
        }

        if($status){
            $this->updateStatus([
                'status' => $status,
                'inventory_time' => time()
            ]);
        }
        return true;
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