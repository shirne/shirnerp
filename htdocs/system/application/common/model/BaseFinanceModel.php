<?php

namespace app\common\model;


use think\Db;

class BaseFinanceModel extends BaseModel
{
    public function getStatics(){
        $format="'%Y-%m-%d'";

        return Db::name($this->name)
            ->field('count(id) as order_count,sum(base_amount) as order_amount,date_format(from_unixtime(create_time),' . $format . ') as awdate')
            ->where('create_time','GT',strtotime('today -6 days'))
            ->where('delete_time',0)
            ->group('awdate')->select();
    }
    public function getFinance($isBack=false){
        $format="'%Y-%m-%d'";

        $last30day=strtotime('today -30 days');
        $last90day=strtotime('today -90 days');
        $model=Db::name($this->name)
            ->where('delete_time',0);
        if($isBack){
            $model->where('parent_order_id','GT',0);
        }else{
            $model->where('parent_order_id',0);
        }
        $saleFinance =$model->whereExp('amount',' > payed_amount')
            ->field('sum(amount - payed_amount) as unpayed_amount,currency,date_format(from_unixtime(create_time),'.$format. ') as awdate')
            ->group('awdate,currency')
            ->select();
        $finance=[
            'total'=>[],
            'in30days'=>[],
            'in90days'=>[],
            'out90days'=>[]
        ];
        foreach ($saleFinance as $item){
            $time = strtotime($item['awdate']);
            $finance['total'][$item['currency']] += $item['unpayed_amount'];
            if($time > $last30day){
                $finance['in30days'][$item['currency']] += $item['unpayed_amount'];
            }elseif($time > $last90day){
                $finance['in90days'][$item['currency']] += $item['unpayed_amount'];
            }else{
                $finance['out90days'][$item['currency']] += $item['unpayed_amount'];
            }
        }

        return $finance;
    }
}