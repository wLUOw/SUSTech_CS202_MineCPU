#include <unicorn/unicorn.h>
#include <verilated.h>
#include <verilated_vpi.h>
#include <vector>
#include <fstream>
#include "VTop.h"

using std::vector;
const char *REG_NAMES[32] = {"x0", "ra", "sp", "gp", "tp", "t0", "t1", "t2", "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"};
const int SIM_TIME = 7;

// verilator
const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
VTop *top = new VTop(contextp.get());

// unicorn simulator
uc_engine *uc;

// vpi handles
vpiHandle pc;
vpiHandle regs[32];
vpiHandle mem[16383];
vpiHandle flush;

// from Monad's code
vector<char> read_binary(const char *name) {
    std::ifstream f;
    f.open(name, std::ios::binary);
    f.seekg(0, std::ios::end);
    size_t size = f.tellg();

    std::vector<char> data;
    data.resize(size);
    f.seekg(0, std::ios::beg);
    f.read(&data[0], size);
    return data;
}

vpiHandle get_handle(const char *name) {
    vpiHandle vh = vpi_handle_by_name((PLI_BYTE8*)name, NULL);
    if (vh == NULL) {
        printf("name: %s\n", name);
        vl_fatal(__FILE__, __LINE__, "get_handle", "No handle found");
    }
    return vh;
}

int get_value(vpiHandle vh) {
	s_vpi_value v; v.format = vpiIntVal;
	vpi_get_value(vh, &v);
	return v.value.integer;
}

void run_one_cycle() {
    top->cpuclk = 0;
    top->eval();
    for(int i = 0; i < 4; i++) {
        top->memclk = 1;
        top->eval();
        top->memclk = 0;
        top->eval();
        if (i % 2 == 0) {
            top->cpuclk = !top->cpuclk;
            top->eval();
        }
    }
}

bool diff_check() {
    bool pass = true;
    for (int i = 0, v; i < 32; i++) {
        uc_reg_read(uc, i + 1, &v);
        if (v != get_value(regs[i])) {
            pass = false;
            printf("regs: uc, cpu\n");
            printf("%4s: 0x%x, 0x%x\n", REG_NAMES[i], v, get_value(regs[i]));
        }
    }
    return pass;
}

void uart_one_bit() {
    for(int i = 0; i < 868; i++) run_one_cycle();
}

void send_uart(char msg) {
    top->rx = 1;
    uart_one_bit();
    top->rx = 0;
    uart_one_bit();
    for(int i = 0; i < 8; i++) {
        top->rx = (msg >> i) & 1;
        uart_one_bit();
    }
    // idle state
    top->rx = 1;
    uart_one_bit();
}

vector<uint32_t> load_program() {
    vector<char> data = read_binary("../sources/assembly/test/fib.bin");
    vector<unsigned int> inst;
    uint32_t size = data.size() / 4;

    if (uc_mem_write(uc, 0x0, data.data(), data.size())) {
        printf("Failed to write emulation code to memory, quit!\n");
        return vector<uint32_t>();
    }

    for(int i = 0; i < data.size(); i++) send_uart(data[i]);

    for(int i = 0, concat_data = 0; i < size; i++) {
        concat_data = 0;
        for(int j = 3; j >= 0; j--) concat_data = (concat_data << 8) | ((data[4 * i + j]) & 0xff);
        inst.push_back(concat_data);
    }

    return inst;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    // initialize unicorn
    uc_err err;
    if ((err = uc_open(UC_ARCH_RISCV, UC_MODE_32, &uc)) != UC_ERR_OK) {
        printf("Failed on uc_open() with error returned: %u\n", err);
        return -1;
    }
    uc_mem_map(uc, 0x0, 1024 * 1024 * 4, UC_PROT_ALL);
    uc_mem_map(uc, 0xffffff00, 1024 * 4, UC_PROT_ALL);
    int uc_sp = 0x7ffc, uc_gp = 0xffffff00;
    uc_reg_write(uc, UC_RISCV_REG_SP, &uc_sp);
    uc_reg_write(uc, UC_RISCV_REG_GP, &uc_gp);

    // initialize vpi handles
    pc = get_handle("TOP.Top.cpu_inst.pc_inst.pc");
    flush = get_handle("TOP.Top.cpu_inst.flush");
    for(int i = 0; i < 32; i++) regs[i] = vpi_handle_by_index(get_handle("TOP.Top.cpu_inst.id_inst.reg_inst.regs"), i);
    for(int i = 0; i < 16383; i++) mem[i] = vpi_handle_by_index(get_handle("TOP.Top.cpu_inst.memory_inst.test_inst.mem"), i);

    long long time = 0, uc_pc = 0;

    // load program
    top->rst_n = 1;
    vector<uint32_t> inst = load_program();
    for(int i = 0; i < 15; i++) uart_one_bit(); // finish uart by idle

    // run four cycles to get warm up
    for(int i = 0; i < 3; i++) run_one_cycle();

    while (uc_pc != 0xc) {
        run_one_cycle();
        if(get_value(flush)) run_one_cycle(); // penalty one cycle
    	VerilatedVpi::callValueCbs();
        // run one instruction on unicorn
        if ((err = uc_emu_start(uc, uc_pc, 0xFFFFFFFF, 0, 1))) {
            printf("pc: 0x%llx\n", uc_pc);
            printf("Failed on uc_emu_start() with error returned %u: %s\n", err, uc_strerror(err));
            break;
        }
        
        uc_reg_read(uc, UC_RISCV_REG_PC, &uc_pc);
        time++;
    }
    top->rst_n = 0;

    diff_check();
    printf("pc: 0x%x\n", get_value(pc));

	top->final();
    delete top;

	return 0;
}
