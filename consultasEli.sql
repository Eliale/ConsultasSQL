set search_path to bancouno;

SELECT sexo, COUNT(id_cliente) AS cantidad,
(SELECT COUNT(cliente.sexo)*100 / count(id_cliente) 
FROM cliente as C ) 
AS porcentaje FROM cliente GROUP BY sexo;



select current_date

select sexo,sum(case when fecha_nac between ((select current_date) - (17 * '1 year'::interval)) and ((select current_date) - (15 * '1 year'::interval))  then 1 else 0 end) *100 / count(id_cliente)  as e15_e17,
sum(case when fecha_nac between ((select current_date) - (30 * '1 year'::interval)) and ((select current_date) - (18 * '1 year'::interval)) then 1 else 0 end)*100 / count(id_cliente)  as e18_e30,
sum(case when fecha_nac between ((select current_date) - (40 * '1 year'::interval)) and ((select current_date) - (31 * '1 year'::interval)) then 1 else 0 end)*100 / count(id_cliente)  as e31_e40,
sum(case when fecha_nac between ((select current_date) - (60 * '1 year'::interval)) and ((select current_date) - (41 * '1 year'::interval)) then 1 else 0 end)*100 / count(id_cliente)  as e41_e60,
sum(case when fecha_nac between ((select current_date) - (111 * '1 year'::interval)) and ((select current_date) - (60 * '1 year'::interval)) then 1 else 0 end)*100 / count(id_cliente)  as e60
from cliente
GROUP By sexo


select sum(case when c.fecha_nac between ((select current_date) - (17 * '1 year'::interval)) and ((select current_date) - (15 * '1 year'::interval))  then 1 else 0 end) *100 / count(c.id_cliente)  as e15_e17,
sum(case when c.fecha_nac between ((select current_date) - (30 * '1 year'::interval)) and ((select current_date) - (18 * '1 year'::interval)) then 1 else 0 end)*100 / count(c.id_cliente)  as e18_e30,
sum(case when c.fecha_nac between ((select current_date) - (40 * '1 year'::interval)) and ((select current_date) - (31 * '1 year'::interval)) then 1 else 0 end)*100 / count(c.id_cliente)  as e31_e40,
sum(case when c.fecha_nac between ((select current_date) - (60 * '1 year'::interval)) and ((select current_date) - (41 * '1 year'::interval)) then 1 else 0 end)*100 / count(c.id_cliente)  as e41_e60,
sum(case when c.fecha_nac between ((select current_date) - (111 * '1 year'::interval)) and ((select current_date) - (60 * '1 year'::interval)) then 1 else 0 end)*100 / count(c.id_cliente)  as e60
from cliente as c
inner join bancouno."serviciosPrestamo"  as sp
on c.id_cliente = sp.id_cliente
