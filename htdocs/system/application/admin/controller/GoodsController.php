<?php

namespace app\admin\controller;


use app\admin\validate\GoodsValidate;
use app\admin\validate\ImagesValidate;
use app\common\facade\GoodsCategoryFacade;
use app\common\model\GoodsCategoryModel;
use app\common\model\GoodsModel;
use shirne\common\Notation;
use shirne\excel\Excel;
use think\Db;

class GoodsController extends BaseController
{
    public function search($key='',$cate=0,$storage_id=0){
        $model=Db::name('goods');
        if(!empty($key)){
            $model->where('id|title|fullname|goods_no','like',"%$key%");
        }
        if($cate>0){
            $model->whereIn('cate_id',GoodsCategoryFacade::getSubCateIds($cate));
        }

        $lists=$model->field('id,title,goods_no,cate_id,unit,price_type,image,description,create_time')
            ->order('id ASC')->limit(10)->select();

        if(!empty($storage_id)){
            $ids = array_column($lists,'id');
            $storages = Db::name('goodsStorage')->where('storage_id',$storage_id)
                ->whereIn('goods_id',$ids)->select();
            $storages = array_index($storages,'goods_id');
            foreach ($lists as &$item){
                if($storages[$item['id']]){
                    $item['storage']=$storages[$item['id']]['count'];
                }else{
                    $item['storage']=0;
                }
            }
        }

        return json(['data'=>$lists,'code'=>1]);
    }

    //从订单中导入
    public function importOrder($file='',$sheet=''){
        $datas = $this->uploadImport($file,$sheet);
        if(empty($datas)){
            $this->error('没有读取到数据');
        }

        $headers = [
            'title'=>'品种,品名,产品',
            'count'=>'件数',
            'weight'=>'重量',
            'price'=>'单价',
            'amount'=>'金额',
            'remark'=>'备注'
        ];

        $headermap=[];
        $rows=[];

        $price_column = '';
        $weight_column = '';
        $count_column = '';
        foreach ($datas as $i=>$data){
            if(empty($headermap)){
                if($i>10){
                    return false;
                }
                $countidx=-1;
                foreach ($data as $k=>$v){
                    foreach ($headers as $key=>$match){
                        if(in_array($key,$headermap))continue;
                        if($this->isMatchHeader($v, $match)){
                            $headermap[$k]=$key;
                            if($key=='count'){
                                $countidx = $k;
                                $count_column = chr(64+$k);
                            }
                            if($key=='weight'){
                                $weight_column = chr(64+$k);
                            }
                            if($key=='price'){
                                $price_column = chr(64+$k);
                            }
                            break;
                        }
                    }
                }
                if($countidx>-1 && !isset($headermap[$countidx+1])){
                    $headermap[$countidx+1]='unit';
                }
            }else{
                $row=['row_index'=>$i+1];
                foreach ($headermap as $rowidx=>$field){
                    if($field!= 'remark' && empty($data[$rowidx])){
                        //忽略行
                        $row=[];
                        break;
                    }
                    $row[$field] = $data[$rowidx];
                }

                if(!empty($row))$rows[]=$row;
            }
        }
        if(empty($rows)){
            $this->error('没有匹配到数据');
        }

        $unitDatas = getGoodsUnits();
        $goods = array_column($rows,'title');
        $hasGoods = Db::name('goods')->whereIn('title',$goods)->select();
        $hasGoods = array_index($hasGoods,'title');
        $unitUpdated=false;

        $errors=[];
        $imported=[];
        foreach ($rows as $idx=>&$row){
            $price_type = 0;

            //判断计价方式
            if(strpos($row['amount'], $weight_column.$row['row_index'])>0){
                $price_type=1;
            }
            if(!isset($hasGoods[$row['title']])){
                if(!isset($unitDatas[$row['unit']])){
                    $unitUpdated=true;
                    $unitDatas[$row['unit']]=Db::name('unit')->insert([
                        'key'=>$row['unit'],
                        'description'=>'',
                        'sort'=>99
                    ],false,true);
                }
                $data = [
                    'title'=>$row['title'],
                    'fullname'=>$row['title'],
                    'goods_no'=>$row['title'],
                    'cate_id'=>0,
                    'price_type'=>$price_type,
                    'unit'=>$row['unit'],
                    'image'=>'',
                    'description'=>''
                ];



                $hasGoods[$row['title']]=GoodsModel::create($data);
                $imported[]=$hasGoods[$row['title']]['id'];
            }

            if(strpos('=',$row['weight'])==0){
                $row['weight'] = Notation::calculate(substr($row['weight'],1));
            }

            $row['goods_id']=$hasGoods[$row['title']]['id'];
            $row['price_type']=$price_type;
            if($row['price_type'] != $hasGoods[$row['title']]['price_type']){
                $errors[]="【{$row['title']}】的计价方式与商品数据中的计价方式不一致！";
            }
            if($row['unit']!= $hasGoods[$row['title']]['unit']){
                $errors[]="【{$row['title']}】的单位与商品数据中的单位不一致！";
            }
            //unset($row['amount']);
        }

        if($unitUpdated)getGoodsUnits(true);
        if(!empty($imported)) {
            user_log($this->mid, ['importgoods', $imported], 1, '导入商品(订单)', 'manager');
        }

        $this->success('处理成功','',['success'=>1,'goods'=>$rows,'errors'=>$errors]);
    }

