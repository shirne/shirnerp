<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="finance_index" title="成本核算" />

    <div id="page-wrapper">
        <div class="row list-header">
            <div class="col">
                <form action="{:url('finance/logs',searchKey('fromdate,todate',''))}" class="form-inline" method="post">
                    <div class="input-group date-range">
                        <div class="input-group-prepend"><span class="input-group-text">时间范围</span></div>
                        <input type="text" class="form-control" name="fromdate" value="{$fromdate}">
                        <div class="input-group-middle"><span class="input-group-text">-</span></div>
                        <input type="text" class="form-control" name="todate" value="{$todate}">
                        <div class="input-group-append">
                            <button class="btn btn-outline-dark" type="submit"><i class="ion-md-search"></i></button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

    </div>

</block>