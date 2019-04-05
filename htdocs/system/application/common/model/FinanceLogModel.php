<?php

namespace app\common\model;


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
     */
    public static function addLog($type,$order,$amount,$pay_type, $remark){

        $data=[
            'type'=>$type,
            'order_id'=>$order['id'],
            'pay_type'=>$pay_type,
            'currency'=>$order['currency'],
            'remark'=>$remark
        ];
        $amount = abs(floatval($amount));
        $base_amount = CurrencyModel::exchange($amount, $order['currency']);
        if($data['type'] == 'sale'){
            $data['customer_id']=$order['customer_id'];
            $data['amount'] = $amount;
            $data['base_amount']=$base_amount;
        }elseif($data['type'] == 'purchase'){
            $data['supplier_id']=$order['supplier_id'];
            $data['amount'] = -$amount;
            $data['base_amount']=-$base_amount;
        }
        $model = static::create($data);
        if($model['id']){
            $order->setInc('payed_amount',$amount);
            return true;
        }
        return false;

    }
}