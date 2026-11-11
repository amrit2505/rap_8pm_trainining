@EndUserText.label: 'Table Function CDS'
@ClientHandling.algorithm: #SESSION_VARIABLE
@ClientHandling.type: #CLIENT_DEPENDENT
define table function Z8PM_CDS_TF
returns {
    client : abap.clnt;
    company_name : abap.char(256);
    total_Sales : abap.curr(13,2);
    currency_code : abap.cuky;
    customer_rank : abap.int4;
  
}
implemented by method Z8PM_ABAP_AMDP_CLASS=>get_total_sales;