/**
 * File name:	memory_controller.svh
 * Created:	12/25/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Controller responsible for communicating with ram
 */

`include "datapath_if.svh"
`include "cpu_ram_if.svh"
`include "rv32ima_pkg.svh"

module memory_controller (
    datapath_if.mem _dpif,
    cpu_ram_if.cpu  _ramif
);
    import rv32ima_pkg::*;
    
    // TODO Arbiter irequest and datarequest
    always_comb begin: ARIBITER
        _dpif.imem_load = '0;
        _dpif.ihit = 1'b0;
        _dpif.dhit = 1'b0;
        _dpif.dmem_load = '0;
        _ramif.ram_addr = '0;
        _ramif.ram_store = '0;
        _ramif.ram_ren = 1'b0;
        _ramif.ram_wen = 1'b0;

        if (_dpif.dmem_wen == 1'b1) begin
            // Serve ongoing store
            _ramif.ram_addr = _dpif.dmem_addr;
            _ramif.ram_store = _dpif.dmem_store;
            _ramif.ram_wen = 1'b1;

            // TODO Get ram response? How?
            // TODO Find a way to synchronize the RAM and CPU?
            // Assume RAM CLK is at least two times faster
            _dpif.dhit = 1'b1;
        end
        else if (_dpif.dmem_ren == 1'b1) begin
            // Serve ongoing load
            _ramif.ram_addr = _dpif.dmem_addr;
            _ramif.ram_ren = 1'b1;

            // Assume RAM CLK is at least two times faster
            _dpif.dmem_load = _ramif.ram_load;
            _dpif.dhit = 1'b1;
        end
        else if (_dpif.imem_ren == 1'b1) begin
            // Serve ongoing fetch
            _ramif.ram_addr = _dpif.imem_addr;
            _ramif.ram_ren = 1'b1;

             // Assume RAM CLK is at least two times faster
            _dpif.imem_load = _ramif.ram_load;
            _dpif.ihit = 1'b1;
        end

    end
endmodule