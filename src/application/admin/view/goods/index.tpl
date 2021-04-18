<extend name="public:base" />

<block name="body">
<include file="public/bread" menu="goods_index" title="商品列表" />
<div id="page-wrapper">

	<div class="row list-header">
		<div class="col-md-6">
			<div class="btn-toolbar list-toolbar" role="toolbar" aria-label="Toolbar with button groups">
				<div class="btn-group btn-group-sm mr-2" role="group" aria-label="check action group">
					<a href="javascript:" class="btn btn-outline-secondary checkall-btn" data-toggle="button" aria-pressed="false">全选</a>
					<a href="javascript:" class="btn btn-outline-secondary checkreverse-btn">反选</a>
				</div>
				<div class="btn-group btn-group-sm mr-2" role="group" aria-label="action button group">
					<a href="javascript:" class="btn btn-outline-secondary action-btn" data-action="delete">{:lang('Delete')}</a>
				</div>
				<a href="{:url('goods/add')}" class="btn btn-outline-primary btn-sm action-btn mr-2" data-needchecks="false" data-action="add"><i class="ion-md-add"></i> 添加商品</a>
				<a href="javascript:" class="btn btn-outline-primary btn-sm action-btn mr-2" data-needchecks="false" data-action="batchadd"><i class="ion-md-add"></i> 批量添加</a>
				<a href="{:url('goods/import')}" class="btn btn-outline-primary btn-sm mr-2 btn-import"><i class="ion-md-cloud-upload"></i> 导入商品</a>
				<a href="{:url('rank')}" data-tab="stat" class="btn btn-outline-primary btn-sm"><i class="ion-md-stats"></i> 商品统计</a>
			</div>
		</div>
		<div class="col-md-6">
			<form action="{:url('goods/index')}" method="post">
				<div class="form-row">
					<div class="col input-group input-group-sm mr-2">
						<div class="input-group-prepend">
							<span class="input-group-text">分类</span>
						</div>
						<select name="cate_id" class="form-control">
							<option value="0">不限分类</option>
							<foreach name="categories" item="v">
								<option value="{$v.id}" {$cate_id == $v['id']?'selected="selected"':""}>{$v.html} {$v.title}</option>
							</foreach>
						</select>
					</div>
					<div class="col input-group input-group-sm">
						<input type="text" class="form-control" name="key" value="{$keyword}" placeholder="按名称搜索">
						<div class="input-group-append">
							<button class="btn btn-outline-secondary" type="submit"><i class="ion-md-search"></i></button>
						</div>
					</div>
				</div>
			</form>
		</div>
	</div>
	<table class="table table-hover table-striped">
		<thead>
			<tr>
				<th width="50">#</th>
				<th>名称</th>
				<th>全名</th>
				<th>单位</th>
				<th>分类</th>
				<th>说明</th>
				<th width="160">&nbsp;</th>
			</tr>
		</thead>
		<tbody>
			<empty name="lists">{:list_empty(8)}</empty>
			<volist name="lists" id="v" >
				<tr>
					<td><input type="checkbox" name="id" value="{$v.id}" /></td>
					<td><span class="badge badge-info">{$v.goods_no}</span> {$v.title}</td>
					<td>
                        {$v.fullname}
					</td>
					<td>{$v.unit}</td>
					<td>{$v.category_title}</td>
					<td>{$v.description}</td>
					<td class="operations">
						<a href="{:url('statics',['goods_id'=>$v['id']])}" data-tab="stat-{$v.id}" title="商品统计" class="btn btn-outline-primary btn-sm"><i class="ion-md-stats"></i></a>
					<a class="btn btn-outline-primary action-btn" data-action="edit" data-needchecks="false" data-id="{$v.id}" title="编辑" href="{:url('goods/edit',array('id'=>$v['id']))}"><i class="ion-md-create"></i> </a>
					<a class="btn btn-outline-danger link-confirm" title="{:lang('Delete')}" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('goods/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
					</td>
				</tr>
			</volist>
		</tbody>
	</table>
	<div class="clearfix"></div>
	{$page|raw}

</div>
</block>
<block name="script">
	<script type="text/html" id="addTpl">
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<label class="input-group-text">商品名称</label>
				</div>
				<input type="text" name="title" class="form-control" required placeholder="输入商品名称">
			</div>
		</div>
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<label class="input-group-text">商品全称</label>
				</div>
				<input type="text" name="fullname" class="form-control" required  placeholder="输入商品全称">
			</div>
		</div>
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<label class="input-group-text">商品编号</label>
				</div>
				<input type="text" name="goods_no" class="form-control" required >
			</div>
		</div>
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<label class="input-group-text">商品分类</label>
				</div>
				<select name="cate_id" id="goods-cate" class="form-control">
					<foreach name="categories" item="v">
						<option value="{$v.id}" >{$v.html} {$v.title}</option>
					</foreach>
				</select>
			</div>
		</div>
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<label class="input-group-text">商品单位</label>
				</div>
				<select name="unit" class="form-control">
					<foreach name="units" item="v">
						<option value="{$v.key}" >{$v.key}</option>
					</foreach>
				</select>
			</div>
		</div>
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<label class="input-group-text">计价方式</label>
				</div>
				<select name="price_type" id="price_type" class="form-control">
					<option value="0">单位计价</option>
					<option value="1">重量计价</option>
				</select>
			</div>
		</div>
		<div class="form-group form-row d-none">
			<label for="image" class="col-3">商品图</label>
			<div class="col">

			</div>
		</div>
		<div class="form-group">
			<label for="description">商品摘要</label>
			<textarea name="description" class="form-control" ></textarea>
		</div>
	</script>
	<script type="text/html" id="batchAddTpl">
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<span class="input-group-text">商品名称</span>
				</div>
				<textarea class="form-control" name="titles" placeholder="一行一个 编号:品名"></textarea>
			</div>
		</div>
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<label class="input-group-text">统一分类</label>
				</div>
				<select name="cate_id" id="goods-cate" class="form-control">
					<foreach name="categories" item="v">
						<option value="{$v.id}" {$goods['cate_id'] == $v['id']?'selected="selected"':""}>{$v.html} {$v.title}</option>
					</foreach>
				</select>
			</div>
		</div>
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<label class="input-group-text">统一单位</label>
				</div>
				<select name="unit" class="form-control">
					<foreach name="units" item="v">
						<option value="{$v.key}" {$goods['unit'] == $v['key']?'selected="selected"':""}>{$v.key}</option>
					</foreach>
				</select>
			</div>
		</div>
		<div class="form-group">
			<div class="input-group">
				<div class="input-group-prepend">
					<label class="input-group-text">计价方式</label>
				</div>
				<select name="price_type" id="price_type" class="form-control">
					<option value="0">单位计价</option>
					<option value="1">重量计价</option>
				</select>
			</div>
		</div>
	</script>
	<script type="text/javascript">
		(function(w){
			w.actionPublish=function(ids){
				dialog.confirm('确定将选中商品发布到前台？',function() {
				    $.ajax({
						url:'{:url('goods/status',['id'=>'__id__','status'=>1])}'.replace('__id__',ids.join(',')),
						type:'GET',
						dataType:'JSON',
						success:function(json){
						    if(json.code==1){
                                dialog.alert(json.msg,function() {
                                    location.reload();
                                });
                            }else{
                                dialog.warning(json.msg);
                            }
                        }
					});
                });
            };
            w.actionCancel=function(ids){
                dialog.confirm('确定取消选中商品的发布状态？',function() {
                    $.ajax({
                        url:'{:url('goods/status',['id'=>'__id__','status'=>0])}'.replace('__id__',ids.join(',')),
                        type:'GET',
                        dataType:'JSON',
                        success:function(json){
                            if(json.code==1){
                                dialog.alert(json.msg,function() {
                                    location.reload();
                                });
                            }else{
                                dialog.warning(json.msg);
                            }
                        }
                    });
                });
            };
            w.actionDelete=function(ids){
                dialog.confirm('确定删除选中的商品？',function() {
                    $.ajax({
                        url:'{:url('goods/delete',['id'=>'__id__'])}'.replace('__id__',ids.join(',')),
                        type:'GET',
                        dataType:'JSON',
                        success:function(json){
                            if(json.code==1){
                                dialog.alert(json.msg,function() {
                                    location.reload();
                                });
                            }else{
                                dialog.warning(json.msg);
                            }
                        }
                    });
                });
            };
            $('.btn-import').click(function (e) {
                e.preventDefault();
                importExcel('导入商品',$(this).attr('href'));
            });

            var addTpl = $('#addTpl').html();
            var addUrl = '{:url("goods/add")}';
            var editUrl = '{:url("goods/edit",['id'=>'__ID__'])}';
            function editGoods(id){
                var dlg = new Dialog({
                    onshown:function (body) {
						if(id>0){
                            $.ajax({
                                url:editUrl.replace('__ID__',id),
                                dataType:'JSON',
                                success:function (json) {
                                    //console.log(json);
                                    if(json.code==1) {
                                        bindData(body, json.data.goods);
                                    }
                                }
                            })
                        }
                    },
                    onsure:function (body) {
						var data = getData(body);
                        $.ajax({
                            url:id>0?editUrl.replace('__ID__',id):addUrl,
                            type:'POST',
                            dataType:'JSON',
                            data:data,
                            success:function (json) {
                                //console.log(json);
                                dialog.alert(json.msg);
                                if(json.code==1){
                                    location.reload();
                                    dlg.close();
                                }
                            }
                        });
                        return false;
                    }
                }).show(addTpl,id>0?'编辑商品':'添加商品');
            }
            w.actionAdd=function () {
                editGoods(0)
            };

            w.actionEdit=function () {
                editGoods($(this).data('id'))
            };
            var batchAddTpl = $('#batchAddTpl').html();
            var batchAddUrl = '{:url("goods/batch")}';

            w.actionBatchadd=function () {
                var dlg = new Dialog({
                    onshown:function (body) {
                    },
                    onsure:function (body) {
                        var data = getData(body);
                        $.ajax({
                            url:batchAddUrl,
                            type:'POST',
                            dataType:'JSON',
                            data:data,
                            success:function (json) {
                                //console.log(json);
                                dialog.alert(json.msg);
                                if(json.code==1){
                                    location.reload();
                                    dlg.close();
                                }
                            }
                        });
                        return false;
                    }
                }).show(batchAddTpl,'批量添加');
            };
        })(window);
	</script>
</block>