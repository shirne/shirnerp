<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="finance_index" title="成本核算" />

    <div id="page-wrapper">
        <div class="row list-header">
            <div class="col">
                <form action="{:url('finance/accounting',searchKey('start_date,end_date',''))}" class="form-inline" >
                    <div class="input-group date-range">
                        <div class="input-group-prepend"><span class="input-group-text">时间范围</span></div>
                        <input type="text" class="form-control fromdate" name="start_date" value="{$start_date}">
                        <div class="input-group-middle"><span class="input-group-text">-</span></div>
                        <input type="text" class="form-control todate" name="end_date" value="{$end_date}">
                        <div class="input-group-append">
                            <button class="btn btn-outline-dark" type="submit"><i class="ion-md-search"></i></button>
                        </div>
                    </div>
                    <if condition="!empty($start_date)">
                        <a href="{:url('accounting',['export'=>1,'start_date'=>$start_date,'end_date'=>$end_date])}" class="btn btn-outline-primary ml-2"><i class="ion-md-download"></i> 导出</a>
                    </if>
                </form>
            </div>
        </div>
        <if condition="empty($start_date)">
            <div class="p-4 text-center text-muted">请选择日期查看</div>
            <else/>
            <div class="row">
                <div class="col">
                    <div class="card">
                        <div class="card-header">销售</div>
                        <table class="table">
                            <thead>
                            <tr class="text-right">
                                <th class="text-center">\</th>
                                <th>订单数</th>
                                <th>总金额</th>
                                <th>已付款</th>
                                <th>未付款</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>销售单</td>
                                <td class="text-right">{$sale_total.count}</td>
                                <td class="text-right">{$sale_total.order_amount|number_format=2}</td>
                                <td class="text-right">{$sale_total.order_payed_amount|number_format=2}</td>
                                <td class="text-right">{$sale_total['order_amount']-$sale_total['order_payed_amount']|number_format=2}</td>
                            </tr>
                            <tr>
                                <td>退货单</td>
                                <td class="text-right">{$sale_total.back_count}</td>
                                <td class="text-right">{$sale_total.back_amount|number_format=2}</td>
                                <td class="text-right">{$sale_total.back_payed_amount|number_format=2}</td>
                                <td class="text-right">{$sale_total['back_amount']-$sale_total['back_payed_amount']|number_format=2}</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>

                </div>
                <div class="col">
                    <div class="card">
                        <div class="card-header">采购</div>
                        <table class="table">
                            <thead>
                            <tr class="text-right">
                                <th class="text-center">\</th>
                                <th>订单数</th>
                                <th>总金额</th>
                                <th>已付款</th>
                                <th>未付款</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>采购单</td>
                                <td class="text-right">{$purchase_total.count}</td>
                                <td class="text-right">{$purchase_total.order_amount|number_format=2}</td>
                                <td class="text-right">{$purchase_total.order_payed_amount|number_format=2}</td>
                                <td class="text-right">{$purchase_total['order_amount']-$purchase_total['order_payed_amount']|number_format=2}</td>
                            </tr>
                            <tr>
                                <td>退货单</td>
                                <td class="text-right">{$purchase_total.back_count}</td>
                                <td class="text-right">{$purchase_total.back_amount|number_format=2}</td>
                                <td class="text-right">{$purchase_total.back_payed_amount|number_format=2}</td>
                                <td class="text-right">{$purchase_total['back_amount']-$purchase_total['back_payed_amount']|number_format=2}</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>
            <table class="table table-bordered table-hover table-striped mt-3">
                <thead class="multirow text-center">
                <tr>
                    <th width="50" rowspan="2">编号</th>
                    <th rowspan="2">品名</th>
                    <th rowspan="2">期初数量</th>
                    <th colspan="3" >采购</th>
                    <th colspan="3" >销售</th>
                    <th rowspan="2">账面结存数量</th>
                    <th rowspan="2">盘点结存数量</th>
                    <th colspan="2" >差异</th>
                    <th rowspan="2">销售成本</th>
                    <th rowspan="2">毛利润</th>
                    <th rowspan="2">毛利率%</th>
                    <th rowspan="2">损耗率%</th>
                </tr>
                <tr>
                    <th>数量</th>
                    <th>单价</th>
                    <th>金额</th>
                    <th>数量</th>
                    <th>单价</th>
                    <th>金额</th>
                    <th>差异数量</th>
                    <th>差异金额</th>
                </tr>
                </thead>
                <tbody class="text-right">
                <php>$empty=list_empty(17);</php>
                <volist name="finance['goods']" id="v" empty="$empty">
                    <tr>
                        <td class="text-center">{$v.id}</td>
                        <td class="text-center">{$v.title}</td>
                        <td>{$v.start_count}</td>
                        <td>{$v.purchase.count}</td>
                        <td>{$v.purchase.avg_price|number_format=2}</td>
                        <td>{$v.purchase.total_amount}</td>
                        <td>{$v.sale.count}</td>
                        <td>{$v.sale.avg_price|number_format=2}</td>
                        <td>{$v.sale.total_amount}</td>
                        <td>{$v.end_count}</td>
                        <td>{$v['inventery_count']}</td>
                        <td></td>
                        <td></td>

                        <td>

                        </td>
                        <td></td>
                        <td></td>
                        <td></td>
                    </tr>
                </volist>
                </tbody>
            </table>

        </if>
    </div>

</block>