<?php

namespace app\admin\middleware;

use think\Db;
use think\facade\Log;
use think\facade\Session;

class AuthMiddleware
{
    public function handle($request, \Closure $next)
    {
        // 从参数中初始化session
        $requestType = $request->server('HTTP_X_REQUESTED_TYPE');
        if( in_array($requestType,['Api','Desktop', 'App']) ){
            Log::record('api request');
            $token = $request->header('token');
            if(empty($token)){
                $token = $request->param('token');
            }
            if(!empty($token)){
                $exists = Db::name('managerToken')->where('token',$token)->find();
                if(!empty($exists)){
                    Session::start('token-'.$token);
                    Log::record('session started with token :'.$token);
                }
            }
            $request->isApp = true;
        }else{
            Log::record('session auto started');
            Session::start();
            $request->isApp = false;
        }

        return $next($request);
    }
}