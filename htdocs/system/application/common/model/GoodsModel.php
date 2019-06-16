<?php
namespace app\common\model;

use app\common\facade\GoodsCategoryFacade;
use think\Db;

/**
 * Class GoodsModel
 * @package app\common\model
 */
class GoodsModel extends ContentModel
{
    protected $autoWriteTimestamp = true;

    function __construct($data = [])
    {
        parent::__construct($data);
        $this->cateFacade=GoodsCategoryFacade::getFacadeInstance();
    }

    public static function statics($start_date='', $end_date=''){
        $pmodel = Db::name('purchaseOrderGoods');
        $smodel = Db::name('saleOrderGoods');
        $start_time=0;
        $end_time=0;
        if($start_date) {
            $start_time = strtotime($start_date);
            if ($start_time) $start_date = date('Y-m-d H:i:s', $start_time);
        }

        if($end_date) {
            $end_time = strtotime($end_date);
            if ($end_time) $end_date = date('Y-m-d H:i:s', $end_time);
        }

        if($start_time){
            if($end_time){
                $pmodel->whereBetween('create_time',[$start_time,$end_time]);
                $smodel->whereBetween('create_time',[$start_time,$end_time]);
            }else{
                $pmodel->where('create_time','>=',$start_time);
                $smodel->where('create_time','>=',$start_time);
            }
        }elseif($end_time){
            $pmodel->where('create_time','<=',$end_time);
            $smodel->where('create_time','<=',$end_time);
        }
        $pdata = $pmodel->field('sum(count) as total_count,sum(base_amount) as total_amount,min(base_price) as min_price,max(base_price) as max_price, goods_id,goods_title,goods_unit')
            ->group('goods_id,goods_unit')->order('total_count DESC')
            ->select();
        $sdata = $smodel->field('sum(count) as total_count,sum(base_amount) as total_amount,min(base_price) as min_price,max(base_price) as max_price, goods_id,goods_title,goods_unit')
            ->group('goods_id,goods_unit')->order('total_count DESC')
            ->select();

        $goods_ids = array_column($pdata,'goods_id');
        $goods_ids = array_merge($goods_ids,array_column($sdata,'goods_id'));
        $goods_ids = array_unique($goods_ids, SORT_NUMERIC );

        $allgoods = Db::name('goods')->whereIn('id',$goods_ids)->field('id,goods_no,title,unit')->select();
        $goods = array_index($allgoods, 'id');


        $purchaseStatics=[];
        foreach ($pdata as $k=>$row){
            $goods_id = $row['goods_id'];
            if($row['goods_unit'] == $goods[$goods_id]['unit']){
                $goods[$goods_id]['purchase'] = $row;
            }else{
                $goods[$goods_id]['other'][$row['goods_unit']]['purchase']=$row;
            }
            $pdata[$k]['price'] = $row['count']>0?round($row['total_amount']/$row['total_count'],2):0;
            $purchaseStatics[]=[
                'value'=> $row['total_count'],
                'label'=> $row['goods_title'].'('.$row['goods_unit'].')'
            ];
        }

        $saleStatics=[];
        foreach ($sdata as $k=>$row){
            $goods_id = $row['goods_id'];
            if($row['goods_unit'] == $goods[$goods_id]['unit']){
                $goods[$goods_id]['sale'] = $row;
            }else{
                $goods[$goods_id]['other'][$row['goods_unit']]['sale']=$row;
            }
            $sdata[$k]['price'] = $row['count']>0?round($row['total_amount']/$row['total_count'],2):0;
            $saleStatics[]=[
                'value'=> $row['total_count'],
                'label'=> $row['goods_title'].'('.$row['goods_unit'].')'
            ];
        }

        return compact('start_date','end_date','purchaseStatics','saleStatics','goods');
    }

    public function staticGoods($start_date='', $end_date=''){
        $format ="'%Y-%m-%d'";
        $pmodel = Db::name('purchaseOrderGoods')->where('goods_id',$this['id']);
        $smodel = Db::name('saleOrderGoods')->where('goods_id',$this['id']);
        $start_time=0;
        $end_time=0;
        if($start_date) {
            $start_time = strtotime($start_date);
            if ($start_time) $start_date = date('Y-m-d H:i:s', $start_time);
        }

        if($end_date) {
            $end_time = strtotime($end_date);
            if ($end_time) $end_date = date('Y-m-d H:i:s', $end_time);
        }

        if($start_time){
            if($end_time){
                $pmodel->whereBetween('create_time',[$start_time,$end_time]);
                $smodel->whereBetween('create_time',[$start_time,$end_time]);
            }else{
                $pmodel->where('create_time','>=',$start_time);
                $smodel->where('create_time','>=',$start_time);
            }
        }elseif($end_time){
            $pmodel->where('create_time','<=',$end_time);
            $smodel->where('create_time','<=',$end_time);
        }
        $pdata = $pmodel->field('sum(count) as total_count,min(base_price) as min_price,max(base_price) as max_price,sum(base_amount) as total_amount,goods_unit,date_format(from_unixtime(create_time),'.$format. ') as awdate')
            ->group('awdate, goods_unit')->order('awdate ASC')
            ->select();
        $sdata = $smodel->field('sum(count) as total_count,min(base_price) as min_price,max(base_price) as max_price,sum(base_amount) as total_amount,goods_unit,date_format(from_unixtime(create_time),'.$format. ') as awdate')
            ->group('awdate, goods_unit')->order('awdate ASC')
            ->select();

        $statics = [];
        $saleStatics = [];
        $purchaseStatics = [];
        foreach ($pdata as $row){
            $row['price'] = $row['total_count']>0?round($row['total_amount']/$row['total_count'],2):0;
            $adate=$row['awdate'];
            if($row['goods_unit'] == $this['unit']) {
                $statics[$adate]['purchase'] = $row;
                $purchaseStatics[]=$row;
            }else{
                $statics[$adate]['other'][$row['goods_unit']]['purchase'] = $row;
            }
        }
        foreach ($sdata as $row){
            $row['price'] = $row['total_count']>0?round($row['total_amount']/$row['total_count'],2):0;
            $adate=$row['awdate'];
            if($row['goods_unit'] == $this['unit']) {
                $statics[$adate]['sale'] = $row;
                $saleStatics[]=$row;
            }else{
                $statics[$adate]['other'][$row['goods_unit']]['sale'] = $row;
            }
        }

        return compact('start_date','end_date','statics','saleStatics','purchaseStatics');
    }
}