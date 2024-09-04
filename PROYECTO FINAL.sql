CREATE DATABASE EMPRESA;

USE EMPRESA;

CREATE TABLE TB_CLIENTE(
DNI VARCHAR(11) NOT NULL,
NOMBRE VARCHAR(100)  NULL,
DIRECCION VARCHAR(150)  ,
BARRIO VARCHAR(50)  ,
CIUDAD VARCHAR(50)  ,
ESTADO VARCHAR(10)  ,
CP VARCHAR(10)  ,
FECHA_NACIMIENTO DATE  ,
EDAD SMALLINT  ,
SEXO VARCHAR(1)  ,
LIMITE_CREDITO FLOAT  ,
VOLUMEN_COMPRA FLOAT  ,
PRIMERA_COMPRA BIT  ,
PRIMARY KEY(DNI)
);

CREATE TABLE TB_VENDEDORES(
MATRICULA VARCHAR(5) NOT NULL,
NOMBRE VARCHAR(100) ,
BARRIO VARCHAR(50)  ,
COMISION FLOAT  ,
FECHA_ADMISION DATE  ,
VACACIONES BIT  ,
PRIMARY KEY(MATRICULA)
);

CREATE TABLE TB_PRODUCTOS(
CODIGO VARCHAR(11) NOT NULL,
DESCCRIPCION VARCHAR(100)  ,
SABOR VARCHAR(50)  ,
TAMANO VARCHAR(50)  ,
ENVASE VARCHAR(50)  ,
PRECIO FLOAT  ,
PRIMARY KEY(CODIGO)
);

CREATE TABLE FACTURAS(
NUMERO INT NOT NULL,
FECHA DATE,
DNI VARCHAR(11) NOT NULL,
MATRICULA VARCHAR(5) NOT NULL,
IMPUESTO FLOAT,
PRIMARY KEY(NUMERO),
FOREIGN KEY (DNI) REFERENCES TB_CLIENTES (DNI),
FOREIGN KEY (MATRICULA) REFERENCES TB_VENDEDORES (MATRICULA) 
);

CREATE TABLE ITEMS_FACTURAS(
NUMERO INT NOT NULL,
CODIGO VARCHAR(10) NOT NULL,
CANTIDAD INT,
PRECIO FLOAT,
PRIMARY KEY(NUMERO,CODIGO),
FOREIGN KEY (NUMERO) REFERENCES FACTURAS (NUMERO),
FOREIGN KEY(CODIGO) REFERENCES TB_PRODUCTOS (CODIGO)
);

INSERT INTO TB_CLIENTES SELECT 
DNI, 
NOMBRE,
DIRECCION_1 AS DIRECCION, 
BARRIO, 
CIUDAD, 
ESTADO, 
CP, 
FECHA_DE_NACIMIENTO AS FECHA_NACIMIENTO,
EDAD,
SEXO,
LIMITE_DE_CREDITO AS LIMITE_CREDITO,
VOLUMEN_DE_COMPRA AS VOLUMEN_COMPRA,
PRIMERA_COMPRA FROM JUGOS_VENTAS.TABLA_DE_CLIENTES;

INSERT INTO TB_VENDEDORES (MATRICULA, NOMBRE, COMISION, FECHA_ADMISION, VACACIONES, BARRIO) SELECT
MATRICULA,
NOMBRE,
PORCENTAJE_COMISION,
FECHA_ADMISION,
VACACIONES,
BARRIO FROM JUGOS_VENTAS.TABLA_DE_VENDEDORES;

INSERT INTO TB_PRODUCTOS SELECT
CODIGO_DEL_PRODUCTO AS CODIGO,
NOMBRE_DEL_PRODUCTO AS DESCRIPCION,
TAMANO,
SABOR,
ENVASE,
PRECIO_DE_LISTA AS PRECIO FROM JUGOS_VENTAS.TABLA_DE_PRODUCTOS;

/*
INSERT INTO ITEMS_FACTURAS SELECT
NUMERO, CODIGO_DEL_PRODUCTO AS CODIGO, CANTIDAD, PRECIO FROM jugos_ventas.items_facturas;

INSERT INTO FACTURAS (DNI, MATRICULA, FECHA, NUMERO, IMPUESTO) SELECT
DNI, MATRICULA, FECHA_VENTA AS FECHA, NUMERO, IMPUESTO FROM JUGOS_VENTAS.FACTURAS;
*/

