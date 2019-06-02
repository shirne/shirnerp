<extend name="public:base" />
<block name="header">
    <style type="text/css">
        html{overflow-y:scroll;}
    </style>
</block>
<block name="body">

    <include file="public/bread" menu="goods_index" title="商品排行" />

    <div id="page-wrapper">
        <div class="list-header">
            <form class="noajax" action="{:url('goods/rank')}" method="post">
                <div class="form-row">
                    <div class="form-group col input-group input-group-sm date-range">
                        <div class="input-group-prepend">
                            <span class="input-group-text">统计时间</span>
                        </div>
                        <input type="text" class="form-control fromdate" name="start_date" placeholder="选择开始日期" value="{$start_date}">
                        <div class="input-group-middle"><span class="input-group-text">-</span></div>
                        <input type="text" class="form-control todate" name="end_date" placeholder="选择结束日期" value="{$end_date}">
                    </div>
                    <div class="form-group col">
                        <input type="submit" class="btn btn-primary btn-sm btn-submit ml-2" value="确定"/>
                    </div>
                </div>
            </form>
        </div>
        <div class="row chart-box">
            <div class="col"><canvas id="purchaseChart" width="400" height="400"></canvas></div>
            <div class="col"><canvas id="saleChart" width="400" height="400"></canvas></div>
        </div>
    </div>

</block>
<block name="script">
    <script type="text/javascript" src="__STATIC__/chart/Chart.bundle.min.js"></script>
    <script type="text/javascript">
        var pchart = document.getElementById("purchaseChart");
        var schart = document.getElementById("saleChart");
        var bgColors = [
            'rgba(255, 99, 132, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 159, 64, 0.2)'
        ];
        var bdColors=[];
        var options={

        };
        var purchaseChart = new Chart(pchart, {
            type: 'pie',
            data: {
                labels: JSON.parse('{:json_encode(array_column($saleStatics,"label"))}'),
                datasets: [{
                    label: '商品销售量',
                    data: JSON.parse('{:json_encode(array_column($saleStatics,"value"))}'),
                    backgroundColor: bgColors,
                    borderColor: bdColors,
                    borderWidth: 1
                }]
            },
            options: options
        });
        var saleChart = new Chart(schart, {
            type: 'pie',
            data: {
                labels: JSON.parse('{:json_encode(array_column($purchaseStatics,"label"))}'),
                datasets: [{
                    label: '商品采购量',
                    data: JSON.parse('{:json_encode(array_column($purchaseStatics,"value"))}'),
                    backgroundColor: bgColors,
                    borderColor: bdColors,
                    borderWidth: 1
                }]
            },
            options: options
        });

    </script>
</block>