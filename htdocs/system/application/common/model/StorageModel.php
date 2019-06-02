<?php

namespace app\common\model;


use think\Db;

class StorageModel extends BaseModel
{
    public static function getGoods($storage_ids='')
    {
        $model = Db::name('goods')->alias('goods')
            ->join('goodsStorage goodsStorage','goods.id=goodsStorage.goods_id','LEFT');
        if(!empty($storage_ids)){
            $model->whereIn('goodsStorage.storage_id',idArr($storage_ids));
        }
        return $model->group('goods.id')->field('goods.id,goods.title,sum(goodsStorage.count) as count')->select();
    }

    /**
     *
     * @param $storage_id
     * @param $goods    array goods_id,count
     * @param string $type '+' '-'
     * @return bool
     */
    public static function updateGoods($storage_id, $goods, $type='+'){
        if(!$storage_id)return false;
        $storages = Db::name('goodsStorage')->where('storage_id',$storage_id)
            ->whereIn('goods_id',array_column($goods,'goods_id'))->select();
        $storages=array_index($storages,'goods_id');
        foreach ($goods as $good){
            $count=isset($good['base_count'])?$good['base_count']:$good['count'];

            if(isset($storages[$good['goods_id']])){
                if($count<0){
                    $count = abs($count);
                    $type = $type=='+'?'-':'+';
                }
                if($type=='-'){
                    Db::name('goodsStorage')->where('storage_id', $storage_id)
                        ->where('goods_id', $good['goods_id'])
                        ->setDec('count', $count);
                }else {
                    Db::name('goodsStorage')->where('storage_id', $storage_id)
                        ->where('goods_id', $good['goods_id'])
                        ->setInc('count', $count);
                }
            }else{
                if($type=='-'){
                    $count = -$count;
                }
                Db::name('goodsStorage')->insert([
                    'storage_id'=>$storage_id,
                    'goods_id'=>$good['goods_id'],
                    'count'=>$count
                ]);
            }
        }
        return true;
    }
}