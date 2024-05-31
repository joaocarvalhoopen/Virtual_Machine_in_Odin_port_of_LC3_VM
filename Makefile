all:
	odin build . -out:vm.exe --debug
opti:
	odin build . -out:vm.exe -o:speed

clean:
	rm vm.exe

prog1:
	odin build ./dir_prog1/simple_program.odin -file -out:./dir_prog1/simple_program.exe

run_prog1:
	./dir_prog1/simple_program.exe --debug

run_vm_prog1:
	./vm.exe ./simple_program.obj

prog2:
	odin build ./dir_prog2/sum_program.odin -file -out:./dir_prog2/sum_program.exe

run_prog2:
	./dir_prog2/sum_program.exe --debug

run_vm_prog2:
	./vm.exe ./sum_program.obj



