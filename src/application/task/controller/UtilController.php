<?php

namespace app\task\controller;


use app\common\command\Install;
use app\common\model\ArticleModel;
use app\common\model\CurrencyModel;
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
        $sqls = [];
        foreach ($sqls as $sql){
            Db::execute($sql);
        }
        exit;
    }

    public function fixOrderData(){
        exit;
        $ogoods = Db::name('saleOrderGoods')->where('base_amount',0)->group('sale_order_id')->field('count(id), sale_order_id')->select();
        $orders = Db::name('saleOrder')->whereIn('id',array_column($ogoods,'sale_order_id'))->select();

        foreach ($orders as $order){
            $ogoods = Db::name('saleOrderGoods')->where('base_amount',0)->where('sale_order_id',$order['id'])->select();
            foreach ($ogoods as $goods){
                if($goods['base_amount'] == 0){
                    Db::name('saleOrderGoods')->where('id',$goods['id'])->update([
                        'base_amount'=>CurrencyModel::exchange($goods['amount'],$order['currency']),
                        'base_price'=>CurrencyModel::exchange($goods['price'],$order['currency']),
                    ]);
                }
            }
        }

        $ogoods = Db::name('purchaseOrderGoods')->where('base_amount',0)->group('purchase_order_id')->field('count(id), purchase_order_id')->select();
        $orders = Db::name('purchaseOrder')->whereIn('id',array_column($ogoods,'purchase_order_id'))->select();

        foreach ($orders as $order){
            $ogoods = Db::name('purchaseOrderGoods')->where('base_amount',0)->where('purchase_order_id',$order['id'])->select();
            foreach ($ogoods as $goods){
                if($goods['base_amount'] == 0){
                    Db::name('purchaseOrderGoods')->where('id',$goods['id'])->update([
                        'base_amount'=>CurrencyModel::exchange($goods['amount'],$order['currency']),
                        'base_price'=>CurrencyModel::exchange($goods['price'],$order['currency']),
                    ]);
                }
            }
        }
    }

    public function truncate(){
        exit;
        $tables=['customer','supplier'];
        foreach ($tables as $table) {
            Db::query('TRUNCATE TABLE `'.config('database.prefix').$table.'`');
        }
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