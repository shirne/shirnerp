<?php

namespace app\admin\controller;

use app\admin\model\ManagerModel;
use app\admin\validate\ManagerValidate;
use app\common\command\Manager;
use think\Db;


/**
 * 管理员管理
 * Class ManagerController
 * @package app\admin\controller
 */
class ManagerController extends BaseController
{

    /**
     * 用户列表
     * @param string $key
     * @return mixed|\think\response\Redirect
     */
    public function index($key = "")
    {
        if ($this->request->isPost() && !$this->request->isAjax()) {
            return redirect(url('', ['key' => base64url_encode($key)]));
        }
        $key = empty($key) ? "" : base64url_decode($key);
        $model = Db::name('Manager')->hidden(['password','salt']);
        if (!empty($key)) {
            $model->whereLike('username|email',"%$key%");
        }

        $lists = $model->order('ID ASC')->paginate(15);

        if (!$lists->isEmpty()) {
            $ids = array_column($lists->items(), 'id');
            $logins = Db::name('managerToken')->whereIn('manager_id', $ids)
            ->field('id,manager_id,platform,create_time,update_time,login_ip')->select();
            $logins = array_index($logins, 'manager_id', true);
            $lists->each(function ($item) use ($logins) {
                if (isset($logins[$item['id']])) {
                    $item['logined_count'] = count($logins[$item['id']]);
                    $item['logins'] = $logins[$item['id']];
                }
                return $item;
            });
        }

        $this->assign('lists', $lists->items());
        $this->assign('total', $lists->total());
        $this->assign('total_page', $lists->lastPage());
        $this->assign('page', $this->request->isAjax() ? $lists->currentPage() : $lists->render());
        return $this->fetch();
    }

    /**
     * 管理员日志
     * @param string $key
     * @param string $type
     * @param int $member_id
     * @return mixed
     */
    public function log($key = '', $type = '', $manager_id = 0)
    {
        if ($this->request->isPost()) {
            return redirect(url('', ['key' => base64_encode($key)]));
        }

        $model = Db::view('ManagerLog', '*')
            ->view('Manager', ['username'], 'ManagerLog.manager_id=Manager.id', 'LEFT');

        if (!empty($key)) {
            $key = base64_decode($key);
            $model->whereLike('ManagerLog.remark', "%$key%");
        }
        if (!empty($type)) {
            $model->where('action', $type);
        }
        if ($manager_id != 0) {
            $model->where('manager_id', $manager_id);
        }

        $logs = $model->order('ManagerLog.id DESC')->paginate(15);
        $this->assign('lists', $logs->items());
        $this->assign('keyword', $key);
        $this->assign('total',$logs->total());
        $this->assign('total_page',$logs->lastPage());
        $this->assign('page',$this->request->isAjax()?$logs->currentPage() : $logs->render());
        return $this->fetch();
    }

    /**
     * 日志详情
     * @param $id
     * @return mixed
     */
    public function logview($id)
    {

        $model = Db::name('ManagerLog')->find($id);
        $manager = Db::name('Manager')->find($model['manager_id']);

        $this->assign('model', $model);
        $this->assign('manager', $manager);
        return $this->fetch();
    }

    /**
     * 清除日志
     */
    public function logclear()
    {
        $date = $this->request->get('date');
        $d = strtotime($date);
        if (empty($d)) {
            $d = strtotime('-7days');
        }

        Db::name('ManagerLog')->where('create_time', 'ELT', $d)->delete();
        user_log($this->mid, 'clearlog', 1, '清除日志', 'manager');
        $this->success("清除完成");
    }

    /**
     * 添加
     * @return mixed
     */
    public function add()
    {
        if ($this->request->isPost()) {

            $data = $this->request->post();
            $validate = new ManagerValidate();
            $validate->setId();
            if (!$validate->check($data)) {
                $this->error($validate->getError());
                exit();
            } else {
                $data['salt'] = random_str(8);
                $data['password'] = encode_password($data['password'], $data['salt']);
                $data['last_view_member'] = time();
                if ($this->manager['type'] > $data['type']) {
                    $this->error('您没有权限添加该类型账号');
                }
                $data['pid'] = $this->mid;
                unset($data['repassword']);
                $model = ManagerModel::create($data);
                if ($model->id) {
                    user_log($this->mid, 'addmanager', 1, '添加管理员' . $model->id, 'manager');
                    $this->success(lang('Add success!'), url('manager/index'));
                } else {
                    $this->error(lang('Add failed!'));
                }
            }
        }
        $model = array('type' => 2, 'status' => 1);
        $this->assign('model', $model);
        return $this->fetch('update');
    }

