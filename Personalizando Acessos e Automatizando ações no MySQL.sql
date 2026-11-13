-- 1. Criação do Schema
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- 2. Criação da Tabela Dept (Tabela Pai)
CREATE TABLE `dept` (
  `DepNume` int(4) NOT NULL,
  `DepNome` char(20) NOT NULL,
  `DepLoca` char(20) NOT NULL,
  `DepOrca` int(12) DEFAULT NULL,
  PRIMARY KEY (`DepNume`),
  UNIQUE KEY `DepNum_Unique` (`DepNume`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 3. Inserção de Dados em Dept
INSERT INTO `dept` (`DepNume`, `DepNome`, `DepLoca`, `DepOrca`) VALUES
(10, 'PRESIDENCIA', 'SAO PAULO', 10000),
(20, 'INFORMATICA', 'RIO DE JANEIRO', 500000),
(30, 'VENDAS', 'BRASILIA', 20000),
(40, 'OPERACOES', 'BELO HORIZONTE', 300000),
(50, 'FABRICA', 'SAO PAULO', 300000);

-- 4. Criação da Tabela Emp (Tabela Filho)
CREATE TABLE `emp` (
  `EmpNume` int(5) NOT NULL,
  `EmpNome` char(30) NOT NULL,
  `EmpGere` int(5) DEFAULT NULL,
  `EmpServ` char(20) DEFAULT NULL,
  `DepNume` int(4) NOT NULL,
  `EmpAdmi` date NOT NULL,
  `EmpSala` int(10) DEFAULT NULL,
  `EmpComi` int(10) DEFAULT NULL,
  PRIMARY KEY (`EmpNume`),
  UNIQUE KEY `EmpNum_Unique` (`EmpNume`),
  KEY `EmpDep_Idx` (`DepNume`),
  -- Adicionando a chave estrangeira para garantir a integridade
  CONSTRAINT `fk_emp_dept` FOREIGN KEY (`DepNume`) REFERENCES `dept` (`DepNume`) 
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 5. Inserção de Dados em Emp
INSERT INTO `emp` (`EmpNume`, `EmpNome`, `EmpGere`, `EmpServ`, `DepNume`, `EmpAdmi`, `EmpSala`, `EmpComi`) VALUES
(1001, 'HORTENCIA OLIVA', 8003, 'BALCONISTA', 40, '1981-02-11', 500, NULL),
(1002, 'FERNANDA VENTURINNI', 8002, 'VENDEDOR', 30, '1983-04-01', 650, 50),
(1003, 'ANA MOSER', 8002, 'VENDEDOR', 30, '1982-05-06', 700, 55),
(1004, 'JANETH ARCAIN', 8003, 'BALCONISTA', 40, '1987-11-07', 800, NULL),
(1005, 'ANA PAULA', 8002, 'VENDEDOR', 30, '1987-01-01', 850, 70),
(1006, 'VIRNA DIAS', 8002, 'VENDEDOR', 30, '1988-12-10', 990, 70),
(1007, 'ROBERTO CARLOS', 8001, 'ANALISTA', 20, '1981-01-09', 1300, NULL),
(1008, 'CAETANO VELOSO', 8001, 'ANALISTA', 20, '1980-02-01', 1500, NULL),
(1009, 'ANA FLAVIA', 8002, 'VENDEDOR', 30, '1986-06-01', 900, 45),
(1010, 'MARIA PAULA', 8003, 'BALCONISTA', 40, '1980-01-01', 450, NULL),
(1011, 'GILBERTO GIL', 8001, 'ANALISTA', 20, '1983-03-04', 1800, NULL),
(1012, 'ERASMO CARLOS', 8001, 'ANALISTA', 20, '1978-04-03', 2100, NULL),
(1020, 'ZETTI', 8004, 'OPERARIO', 50, '1981-12-01', 450, NULL),
(1021, 'CAFU', 8004, 'OPERARIO', 50, '1978-12-02', 450, NULL),
(1022, 'RONALDINHO', 8004, 'OPERARIO', 50, '1981-01-01', 500, NULL),
(1023, 'GIOVANNI', 8004, 'OPERARIO', 50, '1980-01-01', 450, NULL),
(8001, 'GAL COSTA', 9000, 'GERENTE', 20, '1979-05-01', 2900, NULL),
(8002, 'MARIA BETHANIA', 9000, 'GERENTE', 30, '1980-06-07', 3400, NULL),
(8003, 'MARINA LIMA', 9000, 'GERENTE', 40, '1982-07-05', 4000, NULL),
(8004, 'DANIELA MERCURY', 9000, 'GERENTE', 50, '1985-08-08', 4500, NULL),
(9000, 'FERNANDO HENRIQUE', NULL, 'PRESIDENTE', 10, '1980-09-01', 7000, NULL);

COMMIT;
REPLACE INTO `emp` (`EmpNume`, `EmpNome`, `EmpGere`, `EmpServ`, `DepNume`, `EmpAdmi`, `EmpSala`, `EmpComi`) 
VALUES (1001, 'HORTENCIA OLIVA', 8003, 'BALCONISTA', 40, '1981-02-11', 500, NULL);
CREATE VIEW vw_empregados_por_depto_local AS
SELECT 
    d.dname AS Departamento,
    l.dlocation AS Localidade,
    COUNT(e.ssn) AS Total_Empregados
FROM gendept d
JOIN dept_locations l ON d.dnumber = l.dnumber
LEFT JOIN employee e ON d.dnumber = e.dno
GROUP BY d.dnumber, d.dname, l.dlocation;

CREATE VIEW vw_departamentos_gerentes AS
SELECT 
    d.dname AS Departamento,
    CONCAT(e.fname, ' ', e.lname) AS Nome_Gerente,
    e.ssn AS CPF_Gerente
FROM gendept d
JOIN employee e ON d.mgr_ssn = e.ssn;

CREATE VIEW vw_projetos_maior_empregados AS
SELECT 
    p.pname AS Nome_Projeto,
    p.plocation AS Local_Projeto,
    COUNT(ec.essn) AS Total_Empregados
FROM project p
JOIN works_on ec ON p.pnumber = ec.pno
GROUP BY p.pnumber, p.pname, p.plocation
ORDER BY Total_Empregados DESC;

CREATE VIEW vw_projetos_deptos_gerentes AS
SELECT 
    p.pname AS Nome_Projeto,
    d.dname AS Departamento,
    CONCAT(e.fname, ' ', e.lname) AS Nome_Gerente
FROM project p
JOIN gendept d  ON p.dnum = d.dnumber
JOIN employee e ON d.mgr_ssn = e.ssn;

CREATE VIEW vw_empregados_dependentes_gerentes AS
SELECT 
    CONCAT(e.fname, ' ', e.lname) AS Nome_Empregado,
    CASE 
        WHEN d_dep.essn IS NOT NULL THEN 'Sim' 
        ELSE 'Não' 
    END AS Possui_Dependentes,
    CASE 
        WHEN mgr.mgr_ssn IS NOT NULL THEN 'Sim' 
        ELSE 'Não' 
    END AS É_Gerente
FROM employee e
LEFT JOIN (SELECT DISTINCT essn FROM dependent) d_dep ON e.ssn = d_dep.essn
LEFT JOIN (SELECT DISTINCT mgr_ssn FROM gendept) mgr ON e.ssn = mgr.mgr_ssn;

USE ecommerce;

-- 1. Número de empregados por departamento
CREATE OR REPLACE VIEW vw_empregados_por_depto AS
SELECT 
    d.DepNome AS Departamento,
    COUNT(e.EmpNume) AS Total_Empregados
FROM dept d
LEFT JOIN emp e ON d.DepNume = e.DepNume
GROUP BY d.DepNume, d.DepNome;

-- 2. Lista de departamentos e seus gerentes (assumindo que o gerente seja o funcionário de maior cargo/salário ou referência)
CREATE OR REPLACE VIEW vw_departamentos_gerentes AS
SELECT 
    d.DepNume AS Codigo_Departamento,
    d.DepNome AS Departamento,
    e.EmpNome AS Nome_Gerente
FROM dept d
LEFT JOIN emp e ON d.DepNume = e.DepNume AND e.EmpServ = 'GERENTE';

-- 3. Empregados com seus respectivos salários e departamentos
CREATE OR REPLACE VIEW vw_empregados_departamento AS
SELECT 
    e.EmpNume AS Matricula,
    e.EmpNome AS Nome_Empregado,
    e.EmpServ AS Cargo,
    d.DepNome AS Departamento,
    e.EmpSala AS Salario
FROM emp e
JOIN dept d ON e.DepNume = d.DepNume;

-- 4. Ranking de empregados por salário (maior para menor)
CREATE OR REPLACE VIEW vw_ranking_salarios AS
SELECT 
    EmpNume,
    EmpNome,
    EmpServ,
    EmpSala
FROM emp
ORDER BY EmpSala DESC;

USE ecommerce;

-- =========================================================================
-- PARTE 1: PERMISSÕES DE ACESSO ÀS VIEWS (DCL)
-- =========================================================================

-- 1. Criar os usuários (caso não existam)
CREATE USER IF NOT EXISTS 'gerente_user'@'localhost' IDENTIFIED BY 'SenhaGerente123!';
CREATE USER IF NOT EXISTS 'employee_user'@'localhost' IDENTIFIED BY 'SenhaEmp123!';

-- 2. Conceder acesso total/gerencial às views para o Gerente
GRANT SELECT ON ecommerce.vw_empregados_por_depto TO 'gerente_user'@'localhost';
GRANT SELECT ON ecommerce.vw_departamentos_gerentes TO 'gerente_user'@'localhost';
GRANT SELECT ON ecommerce.vw_empregados_departamento TO 'gerente_user'@'localhost';

-- 3. Conceder acesso restrito (apenas relatórios gerais) para o Employee comum
GRANT SELECT ON ecommerce.vw_ranking_salarios TO 'employee_user'@'localhost';

FLUSH PRIVILEGES;


-- =========================================================================
-- PARTE 2: CRIAÇÃO DE TRIGGERS PARA O E-COMMERCE
-- =========================================================================

-- Criar tabela de log de exclusão de clientes (para auditoria antes do delete)
CREATE TABLE IF NOT EXISTS client_audit_log (
    idLOG INT AUTO_INCREMENT PRIMARY KEY,
    idCLIENTE INT,
    NomeCliente VARCHAR(50),
    CPF_Cliente CHAR(11),
    DataExclusao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Alterar delimitador para criar os gatilhos
DELIMITER //

-- 1. TRIGGER DE REMOÇÃO (BEFORE DELETE): Salva log antes de excluir o cliente
DROP TRIGGER IF EXISTS trg_client_before_delete //
CREATE TRIGGER trg_client_before_delete
BEFORE DELETE ON clients
FOR EACH ROW
BEGIN
    INSERT INTO client_audit_log (idCLIENTE, NomeCliente, CPF_Cliente)
    VALUES (OLD.idCLIENTE, CONCAT(OLD.Pnome, ' ', IFNULL(OLD.Sobrenome,'')), OLD.CPF);
END //

-- 2. TRIGGER DE ATUALIZAÇÃO (BEFORE UPDATE): Valida ou audita alterações
DROP TRIGGER IF EXISTS trg_client_before_update //
CREATE TRIGGER trg_client_before_update
BEFORE UPDATE ON clients
FOR EACH ROW
BEGIN
    -- Exemplo de automação: Garante que o CPF não seja esvaziado acidentalmente
    IF NEW.CPF IS NULL OR NEW.CPF = '' THEN
        SET NEW.CPF = OLD.CPF;
    END IF;
END //

DELIMITER ;

USE ecommerce;

-- 1. Criar a tabela 'clients' que faltava para as triggers funcionarem
CREATE TABLE IF NOT EXISTS `clients` (
    `idCLIENTE` INT AUTO_INCREMENT PRIMARY KEY,
    `Pnome` VARCHAR(20) NOT NULL,
    `Sobrenome` VARCHAR(20),
    `CPF` CHAR(11) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Inserir um cliente de teste para validar as triggers
INSERT IGNORE INTO `clients` (`idCLIENTE`, `Pnome`, `Sobrenome`, `CPF`) 
VALUES (1, 'WASHINGTON', 'BRITO', '12345678901');

-- 2. Tabela de auditoria para exclusões
CREATE TABLE IF NOT EXISTS client_audit_log (
    idLOG INT AUTO_INCREMENT PRIMARY KEY,
    idCLIENTE INT,
    NomeCliente VARCHAR(50),
    CPF_Cliente CHAR(11),
    DataExclusao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Configurar Delimitador e Criar Triggers
DELIMITER //

DROP TRIGGER IF EXISTS trg_client_before_delete //
CREATE TRIGGER trg_client_before_delete
BEFORE DELETE ON clients
FOR EACH ROW
BEGIN
    INSERT INTO client_audit_log (idCLIENTE, NomeCliente, CPF_Cliente)
    VALUES (OLD.idCLIENTE, CONCAT(OLD.Pnome, ' ', IFNULL(OLD.Sobrenome,'')), OLD.CPF);
END //

DROP TRIGGER IF EXISTS trg_client_before_update //
CREATE TRIGGER trg_client_before_update
BEFORE UPDATE ON clients
FOR EACH ROW
BEGIN
    IF NEW.CPF IS NULL OR NEW.CPF = '' THEN
        SET NEW.CPF = OLD.CPF;
    END IF;
END //

DELIMITER ;

USE ecommerce;

-- 1. Remover a trigger antiga se ela já existir
DROP TRIGGER IF EXISTS trg_client_before_update;

-- 2. Recriar a trigger corretamente
DELIMITER //
CREATE TRIGGER trg_client_before_update
BEFORE UPDATE ON clients
FOR EACH ROW
BEGIN
    IF NEW.CPF IS NULL OR NEW.CPF = '' THEN
        SET NEW.CPF = OLD.CPF;
    END IF;
END //
DELIMITER ;

USE ecommerce;

DROP TRIGGER IF EXISTS trg_client_before_update;

DELIMITER //
CREATE TRIGGER trg_client_before_update 
BEFORE UPDATE ON clients 
FOR EACH ROW 
BEGIN 
    IF NEW.CPF IS NULL OR NEW.CPF = '' THEN 
        SET NEW.CPF = OLD.CPF; 
    END IF; 
END //
DELIMITER ;



