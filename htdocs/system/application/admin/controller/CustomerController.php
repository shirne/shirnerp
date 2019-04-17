<?php

namespace app\admin\controller;


use app\admin\validate\CustomerValidate;
use app\common\model\CustomerModel;
use shirne\excel\Excel;
use think\Db;

class CustomerController extends BaseController
{
    public function search($key=''){
        $model=Db::name('customer');
        if(!empty($key)){
            $model->where('id|title|phone','like',"%$key%");
        }

        $lists=$model->field('id,title,short,phone,create_time')
            ->order('id ASC')->limit(20)->select();


        return json(['data'=>$lists,'code'=>1]);
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
        $this->assign('lists',$lists);
        $this->assign('page',$lists->render());
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

        $model=new CustomerModel();
        $model->saveAll($datas);

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
            $this->success(lang('Delete success!'), url('customer/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}