    /**
     * 修改
     * @param $id
     * @return mixed
     */
    public function update($id)
    {
        $id = intval($id);
        if ($id == 0) $this->error('参数错误');
        $model = ManagerModel::where('id',$id)->hidden(['password','salt'])->find();
        if ($this->manager['type'] > $model['type']) {
            $this->error('您没有权限查看该管理员');
        }

        if ($this->request->isPost()) {
            if (!$model->hasPermission($this->mid)) {
                $this->error('您没有权限编辑该管理员资料');
            }
            $data = $this->request->post();
            $validate = new ManagerValidate();
            $validate->setId($id);
            if (!$validate->scene('edit')->check($data)) {
                $this->error($validate->getError());
            } else {
                if (!empty($data['password'])) {

                    if (
                        TEST_ACCOUNT == $model['username'] &&
                        TEST_ACCOUNT == $this->manager['username']
                    ) {
                        $this->error('演示账号，不可修改密码');
                    }
                    $data['salt'] = random_str(8);
                    $data['password'] = encode_password($data['password'], $data['salt']);
                } else {
                    unset($data['password']);
                }
                if ($this->manager['type'] > $data['type']) {
                    $this->error('您不能将该管理员设置为更高级的管理员');
                }

                //强制更改超级管理员用户类型
                if (SUPER_ADMIN_ID == $id) {
                    $data['type'] = 1;
                } else {
                    $parent = Db::name('manager')->where('id', $model['pid'])->find();
                    if (!empty($parent)) {
                        if ($data['type'] < $parent['type']) {
                            $this->error('不能将管理员类型设置为比上级高的类型');
                        }
                    }
                }

                //更新
                if ($model->allowField(true)->update($data)) {
                    user_log($this->mid, 'addmanager', 1, '修改管理员' . $model->id, 'manager');
                    $this->success(lang('Update success!'), url('manager/index'));
                } else {
                    $this->error(lang('Update failed!'));
                }
            }
        }

        $this->assign('model', $model);
        $this->assign('logins',Db::name('managerToken')->where('manager_id',$model->id)
            ->field('id,manager_id,platform,create_time,update_time,login_ip')->select());
        return $this->fetch();
    }

    /**
     * 清除app登录
     * @param mixed $id 
     * @return void 
     */
    public function clear($id){
        $login = Db::name('managerToken')->where('id',$id)->find();
        if(empty($login) || empty($login['manager_id'])){
            $this->error('登录记录错误');
        }
        $model = ManagerModel::where('id',$login['manager_id'])->find();
        if (empty($model)) {
            $this->error('管理员资料错误');
        }
        if (!$model->hasPermission($this->mid)) {
            $this->error('您没有权限管理该管理员资料');
        }
        Db::name('managerToken')->where('id',$id)->delete();

        user_log($this->mid, 'loginclear', 1, '清除登录信息'.$login['platform'].'/' . $model->id, 'manager');
        $this->success('清除成功');
    }

    /**
     * 管理员权限
     * @param $id
     * @return mixed
     */
    public function permision($id)
    {
        $id = intval($id);
        if ($id == 0) $this->error('参数错误');
        $manager = ManagerModel::get($id);
        if (empty($manager)) {
            $this->error('管理员资料错误');
        }
        if (!$manager->hasPermission($this->mid)) {
            $this->error('您不能编辑该管理员的权限');
        }
        $model = Db::name('ManagerPermision')->where('manager_id', $id)->find();
        if (empty($model)) {
            $model = array();
            $model['manager_id'] = $id;
            $model['global'] = '';
            $model['detail'] = '';
            $model['id'] = Db::name('manager_permision')->insert($model, false, true);
        }
        if ($this->request->isPost()) {
            $model['global'] = $_POST['global'];
            if (!is_array($model['global'])) $model['global'] = array();
            $model['global'] = implode(',', $model['global']);
            $model['detail'] = $_POST['detail'];
            if (!is_array($model['detail'])) $model['detail'] = array();
            $model['detail'] = implode(',', $model['detail']);
            if (Db::name('ManagerPermision')->update($model)) {
                user_log($this->mid, 'managerpermission', 1, '编辑权限'. $model->id, 'manager');
                $this->success(lang('Update success!'), url('manager/index'));
            } else {
                $this->error(lang('Update failed!'));
            }
        }
        $model['global'] = explode(',', $model['global']);
        $model['detail'] = explode(',', $model['detail']);
        $this->assign('model', $model);
        $this->assign('perms', config('permisions.'));
        return $this->fetch();
    }

    /**
     * 删除管理员
     * @param $id
     */
    public function delete($id)
    {
        $id = intval($id);
        if (1 == $id) $this->error("超级管理员不可禁用!");

        //查询status字段值
        $result = ManagerModel::where('id', $id)->find();
        $data = array();
        if ($result['status'] == 1) {
            $data['status'] = 0;
        }
        if ($result['status'] == 0) {
            $data['status'] = 1;
        }
        if ($result->save($data)) {
            user_log($this->mid, 'managerstatus', 1, ($data['status'] == 1?'启用':'禁用').'管理员'. $id, 'manager');
            $this->success(lang('Update success!'), url('manager/index'));
        } else {
            $this->error(lang('Update failed!'));
        }
    }
}
