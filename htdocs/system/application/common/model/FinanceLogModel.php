<?php

namespace app\common\model;


class FinanceLogModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    /**
     * @param $type
     * @param $order BaseModel
     * @param $amount
     * @param $remark
     * @return bool
     */
    public static function addLog($type,$order,$amount, $remark){

        $data=[
            'type'=>$type,
            'order_id'=>$order['id'],
            'pay_type'=>'',
            'currency'=>$order['currency'],
            'remark'=>$remark
        ];
        $amount = abs(floatval($amount));
        if($data['type'] == 'sale'){
            $data['customer_id']=$order['customer_id'];
            $data['amount'] = $amount;
        }elseif($data['type'] == 'purchase'){
            $data['supplier_id']=$order['supplier_id'];
            $data['amount'] = -$amount;
        }
        $model = static::create($data);
        if($model['id']){
            $order->setInc('payed_amount',$amount);
            return true;
        }
        return false;

    }
}