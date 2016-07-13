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

--  Clientes que tienen cuentas de inversión pero no han pedido ningún préstamo. Listado y Totales. 
select c.id_cliente,c.nombre,c.apellido_p,c.apellido_m from cliente as c inner join servicio_cuenta as sc
on c.id_cliente=sc.id_cliente inner join servicio_inversion as si
on sc.no_cuenta=si.no_cuentagral 
EXCEPT 
select c.id_cliente,c.nombre,c.apellido_p,c.apellido_m from cliente as c inner join "serviciosPrestamo" as sp
on c.id_cliente = sp.id_cliente
group by c.id_cliente

-- 7.- Clientes que tienen cuentas de inversión, cuentas de ahorro pero no han pedido ningún préstamo.
(select c.id_cliente,c.nombre,c.apellido_p,c.apellido_m from cliente as c inner join servicio_cuenta as sc
on c.id_cliente=sc.id_cliente inner join servicio_inversion as si
on sc.no_cuenta=si.no_cuentagral inner join servicio_ahorro as sa
on sa.id_cliente=sc.id_cliente and sc.no_cuenta=si.no_cuentagral 
EXCEPT 
select c.id_cliente,c.nombre,c.apellido_p,c.apellido_m from cliente as c inner join "serviciosPrestamo" as sp
on c.id_cliente = sp.id_cliente
group by c.id_cliente)

--8.- Clientes que pidieron un préstamo a menos de 3 meses de ingresar al banco. 
select sp.id_cliente,c.nombre,c.apellido_p,c.apellido_m from cliente as c inner join 
"serviciosPrestamo" as sp
on c.id_cliente = sp.id_cliente inner join  servicio_cuenta as sc
on sc.id_cliente = sp.id_cliente
where sp.fecha_contratacion<(sc.fecha_contratacion + 90)
group by sp.id_cliente,c.nombre,c.apellido_p,c.apellido_m 
