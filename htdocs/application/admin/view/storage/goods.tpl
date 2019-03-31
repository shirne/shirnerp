<extend name="public:base" />

<block name="body">
    <include file="public/bread" menu="storage_index" title="商品列表" />
    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-md-6">
                <div class="btn-toolbar list-toolbar" role="toolbar" aria-label="Toolbar with button groups">
                    <a href="{:url('storage/export',['id'=>$id])}" class="btn btn-outline-primary btn-sm mr-2" ><i class="ion-md-download"></i> 导出</a>
                    <a href="{:url('storage/prints',['id'=>$id])}" target="_blank" class="btn btn-outline-primary btn-sm print-btn" ><i class="ion-md-print"></i> 打印</a>
                </div>
            </div>
            <div class="col-md-6">
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
                        <a class="btn btn-outline-primary action-btn" data-action="edit" data-needchecks="false" data-id="{$v.id}" title="编辑" href="{:url('goods/edit',array('id'=>$v['id']))}"><i class="ion-md-create"></i> </a>
                        <a class="btn btn-outline-danger link-confirm" title="{:lang('Delete')}" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('goods/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                    </td>
                </tr>
            </volist>
            </tbody>
        </table>

    </div>
</block>
<block name="script">
    <script type="text/javascript">

    </script>
</block>