<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="storage_index" title="仓库盘点" />

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">
                <a href="{:url('storage/createInventory',['storage_id'=>$storage_id])}" data-tab="timestamp" class="btn btn-outline-primary btn-sm"><i class="ion-md-add"></i> 新建盘点单</a>
            </div>
            <div class="col-6">
            </div>
        </div>
        <table class="table table-hover table-striped">
            <thead>
            <tr>
                <th width="50">编号</th>
                <th>单号</th>
                <th>仓库</th>
                <th>日期</th>
                <th>状态</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <php>$empty=list_empty(6);</php>
            <volist name="lists" id="v" empty="$empty">
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.order_no}</td>
                    <td>{$v.storage_title}</td>
                    <td>{$v.create_time|showdate}</td>
                    <td>
                        <if condition="$v['status'] EQ 1">
                            <span class="badge badge-secondary">已盘点</span>
                            <else/>
                            <span class="badge badge-warning">待盘点</span>
                        </if>
                    </td>
                    <td class="operations">
                        <if condition="$v['status'] EQ 1">
                            <a class="btn btn-outline-primary btn-edit-storage" data-tab="detail-{$v.id}" data-id="{$v.id}" title="详情" href="{:url('storage/inventoryDetail',array('id'=>$v['id']))}"><i class="ion-md-document"></i> </a>
                            <else/>
                            <a class="btn btn-outline-primary" data-tab="edit-{$v.id}" title="盘点" href="{:url('storage/inventoryDetail',array('id'=>$v['id'],'is_edit'=>1))}"><i class="ion-md-today"></i> </a>
                            <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('storage/deleteInventory',array('id'=>$v['id'],'storage_id'=>$storage_id))}" ><i class="ion-md-trash"></i> </a>
                        </if>
                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
        {$page|raw}
    </div>
</block>
<block name="script">

    <script type="text/javascript">
        jQuery(function ($) {

        })
    </script>
</block>