    /**
     * 商品列表
     * @param string $key
     * @param int $cate_id
     * @return mixed|\think\response\Redirect
     */
    public function index($key="",$cate_id=0)
    {
        if($this->request->isPost()){
            return redirect(url('',['cate_id'=>$cate_id,'key'=>base64_encode($key)]));
        }
        $key=empty($key)?"":base64_decode($key);
        $model = Db::view('goods','*')->view('goodsCategory',['name'=>'category_name','title'=>'category_title'],'goods.cate_id=goodsCategory.id','LEFT');
            //->view('manager',['username'],'goods.user_id=manager.id','LEFT');
        if(!empty($key)){
            $model->whereLike('goods.title|manager.username|goodsCategory.title',"%$key%");
        }
        if($cate_id>0){
            $model->whereIn('goods.cate_id',GoodsCategoryFacade::getSubCateIds($cate_id));
        }

        $lists=$model->order('id DESC')->paginate(10);
        $this->assign('units',getGoodsUnits());
        $this->assign('lists',$lists);
        $this->assign('page',$lists->render());
        $this->assign('keyword',$key);
        $this->assign('cate_id',$cate_id);
        $this->assign("categories",GoodsCategoryFacade::getCategories());

        return $this->fetch();
    }

    /**
     * 添加
     * @param int $cid
     * @return mixed
     */
    public function add($cid=0){
        if ($this->request->isPost()) {
            $data = $this->request->post();
            if(empty($goods['fullname']))$goods['fullname']=$goods['title'];
            if(empty($goods['goods_no']))$goods['goods_no']=$goods['title'];
            $validate = new GoodsValidate();
            $validate->setId(0);
            if (!$validate->check($data)) {
                $this->error($validate->getError());
            } else {
                $delete_images=[];
                $uploaded = $this->upload('goods', 'upload_image');
                if (!empty($uploaded)) {
                    $data['image'] = $uploaded['url'];
                    $delete_images[]=$data['delete_image'];
                }elseif($this->uploadErrorCode>102){
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }
                unset($data['delete_cover']);
                $data['user_id'] = $this->mid;
                if(empty($data['description']))$data['description']=cutstr($data['content'],240);
                if(!empty($data['create_time']))$data['create_time']=strtotime($data['create_time']);
                if(empty($data['create_time']))unset($data['create_time']);
                $model=GoodsModel::create($data);
                if ($model->id) {
                    //delete_image($delete_images);
                    user_log($this->mid,['addgoods',$model['id']],1,'添加商品 ' ,'manager');
                    $this->success(lang('Add success!'), url('Goods/index'));
                } else {
                    delete_image($data['cover']);
                    $this->error(lang('Add failed!'));
                }
            }
        }
        $model=array('type'=>1,'cate_id'=>$cid);
        $this->assign("categories",GoodsCategoryFacade::getCategories());
        $this->assign('goods',$model);
        $this->assign('id',0);
        return $this->fetch('edit');
    }

