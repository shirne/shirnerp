<?php
namespace app\common\model;

use app\common\facade\GoodsCategoryFacade;

/**
 * Class GoodsModel
 * @package app\common\model
 */
class GoodsModel extends ContentModel
{
    protected $autoWriteTimestamp = true;

    function __construct($data = [])
    {
        parent::__construct($data);
        $this->cateFacade=GoodsCategoryFacade::getFacadeInstance();
    }
}