SET GLOBAL LOG_BIN_TRUST_FUNCTION_CREATORS =1;

/*F_ALEATORIO
MIN = 20 MAX= 250
(RAND() * (MAX-MIN+1))+MIN
*/

SELECT ROUND((RAND()*(250-20+1))+20) AS ALEATORIO;

SELECT F_ALEATORIO(10,1);

/*FUNCION F_CLIENTE_ALEATORIO
CREATE FUNCTION `F_CLIENTE_ALEATORIO` ()
RETURNS VARCHAR(11)
BEGIN
DECLARE VRESULTADO VARCHAR(11);
DECLARE VMAX INT;
DECLARE VALEATORIO INT;
SELECT COUNT(*) INTO VMAX FROM TB_CLIENTES; 
SET VALEATORIO = F_ALEATORIO(VMAX,1)-1;
SELECT DNI INTO VRESULTADO FROM TB_CLIENTES LIMIT VALEATORIO,1;
RETURN VRESULTADO;
END
*/
SELECT F_CLIENTE_ALEATORIO() AS CLIENTE;

SELECT * FROM TB_CLIENTES WHERE DNI = F_CLIENTE_ALEATORIO();

/*F_VENDEDOR_ALEATORIO
CREATE DEFINER=`root`@`localhost` FUNCTION `F_VENDEDOR_ALEATORIO`() RETURNS varchar(5) CHARSET utf8mb4
BEGIN
DECLARE VRESULTADO VARCHAR(5);
DECLARE VMAX INT;
DECLARE VALEATORIO INT;
SELECT COUNT(*) INTO VMAX FROM TB_VENDEDORES; 
SET VALEATORIO = F_ALEATORIO(VMAX,1)-1;
SELECT MATRICULA INTO VRESULTADO FROM TB_VENDEDORES LIMIT VALEATORIO,1;
RETURN VRESULTADO;
END
*/

SELECT F_VENDEDOR_ALEATORIO() AS VENDEDOR;

SELECT * FROM tb_vendedores WHERE MATRICULA = F_VENDEDOR_ALEATORIO();

/*F_PRODUCTO_ALEATORIO
CREATE FUNCTION `F_PRODUCTO_ALEATORIO` ()
RETURNS VARCHAR(11)
BEGIN
DECLARE VRESULTADO VARCHAR(11);
DECLARE VMAX INT;
DECLARE VALEATORIO INT;
SELECT COUNT(*) INTO VMAX FROM TB_PRODUCTOS; 
SET VALEATORIO = F_ALEATORIO(VMAX,1)-1;
SELECT CODIGO INTO VRESULTADO FROM TB_PRODUCTOS LIMIT VALEATORIO,1;
RETURN VRESULTADO;
END
*/

SELECT F_PRODUCTO_ALEATORIO() AS PRODUCTO;

SELECT * FROM TB_PRODUCTOS WHERE CODIGO = F_PRODUCTO_ALEATORIO();

SELECT PRECIO FROM TB_PRODUCTOS WHERE CODIGO =  F_PRODUCTO_ALEATORIO() LIMIT 1;

/*SP_VENTA_ALEATORIA
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_VENTA_ALEATORIA`(FECHA DATE, VMAX INT, CMAX INT)
BEGIN
DECLARE VCLIENTE VARCHAR(11);
DECLARE VENDEDOR VARCHAR(5);
DECLARE VPRODUCTO VARCHAR(11);
DECLARE VCANTIDAD INT;
DECLARE VPRECIO FLOAT;
DECLARE VITEMS INT;
DECLARE VNFACTURAS INT;
DECLARE VCONTADOR  INT default 1;
DECLARE VNITEMS INT;
SELECT MAX(NUMERO) + 1 INTO VNFACTURAS FROM FACTURAS;
IF VNFACTURAS IS NULL THEN SET VNFACTURAS=1; END IF;
SET VCLIENTE = F_CLIENTE_ALEATORIO();
SET VENDEDOR = F_VENDEDOR_ALEATORIO();
INSERT INTO FACTURAS VALUES (VNFACTURAS, FECHA, VCLIENTE, VENDEDOR, 0.16);
SET VITEMS = F_ALEATORIO(1,VMAX);
WHILE VCONTADOR <= VMAX DO
	SET VPRODUCTO = F_PRODUCTO_ALEATORIO();
	SELECT COUNT(*)INTO VNITEMS FROM ITEMS_FACTURAS WHERE CODIGO = VPRODUCTO AND NUMERO = VNFACTURAS;
	IF VNITEMS = 0 THEN
		SET VCANTIDAD = F_ALEATORIO(1,CMAX);
		SELECT PRECIO INTO VPRECIO FROM TB_PRODUCTOS WHERE CODIGO = VPRODUCTO LIMIT 1;
		INSERT INTO ITEMS_FACTURAS VALUES (VNFACTURAS, VPRODUCTO, VCANTIDAD, VPRECIO);
	END IF;
	SET VCONTADOR = VCONTADOR+1;
END WHILE;
END
*/