    /**
     * 批量添加
     */
    public function batch()
    {
        $data = $this->request->post();

        $titles = $data['titles'];
        if(empty($titles)){
            $this->error('请填写品名');
        }
        $titles = preg_split('/[\r\n]+/s',$titles);
        $datas = [];

        foreach ($titles as $title){
            if(strpos($title,':')>0){
                $titlesubs=explode(':',$title,2);
                $row = [
                    'title' => $titlesubs[1],
                    'fullname' => $titlesubs[1],
                    'goods_no'=> $titlesubs[0],
                    'cate_id' => $data['cate_id'],
                    'unit' => $data['unit'],
                    'price_type' => $data['price_type']
                ];
            }else {
                $row = [
                    'title' => $title,
                    'fullname' => $title,
                    'goods_no'=> $title,
                    'cate_id' => $data['cate_id'],
                    'unit' => $data['unit'],
                    'price_type' => $data['price_type']
                ];
            }
            if(in_array($row['title'],array_column($datas,'title'))
            || in_array($row['goods_no'],array_column($datas,'goods_no'))){
                $this->error('提交的数据中 '.$title.' 重复');
            }

            $exists = Db::name('goods')->where('title',$row['title'])
                ->whereOr('fullname',$row['fullname'])
                ->whereOr('goods_no',$row['goods_no'])
                ->find();

            if(!empty($exists)){
                $this->error('商品 '.$title.' 重复');
            }
            $datas[]=$row;
        }
        $model=new GoodsModel();
        $datas = $model->saveAll($datas);
        user_log($this->mid,['addgoods',array_column($datas->toArray(),'id')],1,'批量添加商品 ' ,'manager');
        $this->success('保存成功！');
    }

    public function import($file='',$sheet=''){
        $datas = $this->uploadImport($file,$sheet);
        if(empty($datas)){
            $this->error('没有读取到数据');
        }
        $datas = $this->transData($datas,[
            'title'=>'品种,品名,商品,名称,商品名称',
            'fullname'=>'全称,商品全称,完整名称',
            'goods_no'=>'编号,编码,商品编码,商品编号',
            'unit'=>'商品单位,单位',
            'cate_id'=>'商品分类,分类',
            'price_type'=>'计价方式',
            'description'=>'商品介绍'
        ],'title,goods_no,unit',['fullname'=>'title','goods_no'=>'title']);
        if(empty($datas)){
            $this->error('没有匹配到数据');
        }

        $errors=[];

        $titles = array_column($datas,'title');
        $goods_nos = array_column($datas,'goods_no');
        $title_has=Db::name('goods')->whereIn('title',$titles)->field('id,title')->select();
        $title_has=array_index($title_has,'title');
        $goods_no_has=Db::name('goods')->whereIn('goods_no',$goods_nos)->field('id,goods_no')->select();
        $goods_no_has=array_index($goods_no_has,'goods_no');
        $titles=[];
        $goods_nos=[];
        foreach ($datas as $k=>$row){
            if(isset($title_has[$row['title']])){
                $errors[]="【{$row['title']}】商品资料已存在";
                unset($datas[$k]);
                continue;
            }
            if(isset($goods_no_has[$row['goods_no']])){
                $errors[]="【{$row['title']}】商品编号已存在";
                unset($datas[$k]);
                continue;
            }

            if(in_array($row['title'],$titles)){
                $errors[]="提交的资料【{$row['title']}】重复";
                unset($datas[$k]);
                continue;
            }
            if(in_array($row['goods_no'],$goods_nos)){
                $errors[]="提交的资料【{$row['title']}】编号重复";
                unset($datas[$k]);
                continue;
            }
            $titles[]=$row['title'];
            $goods_nos[]=$row['goods_no'];
        }
        $unitDatas = getGoodsUnits();
        $unitUpdated=false;
        $cateUpdated=false;
        foreach ($datas as &$row){
            $row['price_type']=$row['price_type']=='单位'?0:1;
            if($row['unit']){
                if(!isset($unitDatas[$row['unit']])){
                    $unitUpdated=true;
                    $unitDatas[$row['unit']]=Db::name('unit')->insert([
                        'key'=>$row['unit'],
                        'description'=>'',
                        'sort'=>99
                    ],false,true);
                }
            }
            if(!empty($row['cate_id'])) {
                $cate_title = $row['cate_id'];
                $cate_id = GoodsCategoryFacade::getCategoryId($cate_title);
                if($cate_id) {
                    $row['cate_id'] = $cate_id;
                }else{
                    $cate = GoodsCategoryModel::create([
                        'title'=>$cate_title,
                        'short'=>$cate_title,
                        'name'=>$cate_title,
                        'sort'=>0,
                        'image'=>''
                    ]);
                    $row['cate_id'] = $cate['id'];
                    $cateUpdated=true;
                }
            }else{
                $row['cate_id'] = 0;
            }

        }

        if($unitUpdated)getGoodsUnits(true);
        if($cateUpdated)GoodsCategoryFacade::clearCache();


        $model=new GoodsModel();
        $datas = $model->saveAll($datas);
        user_log($this->mid, ['importgoods', array_column($datas->toArray(),'id')], 1, '导入商品', 'manager');

        $this->success('处理成功','',['success'=>1,'errors'=>$errors]);
    }

