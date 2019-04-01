<?php

namespace app\admin\controller;

use app\admin\model\SettingModel;
use app\admin\validate\SettingValidate;
use think\Db;

/**
 * 配置管理
 * Class SettingController
 * @package app\admin\controller
 */
class SettingController extends BaseController
{
    /**
     * 配置设置
     * @param string $group
     * @return mixed
     */
    public function index($group="")
    {
        if($this->request->isPost()){
            $this->checkPermision("setting_update");
            $data=$this->request->post();
            $settings=getSettings(true,false,true);
            foreach ($data as $k=>$v){
                if(substr($k,0,2)=='v-'){
                    $key=substr($k,2);
                    if(is_array($v))$v=serialize($v);
                    if(isset($settings[$key]) && $settings[$key]['value']!=$v) {
                        Db::name('setting')->where('key', $key)->update(array('value' => $v));
                    }
                }
            }
            $delete_images=[];
            $errmsgs=[];
            foreach ($settings as $k=>$row){
                if($row['type']=='image'){
                    $uploaded=$this->upload('setting','upload_'.$k);
                    if($uploaded){
                        Db::name('setting')->where('key', $k)->update(array('value' => $uploaded['url']));
                        $delete_images[]=$data['delete_'.$k];
                    }elseif($this->uploadErrorCode>102){
                        $errmsgs[]=$row['title'].':'.$this->uploadError;
                    }
                }
            }
            cache('setting',null);
            user_log($this->mid,'sysconfig',1,'修改系统配置' ,'manager');
            delete_image($delete_images);
            $this->success('配置已更新<br />'.implode(',',$errmsgs),url('setting/index',array('group'=>$group)));
        }
        $this->assign('group',$group);
        $this->assign('groups', settingGroups());
        $this->assign('settings',getSettings(true,true));
        return $this->fetch();
    }

    /**
     * 清除缓存
     */
    public function refresh(){
        cache('setting',null);
        $this->success("刷新成功",url('setting/index'));
    }

    /**
     * 导入配置
     */
    public function import(){
        $type=$this->request->post('type');
        if($type=='content') {
            $json = $this->request->post('content');
            if(empty($json)){
                $this->error('请将配置文件内容粘贴在输入框内');
            }
        }else{
            $file=$this->uploadFile('cache','contentFile',false);
            if($file){
                $json=file_get_contents('.'.$file['url']);
                if(empty($json)){
                    $this->error('配置文件内容为空');
                }
            }else{
                $this->error($this->uploadError.'(.json)');
            }
        }
        $data=json_decode($json,TRUE);
        if(empty($data)){
            $this->error('配置内容解析失败');
        }
        $model=Db::name('setting');
        $settings=getSettings(false,false,true);
        if($data['mode']=='full'){
            foreach ($data['data'] as $k=>$v){
                if(is_array($v['value']))$v['value']=serialize($v['value']);
                if(isset($settings[$k])) {
                    if($settings[$k]!=$v)$model->where('key' , $k)->update(array('value' => $v['value']));
                }else{
                    $model->setOption('data',[]);
                    if(is_array($v['data']))$v['data']=serialize($v['data']);
                    $model->insert(array(
                        'key'=>$k,
                        'title'=>$v['title'],
                        'type'=>$v['type'],
                        'group'=>$v['group'],
                        'sort'=>$v['sort'],
                        'value'=>$v['value'],
                        'description'=>$v['description'],
                        'data'=>serialize_data($v['data'])
                    ));
                }
            }
        }else{
            foreach ($data['data'] as $k=>$v){
                if(is_array($v))$v=serialize($v);
                if(isset($settings[$k])) {
                    if($settings[$k]!=$v)$model->where('key' , $k)->update(array('value' => $v));
                }else{
                    $model->setOption('data',[]);
                    $model->insert(array(
                        'key'=>$k,
                        'title'=>$k,
                        'type'=>'text',
                        'group'=>'advance',
                        'sort'=>0,
                        'value'=>$v,
                        'description'=>'',
                        'data'=>''
                    ));
                }
            }
        }
        cache('setting',null);
        $this->success('导入成功');
    }

    /**
     * 导出配置
     * @param string $mode
     * @return \think\Response
     */
    public function export($mode='simple'){
        $data=[];
        if($mode=='full'){
            $data['mode']='full';
            $data['date']=date('Y-m-d H:i:s');
            $data['data']=getSettings(true);
        }else{
            $data['mode']='simple';
            $data['date']=date('Y-m-d H:i:s');
            $data['data']=getSettings();
        }
        return file_download(json_encode($data,JSON_UNESCAPED_UNICODE),'setting.json');
    }

    /**
     * 高级模式
     * @param string $key
     * @return mixed
     */
    public function advance($key=""){

        $model = Db::name('setting');
        $where=array();
        if(!empty($key)){
            $where[] = array('key|description','like',"%$key%");
        }

        $this->assign('keyword',$key);

        $setting  = $model->where($where)->paginate(15);// 查询满足要求的总记录数

        $this->assign('model', $setting);
        $this->assign('page',$setting->render());
        return $this->fetch();
    }

    /**
     * 添加配置
     * @return mixed
     */
    public function add(){
        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new SettingValidate();
            $validate->setId();
            if (!$validate->check($data)) {
                $this->error($validate->getError());
            } else {
                if (SettingModel::create($data)) {
                    cache('setting', null);
                    $this->success(lang('Add success!'), url('setting/advance'));
                } else {
                    $this->error(lang('Add failed!'));
                }
            }

        }
        $model=array();
        $this->assign('model',$model);
        $this->assign('id',0);
        $this->assign('groups',settingGroups());
        $this->assign('types',settingTypes());
        return $this->fetch('edit');
    }

    /**
     * 编辑配置
     * @param $id
     * @return mixed
     */
    public function edit($id)
    {
        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new SettingValidate();
            $validate->setId($id);
            if (!$validate->check($data)) {

                $this->error($validate->getError());
            } else {
                $model=SettingModel::get($id);
                if ($model->allowField(true)->save($data)) {
                    cache('setting',null);
                    $this->success(lang('Update success!'), url('setting/advance'));
                } else {
                    $this->error(lang('Update failed!'));
                }

            }
        }else{
            $model = Db::name('setting')->find($id);
            if(empty($model)){
                $this->error('要修改的配置不存在');
            }
            $this->assign('model',$model);
            $this->assign('id',$id);
            $this->assign('groups',settingGroups());
            $this->assign('types',settingTypes());
            return $this->fetch();
        }
    }

    /**
     * 删除配置
     * @param $id
     */
    public function delete($id)
    {
        $id = intval($id);
        $model = Db::name('setting');

        $result = $model->delete($id);
        if($result){
            $this->success(lang('Delete success!'), url('setting/advance'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }


}
