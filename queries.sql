-- Selecionando um schema
set search_path to public;

-- Diferença entre último e primeiro registro de uma data
select (lst - fst) as consumo
from (select first_value(nb_delivered_active_energy_total) over (order by dt_measurement_date)      fst,
             first_value(nb_delivered_active_energy_total) over (order by dt_measurement_date desc) lst
      from switchboard_measure
      where id_switchboard = 14
        and dt_measurement_date::date = '2023-8-10'
          fetch first 1 rows only) as foo;


