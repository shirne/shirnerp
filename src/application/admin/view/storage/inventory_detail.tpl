{extend name="public:base" /}

{block name="body"}

    {include file="public/bread" menu="storage_index" title="仓库盘点" /}

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">
                <a href="{:url('storage/inventory',['storage_id'=>$storage_id])}" class="btn btn-outline-primary btn-sm"><i class="ion-md-arrow-back"></i> 返回</a>
            </div>
            <div class="col-6">
            </div>
        </div>
        <div class="row">
            <div class="col">仓库：{$storage.title}</div>
            <div class="col">单号：{$inventory.order_no}</div>
            <div class="col">盘点日期：{$inventory.inventory_time|showdate}</div>
        </div>
        <table class="table table-hover table-striped">
            <thead>
            <tr>
                <th width="50">编号</th>
                <th>品名</th>
                <th>初始库存</th>
                <th>盘点库存</th>
                <th>盈亏</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            {php}$empty=list_empty(6);{/php}
            {volist name="goods" id="v" empty="$empty"}
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.title}</td>
                    <td>{$v.count}</td>
                    <td>{$v.new_count}</td>
                    <td>
                        {if $v['new_count'] > $v['count']}
                            <span class="badge badge-success">+ {$v['new_count']-$v['count']}</span>
                            {elseif condition="$v['new_count'] LT $v['count']" /}
                            <span class="badge badge-error">- {$v['count']-$v['new_count']}</span>
                            {else/}
                            <span class="badge badge-secondary"> - </span>
                        {/if}
                    </td>
                    <td class="operations">

                    </td>
                </tr>
            {/volist}
            </tbody>
        </table>
        {$page|raw}
    </div>
{/block}
{block name="script"}
    <script type="text/javascript">
        jQuery(function ($) {


        })
    </script>
{/block}