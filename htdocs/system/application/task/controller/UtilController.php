<?php

namespace app\task\controller;


use app\common\command\Install;
use app\common\model\ArticleModel;
use app\common\model\MemberRechargeModel;
use app\common\model\PayOrderModel;
use app\common\model\ProductModel;
use think\Console;
use think\console\Input;
use think\console\Output;
use think\Controller;
use think\Db;
use think\Response;

class UtilController extends Controller
{
    public function cropimage($img){
        return crop_image($img,$_GET);
    }

    public function cacheimage($img){
        $paths=explode('.',$img);
        if(count($paths)==3) {
            preg_match_all('/(w|h|q|m)(\d+)(?:_|$)/', $paths[1], $matches);
            $args = [];
            foreach ($matches[1] as $idx=>$key){
                $args[$key]=$matches[2][$idx];
            }
            $response = crop_image($paths[0].'.'.$paths[2], $args);
            if($response->getCode()==200) {
                file_put_contents(DOC_ROOT . '/' . $img, $response->getData());
            }
            return $response;
        }else{
            return redirect(ltrim(config('upload.default_img'),'.'));
        }
    }

    public function updatedb()
    {
        $sqls = ["ALTER TABLE `sa_currency` ADD `is_base` tinyint(11) DEFAULT 0 COMMENT '基准货币' AFTER `icon`,
ADD `exchange_rate` DECIMAL(10,4) DEFAULT 1 COMMENT '汇率' AFTER `is_base`;",
            "ALTER TABLE `sa_purchase_order` ADD `base_amount` DECIMAL(14,2) DEFAULT '0' AFTER `currency`;",
            "ALTER TABLE `sa_sale_order` ADD `base_amount` DECIMAL(14,2) DEFAULT '0' AFTER `currency`;",
            "ALTER TABLE `sa_purchase_order_goods` ADD `base_price` DECIMAL(14,2) DEFAULT '0' AFTER `price`;",
            "ALTER TABLE `sa_sale_order_goods` ADD `base_price` DECIMAL(14,2) DEFAULT '0' AFTER `price`;",
            "ALTER TABLE `sa_finance_log` ADD `base_amount` DECIMAL(14,2) DEFAULT '0' AFTER `currency`;",
            "CREATE TABLE `sa_currency_rate` (
  `id` bigint(11) NOT NULL AUTO_INCREMENT,
  `currency` varchar(20) DEFAULT NULL COMMENT '币种编码',
  `exchange_rate` DECIMAL(10,4) DEFAULT 1 COMMENT '汇率',
  `create_time` int(11) DEFAULT 0 COMMENT '时间',
  PRIMARY KEY (`id`),
  KEY `currency` (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;"];
        foreach ($sqls as $sql){
            Db::execute($sql);
        }
        exit;
    }

    public function daily()
    {
        # code...
        $rows = Db::name('product')->whereLike('title',["%1%","%2%"],'AND')->select();
        var_export($rows);
        $instance=ProductModel::getInstance();
        echo $instance->getName();
        $instance=ArticleModel::getInstance();
        echo $instance->getName();
    }

    public function install($sql='',$mode='')
    {
        $console=Console::init(false);
        $output=new Output('buffer');
        $args=['install'];
        if(!empty($sql)){
            $args[]='--sql';
            $args[]=$sql;
        }
        if(!empty($mode)){
            $args[]='--mode';
            $args[]=$mode;
        }
        if($this->request->has('admin','post')){
            $args[]='--admin';
            $args[]=$this->request->post('admin');
        }
        if($this->request->has('password','post')){
            $args[]='--password';
            $args[]=$this->request->post('password');
        }
        $input=new Input($args);

        $console->doRun($input, $output);
        return $output->fetch();
    }

}