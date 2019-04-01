<?php

namespace app\common\model;


use think\Db;

class StorageModel extends BaseModel
{
    /**
     *
     * @param $storage_id
     * @param $goods    array goods_id,count
     * @param string $type '+' '-'
     * @return bool
     */
    public static function updateGoods($storage_id, $goods, $type='+'){

        $storages = Db::name('goodsStorage')->where('storage_id',$storage_id)
            ->whereIn('goods_id',array_column($goods,'goods_id'))->select();
        $storages=array_index($storages,'goods_id');
        foreach ($goods as $good){
            $count=$good['count'];

            if(isset($storages[$good['goods_id']])){
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