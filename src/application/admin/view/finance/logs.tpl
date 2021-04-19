{extend name="public:base" /}

{block name="body"}
    {include file="public/bread" menu="finance_logs" title="" /}

    <div id="page-wrapper">
        <div class="row list-header">
            <div class="col-md-12">
                <form action="{:url('finance/logs',searchKey('fromdate,todate',''))}" class="form-inline" >
                    <div class="input-group date-range">
                        <div class="input-group-prepend"><span class="input-group-text">时间范围</span></div>
                        <input type="text" class="form-control" name="fromdate" value="{$fromdate}">
                        <div class="input-group-middle"><span class="input-group-text">-</span></div>
                        <input type="text" class="form-control" name="todate" value="{$todate}">
                        <div class="input-group-append">
                          <button class="btn btn-outline-dark" type="submit"><i class="ion-md-search"></i></button>
                        </div>
                    </div>
                    {if $id > 0}
                        <div class="btn-group ml-3">
                            <button type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">客户: {$customer.title}<span class="caret"></span>
                            </button>
                            <div class="dropdown-menu">
                                <a class="dropdown-item" href="{:url('logs',searchKey('id',0))}">不限客户</a>
                            </div>
                        </div>
                    {/if}
                    {if $from_id > 0}
                        <div class="btn-group ml-3">
                            <button type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">供应商: {$supplier.title}<span class="caret"></span>
                            </button>
                            <div class="dropdown-menu">
                                <a class="dropdown-item" href="{:url('logs',searchKey('from_id',0))}">不限供应商</a>
                            </div>
                        </div>
                    {/if}
                    <div class="btn-group ml-3">
                        <button type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            {$types[$type]} <span class="caret"></span>
                        </button>
                        <div class="dropdown-menu">
                            {foreach $types as $k => $t}
                                <a class="dropdown-item" href="{:url('logs',searchKey('type',$k))}">{$t}</a>
                            {/foreach}
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <table class="table table-hover table-striped">
            <thead>
            <tr>
                <th width="50">编号</th>
                <th>订单</th>
                <th>付款方式</th>
                <th>金额</th>
                <th>来源</th>
                <th>时间</th>
                <th>备注</th>
                <th width="70"></th>
            </tr>
            </thead>
            <tbody>
            {php}$empty=list_empty(8);{/php}
            {volist name="logs" id="v" empty="$empty"}
                <tr>
                    <td>{$v.id}</td>
                    <td>
                        {if $v['type'] == 'sale'}
                            <a href="{:url('saleOrder/detail',['id'=>$v['order_id']])}" rel="ajax" data-title="订单详情">
                            <span class="badge badge-info">销售单</span> {$v['order_id']}
                            </a>
                            {elseif condition="$v['type'] == 'purchase'"/}
                            <a href="{:url('purchaseOrder/detail',['id'=>$v['order_id']])}" rel="ajax" data-title="订单详情">
                            <span class="badge badge-warning">采购单</span> {$v['order_id']}
                            </a>
                            {else/}
                            {$v['order_id']}
                        {/if}
                    </td>
                    <td>{$v.pay_type|finance_type|raw}</td>
                    <td class="{$v['amount']>0?'text-success':'text-danger'}">
                        <span class="badge badge-info">{$v.currency}</span> {$v.amount}
                    </td>
                    <td>
                        {if $v['customer_id'] > 0}
                            <span class="badge badge-info">客户</span> {$v['customer_title']}
                            {else/}
                            <span class="badge badge-warning">供应商</span>{$v['supplier_title']}
                        {/if}
                    </td>
                    <td>{$v.create_time|showdate}</td>
                    <td>{$v.remark}</td>
                    <td>

                    </td>
                </tr>
            {/volist}
            </tbody>
        </table>
        {$page|raw}
    </div>

{/block}