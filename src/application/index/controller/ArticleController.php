<?php

namespace app\index\controller;

use app\common\facade\CategoryFacade;
use app\common\model\ArticleCommentModel;
use app\common\model\ArticleModel;
use app\common\validate\ArticleCommentValidate;
use \think\Db;
/**
 * 文章
 */
class ArticleController extends BaseController{

    protected $categries;
    protected $category;
    protected $topCategory;
    protected $categoryTree;
    protected $pagesize=12;

    public function initialize()
    {
        parent::initialize();
        $this->assign('navmodel','article');
    }

    public function index($name=""){
        $this->category($name);
        $model=Db::view('article','*')
            ->view('category',['name'=>'category_name','title'=>'category_title'],'article.cate_id=category.id','LEFT')
            ->view('manager',['username'],'manager.id=article.user_id','LEFT');

        $model->where('article.status',1);
        if(!empty($this->category)){
            $this->seo($this->category['title']);
            $model->whereIn('article.cate_id',CategoryFacade::getSubCateIds($this->category['id']));
        }else{
            $this->seo(lang('News'));
        }

        $lists=$model->order('article.create_time DESC,article.id DESC')->paginate($this->pagesize);
        $lists->each(function($item){
            if(!empty($item['prop_data'])){
                $item['prop_data']=json_decode($item['prop_data'],true);
            }
            $item['prop_data']=[];
            return $item;
        });

        $this->assign('lists', $lists);
        $this->assign('page',$lists->render());
        if(!empty($this->categoryTree)){
            for($i=count($this->categoryTree)-1;$i>=0;$i--){
                if($this->categoryTree[$i]['use_template']){
                    return $this->fetch($this->categoryTree[$i]['name'].'/index');
                }
            }
        }

        return $this->fetch();
    }

    public function view($id){
        $article = ArticleModel::get($id);
        if(empty($article)){
            $this->error(lang('Article not exists!'));
        }
        $this->seo($article['title']);
        $this->category($article['cate_id']);

        $article->setInc('views',1);

        $this->assign('article', $article);
        $this->assign('images',Db::name('ArticleImages')->where('article_id',$article['id'])->select());
        if(!empty($this->categoryTree)){
            for($i=count($this->categoryTree)-1;$i>=0;$i--){
                if($this->categoryTree[$i]['use_template']){
                    return $this->fetch($this->categoryTree[$i]['name'].'/view');
                }
            }
        }
        return $this->fetch();
    }
    public function notice($id){
        $article = Db::name('notice')->find($id);
        $this->seo($article['title']);
        $this->category();

        $this->assign('article', $article);
        return $this->fetch();
    }

    private function category($name=''){

        $this->category=CategoryFacade::findCategory($name);
        $this->categoryTree=CategoryFacade::getCategoryTree($name);
        $this->categries=CategoryFacade::getTreedCategory();
        if(empty($this->category)){
            $this->category=['id'=>0,'title'=>'新闻中心'];
            $this->topCategory=$this->category;
        }else{
            $this->topCategory=$this->categoryTree[0];
        }

        $this->assign('category',$this->category);
        $this->assign('topCategory',$this->topCategory);
        $this->assign('categoryTree',$this->categoryTree);
        $this->assign('categories',$this->categries);

        if(!empty($this->categoryTree)) {
            $this->assign('navmodel', 'article-' . $this->categoryTree[0]['name']);

            foreach ($this->categoryTree as $cate){
                if($cate['pagesize']>0){
                    $this->pagesize=intval($cate['pagesize']);
                }
            }
        }
    }
}
