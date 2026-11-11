CLASS z8pm_abap_amdp_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .
    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS : SUM_TWO_NUMBERS
                AMDP OPTIONS CDS SESSION CLIENT DEPENDENT
                        IMPORTING
                            value(p_num1) type i
                            value(p_num2) type i
                        exporting
                            value(e_res) type i.


     CLASS-methods : company_details
                    AMDP OPTIONS CDS SESSION CLIENT DEPENDENT
                    importing
                        value(i_bp_id) type Z8PM_DE_ID
                    exporting
                        value(e_comp_name) type Z8PM_DE_COMPANY_NAME.
     CLASS-METHODS : GET_PRODUCT_DETAILS
                AMDP OPTIONS CDS SESSION CLIENT DEPENDENT
                        IMPORTING
                            value(i_tax) type i
                        exporting
                            value(i_tab) type Z8PM_TT_PRODUCTS.

     CLASS-methods : get_total_sales
                        for table function Z8PM_CDS_TF.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z8pm_abap_amdp_class IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*     z8pm_abap_amdp_class=>sum_two_numbers(
*       EXPORTING
*         p_num1 = 90
*         p_num2 = 35
*       IMPORTING
*         e_res  = data(lv_output)
*     ).

*    z8pm_abap_amdp_class=>company_details(
*      EXPORTING
*        i_bp_id     = '168D590A88E71FE1ACA2DA6CA93D48FC'
*      IMPORTING
*        e_comp_name = data(lv_company_name)
*    ).

    z8pm_abap_amdp_class=>get_product_details(
      EXPORTING
        i_tax = 18
      IMPORTING
        i_tab = data(lt_prod_price)
    ).



     out->write( lt_prod_price ).
  ENDMETHOD.

  method sum_two_numbers BY database procedure
            for hdb language sqlscript options
                READ-only.
        --Write some SQL Script Here
        declare x integer;
        declare y integer;
        declare z integer;

        x := :p_num1;
        y := :p_num2;
        z := :x + :y;

        --send the response
        e_res := :z;

  endmethod.
  METHOD company_details by database procedure
    for hdb language sqlscript options READ-only
        using Z8PM_TAB_BPA.

       select company_name
            into e_comp_name
            from z8pm_tab_bpa
          where bp_id = :i_bp_id;

  ENDMETHOD.

  METHOD get_product_details BY database procedure
        for hdb language sqlscript
            options READ-only
            using z8pm_tab_prod.

      --Step 1 :- Declaring the variables
      declare lv_count integer;
      declare i integer;
      declare lv_mrp bigint;
      declare lv_price_d integer;

      --Step 2 :- Get all the products from table in a internal table
      lt_products = select * from z8pm_tab_prod;
      --Step 3 :- Get the record count of total products
      lv_count = record_count( :lt_products );
      --Step 4 :- loop at each of the record
      for i in 1..:lv_count do
            --Calculate the MRP based on the input tax
         lv_price_d = :lt_products.price[i] * ( 100 - :lt_products.discount[i] ) / 100;
         lv_mrp = lv_price_d * ( 100 + :i_tax ) / 100;
            -- if the mrp is > 15k, apply 10% off
          if :lv_mrp > 15000 then
              lv_mrp = :lv_mrp * 0.90;
          end if;
            --fill the result internal table
            :i_tab.insert(
                (
                   :lt_products.name[i],
                   :lt_products.category[i],
                   :lt_products.price[i],
                   :lt_products.currency_code[i],
                   :lv_price_d,
                   :lv_mrp
                ), i
            );

      end for;

  ENDMETHOD.

  METHOD get_total_sales by database function
    for hdb language sqlscript options read-only
         using z8pm_tab_bpa z8pm_tab_so_h z8pm_tab_so_i.

        --SQL Script code

      return
            Select
                bpa.client as client,
                bpa.company_name as company_name,
                sum ( item.gross_amount ) as total_Sales,
                item.currency_code as currency_code,
                rank ( ) over ( order by sum ( item.gross_amount ) desc ) as customer_rank
            from z8pm_tab_bpa as bpa
                inner join z8pm_tab_so_h as header
                on bpa.bp_id = header.buyer
                inner join z8pm_tab_so_i as item
                on header.order_id = item.order_id
                group by
                    bpa.client,
                    bpa.company_name,
                    item.currency_code;

  ENDMETHOD.

ENDCLASS.
