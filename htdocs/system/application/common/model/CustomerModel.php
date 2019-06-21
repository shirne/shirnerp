<?php

namespace app\common\model;


use think\Db;

class CustomerModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    public static function ranks($start_date='', $end_date=''){
        $model = new SaleOrderModel();

        $statics = $model->getStatics($start_date, $end_date, 'customer_id');
        $customer_ids = array_column($statics,'customer_id');
        if(!empty($customer_ids)){
            $customers = Db::name('customer')->whereIn('id',$customer_ids)->select();
            $customers = array_index($customers, 'id');

            foreach ($statics as &$item){
                if($item['customer_id'] && isset($customers[$item['customer_id']])) {
                    $item['customer'] = $customers[$item['customer_id']];
                }
            }
        }

        return $statics;
    }

    public function statics($start_date='', $end_date='', $type='date'){
        $model = new SaleOrderModel();

        return $model->getStatics($start_date, $end_date, $type, ['customer_id'=>$this->id]);
    }
}