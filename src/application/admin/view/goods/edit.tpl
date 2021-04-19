{extend name="public:base" /}

{block name="body"}
{include file="public/bread" menu="goods_index" title="商品详情" /}
<div id="page-wrapper">
    <div class="page-header">{$id>0?'编辑':'添加'}商品</div>
    <div id="page-content">
    <form method="post" class="page-form" action="" enctype="multipart/form-data">
        <div class="form-row">
            <div class="col form-group">
                <label for="goods-title">商品名称</label>
                <input type="text" name="title" class="form-control" value="{$goods.title}" id="goods-title" placeholder="输入商品名称">
            </div>
            <div class="col form-group">
                <label for="vice_title">副标题</label>
                <input type="text" name="vice_title" class="form-control" value="{$goods.vice_title}" >
            </div>
        </div>
        <div class="form-row">
            <div class="col form-group">
                <label for="goods-cate">商品分类</label>
                <select name="cate_id" id="goods-cate" class="form-control">
                    {foreach $categories as $v}
                        <option value="{$v.id}" {$goods['cate_id'] == $v['id']?'selected="selected"':""}>{$v.html} {$v.title}</option>
                    {/foreach}
                </select>
            </div>
            <div class="col form-group">
                <label for="create_time">商品单位</label>
                <input type="text" name="unit" class="form-control" value="{$goods.unit}" >
            </div>
        </div>
        <div class="form-group">
            <label for="image">商品图</label>
            <div class="input-group">
                <div class="custom-file">
                    <input type="file" class="custom-file-input" name="upload_image"/>
                    <label class="custom-file-label" for="upload_image">选择文件</label>
                </div>
            </div>
            {if $goods['image']}
                <figure class="figure">
                    <img src="{$goods.image}" class="figure-img img-fluid rounded" alt="image">
                    <figcaption class="figure-caption text-center">{$goods.image}</figcaption>
                </figure>
                <input type="hidden" name="delete_image" value="{$goods.image}"/>
            {/if}
        </div>
        <div class="form-group">
            <label for="description">商品摘要</label>
            <textarea name="description" class="form-control" >{$goods.description}</textarea>
        </div>
        <div class="form-group submit-btn">
            <input type="hidden" name="id" value="{$goods.id}">
            <button type="submit" class="btn btn-primary">{$id>0?'保存':'添加'}</button>
        </div>
    </form>
        </div>
</div>
    {/block}
{block name="script"}
    <script type="text/javascript" src="__STATIC__/js/jquery.autocomplete.min.js"></script>
<script type="text/javascript">
    jQuery(function ($) {

    });
</script>
{/block}