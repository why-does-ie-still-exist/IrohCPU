# IrohCPU
### *An 8-bit CPU written entirely in Verilog*

This is a CPU written in Verilog intended for simulation. It has 256 words of addressable memory, although only 256 bytes of this is accessible to most instructions.

I wrote it so I could learn how CPUs work at the register level as well as learning about digital logic. It is turing complete, although given the memory limitations it probably cna't implement many useful algorithms.

### How to run

The CPU was simulated in Intel ModelSim. However, I have reason to believe ModelSim has hardcoded paths baked into project files, so you'll have to create an empty project and create a simluation configuration that runs `tb.v`, which has all the code necessary to run the cpu.

The CPU will load whatever program you put into `program.dat`
