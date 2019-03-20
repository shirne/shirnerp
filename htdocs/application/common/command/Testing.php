<?php

namespace app\common\command;


use app\common\facade\OrderFacade;
use app\common\model\MemberModel;
use think\console\Command;
use think\console\Input;
use think\console\input\Argument;
use think\console\input\Option;
use think\console\Output;
use think\Db;

/**
 * 测试用例
 * Class Testing
 * @package app\common\command
 */
class Testing extends Command
{
    protected function configure()
    {
        $this->setName('testing')
            ->addArgument('action', Argument::REQUIRED, "add front member")
            ->addOption('username', 'u', Option::VALUE_OPTIONAL, 'username, usefor prefix if count great then 1')
            ->addOption('count', 'c', Option::VALUE_OPTIONAL, 'count of user, default 1')
            ->addOption('password', 's', Option::VALUE_OPTIONAL, 'password of all user, default 123456')
            ->addOption('parent', 'p', Option::VALUE_OPTIONAL, 'reference of the users.')
            ->setDescription('Testing command');
    }

    /**
     * 命令调度
     * @param Input $input
     * @param Output $output
     * @return mixed
     */
    protected function execute(Input $input, Output $output)
    {
        $action=$input->getArgument('action');

        if(method_exists($this,'action'.ucfirst($action))){
            call_user_func([$this,'action'.ucfirst($action)],$input,$output);
        }else{
            $output->error('act error. excepted actions: random, adduser, resetrcount');
        }
        $output->writeln('exit.');
    }

    /**
     * 重置会员的推荐人数目
     * @param Input $input
     * @param Output $output
     */
    protected function actionResetrcount(Input $input, Output $output)
    {
        Db::name('member')->where('id','GT',0)->update(['recom_count'=>0,'team_count'=>0]);
        $members=Db::name('member')->field('id,referer')
            ->where('is_agent','GT',0)
            ->where('referer','GT',0)
            ->select();
        $layer=getSetting('performance_layer');
        foreach ($members as $member){
            $parents=getMemberParents($member['id'],$layer);
            if(!empty($parents)) {
                Db::name('member')->where('id', $parents[0])->setInc('recom_count', 1);
                Db::name('member')->whereIn('id', $parents)->setInc('team_count', 1);
                $output->writeln('user '.$member['id'].'\'s parents recommend count updated');
            }else{
                $output->error('user '.$member['id'].'\'s parent '.$member['referer'].' not found');
            }
        }
    }

    /**
     * 随机数据测试
     * @param Input $input
     * @param Output $output
     */
    protected function actionRandom(Input $input, Output $output)
    {
        $pid=0;
        if($input->hasOption('buyproduct')){
            $pid=$input->getOption('buyproduct');
        }

        $count=$input->getOption('count');
        while($count--){
            $member=Db::name('member')->where('is_agent','GT',0)->order(Db::raw('rand()'))->find();

            $output->writeln('用户 '.$member['username'].'['.$member['id'].'] 推荐了新会员:');

            $newname='u'.random_str(mt_rand(5,8));
            while(Db::name('member')->where('username',$newname)->count()){
                $newname='u'.random_str(mt_rand(5,8));
            }

            $this->createUser($output,$newname,'123456',$member['id']);

            sleep(1);
        }

    }

    /**
     * 添加会员的命令
     * @param Input $input
     * @param Output $output
     */
    protected function actionAdduser(Input $input, Output $output)
    {
        if(!$input->hasOption('username')){
            $output->error('username option must be specified.');
            return;
        }
        $username=$input->getOption('username');
        $count=1;
        $password='123456';
        $parent=0;
        $address=[];
        if($input->hasOption('count')){
            $count=intval($input->getOption('count'));
        }
        if($input->hasOption('password')){
            $password=intval($input->getOption('password'));
        }
        if($input->hasOption('parent')){
            $parent=intval($input->getOption('parent'));
        }

        if($count<=1){
            $this->createUser($output,$username,$password,$parent);
        }else{
            for($i=0;$i<$count;$i++){
                $sufix=str_pad($i,strlen($count),'0',STR_PAD_LEFT);
                $address['recive_name']=$username.$sufix;
                $this->createUser($output,$username.$sufix,$password,$parent);
            }
        }
    }


    /**
     * 创建一个会员，如果指定了商品id，则顺便下单购买了
     * @param Output $output
     * @param $username
     * @param $password
     * @param $parent
     * @return bool
     */
    private function createUser(Output $output,$username,$password,$parent)
    {
        $data['username']=$username;
        $data['salt']=random_str(8);
        $data['password']=encode_password($password,$data['salt']);
        $data['referer']=$parent;
        $data['level_id']=getDefaultLevel();
        $model=MemberModel::create($data);
        if(empty($model['id'])){
            $output->error('创建用户 '.$username.' 失败！');
            return false;
        }
        $output->writeln('成功添加用户 '.$username.'['.$model['id'].']');

        return true;
    }

}