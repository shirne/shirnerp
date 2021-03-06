{extend name="public:base" /}

{block name="body"}

{include file="public/bread" menu="adv_index" title="广告资料" /}

<div id="page-wrapper">
    <div class="page-header">{$id>0?'编辑':'添加'}广告</div>
    <div class="page-content">
    <form method="post" class="page-form" action="" enctype="multipart/form-data">
        <div class="form-group">
            <label for="title">名称</label>
            <input type="text" name="title" class="form-control" value="{$model.title}" placeholder="名称">
        </div>
        <div class="form-group">
            <label for="image">图片</label>
            <div class="input-group">
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
        <div class="form-group">
            <label for="text">文本</label>
            <input type="text" name="text" class="form-control" value="{$model.text}" placeholder="显示文本">
        </div>
        <div class="form-group">
            <label for="text_vice">附加文本</label>
            <input type="text" name="text_vice" class="form-control" value="{$model.text_vice}" placeholder="附加文本">
        </div>
        <div class="form-group">
            <label for="image">有效期</label>
            <div class="form-row date-range">
                <div class="input-group col">
                    <div class="input-group-prepend">
                    <span class="input-group-text">从</span>
                    </div>
                    <input type="text" name="start_date" class="form-control fromdate" value="{$model.start_date|showdate=''}" />
                </div>
                <div class="input-group col">
                    <div class="input-group-prepend">
                    <span class="input-group-text">至</span>
                    </div>
                    <input type="text" name="end_date" class="form-control todate" value="{$model.end_date|showdate=''}" />
                </div>
            </div>

        </div>
        <div class="form-row">
            <div class="col form-group">
                <label for="url">链接</label>
                <input type="text" name="url" class="form-control" value="{$model.url}" />
            </div>
            <div class="col form-group">
                <label for="image">排序</label>
                <input type="text" name="sort" class="form-control" value="{$model.sort}" />
            </div>
        </div>
        <div class="form-group">
            <label for="cc">状态</label>
            <label class="radio-inline">
                <input type="radio" name="status" value="1" {if $model['status'] == 1}checked="checked"{/if} >显示
            </label>
            <label class="radio-inline">
                <input type="radio" name="status" value="0" {if $model['status'] == 0}checked="checked"{/if}>隐藏
            </label>
        </div>
        <div class="form-group submit-btn">
            <input type="hidden" name="group_id" value="{$model.group_id}">
            <button type="submit" class="btn btn-primary">{$id>0?'保存':'添加'}</button>
        </div>
    </form>
    </div>
</div>
{/block}