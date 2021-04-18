<?php

namespace app\common\model;


use think\Db;

class CurrencyModel extends BaseModel
{
    private static $cache_key='currencies';
    private static $currencies;

    public static function init()
    {
        parent::init();

        self::afterWrite(function ( $model) {
            if ($model['is_base']) {
                $current = Db::name('currency')->where($model->getWhere())->find();
                if($current) {
                    Db::name('currency')->where('id', 'NEQ', $current['id'])->update(['is_base' => 0]);
                }
            }
            self::clearCache();
        });
    }

    public static function getCurrency($key)
    {
        $currencies = self::getCurrencies();
        return $currencies[$key]?:[];
    }

    public static function getCurrencies($force = false)
    {
        if($force)self::clearCache();

        if (empty(self::$currencies)) {
            self::$currencies = cache(self::$cache_key);
            if (empty(self::$currencies)) {
                $data =  Db::name('currency')->order('sort ASC,id ASC')->select();
                self::$currencies=array_index($data,'key');
                cache(self::$cache_key, self::$currencies);
            }
        }
        return self::$currencies;
    }

    public static function clearCache(){
        self::$currencies=null;
        cache(self::$cache_key, NULL);
    }


    /**
     * 转换为基准货币
     * @param $amount
     * @param $currency
     */
    public static function exchange($amount,$currency)
    {
        $currencies = self::getCurrencies();
        $cur = $currencies[$currency];
        if($cur){
            $amount = $amount * $cur['exchange_rate'];
        }
        return $amount;
    }
}