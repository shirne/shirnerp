<form method="post" class="page-form" action="" enctype="multipart/form-data">
    <div class="form-row">
        <div class="form-group col">
            <div class="input-group">
                <div class="input-group-prepend">
                    <span class="input-group-text">{:lang('Category Title')}</span>
                </div>
                <input type="text" name="title" class="form-control" placeholder="输入分类名称"/>
            </div>
        </div>
        <div class="form-group col-4">
            <div class="input-group">
                <div class="input-group-prepend">
                    <span class="input-group-text">简称</span>
                </div>
                <input type="text" name="short" class="form-control" />
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
                    <foreach name="categories" item="v">
                        <option value="{$v.id}"
                        <?php if($model['pid'] == $v['id']) {echo 'selected="selected"' ;}?>
                        >{$v.html} {$v.title}</option>
                    </foreach>
                </select>
            </div>
        </div>
        <div class="form-group col-4">
            <div class="input-group">
                <div class="input-group-prepend">
                    <span class="input-group-text">排序</span>
                </div>
                <input type="text" name="sort" class="form-control" placeholder="排序按从小到大">
            </div>
        </div>
    </div>
    <div class="form-group">
        <label for="description">描述信息</label>
        <textarea name="description" cols="30" rows="10" class="form-control" placeholder="请输入分类描述(选填)"></textarea>
    </div>
</form>