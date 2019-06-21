<?php

namespace app\common\model;


use think\Db;

class SupplierModel extends BaseModel
{
    protected $autoWriteTimestamp = true;

    public static function ranks($start_date='', $end_date=''){
        $model = new PurchaseOrderModel();

        $statics = $model->getStatics($start_date, $end_date, 'supplier_id');
        $supplier_ids = array_column($statics,'supplier_id');
        if(!empty($supplier_ids)){
            $suppliers = Db::name('supplier')->whereIn('id',$supplier_ids)->select();
            $suppliers = array_index($suppliers, 'id');

            foreach ($statics as &$item){
                if($item['supplier_id'] && isset($suppliers[$item['supplier_id']])) {
                    $item['supplier'] = $suppliers[$item['supplier_id']];
                }
            }
        }
        return $statics;
    }

    public function statics($start_date='', $end_date='', $type='date'){
        $model = new PurchaseOrderModel();

        return $model->getStatics($start_date, $end_date, $type, ['supplier_id'=>$this->id]);
    }
}