SELECT MAX(NUMERO)+1 FROM FACTURAS;

SELECT CURRENT_DATE();
CALL SP_VENTA_ALEATORIA(current_date(),100,10);

SELECT * FROM FACTURAS;

SELECT * FROM items_facturas;

DELETE FROM FACTURAS;

DELETE FROM items_facturas;

SELECT YEAR(F.FECHA), CEIL(SUM(F.IMPUESTO * (I.CANTIDAD * I.PRECIO))) 
AS RESULTADO
FROM FACTURAS F
INNER JOIN items_facturas I ON F.NUMERO = I.NUMERO
WHERE YEAR(F.FECHA) = 2024
GROUP BY YEAR(F.FECHA);

/*TRIGGERS*/

CREATE TABLE facturacion(
FECHA DATE NULL,
VENTA_TOTAL FLOAT
);

DELIMITER //
CREATE TRIGGER TG_FACTURACION_INSERT 
AFTER INSERT ON items_facturas
FOR EACH ROW BEGIN
  DELETE FROM facturacion;
  INSERT INTO facturacion
  SELECT A.FECHA, SUM(B.CANTIDAD * B.PRECIO) AS VENTA_TOTAL
  FROM facturas A
  INNER JOIN
  items_facturas B
  ON A.NUMERO = B.NUMERO
  GROUP BY A.FECHA;
END //

DELIMITER //
CREATE TRIGGER TG_FACTURACION_DELETE
AFTER DELETE ON items_facturas
FOR EACH ROW BEGIN
  DELETE FROM facturacion;
  INSERT INTO facturacion
  SELECT A.FECHA, SUM(B.CANTIDAD * B.PRECIO) AS VENTA_TOTAL
  FROM facturas A
  INNER JOIN
  items_facturas B
  ON A.NUMERO = B.NUMERO
  GROUP BY A.FECHA;
END //

DELIMITER //
CREATE TRIGGER TG_FACTURACION_UPDATE
AFTER UPDATE ON items_facturas
FOR EACH ROW BEGIN
  DELETE FROM facturacion;
  INSERT INTO facturacion
  SELECT A.FECHA, SUM(B.CANTIDAD * B.PRECIO) AS VENTA_TOTAL
  FROM facturas A
  INNER JOIN
  items_facturas B
  ON A.NUMERO = B.NUMERO
  GROUP BY A.FECHA;
END //

DROP TRIGGER TG_FACTURACION_DELETE;
DROP TRIGGER TG_FACTURACION_UPDATE;
DROP TRIGGER TG_FACTURACION_INSERT;

/*TRIGGER CON SP*/

DELIMITER //
CREATE TRIGGER TG_FACTURACION_INSERT_TRIGGERS 
AFTER INSERT ON items_facturas
FOR EACH ROW BEGIN
  CALL SP_TRIGGERS();
END //

DELIMITER //
CREATE TRIGGER TG_FACTURACION_DELETE_TRIGGERS
AFTER DELETE ON items_facturas
FOR EACH ROW BEGIN
  CALL SP_TRIGGERS();
END //

DELIMITER //
CREATE TRIGGER TG_FACTURACION_UPDATE_TRIGGERS
AFTER UPDATE ON items_facturas
FOR EACH ROW BEGIN
 CALL SP_TRIGGERS();
END //

CALL SP_VENTA_ALEATORIA(current_date(),100,10);

SELECT * FROM FACTURACION;

DELETE FROM ITEMS_FACTURAS;
DELETE FROM FACTURACION;
