<?php

namespace app\common\model;


use think\Db;
use think\Exception;

class BaseFinanceModel extends BaseModel
{
    /**
     * 整理订单及商品数据
     * @param $order
     * @param $goods
     * @param $total
     * @throws Exception
     * @throws \think\db\exception\DataNotFoundException
     * @throws \think\db\exception\ModelNotFoundException
     * @throws \think\exception\DbException
     */
    public static function fixOrderDatas(&$order, &$goods, &$total)
    {
        $isback = !empty($order['parent_order_id']);

        $goods_ids=array_column($goods, 'goods_id');
        $oGoods = Db::name('goods')->whereIn('id',$goods_ids)->select();
        $oGoods = array_index($oGoods, 'id');

        $units = getGoodsUnits();
        $total_price=0;
        foreach ($goods as $k=>&$good) {
            if(!$good['goods_id']){
                unset($goods[$k]);
                continue;
            }
            $goods_id=$good['goods_id'];
            if(!isset($oGoods[$goods_id])) throw new Exception('订单中商品未找到');


            $good['goods_title']=$oGoods[$goods_id]['title'];
            $good['goods_no']=$oGoods[$goods_id]['goods_no'];
            $good['weight']=tonumber($good['weight']);
            $good['count']=tonumber($good['count']);
            $good['storage_id']=!empty($good['storage_id'])?$good['storage_id']:$order['storage_id'];

            if(isset($good['unit']) && !isset($good['goods_unit'])){
                $good['goods_unit']=$good['unit'];
            }

            if(!empty($good['goods_unit']) && isset($units[$good['goods_unit']])){
                $unitData=$units[$good['goods_unit']];
                $weightRate = floatval($unitData['weight_rate']);
                if(!empty($weightRate)){
                    if(empty($good['count']) && !empty($good['weight'])){
                        if(!empty($good['weight'])){
                            $good['count'] = $good['weight'] / $weightRate;
                        }
                    }elseif(empty($good['weight']) && !empty($good['count'])){
                        if(empty($good['weight'])){
                            $good['weight'] = $good['count'] * $weightRate;
                        }
                    }
                }
            }

            $good['weight']=transsymbol($good['weight'],$isback?'-':'+');
            $good['count']=transsymbol($good['count'],$isback?'-':'+');
            $good['price']=tonumber($good['price']);
            $good['base_price'] = CurrencyModel::exchange($good['price'],$order['currency']);

            if($good['goods_unit'] == $oGoods[$goods_id]['unit']){
                $good['base_count']=$good['count'];
            }elseif($good['weight']){
                $unitData=$units[$oGoods[$goods_id]['unit']];
                $weightRate = floatval($unitData['weight_rate']);
                if(!empty($weightRate)){
                    $good['base_count'] = $good['weight'] / $weightRate;
                }
            }

            if($good['diy_price']==1){
                $amount = transsymbol(tonumber($good['total_price']),$isback?'-':'+');
            }else {
                $amount = $good['price_type'] == 1 ? ($good['weight'] * $good['price']) : ($good['count'] * $good['price']);
            }
            $amount = round($amount,2);
            $good['amount']=$amount;
            $good['base_amount']=CurrencyModel::exchange($amount,$order['currency']);

            $total_price += $amount;
        }

        $total_price = round($total_price,2);
        $total['price']=transsymbol(tonumber($total['price']),$isback?'-':'+');
        $order['freight'] = transsymbol(tonumber($order['freight']),$isback?'-':'+');
        if($order['diy_price']==1) {
            $order['amount'] = $total['price'];
        }else {
            $order['amount'] = $total_price;
            if($order['amount'] != $total['price']){

                //throw new Exception('订单总价计算错误：'.$total['price'].'<br />计算总价:'.$order['amount']);
            }
        }

        $order['amount'] = $order['amount'] + $order['freight'];
        $order['base_amount']=CurrencyModel::exchange($order['amount'],$order['currency']);
    }

    public function getTotal($from_time, $to_time){

        $datas = Db::name($this->name)
            ->field('count(id) as order_count,sum(base_amount) as order_amount,sum(payed_amount) as order_payed_amount,currency')
            ->whereBetween('confirm_time',[$from_time, $to_time])
            ->where('parent_order_id','0')
            ->group('currency')
            ->select();

        $data=[
            'count'=>0,
            'order_amount'=>0,
            'order_payed_amount'=>0,
            'back_count'=>0,
            'back_amount'=>0,
            'back_payed_amount'=>0
        ];
        foreach ($datas as $row){
            $data['count'] += $row['order_count'];
            $data['order_amount'] += $row['order_amount'];
            $data['order_payed_amount'] += CurrencyModel::exchange($row['order_payed_amount'],$row['currency']);
        }

        $datas = Db::name($this->name)
            ->field('count(id) as order_count,sum(base_amount) as order_amount,sum(payed_amount) as order_payed_amount,currency')
            ->whereBetween('confirm_time',[$from_time, $to_time])
            ->where('parent_order_id','GT','0')
            ->group('currency')
            ->select();
        foreach ($datas as $row){
            $data['back_count'] += $row['order_count'];
            $data['back_amount'] += abs($row['order_amount']);
            $data['back_payed_amount'] += CurrencyModel::exchange(abs($row['order_payed_amount']),$row['currency']);
        }
        return $data;
    }

    public function getStatics($start_date, $end_date,$type='day', $condition=[]){
        $format="'%Y-%m-%d'";
        if($type == 'month'){
            $format="'%Y-%m'";
        }elseif($type=='week'){
            $format="'%x-%v'";
        }elseif($type=='year'){
            $format="'%Y'";
        }elseif($type !== 'day' && $type !== 'date'){
            $format="";
        }

        $model = Db::name($this->name)
            ->where('delete_time',0);

        $start_time=0;
        $end_time=0;
        if($start_date) {
            $start_time = is_int($start_date)?$start_date:strtotime($start_date);
        }

        if($end_date) {
            $end_time = is_int($end_date)?$end_date:strtotime($end_date);
        }
        if($start_time){
            if($end_time){
                $model->whereBetween('create_time',[$start_time,$end_time]);
            }else{
                $model->where('create_time','>=',$start_time);
            }
        }elseif($end_time){
            $model->where('create_time','<=',$end_time);
        }

        if(!empty($condition)){
            foreach ($condition as $k=>$v) {
                $model->where($k, $v);
            }
        }

        if($format) {
            $model->field('count(id) as order_count,sum(base_amount) as order_amount,date_format(from_unixtime(create_time),' . $format . ') as awdate')->group('awdate')->order('awdate');
        }else{
            $model->field('count(id) as order_count,sum(base_amount) as order_amount,'.$type)->group($type)->order('order_amount DESC');
        }
        return $model->select();
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