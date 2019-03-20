<?php

namespace app\common\model;


use think\Db;

/**
 * Class AdvGroupModel
 * @package app\common\model
 */
class AdvGroupModel extends BaseModel
{
    public static function getAdList($flag,$limit=10)
    {
        $model=self::get(['flag'=>$flag]);
        if(empty($model)){
            return [];
        }
        $time=strtotime(date('Y-m-d'));
        return Db::name('AdvItem')
            ->where('group_id',$model->id)
            ->where('status',1)
            ->where('start_date',['=',0],['<=',$time],'OR')
            ->where('end_date',['=',0],['>=',$time],'OR')
            ->order('sort ASC, id DESC')
            ->limit($limit)
            ->select();
    }

    public static function getAdItem($flag)
    {
        $model=self::get(['flag'=>$flag]);
        if(empty($model)){
            return [];
        }
        $time=strtotime(date('Y-m-d'));
        return Db::name('AdvItem')
            ->where('group_id',$model->id)
            ->where('status',1)
            ->where('start_date',['=',0],['<=',$time],'OR')
            ->where('end_date',['=',0],['>=',$time],'OR')
            ->order('sort ASC, id DESC')
            ->find();
    }
}