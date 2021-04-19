{extend name="public:base" /}

{block name="body"}

{include file="public/bread" menu="storage_index" title="链接仓库" /}

<div id="page-wrapper">
    <div class="page-header">{$id>0?'编辑':'添加'}仓库</div>
    <div class="page-content">
    <form method="post" action="" enctype="multipart/form-data">
        <div class="form-group">
            <label for="title">仓库名称</label>
            <input type="text" name="title" class="form-control" value="{$model.title}" >
        </div>
        <div class="form-group">
            <label for="url">仓库地址</label>
            <input type="text" name="url" class="form-control" value="{$model.url}" >
        </div>
        <div class="form-group">
            <label for="sort">排序</label>
            <input type="text" name="sort" class="form-control" value="{$model.sort}"  >
        </div>
        <div class="form-group">
            <input type="hidden" name="id" value="{$model.id}">
            <button type="submit" class="btn btn-primary">{$id>0?'保存':'添加'}</button>
        </div>
    </form>
    </div>
</div>
{/block}