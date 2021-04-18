<?php

namespace app\common\model;

use think\Db;
use think\Exception;
use think\facade\Log;
use think\Model;

/**
 * 数据模型基类
 * Class BaseModel
 * @package app\common\model
 */
class BaseModel extends Model
{
    public static function getActions()
    {
        return [];
    }

    public static function getLogs($id)
    {
        $actions = [];
        if(empty($actions)){
            return [];
        }
        $logs = Db::view('managerLog',['*','date_format(from_unixtime(managerLog.`create_time`),\'%Y-%m-%d %H:%i:%S\')'=>'datetime'])
            ->view('manager',['username','realname'],'manager.id=managerLog.manager_id','LEFT')
            ->whereIn('action',static::getActions())
            ->where('other_id',$id)
            ->order('managerLog.create_time ASC')
            ->select();
        foreach ($logs as &$log) {
            $log['remark']=print_remark($log['remark']);
        }
        return $logs;
    }

    protected function getRelationAttribute($name, &$item)
    {
        try{
            return parent::getRelationAttribute($name, $item);
        }catch (\InvalidArgumentException $e){
            Log::record($e->getMessage(),\think\Log::NOTICE);
            return null;
        }
    }

    protected static function create_no($pk='id'){
        $maxid=static::field('max('.$pk.') as maxid')->find();
        $maxid = $maxid['maxid'];
        if(empty($maxid))$maxid=0;
        return date('YmdHis').self::pad_orderid($maxid+1,4);
    }

    private static function pad_orderid($id,$len=4){
        $strlen=strlen($id);
        return $strlen<$len?str_pad($id,$len,'0',STR_PAD_LEFT):substr($id,$strlen-$len);
    }

    protected static $instances=[];

    /**
     * @return static
     */
    public static function getInstance()
    {
        $class = get_called_class();
        if(!isset(self::$instances[$class])){
            self::$instances[$class] = new static();
        }
        return self::$instances[$class];
    }

    protected function triggerStatus($item,$status)
    {}

    /**
     * 用于更新需要触发状态改变的表
     * @param $toStatus int|array
     * @param $where string|array|int
     * @throws Exception
     */
    public function updateStatus($toStatus,$where=null){
        if(is_array($toStatus)){
            $data=$toStatus;
        }else{
            $data['status']=$toStatus;
        }
        if(empty($where)) {
            if($this->isExists()){
                $odata=$this->getOrigin();
                Db::name($this->name)->where($this->getWhere())->update($data);
                if ($odata['status'] != $data['status']) {
                    $this->triggerStatus($odata, $data['status']);
                }
            }else{
                throw new Exception('Update status with No data exists');
            }
        }else {
            $lists = Db::name($this->name)->where($where)->select();
            Db::name($this->name)->where($where)->update($data);
            foreach ($lists as $item) {
                if ($item['status'] != $data['status']) {
                    $this->triggerStatus($item, $data['status']);
                }
            }
        }
    }
}