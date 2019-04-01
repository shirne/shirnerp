<extend name="public:base" />

<block name="body">
    <include file="public/bread" menu="finance_logs" title="" />

    <div id="page-wrapper">
        <div class="row list-header">
            <div class="col-md-12">
                <form action="{:url('financec/logs',searchKey('fromdate,todate',''))}" class="form-inline" method="post">
                    <div class="input-group date-range">
                        <div class="input-group-prepend"><span class="input-group-text">时间范围</span></div>
                        <input type="text" class="form-control" name="fromdate" value="{$fromdate}">
                        <div class="input-group-middle"><span class="input-group-text">-</span></div>
                        <input type="text" class="form-control" name="todate" value="{$todate}">
                        <div class="input-group-append">
                          <button class="btn btn-outline-dark" type="submit"><i class="ion-md-search"></i></button>
                        </div>
                    </div>
                    <if condition="$id">
                        <div class="btn-group ml-3">
                            <button type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">客户: {$customer.title}<span class="caret"></span>
                            </button>
                            <div class="dropdown-menu">
                                <a class="dropdown-item" href="{:url('logs',searchKey('id',0))}">不限客户</a>
                            </div>
                        </div>
                    </if>
                    <if condition="$from_id">
                        <div class="btn-group ml-3">
                            <button type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">供应商: {$supplier.title}<span class="caret"></span>
                            </button>
                            <div class="dropdown-menu">
                                <a class="dropdown-item" href="{:url('logs',searchKey('from_id',0))}">不限供应商</a>
                            </div>
                        </div>
                    </if>
                    <div class="btn-group ml-3">
                        <button type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            {$types[$type]} <span class="caret"></span>
                        </button>
                        <div class="dropdown-menu">
                            <foreach name="types" item="t" key="k">
                                <a class="dropdown-item" href="{:url('logs',searchKey('type',$k))}">{$t}</a>
                            </foreach>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <table class="table table-hover table-striped">
            <thead>
            <tr>
                <th width="50">编号</th>
                <th>类型</th>
                <th>订单</th>
                <th>金额</th>
                <th>来源</th>
                <th>时间</th>
                <th>备注</th>
                <th width="70"></th>
            </tr>
            </thead>
            <tbody>
            <php>$empty=list_empty(8);</php>
            <volist name="logs" id="v" empty="$empty">
                <tr>
                    <td>{$v.id}</td>
                    <td>{$types[$v['type']]}</td>
                    <td>
                        <if condition="$v['type'] EQ 'sale'">
                            <span class="badge badge-info">销售单</span> {$v['order_id']}
                            <elseif condition="$v['type'] EQ 'purchase'"/>
                            <span class="badge badge-warning">采购单</span> {$v['order_id']}
                            <else/>
                            -
                        </if>
                    </td>
                    <td class="{$v['amount']>0?'text-success':'text-danger'}">{$v.field|money_type|raw}&nbsp;{$v.amount|showmoney}</td>
                    <td>
                        <if condition="$v['customer_id']">
                            <span class="badge badge-info">客户</span> {$v['customer_title']}
                            <else/>
                            <span class="badge badge-warning">供应商</span>{$v['supplier_title']}
                        </if>
                    </td>
                    <td>{$v.create_time|showdate}</td>
                    <td>{$v.remark}</td>
                    <td>

                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
        {$page|raw}
    </div>

</block>