CLASS z8pm_sales_Fill_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
        METHODS FILL_TRANSACTION_DATA.
        METHODS FILL_MASTER_DATA.
        METHODS FLUSH.
ENDCLASS.



CLASS z8pm_sales_Fill_data IMPLEMENTATION.
    METHOD IF_OO_ADT_CLASSRUN~MAIN.
    FLUSH( ). "erasing any existing data in all 4 tables
    FILL_MASTER_DATA( ). "filling bp an product table
    FILL_TRANSACTION_DATA( ). "filling sales header and item table
    OUT->WRITE(
      EXPORTING
        DATA   = 'Processing is completed Successfully'
*        NAME   =
*      RECEIVING
*        OUTPUT =
    ).
  ENDMETHOD.
   METHOD FILL_MASTER_DATA.
    DATA : LT_BP   TYPE TABLE OF z8pm_tab_bpa,
           LT_PROD TYPE TABLE OF z8pm_tab_prod.


    APPEND VALUE #(
          BP_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
          BP_ROLE = '01'
          COMPANY_NAME = 'TACUM'
          STREET = 'Victoria Street'
          CITY = 'Kolkata'
          COUNTRY = 'IN'
          REGION = 'APJ'
          )
          TO LT_BP.
    APPEND VALUE #(
          BP_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
          BP_ROLE = '01'
          COMPANY_NAME = 'SAP'
          STREET = 'Rosvelt Street Road'
          CITY = 'Wallforf'
          COUNTRY = 'DE'
          REGION = 'EMEA'
          )
          TO LT_BP.
    APPEND VALUE #(
         BP_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         BP_ROLE = '01'
         COMPANY_NAME = 'Asia High Tech'
         STREET = '1-7-2 Otemachi'
         CITY = 'Tokyo'
         COUNTRY = 'JP'
         REGION = 'APJ'
         )
         TO LT_BP.
    APPEND VALUE #(
         BP_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         BP_ROLE = '01'
         COMPANY_NAME = 'AVANTEL'
         STREET = 'Bosque de Duraznos'
         CITY = 'Maxico'
         COUNTRY = 'MX'
         REGION = 'NA'
         )
         TO LT_BP.
    APPEND VALUE #(
         BP_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         BP_ROLE = '01'
         COMPANY_NAME = 'Pear Computing Services'
         STREET = 'Dunwoody Xing'
         CITY = 'Atlanta Geogia'
         COUNTRY = 'US'
         REGION = 'NA'
         )
         TO LT_BP.
    APPEND VALUE #(
         BP_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         BP_ROLE = '01'
         COMPANY_NAME = 'PicoBit'
         STREET = 'Fifth Avenue'
         CITY = 'New York City'
         COUNTRY = 'US'
         REGION = 'NA'
         )
         TO LT_BP.
    APPEND VALUE #(
         BP_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         BP_ROLE = '01'
         COMPANY_NAME = 'TACUM'
         STREET = 'Victoria Street'
         CITY = 'Kolkata'
         COUNTRY = 'IN'
         REGION = 'APJ'
         )
         TO LT_BP.
    APPEND VALUE #(
         BP_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         BP_ROLE = '01'
         COMPANY_NAME = 'Indian IT Trading Company'
         STREET = 'Nariman Point'
         CITY = 'Mumbai'
         COUNTRY = 'IN'
         REGION = 'APJ'
         )
         TO LT_BP.
    APPEND VALUE #(
         PRODUCT_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         NAME = 'Blaster Extreme'
         CATEGORY = 'Speakers'
         PRICE = '1500.00'
         CURRENCY_CODE = 'INR'
         DISCOUNT = 3
         )
         TO lt_PROD.
    APPEND VALUE #(
         PRODUCT_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         NAME = 'Sound Booster'
         CATEGORY = 'Speakers'
         PRICE = '2500.00'
         CURRENCY_CODE = 'INR'
         DISCOUNT = 2
         )
         TO lt_PROD.
    APPEND VALUE #(
         PRODUCT_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         NAME = 'Smart Office'
         CATEGORY = 'Software'
         PRICE = '1540.00'
         CURRENCY_CODE = 'INR'
         DISCOUNT = 32
         )
         TO lt_PROD.
    APPEND VALUE #(
         PRODUCT_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         NAME = 'Smart Design'
         CATEGORY = 'Software'
         PRICE = '2400.00'
         CURRENCY_CODE = 'INR'
         DISCOUNT = 12
         )
         TO lt_PROD.
    APPEND VALUE #(
         PRODUCT_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         NAME = 'Transcend Carry pocket'
         CATEGORY = 'PCs'
         PRICE = '14000.00'
         DISCOUNT = 7
         )
         TO lt_PROD.
    APPEND VALUE #(
         PRODUCT_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
         NAME = 'Gaming Monster Pro'
         CATEGORY = 'PCs'
         PRICE = '15500.00'
         CURRENCY_CODE = 'INR'
         DISCOUNT = 8
         )
         TO lt_PROD.

    INSERT z8pm_tab_bpa FROM TABLE @LT_BP.
    INSERT z8pm_tab_prod FROM TABLE @LT_PROD.

  ENDMETHOD.

  METHOD FILL_TRANSACTION_DATA.
    DATA : O_RAND    TYPE REF TO CL_ABAP_RANDOM_INT,
           N         TYPE I,
           SEED      TYPE I,
           LV_DATE   TYPE TIMESTAMP,
           LV_ORD_ID TYPE z8pm_de_id,
           LT_SO     TYPE TABLE OF z8pm_tab_so_h,
           LT_SO_I   TYPE TABLE OF z8pm_tab_so_i.

    SEED = CL_ABAP_RANDOM=>SEED( ).
    CL_ABAP_RANDOM_INT=>CREATE(
      EXPORTING
        SEED = SEED                 " Initial Value of PRNG
        MIN  = 1      " Lower Limit for Value Area
        MAX  = 7       " Upper Limit for Value Area
      RECEIVING
        PRNG = O_RAND                  " Random Number Generator Object
    ).
    GET TIME STAMP FIELD LV_DATE.

    SELECT * FROM z8pm_tab_bpa INTO TABLE @DATA(LT_BPA).
    SELECT * FROM z8pm_tab_prod INTO TABLE @DATA(LT_PROD).

    DO 50 TIMES.
      LV_ORD_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( ).
      N = O_RAND->GET_NEXT( ).
      READ TABLE LT_BPA INTO DATA(LS_BP) INDEX N.
      APPEND VALUE #(
          ORDER_ID = LV_ORD_ID
          ORDER_NO = SY-INDEX
          BUYER = LS_BP-BP_ID
          GROSS_AMOUNT = 10 * N
          CURRENCY_CODE = 'EUR'
          CREATED_BY = SY-UNAME
          CREATED_ON = LV_DATE
          CHANGED_BY = SY-UNAME
          CHANGED_ON = LV_DATE
      ) TO LT_SO.
      do 2 times.
        READ TABLE LT_PROD INTO DATA(LS_PROD) INDEX N.
        APPEND VALUE #(
            ITEM_ID = CL_UUID_FACTORY=>CREATE_SYSTEM_UUID( )->CREATE_UUID_C32( )
            ORDER_ID = LV_ORD_ID
            PRODUCT = LS_PROD-PRODUCT_ID
            QTY = N
            UOM = 'EA'
            GROSS_AMOUNT = n * LS_PROD-PRICE
            CURRENCY_CODE = LS_PROD-currency_code
        ) TO LT_SO_I.
      enddo.
    ENDDO.

    INSERT z8pm_tab_so_h FROM TABLE @LT_SO.
    INSERT z8pm_tab_so_i FROM TABLE @LT_SO_I.

  ENDMETHOD.

  METHOD FLUSH.
    DELETE FROM : z8pm_tab_bpa, z8pm_tab_prod, z8pm_tab_so_h, z8pm_tab_so_i.
  ENDMETHOD.
ENDCLASS.

