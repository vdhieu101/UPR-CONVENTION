# UPR-CONVENTION
Contains all logic about UPR Calculation and Maintainance

**UPR**: Là khoản dự phòng của công ty cho các hợp đồng còn hiệu lực tại thời điểm cuối năm tài chính hay là khoản nợ của công ty bảo hiểm đối với khách hàng tại thời điểm trích lập cuối năm 31/12.


[TT 50/2017/TT-BTC](http://www.docluat.vn/van-ban-phap-luat-ve-kinh-doanh-bao-hiem/tt-50-2017-tt-btc-huong-dan-thi-hanh-nghi-dhinh-so-73-2016-ndh-cp-ngay-01-7-2016-cua-chinh-phu-quy-dhinh-chi-tiet-thi-hanh-luat-kinh-doanh-bao-hiem-va-luat-sua-dhoi-bo-sung-mot-so-dhieu-cua-luat-kinh-doanh-bao-hiem-1#TOC-M-c-2.-D-PH-NG-NGHI-P-V-)

#### Method:

	Tất cả các sản phẩm đều được tính DPP dựa trên phương pháp 1/365.

#### Trigger condition:

	UPR date > booking date
	UPR separately compute original policy and endo 

#### Các loại đơn bảo hiểm tính dự phòng:

	1. Dự phòng bảo hiểm đơn gốc
	2. Move POI Endo 
	3. Shorten POI endo
  	4. Extend POI endo
	5. Cancel endo
	6. Installment

Example:


	

#### Quy trình tính toán DPP:

Kiểm tra dữ liệu đầu vào:

	1. Hợp đồng có đầy đủ ngày effective date và expiry date hay không?
	2. Thời hạn hiệu lực có hợp lý theo từng đặc thù của các nghiệp vụ?

Logic tính toán trung tâm sẽ được áp dụng chung cho toàn bộ các loại nghiệp vụ như sau:

	1. Dự phòng phí được tính toán theo cấp độ riêng lẻ theo hợp đồng.
	2. Doanh thu / Nhượng Tái / Hoa hồng booking trên sổ từ kì 201301 sẽ được tính toán DPP theo ngày issue và expiry của Hợp đồng.
	3. Nhượng Tái XOL sẽ được tính DPP theo thời hiệu từ 01/01 đến 31/12 trong 1 năm.
	4. Những hợp đồng có thời hạn > 50 năm được điều chỉnh thời hạn xuống còn 1 ngày.
 
Tùy vào đặc thù của từng nghiệp vụ. Trong quá trình tính toán sẽ có những điều chỉnh về thời hạn hiệu lực để số liệu chính xác hơn

	
| LOB 	| Điều chỉnh                                                                                                                                                                                                             	|
|-----	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| 01  	| Đối với DVL, DPP được tính riêng theo từng rủi ro và được tính toán riêng so với các sản phẩm thông thường. Điều chỉnh thời hạn một số mã CK_GD,CK_DA..                                                            		|
| 02  	| Nhượng tái được tính DPP theo hiệu lực HĐ Gốc                                                                                                                                                                        		|
| 03  	| - Do đặc thù các chuyến hàng thường kéo dài không quá 3 tháng. Nên Các hợp đồng có tg hiệu lực > 3 tháng đều được quy về 3 tháng.																						|
|		| - Các hợp đồng có hiệu lực nhỏ hơn 3 tháng sẽ giữ nguyên thời hạn. Vì những đơn nhập chính xác ngày hiệu lực ( thường <3 tháng) thì không cần điều chỉnh 																	|
| 04  	|                                                                                                                                                                                                                        	|
| 05  	| Có thể trích xuất và tính dự phòng theo danh sách rủi ro. Kỳ vọng thời hiệu của hợp đồng không lệch nhiều so với thời hạn của rủi ro bên trong. Cần điều chỉnh cách tính nếu lệch nhiều UPR                         	|
| 06  	| Bao gồm cả dữ liệu   trên GICORE và IBMS                                                                                                                                                                               	|
| 07  	|                                                                                                                                                                                                                        	|
| 08  	|                                                                                                                                                                                                                        	|

 #### Execute sql code

```SQL
select
*
from E_fn_tbl_UPR_CORE(201912,201912,201912)
```


#### Demo

Các hàm được gọi trong trong quá trình tính UPR:
	
	E_FNUMBER(@n): trả về @n dòng dữ liệu
	E_fn_SPLIT_INTERVAL1(@P_DATE_ISSUE, @P_DATE_EXPIRY, @anchor_date): tính UPR theo phương pháp tách hợp đồng thành từng tháng nhỏ
	E_fn_tbl_UPR_CORE: Trả về full data UPR

E_fn_SPLIT_INTERVAL1(@p_date_issue, @p_date_expiry, @anchor_date)

Hàm tính UPR theo phương pháp chia nhỏ thời hạn theo từng tháng. Phí của hợp đồng sẽ được chia đều theo từng tháng (pro-data)


Example: policy A với @P_DATE_ISSUE = 201901, @P_DATE_EXPIRY = 201912. function E_fn_SPLIT_INTERVAL1 sẽ chia thời hạn ra thành 12 dòng, mỗi dòng tương ứng 1 tháng và UPR tương ứng của mỗi tháng:

```SQL
> SELECT
> *
> FROM E_fn_SPLIT_INTERVAL1('20190101','20191231',NULL)
```
![U P R 01](UPR-01.png)

Thay giá trị NULL bằng ngày UPR date là 20190501. Hàm sẽ trả về giá trị UPR tại thời điểm tháng 05

```SQL
> SELECT
> *
> FROM E_fn_SPLIT_INTERVAL1('20190101','20191231','20190501')
```

![U P R 02](D:/hieu.vuduc/Desktop/UPR-02.png)


E_fn_tbl_UPR_CORE(@data_period, @upr_period_from, @upr_period_to): Trả về full data UPR từ @upr_period_from đến @upr_period_to

	@data_period: Dữ liệu được lấy tới thời điểm @data_period

	@upr_period_from: UPR được tính bắt đầu từ thời điểm @upr_period_from

	@upr_period_to:UPR được tính đến thời điểm @upr_period_to
	 
- 	Đầu tiên, toàn bộ dữ liệu tính toán sẽ được lấy trong dbo.A3_fn_GLDE_COMBINE( 201301,@DATA_PERIOD, 0 )
	
- 	Tính UPR trên data sẵn có bằng cách JOIN với hàm tính UPR E_fn_SPLIT_INTERVAL1(@p_date_issue, @p_date_expiry, @upr_period)

DEMO

```SQL	

CREATE TABLE dbo.E_UPR_dummydata
    (
		 P_CODE				VARCHAR(20)		NOT NULL,
         LOB				NCHAR(10)			NOT NULL,
		 PRODUCT_CODE		NVARCHAR(10)	NOT NULL,
		 F_PERIOD			INT				NOT NULL,
         EFFECTIVE_DATE		DATE			NOT NULL,
         EXPIRY_DATE		DATE			NOT NULL,
         PREMIUM_WRITTEN	FLOAT			NOT NULL,
		 UPR_PERIOD			INT				NOT NULL
    )
GO
 
 
INSERT dbo.E_UPR_dummydata VALUES
     ('P1', 'lob01','A',201901 ,'2019-02-01', '2020-02-01', 15000000, 201912)
    ,('P2', 'lob01','B',201903 ,'2019-01-01', '2019-07-15', 100000000,201912 )
    ,('P3', 'lob01','C',201806 ,'2018-01-31', '2020-12-31', 20000000, 201912)
    ,('P4', 'lob01','A',201702 ,'2017-01-01', '2017-12-31', 80000000, 201912)
    ,('P5', 'lob01','B',202003 ,'2019-01-01', '2020-07-16', 5000000 , 201912)
  
SELECT * FROM dbo.E_UPR_dummydata
```


```SQL	
SELECT

	__.P_CODE							AS P_CODE,
	__.LOB								AS P_LOB,
	__.PRODUCT_CODE						AS P_PRODUCT,
	__.F_PERIOD						AS F_PERIOD,
	__.EFFECTIVE_DATE					AS P_DATE_ISSUE,
	__.EXPIRY_DATE						AS P_DATE_EXPIRY,
	__.PREMIUM_WRITTEN					AS PREMIUM_WRITTEN,
	__.UPR_PERIOD						AS UPR_PERIOD,
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
![U P R 03](D:/hieu.vuduc/Desktop/UPR-03.png)