    /**
     * 修改
     * @param $id
     * @return mixed
     */
    public function edit($id)
    {
        $id = intval($id);

        if ($this->request->isPost()) {
            $data=$this->request->post();
            if(empty($goods['fullname']))$goods['fullname']=$goods['title'];
            if(empty($goods['goods_no']))$goods['goods_no']=$goods['title'];
            $validate=new GoodsValidate();
            $validate->setId($id);
            if (!$validate->check($data)) {
                $this->error($validate->getError());
            }else{
                $delete_images=[];
                $uploaded=$this->upload('article','upload_cover');
                if(!empty($uploaded)){
                    $data['cover']=$uploaded['url'];
                    $delete_images[]=$data['delete_cover'];
                }elseif($this->uploadErrorCode>102){
                    $this->error($this->uploadErrorCode.':'.$this->uploadError);
                }
                if(empty($data['description']))$data['description']=cutstr($data['content'],240);
                if(!empty($data['create_time']))$data['create_time']=strtotime($data['create_time']);
                if(empty($data['create_time']))unset($data['create_time']);
                $model=GoodsModel::get($id);
                if ($model->allowField(true)->save($data)) {
                    //delete_image($delete_images);
                    user_log($this->mid, ['updategoods',$id], 1, '修改商品 ' . $id, 'manager');
                    $this->success("编辑成功", url('Article/index'));
                } else {
                    delete_image($data['cover']);
                    $this->error("编辑失败");
                }
            }
        }

        $model = GoodsModel::get($id);
        if(empty($model)){
            $this->error('商品不存在');
        }
        $this->assign("categories",GoodsCategoryFacade::getCategories());
        $this->assign('goods',$model);
        $this->assign('id',$id);
        return $this->fetch();
    }

