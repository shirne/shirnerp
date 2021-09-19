<?php

namespace app\common\model;


use think\Db;
use think\Exception;

class PurchaseOrderModel extends BaseFinanceModel
{
    protected $autoWriteTimestamp = true;

    const ACTION_ADD = 'addpurchaseorder';
    const ACTION_EDIT = 'editpurchaseorder';
    const ACTION_AUDIT = 'auditpurchaseorder';
    const ACTION_EXPORT = 'exportpurchaseorder';
    const ACTION_PRINT = 'printpurchaseorder';
    const ACTION_DELETE = 'deletepurchaseorder';

    public static function getActions()
    {
        return [
            self::ACTION_ADD,
            self::ACTION_EDIT,
            self::ACTION_AUDIT,
            self::ACTION_EXPORT,
            self::ACTION_PRINT,
            self::ACTION_DELETE
        ];
    }

    public static function getGoodsChanges($start_time, $storage_ids='')
    {
        $model= Db::name('purchaseOrderGoods')->alias('purchaseOrderGoods')
            ->join('purchaseOrder purchaseOrder','purchaseOrder.id=purchaseOrderGoods.purchase_order_id','LEFT');

        if(!empty($storage_ids)){
            $model->whereIn('purchaseOrderGoods.storage_id',idArr($storage_ids));
        }
        if(is_array($start_time)){
            $model->whereBetween('purchaseOrder.confirm_time',$start_time);
        }else{
            $model->where('purchaseOrder.confirm_time','GT',$start_time);
        }
        $datas =$model->where('purchaseOrder.status',1)
            ->group('goods_id')
            ->field('goods_id, sum(count) as count, sum(purchaseOrderGoods.base_amount) as total_amount, avg(base_price) as avg_price,min(base_price) as min_price,max(base_price) as max_price')
            ->select();

        return array_index($datas,'goods_id');
    }

    /**
     * @param $order
     * @param $orderGoods
     * @param $total
     * @return bool|int
     * @throws Exception
     */
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
                'base_count'=>$good['base_count'],
                'weight'=>$good['weight'],
                'price_type'=>$good['price_type'],
                'price'=>$good['price'],
                'base_price'=>$good['base_price'],
                'remark'=>$good['remark'],
                'amount'=>$good['amount'],
                'base_amount'=>$good['amount'],
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
            $data['status'] = 0;
            $model->triggerStatus($data, $order['status']);
            return $model->id;
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
                'base_count'=>$good['base_count'],
                'weight'=>$good['weight'],
                'price'=>$good['price'],
                'base_price'=>$good['base_price'],
                'amount'=>$good['amount'],
                'base_amount'=>$good['amount'],
                'remark'=>$good['remark'],
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
        if($status > $item['status']){
            switch ($status){
                case 1:
                    $goods = Db::name('purchaseOrderGoods')->where('purchase_order_id',$item['id'])->select();
                    StorageModel::updateGoods($item['storage_id'],$goods);
                    break;
            }
        }
    }
}