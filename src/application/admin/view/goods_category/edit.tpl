{extend name="public:base"/}

{block name="body"}
    {include file="public/bread" menu="goods_category_index" title="分类详情"/}

    <div id="page-wrapper">
        <div class="page-header">{:lang($id>0?'Edit':'Add')}{:lang('Category')}</div>
        <div class="page-content">
            <form method="post" class="page-form" action="" enctype="multipart/form-data">
                <div class="form-row">
                    <div class="form-group col">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">{:lang('Category Title')}</span>
                            </div>
                            <input type="text" name="title" class="form-control" value="{$model.title}" placeholder="输入分类名称"/>
                        </div>
                    </div>
                    <div class="form-group col">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">简称</span>
                            </div>
                            <input type="text" name="short" class="form-control" value="{$model.short}"/>
                        </div>
                    </div>

                    <div class="form-group col">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">分类别名</span>
                            </div>
                            <input type="text" name="name" class="form-control" value="{$model.name}" placeholder="输入分类别名,不能和其他分类别名重复">
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">父分类</span>
                            </div>
                        <select name="pid" class="form-control">
                            <option value="">顶级分类</option>
                            {foreach $cate as $v}
                                <option value="{$v.id}"
                                <?php if($model['pid'] == $v['id']) {echo 'selected="selected"' ;}?>
                                >{$v.html} {$v.title}</option>
                            {/foreach}
                        </select>
                        </div>
                    </div>
                    <div class="form-group col">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">排序</span>
                            </div>
                            <input type="text" name="sort" class="form-control" value="{$model.sort}" placeholder="排序按从小到大">
                        </div>
                    </div>
                </div>
                <div class="form-row">
                <div class="form-group col">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text">分类图标</span>
                        </div>
                        <div class="custom-file">
                        <input type="file" class="custom-file-input" name="upload_icon"/>
                            <label class="custom-file-label" for="upload_icon">选择文件</label>
                        </div>
                    </div>
                    {if !empty($model['icon'])}
                        <figure class="figure">
                            <img src="{$model.icon}" class="figure-img img-fluid rounded" alt="icon">
                            <figcaption class="figure-caption text-center">{$model.icon}</figcaption>
                        </figure>
                        <input type="hidden" name="delete_icon" value="{$model.icon}"/>
                    {/if}
                </div>
                <div class="form-group col">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text">分类图片</span>
                        </div>
                        <div class="custom-file">
                        <input type="file" class="custom-file-input" name="upload_image"/>
                            <label class="custom-file-label" for="upload_image">选择文件</label>
                        </div>
                    </div>
                    {if !empty($model['image'])}
                        <figure class="figure">
                            <img src="{$model.image}" class="figure-img img-fluid rounded" alt="image">
                            <figcaption class="figure-caption text-center">{$model.image}</figcaption>
                        </figure>
                        <input type="hidden" name="delete_image" value="{$model.image}"/>
                    {/if}
                </div>
                </div>
                <div class="form-group">
                    <label for="description">描述信息</label>
                    <textarea name="description" cols="30" rows="10" class="form-control"
                              placeholder="请输入分类描述(选填)">{$model.description}</textarea>
                </div>
                <div class="form-group submit-btn">
                    <input type="hidden" name="id" value="{$model.id}">
                    <button type="submit" class="btn btn-primary">{$id>0?'保存':'添加'}</button>
                </div>
            </form>
        </div>
    </div>
{/block}