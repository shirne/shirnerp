<?php
namespace app\admin\controller;

use extcore\traits\Verify;
use think\Db;
use think\facade\Log;
use think\facade\Session;

/**
 * 后台登录
 * Class LoginController
 * @package app\admin\controller
 */
class LoginController extends BaseController {

    public function initialize()
    {
        parent::initialize();
    }

    public function token($platform, $last_token = ''){
        // todo ip 限制

        do{
            $token = sha1(config('session.sec_key').rand(1000,9999).microtime());
            $exists = Db::name('managerToken')->where('platform',$platform)->where('token', $token)->find();
        }while(!empty($exists));

        $this->assign('token', $token);
        $this->assign('is_login', 0);
        Session::start('token-'.$token);
        session('token', $token);

        $hasTokenData = false;
        if(!empty($last_token)){
            $tokenData = Db::name('managerToken')->where('platform',$platform)->where('token', $last_token)->find();
            if(!empty($tokenData)){
                if($tokenData['manager_id'] > 0){
                    $this->mid = $tokenData['manager_id'];
                    $this->manager = Db::name('Manager')->where('id',$this->mid)->find();
                    setLogin($this->manager, 0);
                    $this->manager['logintime'] = session(SESSKEY_ADMIN_LAST_TIME);
                    $this->assign('is_login', 1);
                }

                Db::name('managerToken')->where('id', $tokenData['id'])->update([
                    'token'=>$token,
                    'update_time'=>session(SESSKEY_ADMIN_LAST_TIME)
                ]);
                
                // 删除同平台其它token
                Db::name('managerToken')->where('platform',$platform)->where('manager_id', $this->mid)->where('token', '<>', $token)->delete();

                $hasTokenData = true;
            }
        }

        if(!$hasTokenData){
            Db::name('managerToken')->insert([
                'manager_id'=>0,
                'token'=>$token,
                'platform'=>$platform,
                'create_time'=>time(),
                'update_time'=>time()
            ]);
        }

        if(rand(1000,9999) > 9000){
            Db::name('managerToken')->where('update_time', '<', time() - 3600)->where('manager_id',0)->delete();
        }
        Log::record('isajax '.$this->request->isAjax());
        return $this->fetch();
    }

    /**
     * 登陆主页
     * @return mixed
     */
    public function index(){
        $this->autoLogin();
        if($this->mid){
            $this->success('已自动登录',url('admin/index/index'));
        }
        $this->assign('config',getSettings());
        return $this->fetch();
    }

    /**
     * 登陆验证
     * @param string $username 
     * @param string $password 
     * @param int $remember 
     * @return void 
     */
    public function login($username, $password, $remember = 0){
        if(!$this->request->isPost())$this->error(lang('Bad Request!'));
        $member = Db::name('Manager');
        $username =trim($username);

        if(empty($username) || empty($password)){
            $this->error(lang('Please fill in the login field!'));
        }

        //验证验证码是否正确
        if(!($this->check_verify($this->request->post()))){
            $this->error(lang('Verify code error!'));
        }

        $sess_key='back_login_error';
        $error_count=session($sess_key);
        if(is_null($error_count)){
            $error_count=0;
        }elseif($error_count>5){
            $this->error(lang('Login error of too many times!'));
        }

        $ip=$this->request->ip();
        $cache_key='back_login_error_'.str_replace(['.',':'],['_','-'],$ip);
        $iperror_count=cache($cache_key);
        if(is_null($iperror_count)){
            $iperror_count=0;
        }elseif($iperror_count>10){
            $this->error(lang('Login error of too many times!'));
        }

        //验证账号密码是否正确
        $user = $member->where('username',$username)->find();

        if(empty($user) || $user['password'] !== encode_password($password,$user['salt'])) {

            $error_count++;
            $iperror_count++;
            session($sess_key,$error_count);
            cache($cache_key,$iperror_count,['expire'=>3600]);

            if(!empty($user)){
                //登录日志
                user_log($user['id'],'login',0,['Incorrect password: %s',$password],'manager');
            }
            $this->error(lang('Account or password incorrect!')) ;
        }

        //登录成功清除限制
        session($sess_key,null);
        cache($cache_key,null);

        //验证账户是否被禁用
        if($user['status'] == 0){
            user_log($user['id'],'login',0,lang('Account is disabled!') ,'manager');
            $this->error(lang('Account is disabled, pls contact the super master!'));
        }

        //密码复杂度检查
        check_password($password);

        setLogin($user);

        if($remember){
            $this->setAutoLogin($user);
        }

        // 登录状态保存到token
        if($this->request->isApp){
            $token = session('token');
            $tokenData = Db::name('managerToken')->where('token', $token)->find();
            if(!empty($tokenData)){
                Db::name('managerToken')->where('id', $tokenData['id'])->update([
                    'manager_id'=>$user['id'],
                    'username'=>$user['username'],
                    'avatar'=>$user['avatar'],
                    'update_time'=>time()
                ]);

                // 删除同平台其它token
                Db::name('managerToken')->where('platform',$tokenData['platform'])->where('manager_id', $this->mid)->where('token', '<>', $token)->delete();
            }
        }

        $this->success(lang('Login success!'),url('Index/index'));
    }

    use Verify;

    /**
     * 验证码
     * @return \think\Response
     */
    public function verify(){
        return $this->verify_auto('backend',getSettings());
    }

    protected function check_verify($data){
        return $this->check_verify_auto('backend',$data,getSettings());
    }

    /**
     * 退出登录
     */
    public function logout(){
        clearLogin();
        $this->redirect(url('index'));
    }
}