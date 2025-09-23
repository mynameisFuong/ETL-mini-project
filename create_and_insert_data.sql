use TASK;

drop table if exists transactions;
create table Transactions (
	transaction_id NVARCHAR(255) PRIMARY KEY,
    transaction_event_code TEXT,
    transaction_initiation_date TEXT,
    transaction_updated_date TEXT,
    transaction_amount TEXT,
    transaction_status TEXT,
    transaction_subject TEXT,
    ending_balance TEXT,
    ending_balance_currency TEXT,
    available_balance TEXT,
    available_balance_currency TEXT,
    protection_eligibility INTEGER,
   -- created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

--xoá dữ liệu bảng transactions

TRUNCATE TABLE transactions;

--thêm dữ liệu vào bảng transactions

INSERT INTO transactions(
    transaction_id, transaction_event_code, transaction_initiation_date, 
    transaction_updated_date, transaction_amount, transaction_status, 
    transaction_subject, ending_balance, available_balance, protection_eligibility
)
SELECT DISTINCT
    t.transaction_id,
    t.transaction_event_code,
    t.transaction_initiation_date,
    t.transaction_updated_date,
    t.transaction_amount,
    t.transaction_status,
    t.transaction_subject,
    t.ending_balance,
    t.available_balance,
    t.protection_eligibility
FROM transactions_pp02 t
WHERE t.transaction_id IS NOT NULL
  AND NOT EXISTS (
        SELECT 1 
        FROM transactions x
        WHERE x.transaction_id = t.transaction_id
  );



drop table if exists payer_info;
create table Payer_info(
	id INTEGER PRIMARY KEY,
    transaction_id NVARCHAR(255),
    account_id TEXT,
    email_address TEXT,
    address_status TEXT,
    payer_status TEXT,
    given_name TEXT,
    surname TEXT,
    alternate_full_name TEXT,
    country_code TEXT,
    FOREIGN KEY (transaction_id) REFERENCES transactions (transaction_id)
);

drop table if exists cart_items;
create table cart_items(
	id INTEGER PRIMARY KEY,
    transaction_id NVARCHAR(255),
    item_name TEXT,
    item_quantity TEXT,
    item_unit_price TEXT,
    item_amount TEXT,
    total_item_amount TEXT,
    currency_code TEXT,
    tax_percentage TEXT,
    FOREIGN KEY (transaction_id) REFERENCES transactions (transaction_id)
);

drop table if exists shipping_info;
create table shipping_info(
	id INTEGER PRIMARY KEY,
    transaction_id NVARCHAR(255),
    [name] TEXT,
    address_line1 TEXT,
    city TEXT,
    postal_code TEXT,
    country_code TEXT,
    FOREIGN KEY (transaction_id) REFERENCES transactions (transaction_id)
);

--câu truy vấn để xoá ràng buộc khoá ngoại nếu tồn tại

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
           WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'
           AND TABLE_NAME = 'fact_table')
BEGIN
    ALTER TABLE payer_info
    DROP CONSTRAINT FK_Payer_trans;
    
    ALTER TABLE cart_items
    DROP CONSTRAINT FK_cart_trans;
    
    ALTER TABLE shipping_info
    DROP CONSTRAINT FK_shipping__trans;
END