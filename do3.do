vlib work
vlog alr.v alsu.v packq3.sv q3.sv +cover
vsim -voptargs=+acc work.ALSU -cover
add wave *
coverage save alsu.ucdb -onexit
run -all