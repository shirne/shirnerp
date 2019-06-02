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
        $sqls = ["UPDATE sa_permission set `url`='Index/dashboard' where `id`=1",
            "ALTER TABLE sa_sale_order_goods ADD `base_count` DECIMAL(14,2) DEFAULT '0' AFTER `count`",
            "ALTER TABLE sa_purchase_order_goods ADD `base_count` DECIMAL(14,2) DEFAULT '0' AFTER `count`"];
        foreach ($sqls as $sql){
            Db::execute($sql);
        }
        exit;
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