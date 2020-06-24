# UPR-CONVENTION
Contains all logic about UPR Calculation and Maintainance

**UPR**: Là khoản dự phòng của công ty cho các hợp đồng còn hiệu lực tại thời điểm cuối năm tài chính hay là khoản nợ của công ty bảo hiểm đối với khách hàng tại thời điểm trích lập cuối năm 31/12.


[TT 50/2017/TT-BTC](http://www.docluat.vn/van-ban-phap-luat-ve-kinh-doanh-bao-hiem/tt-50-2017-tt-btc-huong-dan-thi-hanh-nghi-dhinh-so-73-2016-ndh-cp-ngay-01-7-2016-cua-chinh-phu-quy-dhinh-chi-tiet-thi-hanh-luat-kinh-doanh-bao-hiem-va-luat-sua-dhoi-bo-sung-mot-so-dhieu-cua-luat-kinh-doanh-bao-hiem-1#TOC-M-c-2.-D-PH-NG-NGHI-P-V-)

### Method:

	Tất cả các sản phẩm đều được tính DPP dựa trên phương pháp 1/365.
	
| Dự phòng phí chưa được hưởng 	| = 	| Phí bảo hiểm x Số ngày bảo hiểm còn lại   của hợp đồng bảo hiểm, tái bảo hiểm 	|
|-----------------------------	|---	|-------------------------------------------------------------------------------	|
|                             	|   	| Tổng số ngày bảo hiểm theo hợp đồng bảo hiểm,   tái bảo hiểm                  	|


### Trigger condition:

	UPR date > booking date
	UPR separately compute original policy and endo 

### Cấp độ tính toán dự phòng theo từng từng loại nghiệp vụ:

LOB	| Policy| Risk | Coverage
:------------ | :-------------| :-------------| :-------------
01 | :heavy_check_mark: |  :x: | :x:
02 | :heavy_check_mark: |  :x: | :x:
03 | :heavy_check_mark: |  :x: | :x:
04 | :heavy_check_mark: |  :x: | :x:
05 | :heavy_check_mark: |  :x: | :x:
06 | :heavy_check_mark: |  :x: | :x:
07 | :heavy_check_mark: |  :x: | :x:
08 | :heavy_check_mark: |  :x: | :x:
Others | :heavy_check_mark: |  :x: | :x:

EXCEPTION:

LOB	|PRODUCT	| Policy| Risk | Coverage
:------------ |:------------ | :-------------| :-------------| :-------------
01	|DVL| :x:	  |  :heavy_check_mark: | :x:
01	|BA | :x: |  :x: | :heavy_check_mark:
01	|DH | :x: |  :x: | :heavy_check_mark:
02	|QX | :x: |  :x: | :heavy_check_mark:
02	|WF | :x: |  :x: | :heavy_check_mark:

Tùy vào đặc thù của từng nghiệp vụ. Trong quá trình tính toán sẽ có những điều chỉnh về thời hạn hiệu lực để số liệu chính xác hơn

##### Nghiệp vụ 01:
TÍnh dự phòng phí theo cấp độ riêng lẻ hợp đồng ngoại trừ DVL được tính riêng theo cấp độ rủi ro
##### Nghiệp vụ 02:

##### Nghiệp vụ 03:
- Do đặc thù các chuyến hàng thường kéo dài không quá 3 tháng. Nên Các hợp đồng có tg hiệu lực > 3 tháng đều được quy về 3 tháng.																						|
- Các hợp đồng có hiệu lực nhỏ hơn 3 tháng sẽ giữ nguyên thời hạn. Vì những đơn nhập chính xác ngày hiệu lực ( thường <3 tháng) thì không cần điều chỉnh

##### Nghiệp vụ 04:

##### Nghiệp vụ 05:

##### Nghiệp vụ 06:

##### Nghiệp vụ 07:

##### Nghiệp vụ khác:

#### Các loại phí tính dự phòng:

| Fee type             	| Duration        	| UPR                         	|
|----------------------	|-----------------	|-----------------------------------	|
| 1. GWP           		| Theo thời hạn hợp đồng 		| Theo như pp trích lập 1/365 Mục 1 	|
| 2. Inward premium    	| Theo thời hạn hợp đồng gốc	| Theo như pp trích lập 1/365 Mục 1 	|
| 3. Inward commission 	| Theo thời hạn hợp đồng gốc 	| Theo như pp trích lập 1/365 Mục 1 	|
| 4. Ceded Premium     	| Theo thời hạn hợp đồng gốc 	| Theo như pp trích lập 1/365 Mục 1 	|
| 5. Ceded commission  	| Theo thời hạn hợp đồng gốc 	| Theo như pp trích lập 1/365 Mục 1 	|
| 6. XOL               	| 1/1-31/12       	| Theo như pp trích lập 1/365 Mục 1 	|


### Quy trình tính toán DPP:

PP tính: Chia tách phí theo tháng

- [ ] Toàn bộ dữ liệu tính toán DPP sẽ được lấy trong [IBMS_GIC].[dbo].[A3_fn_GLDE_COMBINE]( 201301,@DATA_PERIOD, 0 )

- [ ] Hiện tại UPR được tính bằng cách phân tách theo hai nhóm chính: nhóm dịch vụ lớn và nhóm các sản phẩm CORE còn lại.

- **Đối với DVL**: Dữ liệu chia tách phí theo tháng cuối cùng được lưu trong bảng A_PA_ULTI_SPLIT2_CREDIT_PREMIUM
- **Đối với CORE**: Dữ liệu UPR tháng được chạy từ  dbo.A3_fn_tbl_UPR_CORE( @UPR_FLAG, @UPR_FLAG, @UPR_FLAG )

=> Merge 2 nguồn dữ liệu tính toán bên trên ta được số liệu UPR tổng hợp tất cả các nghiệp vụ chi tiết theo hợp đồng


- [ ] Kiểm tra dữ liệu

	1. Hợp đồng có đầy đủ ngày effective date và expiry date hay không?
	2. Effective date <= expiry date?
	3. Thời hạn hiệu lực có hợp lý theo từng đặc thù của các nghiệp vụ?
	4. Thời hạn HĐ gốc không trùng với thời hạn của tái, hoa hồng...? 
	5. Hợp đồng có phí tái/hoa hồng nhưng không có phí gốc?.
 ### Execute sql code


Step 1:
Đối với DVL

Khởi tạo dữ liệu mới

Dữ liệu được phân tách qua theo các bước sau:
- Tổng hợp dữ liệu từ IBMS, server
- Split theo danh sách hợp đồng summary

```SQL
EXEC [IBMS_GIC].[dbo].[A_sp_PA_ULTI_SPLIT_CREDIT_PREMIUM_Summary] @period
EXEC [IBMS_GIC].[dbo].[A_sp_PA_ULTI_SPLIT_CREDIT_PREMIUM_Split] 
```
> Return : [IBMS_GIC].[dbo].[A_PA_ULTI_SPLIT2_CREDIT_PREMIUM]

Đối với trường hợp chạy lại dữ liệu phân tách. Chỉ cần detect những dòng thay đổi và những dòng mới sau đó update/insert lên data hiện tại bằng câu lệnh:
 
```SQL
EXEC [IBMS_GIC].[dbo].[A_sp_PA_ULTI_SPLIT_CREDIT_PREMIUM_Update] @period
```

> Return : [IBMS_GIC].[dbo].[A_PA_ULTI_SPLIT2_CREDIT_PREMIUM]

Step 2: 
Tính toán UPR cho các sản phẩm CORE:
```SQL
SELECT
*
FROM
[IBMS_GIC].[dbo].A3_fn_tbl_UPR_CORE( @UPR_FLAG, @UPR_FLAG, @UPR_FLAG )
```
Step 3:

Merge data giữa 2 step

[UPR_COMBINE](https://github.com/vdhieu101/UPR-CONVENTION/blob/patch-1/UPR_COMBINE.sql)

Step 4:

Upload data vào excel

[UPR_EXCEL](https://github.com/vdhieu101/UPR-CONVENTION/blob/patch-1/(20200428%20-%201.0A)%20UPR%20COMBINE%20202003.xlsx)

### Demo

Mô tả cách tính toán DPD hiện tại trên một số hợp đồng tiêu biểu theo cách chia tách thời hạn theo tháng

> E_fn_SPLIT_INTERVAL1(@p_date_issue, @p_date_expiry, @anchor_date)
> 
> Hàm tính UPR theo phương pháp chia nhỏ thời hạn theo từng tháng. Phí của hợp đồng sẽ được chia đều theo từng tháng (pro-data)
> 

Example: 

Policy A với:

- Effective date: 201901
- Expiry date : 201912 
- function E_fn_SPLIT_INTERVAL1 sẽ chia thời hạn ra thành 12 dòng, mỗi dòng tương ứng 1 tháng và tỉ lệ UPR tương ứng của mỗi tháng:

```SQL
> SELECT
> *
> FROM E_fn_SPLIT_INTERVAL1('20190101','20191231',NULL)
```
![U P R 01](https://github.com/vdhieu101/hieu.vuduc/blob/master/Images/UPR-01.png)

Như vậy ta có thể thấy tỉ lệ UPR trả về theo từng tháng

Thay giá trị NULL bằng ngày UPR date là 20190501. Hàm sẽ trả về giá trị UPR tại thời điểm tháng 05

```SQL
> SELECT
> *
> FROM E_fn_SPLIT_INTERVAL1('20190101','20191231','20190501')
```

![U P R 02](https://github.com/vdhieu101/hieu.vuduc/blob/master/Images/UPR-02.png)

Sample data:

```SQL	

CREATE TABLE dbo.E_UPR_dummydata
    (
		 P_CODE				VARCHAR(20)		NOT NULL,
        LOB					NCHAR(10)			NOT NULL,
		 PRODUCT_CODE		NVARCHAR(10)	NOT NULL,
		 BOM_TYPE		NVARCHAR(10)	NOT NULL,
		 F_PERIOD			INT				NOT NULL,
         EFFECTIVE_DATE		DATE			NOT NULL,
         EXPIRY_DATE		DATE			NOT NULL,
         PREMIUM_WRITTEN	FLOAT			NOT NULL,
		 UPR_PERIOD			INT				NOT NULL
    )
GO
 
 
INSERT dbo.E_UPR_dummydata VALUES
     ('P1', 'lob01','A','PREMIUM'     , 201901,'2019-02-01', '2020-02-01', 15000000, 201912)
    ,('P2', 'lob01','B','CEDED'       , 201903,'2019-01-01', '2019-07-15', 100000000,201912)
    ,('P3', 'lob01','C','PREMIUM_COM' , 201806,'2018-01-31', '2020-12-31', 20000000, 201912)
    ,('P4', 'lob01','A','PREMIUM'     , 201702,'2017-01-01', '2017-12-31', 80000000, 201912)
    ,('P5', 'lob01','B','PREMIUM'     , 202003,'2019-01-01', '2020-07-16', 5000000 , 201912)
  
SELECT * FROM dbo.E_UPR_dummydata
```


```SQL	
SELECT

	__.P_CODE								AS P_CODE,
	__.LOB									AS P_LOB,
	__.PRODUCT_CODE								AS P_PRODUCT,
	__.F_PERIOD								AS F_PERIOD,
	__.EFFECTIVE_DATE							AS P_DATE_ISSUE,
	__.EXPIRY_DATE								AS P_DATE_EXPIRY,
	__.PREMIUM_WRITTEN							AS PREMIUM_WRITTEN,
	__.UPR_PERIOD								AS UPR_PERIOD,
	SPL.MONTH_SPLIT,
	SPL.STD_P_DATE_ISSUE,
	SPL.STD_P_DATE_EXPIRY,
	SPL.MONTH_CROSS,
	SPL.[%PREMIUM],
	SPL.UPR_RATE,
	__.UPR_PERIOD,

	--invoice date > UPR date then calculate UPR
	--invoice date < UPR date then UPR amount = 0
	CASE
	WHEN F_PERIOD >  __.UPR_PERIOD
	THEN 0
	ELSE COALESCE(__.PREMIUM_WRITTEN*SPL.UPR_RATE,0)
	END										AS UPR_AMOUNT
				
FROM dbo.E_UPR_dummydata __	OUTER APPLY	E_fn_SPLIT_INTERVAL1( __.EFFECTIVE_DATE, __.EXPIRY_DATE, __.UPR_PERIOD)	AS SPL 
```
![U P R 03](https://github.com/vdhieu101/hieu.vuduc/blob/master/Images/UPR-03.png)

