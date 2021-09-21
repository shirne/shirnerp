<?php

namespace app\admin\controller;


use app\admin\validate\CustomerValidate;
use app\common\model\CustomerModel;
use shirne\excel\Excel;
use think\Db;

class CustomerController extends BaseController
{
    public function search($key='',$ids = '', $is_page = 0){
        $model=Db::name('customer');
        if(!empty($key)){
            $model->where('id|title|phone','like',"%$key%");
        }
        if(!empty($ids)){
            $model->whereIn('id', idArr($ids));
        }

        $lists=$model->field('id,title,short,phone,create_time')
            ->order('id ASC')->paginate(10);

        if($is_page){
            return json(['data'=>[
                'lists'=>$lists->items(),
                'total'=>$lists->count(),
                'page'=>$lists->currentPage(),
                'total_page'=>$lists->lastPage()
            ],'code'=>1]);
        }
        return json(['data'=>$lists->items(),'code'=>1]);
    }

    /**
     * 客户列表
     * @param string $key
     * @return mixed|\think\response\Redirect
     */
    public function index($key="")
    {
        if($this->request->isPost()){
            return redirect(url('',['key'=>base64_encode($key)]));
        }
        $key=empty($key)?"":base64_decode($key);
        $model = Db::name('customer');

        if(!empty($key)){
            $model->whereLike('title|short|phone',"%$key%");
        }
        $lists=$model->order('ID DESC')->paginate(15);
        $this->assign('lists',$lists->items());
        $this->assign('total',$lists->total());
        $this->assign('total_page',$lists->lastPage());
        $this->assign('page',$this->request->isAjax()?$lists->currentPage() : $lists->render());
        return $this->fetch();
    }

    public function import($file='',$sheet=''){
        $datas = $this->uploadImport($file,$sheet);
        if(empty($datas)){
            $this->error('没有读取到数据');
        }
        $datas = $this->transData($datas,[
            'title'=>'客户名称,名称',
            'short'=>'客户简称,简称',
            'province'=>'所在省份,省份',
            'city'=>'所在城市,城市',
            'area'=>'所在地区,地区',
            'address'=>'详细地址,地址',
            'phone'=>'联系电话,电话号码,电话,手机号码,手机',
            'website'=>'客户网站,网站',
            'email'=>'客户邮箱,邮箱,Email',
            'fax'=>'客户传真,传真'
        ],'title',['short'=>'title']);
        if(empty($datas)){
            $this->error('没有匹配到数据');
        }

        //去重及去除已存在的数据
        $titles = array_column($datas,'title');
        $shorts = array_column($datas,'short');
        $exists =  Db::name('customer')->whereIn('title',$titles,'OR')
            ->whereIn('short',$shorts,'OR')
            ->select();
        if(!empty($exists)){
            $titleExists = array_column($exists,'title');
            $shortExists = array_column($exists,'short');
            foreach ($datas as $k=>$row){
                if(in_array($row['title'],$titleExists)){
                    unset($datas[$k]);
                }
                if(in_array($row['short'],$shortExists)){
                    unset($datas[$k]);
                }
            }
        }
        foreach ($datas as $k=>$row) {
            if (empty($row['title'])) {
                unset($datas[$k]);
            }
        }

        $model=new CustomerModel();
        $datas = $model->saveAll($datas);
        user_log($this->mid,['importcustomer',array_index($datas->toArray(),'id')],1,'导入客户 ' ,'manager');
        $this->success('处理成功','',['success'=>1]);
    }

    /**
     * 添加客户
     * @return mixed
     */
    public function add(){
        if ($this->request->isPost()) {
            //如果用户提交数据
            $data = $this->request->post();
            if(empty($data['short']))$data['short']=$data['title'];
            $validate=new CustomerValidate();
            $validate->setId(0);
            if (!$validate->check($data)) {
                $this->error($validate->getError());
            } else {
                $uploaded=$this->upload('customer','upload_logo');
                if(!empty($uploaded)){
                    $data['logo']=$uploaded['url'];
                }elseif($this->uploadErrorCode>102){
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }

                $result = CustomerModel::create($data);
                if ($result['id']) {
                    user_log($this->mid,['addcustomer',$result['id']],1,'创建客户 ' ,'manager');
                    $this->success(lang('Add success!'), url('customer/index'));
                } else {
                    $this->error(lang('Add failed!'));
                }
            }
        }
        $model=array('sort'=>99);
        $this->assign('model',$model);
        $this->assign('id',0);
        return $this->fetch('edit');
    }

