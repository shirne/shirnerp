<?php

namespace app\common\model;


use think\Exception;

class FinanceLogModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    /**
     * @param $type
     * @param $order BaseModel
     * @param $amount
     * @param $pay_type
     * @param $remark
     * @return bool
     * @throws Exception
     */
    public static function addLog($type,$order,$amount,$pay_type, $remark){
        if($order['payed_time']>0){
            throw new Exception('订单已结完');
        }
        if($order['payed_amount']==$order['amount']){
            $order->save(['payed_time'=>time()]);
            throw new Exception('订单已结完');
        }

        $data=[
            'type'=>$type,
            'order_id'=>$order['id'],
            'pay_type'=>$pay_type,
            'currency'=>$order['currency'],
            'remark'=>$remark
        ];
        $amount = abs(floatval($amount));
        $base_amount = CurrencyModel::exchange($amount, $order['currency']);
        $uptype='INC';
        if($data['type'] == 'sale'){
            $data['customer_id']=$order['customer_id'];

            if($order['parent_order_id']>0){
                $data['amount'] = -$amount;
                $data['base_amount']=-$base_amount;
                $uptype='DEC';
            }else{
                $data['amount'] = $amount;
                $data['base_amount']=$base_amount;
            }

        }elseif($data['type'] == 'purchase'){
            $data['supplier_id']=$order['supplier_id'];

            if($order['parent_order_id']>0){
                $data['amount'] = $amount;
                $data['base_amount']=$base_amount;
                $uptype='DEC';
            }else{
                $data['amount'] = -$amount;
                $data['base_amount']=-$base_amount;
            }

        }
        $model = static::create($data);
        if($model['id']){
            $data = [
                'payed_amount'=>[$uptype,$amount]
            ];
            if($uptype == 'INC'){
                if($order['payed_amount']+$amount >= $order['amount']){
                    $data['payed_time']=time();
                }
            }else{
                if($order['payed_amount']-$amount <= $order['amount']){
                    $data['payed_time']=time();
                }
            }
            $order->save($data);
            return true;
        }
        return false;

    }
}