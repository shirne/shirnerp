{extend name="public:print" /}

{block name="body"}

    <div class="page-wrapper container ml-auto mr-auto mb-3 d-print-none">
        <div class="pl-3 pr-3">仓库：{$storage.title}</div>
        <div class="col">
            &nbsp;
        </div>
        <div class="col">
            <div class="input-group input-group-sm ml-auto" style="width: 100px;">
                <div class="input-group-prepend"><button class="btn btn-outline-secondary sizeminus" type="button" id="button-addon1"><i class="ion-md-remove"></i></button></div>
                <input type="text" class="form-control text-center" name="fontsize" value="14"  />
                <div class="input-group-append"><button class="btn btn-outline-secondary sizeplus" type="button" id="button-addon1"><i class="ion-md-add"></i></button></div>
            </div>
        </div>
        <div class="col text-right">
            <a href="javascript:" class="btn btn-primary print-btn d-print-none">打印</a>
        </div>
    </div>
    <div id="page-wrapper" class="container table-page m-auto">

        <table class="table table-bordered">
            <thead>
            <tr>
                <th width="50">#</th>
                <td>编码</td>
                <th>品名</th>
                <th>库存</th>
                <th>单位</th>
                <th>盘点</th>
                <th>备注</th>
            </tr>
            </thead>
            <tbody>
            <empty name="goods">{:list_empty(7)}</empty>
            {volist name="goods" id="v" }
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.goods_no}</td>
                    <td>{$v.title}</td>
                    <td>{$v.count}</td>
                    <td>{$v.unit}</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
            {/volist}
            </tbody>
        </table>

    </div>
{/block}
{block name="script"}
    <script type="text/javascript" src="__STATIC__/store.js/store.modern.min.js"></script>
    <script type="text/javascript">
        jQuery(function ($) {
            window.print();
            $('.print-btn').click(function () {
                window.print();
            })
            var defaultsize=store.get('print-font-size');
            if(!defaultsize) {
                defaultsize = $('.table-page').css('font-size').replace(/[^\d]+/,'');
            }
            if(!defaultsize) {
                defaultsize = 14
                $('.table-page').css('font-size',defaultsize+'px')
            }

            var inputsize=$('[name=fontsize]')
            inputsize.change(function (e) {
                var fontsize=$(this).val()
                fontsize=parseInt(fontsize)
                if(isNaN(fontsize))fontsize=defaultsize
                store.set('print-font-size',fontsize);
                $('.table-page').css('font-size',fontsize+'px');
            })
            $('.sizeplus').click(function (e) {
                var val=inputsize.val()
                val=parseInt(val)
                if(isNaN(val))val=defaultsize
                val ++
                inputsize.val(val).trigger('change')
            })
            inputsize.val(defaultsize).trigger('change')
            $('.sizeminus').click(function (e) {
                var val=inputsize.val()
                val=parseInt(val)
                if(isNaN(val))val=defaultsize
                val --
                inputsize.val(val).trigger('change')
            })
        })
    </script>
{/block}