    /**
     * 编辑客户
     * @param $id
     * @return mixed
     */
    public function edit($id)
    {
        if ($this->request->isPost()) {
            //如果用户提交数据
            $data = $this->request->post();
            if(empty($data['short']))$data['short']=$data['title'];
            $validate=new CustomerValidate();
            $validate->setId($id);
            if (!$validate->check($data)) {
                $this->error($validate->getError());
            } else {
                $delete_images=[];
                $uploaded=$this->upload('customer','upload_logo');
                if(!empty($uploaded)){
                    $data['logo']=$uploaded['url'];
                    $delete_images[]=$data['delete_logo'];
                }elseif($this->uploadErrorCode>102){
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }
                unset($data['delete_image']);

                $result = CustomerModel::update($data,['id'=>$id]);
                if ($result) {
                    delete_image($delete_images);
                    user_log($this->mid,['editcustomer',$id],1,'编辑客户 ' ,'manager');
                    $this->success(lang('Update success!'), url('customer/index'));
                } else {
                    $this->error(lang('Update failed!'));
                }
            }
        }

        $model = Db::name('customer')->find($id);
        if(empty($model)){
            $this->error('信息不存在');
        }
        $this->assign('model',$model);
        $this->assign('id',$id);
        return $this->fetch();
    }

    /**
     * 删除客户
     * @param $id
     */
    public function delete($id)
    {
        $id = intval($id);
        $hasOrder = Db::name('saleOrder')->where('customer_id',$id)->count();
        if($hasOrder){
            $this->error('已有订单，无法删除');
        }
        $model = Db::name('customer');
        $result = $model->delete($id);
        if($result){
            user_log($this->mid,['deletecustomer',$id],1,'删除客户 ' ,'manager');
            $this->success(lang('Delete success!'), url('customer/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }

    public function rank($start_date='', $end_date='')
    {

        $data = CustomerModel::ranks($start_date, $end_date);

        $this->assign('statics',$data);

        return $this->fetch();
    }

    public function rankExport($start_date='', $end_date=''){
        $statics = CustomerModel::ranks($start_date, $end_date);

        $excel=new Excel('Xlsx');

        $excel->setHeader([
            '编号','客户','单数','金额','平均金额'
        ]);
        foreach ($statics as $good){
            $excel->addRow([
                $good['customer_id'],$good['customer'],
                $good['order_count'],$good['order_amount'],
                $good['order_count']>0?round($good['order_amount']/$good['order_count'],2):0
            ]);
        }
        $datestr = '';
        if(!empty($data['start_date'])){
            $datestr = '['.$data['start_date'].'-'.$data['end_date'].']';
        }

        $excel->output('客户统计'.$datestr);
    }

    public function statics($customer_id, $start_date='', $end_date='')
    {
        $customer = CustomerModel::get($customer_id);
        if(empty($customer)){
            $this->error('参数错误');
        }
        $statics =$customer->statics($start_date, $end_date);

        $this->assign('statics',$statics);
        $this->assign('customer',$customer);

        return $this->fetch();
    }

    public function staticsExport($customer_id, $start_date='', $end_date=''){
        $customer = CustomerModel::get($customer_id);
        if(empty($customer)){
            $this->error('参数错误');
        }
        $statics =$customer->statics($start_date, $end_date);

        $excel=new Excel('Xlsx');

        $excel->setHeader([
            '客户','日期','采购单数','采购总金额','订单均额'
        ]);
        foreach ($statics as $item){
            $excel->addRow([
                $customer['title'],$item['awdate'],
                $item['order_count'],$item['order_amount'],
                $item['order_count']>0?round($item['order_amount']/$item['order_count']):0
            ]);
        }
        $datestr = '';
        if(!empty($data['start_date'])){
            $datestr = '['.$data['start_date'].'-'.$data['end_date'].']';
        }

        $excel->output('['.$customer['title'].']统计'.$datestr);
    }
}