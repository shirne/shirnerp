<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="finance_index" title="客户财务" />

    <div id="page-wrapper">
        <div class="row list-header">
            <div class="col">
                <a href="{:url('accounting')}" class="btn btn-outline-primary"><i class="ion-md-podium"></i> 成本核算</a>
            </div>
        </div>
        <div class="card border-default">
            <div class="card-header">
                <h5 class="panel-title"><i class="ion-md-swap"></i> 资金</h5>
            </div>
            <table class="table table-striped">
                <tr>
                    <th>款项</th>
                    <th>总额</th>
                    <th>账龄30天内</th>
                    <th>账龄90天内</th>
                    <th>账龄90天以上</th>
                </tr>
                <tr>
                    <td>应收账款</td>
                    <td> {$finance.sales.total|show_finance|raw} </td>
                    <td> {$finance.sales.in30days|show_finance|raw} </td>
                    <td> {$finance.sales.in90days|show_finance|raw} </td>
                    <td> {$finance.sales.out90days|show_finance|raw} </td>
                </tr>
                <if condition="!empty($finance['sales_back']['total'])">
                    <tr>
                        <td>销售退货</td>
                        <td> {$finance.sales_back.total|show_finance|raw} </td>
                        <td> {$finance.sales_back.in30days|show_finance|raw} </td>
                        <td> {$finance.sales_back.in90days|show_finance|raw} </td>
                        <td> {$finance.sales_back.out90days|show_finance|raw} </td>
                    </tr>
                </if>
                <tr>
                    <td>应付账款</td>
                    <td> {$finance.purchases.total|show_finance|raw} </td>
                    <td> {$finance.purchases.in30days|show_finance|raw} </td>
                    <td> {$finance.purchases.in90days|show_finance|raw} </td>
                    <td> {$finance.purchases.out90days|show_finance|raw} </td>
                </tr>
                <if condition="!empty($finance['purchases_back']['total'])">
                    <tr>
                        <td>采购退货</td>
                        <td> {$finance.purchases_back.total|show_finance|raw} </td>
                        <td> {$finance.purchases_back.in30days|show_finance|raw} </td>
                        <td> {$finance.purchases_back.in90days|show_finance|raw} </td>
                        <td> {$finance.purchases_back.out90days|show_finance|raw} </td>
                    </tr>
                </if>
            </table>
        </div>
    </div>

</block>