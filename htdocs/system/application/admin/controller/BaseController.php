<?php

namespace app\admin\controller;

use extcore\traits\Upload;
use shirne\excel\Excel;
use think\Controller;
use think\Db;
use think\facade\Env;

/**
 * 后台基类
 * 自带基于方法名的权限验证
 * Class BaseController
 * @package app\admin\controller
 */
class BaseController extends Controller {

    use Upload;

    protected $errMsg;
    protected $table;
    protected $model;

    protected $mid;
    protected $manage;
    protected $permision;

    protected $viewData=[];

    public function initialize(){
        parent::initialize();

        $this->mid = session('adminId');
        //判断用户是否登陆
        if(empty($this->mid ) ) {
            $this->error(lang('Please login first!'),url('admin/login/index'));
        }
        $this->manage=Db::name('Manager')->find($this->mid);
        if(empty($this->manage)){
            clearLogin();
            $this->error(lang('Invalid account!'),url('admin/login/index'));
        }
        if($this->manage['logintime']!=session('adminLTime')){
            clearLogin();
            $this->error(lang('The account has login in other places!'),url('admin/login/index'));
        }

        $controller=strtolower($this->request->controller());
        if($controller!='index'){
            $action=strtolower($this->request->action());
            if($this->request->isPost() || $action=='add' || $action=='update'){
                $this->checkPermision("edit");
            }
            if(strpos('del',$action)!==false || strpos('clear',$action)!==false){
                $this->checkPermision("del");
            }

            $this->checkPermision($controller.'_'.$action);
        }

        if(!$this->request->isAjax()) {
            $this->assign('menus', getMenus());

            //空数据默认样式
            $this->assign('empty', list_empty());
        }
    }

    /**
     * 检查权限
     * @param $permitem
     */
    protected function checkPermision($permitem){
        if($this->getPermision($permitem)==false){
            $this->error(lang('You have no permission to do this operation!'));
        }
    }

    /**
     * 检查是否有权限
     * @param $permitem
     * @return bool
     */
    protected function getPermision($permitem)
    {
        if($this->manage['type']==1){
            return true;
        }
        if(empty($this->permision)){
            $this->permision=Db::name('ManagerPermision')->where('manager_id',$this->mid)->find();
            if(empty($this->permision)){
                $this->error(lang('Bad permission settings, pls contact the manager!'));
            }
            $this->permision['global']=explode(',',$this->permision['global']);
            $this->permision['detail']=explode(',',$this->permision['detail']);
        }
        if(strpos($permitem,'_')>0){
            if(in_array($permitem,$this->permision['detail']))return true;
        }else{
            if(in_array($permitem,$this->permision['global']))return true;
        }
        return false;
    }

    /**
     * 兼容ajax的数据注册
     * @param mixed $name
     * @param string $value
     * @return $this
     */
    protected function assign($name, $value = '')
    {
        if($this->request->isAjax()) {
            if (is_array($name)) {
                $this->viewData = array_merge($this->viewData, $name);
            } else {
                $this->viewData[$name] = $value;
            }
        }else{
            $this->view->assign($name, $value);

        }

        return $this;
    }

    /**
     * 兼容ajax的输出
     * @param string $template
     * @param array $vars
     * @param array $config
     * @return mixed
     */
    protected function fetch($template = '', $vars = [], $config = [])
    {
        if($this->request->isAjax()){
            $this->result($this->viewData,1);
        }

        return $this->view->fetch($template, $vars, $config);
    }

    protected function uploadImport($file='',$sheet='')
    {
        if($this->request->isPost()){
            $uploaded=$this->uploadFile('excel','uploadFile');
            if(!empty($uploaded)){
                if(!in_array(strtolower($uploaded['extension']),['xls','xlsx'])){
                    $this->error('请上传Excel文件');
                }
                $file = $uploaded['url'];
            }else{
                $this->error('文件上传失败:'.$this->uploadError);
            }
        }

        $extension = substr($file,strrpos('.',$file)+1);
        $excel = new Excel($extension=='xls'?'Xls':'Xlsx');
        $excel->load('.'.$file);
        $names = $excel->getSheets();
        if(count($names) == 1)$sheet=$names[0];
        if(empty($sheet)){
            $this->result(['file'=>$file,'sheets'=>$excel->getSheets()],1);
        }

        $excel->setSheet($sheet);
        $data = $excel->read();

        return $data;
    }

    protected function transData($datas,$headers){
        $rows=[];
        $headermap=[];
        foreach ($datas as $i=>$item){
            if(empty($headermap)){
                foreach ($item as $k=>$v){
                    foreach ($headers as $key=>$match){
                        if(in_array($key,$headermap))continue;
                        if(in_array($v,explode(',',$match))){
                            $headermap[$k]=$key;
                            break;
                        }
                    }
                }
                if($i>10){
                    return false;
                }
            }else{
                $row=[];
                foreach ($item as $k=>$v) {
                    if(isset($headermap[$k])) {
                        $row[$headermap[$k]] = $v;
                    }
                }
                $rows[]=$row;
            }
        }
        return $rows;
    }
}