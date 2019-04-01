<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="finance_index" title="客户财务" />

    <div id="page-wrapper">
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
                    <td> {$finance.sales.total} </td>
                    <td> {$finance.sales.in30days} </td>
                    <td> {$finance.sales.in90days} </td>
                    <td> {$finance.sales.out90days} </td>
                </tr>
                <tr>
                    <td>应付账款</td>
                    <td> {$finance.purchases.total} </td>
                    <td> {$finance.purchases.in30days} </td>
                    <td> {$finance.purchases.in90days} </td>
                    <td> {$finance.purchases.out90days} </td>
                </tr>
            </table>
        </div>
    </div>

</block>