    /**
     * 删除商品
     * @param $id
     */
    public function delete($id)
    {
        $salecount = Db::name('saleOrderGoods')->whereIn('goods_id',idArr($id))->count();
        if($salecount>0){
            $this->error('商品已在销售单中使用，无法删除');
        }
        $purchasecount = Db::name('purchaseOrderGoods')->whereIn('goods_id',idArr($id))->count();
        if($purchasecount>0){
            $this->error('商品已在采购单中使用，无法删除');
        }
        $model = Db::name('goods');
        $result = $model->whereIn("id",idArr($id))->delete();
        if($result){
            //Db::name('goodsImages')->whereIn("goods_id",idArr($id))->delete();
            user_log($this->mid,['deletegoods',$id],1,'删除商品 '.$id ,'manager');
            $this->success(lang('Delete success!'), url('Goods/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }

    public function rank($start_date='', $end_date='')
    {

        $data = GoodsModel::statics($start_date, $end_date);

        $this->assign($data);

        return $this->fetch();
    }

    public function rankExport($start_date='', $end_date=''){
        $data = GoodsModel::statics($start_date, $end_date);

        $excel=new Excel('Xlsx');

        $excel->setHeader([
            '编号','品名','单位','采购量','采购金额','采购单价','采购最低价','采购最高价','销售量','销售金额','销售单价','销售最低价','销售最高价',
        ]);
        foreach ($data['goods'] as $good){
            $excel->addRow([
                $good['id'],$good['title'],$good['unit'],
                $good['purchase']['total_count'],$good['purchase']['total_amount'],$good['purchase']['price'],$good['purchase']['min_price'],$good['purchase']['max_price'],
                $good['sale']['total_count'],$good['sale']['total_amount'],$good['sale']['price'],$good['sale']['min_price'],$good['sale']['max_price']
            ]);
            if(!empty($good['other'])){
                foreach ($good['other'] as $vgood) {
                    $excel->addRow([
                        $vgood['id'], $vgood['goods_title'], $vgood['goods_unit'],
                        $vgood['purchase']['total_count'], $vgood['purchase']['total_amount'], $vgood['purchase']['price'], $vgood['purchase']['min_price'], $vgood['purchase']['max_price'],
                        $vgood['sale']['total_count'], $vgood['sale']['total_amount'], $vgood['sale']['price'], $vgood['sale']['min_price'], $vgood['sale']['max_price']
                    ]);
                }
            }
        }
        $datestr = '';
        if(!empty($data['start_date'])){
            $datestr = '['.$data['start_date'].'-'.$data['end_date'].']';
        }

        $excel->output('品种统计'.$datestr);
    }

    public function statics($goods_id, $start_date='', $end_date='')
    {
        $goods = GoodsModel::get($goods_id);
        if(empty($goods)){
            $this->error('品种错误');
        }
        $data =$goods->staticGoods($start_date, $end_date);

        $this->assign($data);
        $this->assign('goods',$goods);

        return $this->fetch();
    }

    public function staticsExport($goods_id, $start_date='', $end_date=''){
        $goods = GoodsModel::get($goods_id);
        if(empty($goods)){
            $this->error('品种错误');
        }
        $data =$goods->staticGoods($start_date, $end_date);

        $excel=new Excel('Xlsx');

        $excel->setHeader([
            '编号','品名','日期','单位','采购量','采购金额','采购单价','采购最低价','采购最高价','销售量','销售金额','销售单价','销售最低价','销售最高价',
        ]);
        foreach ($data['statics'] as $date=>$good){
            $excel->addRow([
                $goods['id'],$goods['title'],$date,$goods['unit'],
                $good['purchase']['total_count'],$good['purchase']['total_amount'],$good['purchase']['price'],$good['purchase']['min_price'],$good['purchase']['max_price'],
                $good['sale']['total_count'],$good['sale']['total_amount'],$good['sale']['price'],$good['sale']['min_price'],$good['sale']['max_price']
            ]);
            if(!empty($good['other'])){
                foreach ($good['other'] as $k=>$vgood) {
                    $excel->addRow([
                        $goods['id'],$goods['title'],$date, $k,
                        $vgood['purchase']['total_count'], $vgood['purchase']['total_amount'], $vgood['purchase']['price'], $vgood['purchase']['min_price'], $vgood['purchase']['max_price'],
                        $vgood['sale']['total_count'], $vgood['sale']['total_amount'], $vgood['sale']['price'], $vgood['sale']['min_price'], $vgood['sale']['max_price']
                    ]);
                }
            }
        }
        $datestr = '';
        if(!empty($data['start_date'])){
            $datestr = '['.$data['start_date'].'-'.$data['end_date'].']';
        }

        $excel->output('['.$goods['title'].']统计'.$datestr);
    }

    /**
     * 发布
     * @param $id
     * @param int $status
     */
    public function status($id,$status=0)
    {
        $data['status'] = $status==1?1:0;

        $result = Db::name('goods')->whereIn("id",idArr($id))->update($data);
        if ($result && $data['status'] === 1) {
            user_log($this->mid,'pushgoods',1,'发布商品 '.$id ,'manager');
            $this -> success("发布成功", url('Goods/index'));
        } elseif ($result && $data['status'] === 0) {
            user_log($this->mid,'cancelgoods',1,'撤销商品 '.$id ,'manager');
            $this -> success("撤销成功", url('Goods/index'));
        } else {
            $this -> error("操作失败");
        }
    }

    /**
     * 图集
     * @param $aid
     * @return mixed
     */
    public function imagelist($aid){
        $model = Db::name('goodsImages');
        $goods=Db::name('Goods')->find($aid);
        if(empty($goods)){
            $this->error('商品不存在');
        }
        $model->where('goods_id',$aid);
        if(!empty($key)){
            $model->where('title','like',"%$key%");
        }
        $lists=$model->order('sort ASC,id DESC')->paginate(15);
        $this->assign('goods',$goods);
        $this->assign('lists',$lists);
        $this->assign('page',$lists->render());
        $this->assign('aid',$aid);
        return $this->fetch();
    }

    /**
     * 添加图片
     * @param $aid
     * @return mixed
     */
    public function imageadd($aid){
        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new ImagesValidate();

            if (!$validate->check($data)) {
                $this->error($validate->getError());
            }else{
                $uploaded=$this->upload('goods','upload_image');
                if(!empty($uploaded)){
                    $data['image']=$uploaded['url'];
                }
                $model = Db::name("GoodsImages");
                $url=url('goods/imagelist',array('aid'=>$aid));
                if ($model->insert($data)) {
                    $this->success(lang('Add success!'),$url);
                } else {
                    delete_image($data['image']);
                    $this->error(lang('Add failed!'));
                }
            }
        }
        $model=array('status'=>1,'goods_id'=>$aid);
        $this->assign('model',$model);
        $this->assign('aid',$aid);
        $this->assign('id',0);
        return $this->fetch('imageupdate');
    }

    /**
     * 修改图片
     * @param $id
     * @return mixed
     */
    public function imageupdate($id)
    {
        $id = intval($id);

        if ($this->request->isPost()) {
            $data=$this->request->post();
            $validate=new ImagesValidate();

            if (!$validate->check($data)) {
                $this->error($validate->getError());
            }else{
                $model = Db::name("GoodsImages");
                $url=url('goods/imagelist',array('aid'=>$data['goods_id']));
                $delete_images=[];
                $uploaded=$this->upload('goods','upload_image');
                if(!empty($uploaded)){
                    $data['image']=$uploaded['url'];
                    $delete_images[]=$data['delete_image'];
                }
                unset($data['delete_image']);
                $data['id']=$id;
                if ($model->update($data)) {
                    delete_image($delete_images);
                    $this->success(lang('Update success!'), $url);
                } else {
                    delete_image($data['image']);
                    $this->error(lang('Update failed!'));
                }
            }
        }else{
            $model = Db::name('GoodsImages')->where('id', $id)->find();
            if(empty($model)){
                $this->error('图片不存在');
            }

            $this->assign('model',$model);
            $this->assign('aid',$model['goods_id']);
            $this->assign('id',$id);
            return $this->fetch();
        }
    }

    /**
     * 删除图片
     * @param $aid
     * @param $id
     */
    public function imagedelete($aid,$id)
    {
        $id = intval($id);
        $model = Db::name('GoodsImages');
        $result = $model->delete($id);
        if($result){
            $this->success(lang('Delete success!'), url('goods/imagelist',array('aid'=>$aid)));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }
}