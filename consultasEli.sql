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

-- Version ligeramente mejorada xD
select sp.id_cliente,c.nombre,c.apellido_p,c.apellido_m,sc.fecha_contratacion as fecha_contrato,sp.fecha_contratacion as fecha_prestamo from cliente as c inner join 
"serviciosPrestamo" as sp
on c.id_cliente = sp.id_cliente inner join  servicio_cuenta as sc
on sc.id_cliente = sp.id_cliente
where sp.fecha_contratacion<(sc.fecha_contratacion + 90)
group by sp.id_cliente,c.nombre,c.apellido_p,c.apellido_m,sc.fecha_contratacion,sp.fecha_contratacion



-- vista total prestado

create view t_prestado as
(select sp.id_cliente,c.nombre,sum(sp.cantidad_prestamo) as total_prestamos from
"serviciosPrestamo" as sp inner join cliente as c
on sp.id_cliente = c.id_cliente
group by sp.id_cliente,c.nombre
order by sp.id_cliente)

-- vista total ahorrado
create view t_ahorrado as
(select sam.id_cliente,c.nombre,sum(sam.monto_total) as total_ahorrado from
servicio_ahorro_mov as sam inner join cliente as c
on sam.id_cliente = c.id_cliente
group by sam.id_cliente,c.nombre
order by sam.id_cliente)

--Clientes que pueden cubrir el saldo de su préstamo con su cuenta de ahorro. 
select ta.nombre,ta.id_cliente from t_prestado as tp,t_ahorrado as ta
where ta.id_cliente=tp.id_cliente and ta.total_ahorrado - tp.total_prestamos > 0

--mejorada xD
select ta.nombre,ta.id_cliente, ta.total_ahorrado - tp.total_prestamos as saldo_favor from t_prestado as tp,t_ahorrado as ta
where ta.id_cliente=tp.id_cliente and ta.total_ahorrado - tp.total_prestamos > 0

-- tardan mucho

-- Total invertido
create view t_invertido as
select sc.id_cliente,c.nombre,sum(si.monto) as total_invertido from servicio_cuenta as sc inner join
servicio_inversion as si
on sc.no_cuenta=si.no_cuentagral
inner join cliente as c
on c.id_cliente = sc.id_cliente
group by sc.id_cliente,c.nombre
order by sc.id_cliente
-- Clientes que pueden cubrir el saldo de su préstamo con su cuenta de inversión.
select ti.nombre,ti.id_cliente from t_prestado as tp,t_invertido as ti
where ti.id_cliente=tp.id_cliente and ti.total_invertido - tp.total_prestamos > 0

-- 11.- Total de prestamos otorgados por mes. 
select date_part('year',sp.fecha_contratacion) as año , date_part('month'::text,
sp.fecha_contratacion)as mes, count(sp.no_prestamo) as total_mes
   from "serviciosPrestamo" as sp 
    group by date_part('year',sp.fecha_contratacion), 
   date_part('month'::text, sp.fecha_contratacion) order by 1,2

--12.- Total del monto de prestamos otorgados por mes. 
   select date_part('year',sp.fecha_contratacion) as año , date_part('month'::text,
sp.fecha_contratacion)as mes, sum(sp.monto) as total_mes
   from "serviciosPrestamo" as sp 
    group by date_part('year',sp.fecha_contratacion), 
   date_part('month'::text, sp.fecha_contratacion) order by 1,2

--14.- Total de ingresos por intereses en créditos. 
   SELECT sum(monto - cantidad_prestamo) as ganancia
  FROM bancouno."serviciosPrestamo"



-- 16.- ¿Que sexo ahorra mas en cuentas de ahorro? 
select c.sexo,sum(sam.monto_total) as total_ahorrado from
servicio_ahorro_mov as sam inner join cliente as c
on sam.id_cliente = c.id_cliente
group by c.sexo
order by total_ahorrado desc
limit 1




-- 17.- ¿Que sexo ahorra mas en cuentas de inversión? 
select c.sexo,sum(si.monto) as total_invertido from servicio_cuenta as sc inner join
servicio_inversion as si
on sc.no_cuenta=si.no_cuentagral
inner join cliente as c
on c.id_cliente = sc.id_cliente
group by c.sexo
order by total_invertido desc
limit 1



-- 19.- ¿En que mes piden mas prestamos los hombres? 
select date_part('year',sp.fecha_contratacion) as año , date_part('month'::text,
sp.fecha_contratacion)as mes, count(sp.no_prestamo) as total_mes
   from "serviciosPrestamo" as sp inner join cliente as c
   on c.id_cliente = sp.id_cliente
   where c.sexo='M'
    group by date_part('year',sp.fecha_contratacion),
   date_part('month'::text, sp.fecha_contratacion) 
   order by total_mes desc 
   limit 1
   