<?php

use think\Db;
use think\facade\Request;

define('SESSKEY_ADMIN_ID','adminId');
define('SESSKEY_ADMIN_NAME','adminname');
define('SESSKEY_ADMIN_LAST_TIME','adminLTime');
define('SESSKEY_ADMIN_AUTO_LOGIN','adminlogin');

function setLogin($user, $logintype = 1, $isApp = false){
    $time=time();
    session(SESSKEY_ADMIN_ID,$user['id']);
    session(SESSKEY_ADMIN_LAST_TIME,$time);
    session(SESSKEY_ADMIN_NAME,empty($user['realname'])?$user['username']:$user['realname']);
    if(!$isApp){
        Db::name('Manager')->where('id',$user['id'])->update(array(
            'login_ip'=>Request::ip(),
            'logintime'=>$time
        ));
    }
    if($logintype == 1){
        user_log($user['id'],'login',1,'登录成功' ,'manager');
    }else{
        user_log($user['id'],'login',1,'自动登录成功' ,'manager');
    }
}

function filterurl($url){
    //只保留本站url
    if(!preg_match('/^\/[a-zA-Z0-9\-_\.\/]+$/',$url)){
        return '';
    }
    return $url;
}

function clearLogin($log=true){
    $id=session(SESSKEY_ADMIN_ID);
    if($log && !empty($id)) {
        user_log($id, 'logout', 1, '退出登录');
    }

    session(SESSKEY_ADMIN_ID,null);
    session(SESSKEY_ADMIN_NAME,null);
    session(SESSKEY_ADMIN_LAST_TIME,null);
}

function getMenus(){
    $menus=cache('menus');
    if(empty($menus)){
        $list=Db::name('permission')->where('disable',0)->order('parent_id ASC,sort_id ASC,id ASC')->select();
        $menus=array();
        foreach ($list as $item){
            $menus[$item['parent_id']][]=$item;
        }

        cache('menus',$menus,1800);
    }
    return $menus;
}

function check_password($password){
    if(in_array($password,['123456','654321','admin','abc123','123abc','12345678','123456789'])){
        session('password_error',1);
    }elseif(preg_match('/^([0-9])\\1*$/',$password)){
        session('password_error',2);
    }elseif(preg_match('/^[0-9]*$/',$password)){
        session('password_error',3);
    }elseif(preg_match('/^([a-zA-Z])\\1*$/',$password)){
        session('password_error',4);
    }else{
        session('password_error',null);
    }
}

function FU($url='',$vars=''){

    $link=url($url,$vars);

    return str_replace(app()->getModulePath(),'',$link);
}

function delete_image($images){
    if(is_array($images)){
        foreach ($images as $image){
            delete_image($image);
        }
    }else{
        if(!empty($images) && strpos($images,'/uploads/')===0){
            @unlink('.'.$images);
        }
    }
}


function list_empty($col=5){
    return '<tr><td colspan="'.$col.'" class="text-center text-muted">暂时没有记录</td></tr>';
}

function show_finance($finance){
    $items=[];
    foreach ($finance as $c=>$item){
        $items[]='<span class="badge badge-secondary">'.$c.'</span> '.$item;
    }

    return empty($items)?'-':implode("<br />",$items);
}
//end file