{extend name="public:base" /}

{block name="body"}
    {include file="public/bread" menu="storage_index" title="商品列表" /}
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
                <th>库存</th>
                <th>单位</th>
                <th>分类</th>
                <th>说明</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            {empty name="goods"}{:list_empty(8)}{/empty}
            {volist name="goods" id="v" }
                <tr>
                    <td><input type="checkbox" name="id" value="{$v.id}" /></td>
                    <td><span class="badge badge-info">{$v.goods_no}</span> {$v.title}</td>
                    <td>
                        {$v.count}
                    </td>
                    <td>{$v.unit}</td>
                    <td>{$v.category_title}</td>
                    <td>{$v.description}</td>
                    <td class="operations">

                    </td>
                </tr>
            {/volist}
            </tbody>
        </table>

    </div>
{/block}
{block name="script"}
    <script type="text/javascript">

    </script>
{/block}