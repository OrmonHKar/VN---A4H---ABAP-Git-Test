@EndUserText.label: 'abstract entity for calculate amount per year'

@Metadata.allowExtensions: true
define root abstract entity ZE_I_TB_CALCULATEAMOUNT
//define abstract entity ZE_I_TB_CALCULATEAMOUNT
{
    @Semantics.amount.currencyCode: 'Currency'
    key amount : ze_tv_mon_amount;
    key fyear  : gjahr;
    currency         : ze_tv_currency;
}
