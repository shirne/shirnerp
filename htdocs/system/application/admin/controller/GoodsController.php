<?php

namespace app\admin\controller;


use app\admin\validate\GoodsValidate;
use app\admin\validate\ImagesValidate;
use app\common\facade\GoodsCategoryFacade;
use app\common\model\GoodsModel;
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

        $lists=$model->field('id,title,goods_no,cate_id,unit,image,description,create_time')
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
                    user_log($this->mid,'addgoods',1,'添加商品 '.$model->id ,'manager');
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
                $datas[] = [
                    'title' => $titlesubs[1],
                    'fullname' => $title,
                    'goods_no'=> $titlesubs[0],
                    'cate_id' => $data['cate_id'],
                    'unit' => $data['unit']
                ];
            }else {
                $datas[] = [
                    'title' => $title,
                    'fullname' => $title,
                    'goods_no'=> $title,
                    'cate_id' => $data['cate_id'],
                    'unit' => $data['unit']
                ];
            }
        }
        $model=new GoodsModel();
        $model->saveAll($datas);
        $this->success('保存成功！');
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
                    user_log($this->mid, 'updategoods', 1, '修改商品 ' . $id, 'manager');
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
        $model = Db::name('goods');
        $result = $model->whereIn("id",idArr($id))->delete();
        if($result){
            Db::name('goodsImages')->whereIn("goods_id",idArr($id))->delete();
            user_log($this->mid,'deletegoods',1,'删除商品 '.$id ,'manager');
            $this->success(lang('Delete success!'), url('Goods/index'));
        }else{
            $this->error(lang('Delete failed!'));
        }
    }

    public function rank($start_date='', $end_date='')
    {
        $pmodel = Db::name('purchaseOrderGoods');
        $smodel = Db::name('saleOrderGoods');
        $start_time=0;
        $end_time=0;
        if($start_date) {
            $start_time = strtotime($start_date);
            if ($start_time) $start_date = date('Y-m-d H:i:s', $start_time);
        }

        if($end_date) {
            $end_time = strtotime($end_date);
            if ($end_time) $end_date = date('Y-m-d H:i:s', $end_time);
        }

        if($start_time){
            if($end_time){
                $pmodel->whereBetween('create_time',[$start_time,$end_time]);
                $smodel->whereBetween('create_time',[$start_time,$end_time]);
            }else{
                $pmodel->where('create_time','>=',$start_time);
                $smodel->where('create_time','>=',$start_time);
            }
        }elseif($end_time){
            $pmodel->where('create_time','<=',$end_time);
            $smodel->where('create_time','<=',$end_time);
        }
        $pdata = $pmodel->field('sum(count) as total_count,goods_id,goods_title,goods_unit')
            ->group('goods_id')->order('total_count DESC')
            ->select();
        $sdata = $pmodel->field('sum(count) as total_count,goods_id,goods_title,goods_unit')
            ->group('goods_id')->order('total_count DESC')
            ->select();

        $purchaseData=[];
        foreach ($pdata as $k=>$row){
            $purchaseData[]=[
                'value'=> $row['total_count'],
                'label'=> $row['goods_title'].'('.$row['goods_unit'].')'
            ];
        }

        $saleData=[];
        foreach ($sdata as $k=>$row){
            $saleData[]=[
                'value'=> $row['total_count'],
                'label'=> $row['goods_title'].'('.$row['goods_unit'].')'
            ];
        }


        $this->assign(compact('start_date','end_date'));
        $this->assign('purchaseStatics',$purchaseData);
        $this->assign('saleStatics',$saleData);

        return $this->fetch();
    }

    public function statics($goods_id, $start_date='', $end_date='')
    {
        $format ="'%Y-%m-%d'";
        $pmodel = Db::name('purchaseOrderGoods')->where('goods_id',$goods_id);
        $smodel = Db::name('saleOrderGoods')->where('goods_id',$goods_id);
        $start_time=0;
        $end_time=0;
        if($start_date) {
            $start_time = strtotime($start_date);
            if ($start_time) $start_date = date('Y-m-d H:i:s', $start_time);
        }

        if($end_date) {
            $end_time = strtotime($end_date);
            if ($end_time) $end_date = date('Y-m-d H:i:s', $end_time);
        }

        if($start_time){
            if($end_time){
                $pmodel->whereBetween('create_time',[$start_time,$end_time]);
                $smodel->whereBetween('create_time',[$start_time,$end_time]);
            }else{
                $pmodel->where('create_time','>=',$start_time);
                $smodel->where('create_time','>=',$start_time);
            }
        }elseif($end_time){
            $pmodel->where('create_time','<=',$end_time);
            $smodel->where('create_time','<=',$end_time);
        }
        $pdata = $pmodel->field('sum(count) as total_p_count,avg(base_price) as p_price,date_format(from_unixtime(create_time),'.$format. ') as awdate')
            ->group('awdate')->order('awdate ASC')
            ->select();
        $sdata = $pmodel->field('sum(count) as total_s_count,avg(base_price) as s_price,date_format(from_unixtime(create_time),'.$format. ') as awdate')
            ->group('awdate')->order('awdate ASC')
            ->select();
        $sdata = array_index($sdata,'awdate');

        $statics = [];
        foreach ($pdata as $row){
            $srow = $sdata[$row['awdate']]?:['total_s_count'=>0,'s_price'=>0];
            $statics[]=array_merge($row,$srow);
        }

        $this->assign(compact('start_date','end_date'));
        $this->assign('statics',$statics);

        return $this->fetch();
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