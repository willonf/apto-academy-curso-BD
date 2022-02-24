CREATE TABLE state (
  id SERIAL,
  name VARCHAR(64) NOT NULL,
  abbreviation CHAR(2) NOT NULL,
  CONSTRAINT PK_state PRIMARY KEY (id)
);

CREATE TABLE city (
  id SERIAL,
  id_state INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  CONSTRAINT PK_city PRIMARY KEY (id)
);

CREATE TABLE zone (
  id SERIAL,
  name VARCHAR(64) NOT NULL,
  CONSTRAINT PK_zone PRIMARY KEY (id)
);

CREATE TABLE district (
  id SERIAL,
  id_city INTEGER NOT NULL,
  id_zone INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  CONSTRAINT PK_district PRIMARY KEY (id)
);

CREATE TABLE branch (
  id SERIAL,
  id_district INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  CONSTRAINT PK_branch PRIMARY KEY (id)
);

CREATE TABLE marital_status (
  id SERIAL,
  name VARCHAR(64) NOT NULL,
  CONSTRAINT PK_marital_status PRIMARY KEY (id)
);

CREATE TABLE customer (
  id SERIAL,
  id_district INTEGER NOT NULL,
  id_marital_status INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  income NUMERIC(16,2) NOT NULL,
  gender CHAR(1) NOT NULL,
  CONSTRAINT PK_customer PRIMARY KEY (id)
);

CREATE TABLE department (
  id SERIAL,
  name VARCHAR(64) NOT NULL,
  CONSTRAINT PK_department PRIMARY KEY (id)
);

CREATE TABLE employee (
  id SERIAL,
  id_department INTEGER NOT NULL,
  id_district INTEGER NOT NULL,
  id_marital_status INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  salary NUMERIC(16,2) NOT NULL,
  admission_date DATE NOT NULL,
  birth_date DATE NOT NULL,
  gender CHAR(1) NOT NULL,
  CONSTRAINT PK_employee PRIMARY KEY (id)
);

CREATE TABLE product_group (
  id SERIAL,
  name VARCHAR(64) NOT NULL,
  commission_percentage NUMERIC(5,2) NOT NULL,
  gain_percentage NUMERIC(5,2) NOT NULL,
  CONSTRAINT PK_product_group PRIMARY KEY (id)
);

CREATE TABLE supplier (
  id SERIAL,
  name VARCHAR(64) NOT NULL,
  legal_document VARCHAR(20) NOT NULL,
  CONSTRAINT PK_supplier PRIMARY KEY (id)
);

CREATE TABLE product (
  id SERIAL,
  id_product_group INTEGER NOT NULL,
  id_supplier INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  cost_price NUMERIC(16,2) NOT NULL,
  sale_price NUMERIC(16,2) NOT NULL,
  CONSTRAINT PK_product PRIMARY KEY (id)
);

CREATE TABLE sale (
  id SERIAL,
  id_customer INTEGER NOT NULL,
  id_branch INTEGER NOT NULL,
  id_employee INTEGER NOT NULL,
  date TIMESTAMP NOT NULL,
  CONSTRAINT PK_sale PRIMARY KEY (id)
);

CREATE TABLE sale_item (
  id SERIAL,
  id_sale INTEGER NOT NULL,
  id_product INTEGER NOT NULL,
  quantity NUMERIC(16,3) NOT NULL,
  CONSTRAINT PK_sale_item PRIMARY KEY (id)
);

/*================================================================================*/
/* CREATE FOREIGN KEYS                                                            */
/*================================================================================*/

ALTER TABLE city
  ADD CONSTRAINT FK_city_state
  FOREIGN KEY (id_state) REFERENCES state (id);

ALTER TABLE district
  ADD CONSTRAINT FK_district_city
  FOREIGN KEY (id_city) REFERENCES city (id);

ALTER TABLE district
  ADD CONSTRAINT FK_district_zone
  FOREIGN KEY (id_zone) REFERENCES zone (id);

ALTER TABLE branch
  ADD CONSTRAINT FK_branch_district
  FOREIGN KEY (id_district) REFERENCES district (id);

ALTER TABLE customer
  ADD CONSTRAINT FK_customer_district
  FOREIGN KEY (id_district) REFERENCES district (id);

ALTER TABLE customer
  ADD CONSTRAINT FK_customer_marital_status
  FOREIGN KEY (id_marital_status) REFERENCES marital_status (id);

ALTER TABLE employee
  ADD CONSTRAINT FK_employee_department
  FOREIGN KEY (id_department) REFERENCES department (id);

ALTER TABLE employee
  ADD CONSTRAINT FK_employee_marital_status
  FOREIGN KEY (id_marital_status) REFERENCES marital_status (id);

ALTER TABLE employee
  ADD CONSTRAINT FK_employee_district
  FOREIGN KEY (id_district) REFERENCES district (id);

ALTER TABLE product
  ADD CONSTRAINT FK_product_product_group
  FOREIGN KEY (id_product_group) REFERENCES product_group (id);

ALTER TABLE product
  ADD CONSTRAINT FK_product_supplier
  FOREIGN KEY (id_supplier) REFERENCES supplier (id);

ALTER TABLE sale
  ADD CONSTRAINT FK_sale_customer
  FOREIGN KEY (id_customer) REFERENCES customer (id);

ALTER TABLE sale
  ADD CONSTRAINT FK_sale_branch
  FOREIGN KEY (id_branch) REFERENCES branch (id);

ALTER TABLE sale
  ADD CONSTRAINT FK_sale_employee
  FOREIGN KEY (id_employee) REFERENCES employee (id);

ALTER TABLE sale_item
  ADD CONSTRAINT FK_sale_item_sale
  FOREIGN KEY (id_sale) REFERENCES sale (id);

ALTER TABLE sale_item
  ADD CONSTRAINT FK_sale_item_product
  FOREIGN KEY (id_product) REFERENCES product (id);
