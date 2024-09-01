// Code your testbench here
// or browse Examples


`include "uvm_macros.svh"

package P4_pkg; 
import uvm_pkg::*;

localparam int NBIT = 16;
localparam int num_cycles = 1000;

  class sqnc_item extends uvm_sequence_item;

    `uvm_object_utils(sqnc_item)
  
    rand bit cin;
    rand logic [NBIT-1:0] A;
    rand logic [NBIT-1:0] B;
    bit cout;
    logic [NBIT-1:0] S;
    
    // Constraint to prefer corner cases for operands /10x more likely)
    constraint ab_dist_c {
        A dist {
            0                   :=1000, 
            (1<<NBIT)-1       :=1000,
            (1<<(NBIT-1))-1   :=1000, 
            [1:(1<<NBIT)-2]   :=1
        };
        B dist {
            0                   :=1000, 
            (1<<NBIT)-1       :=1000,
            (1<<(NBIT-1))-1   :=1000, 
            [1:(1<<NBIT)-2]   :=1
        };
    };
    
    function new (string name = "");
      super.new(name);
    endfunction
    
    function string convert2string;
      return $sformatf("Cin=%b, A=%0d, B=%0d, S=%0d, Cout=%0d", cin, A, B, S, cout);
    endfunction

    function void do_copy(uvm_object rhs);
      sqnc_item tx;
      $cast(tx, rhs);
      cin  = tx.cin;
      A = tx.A;
      B = tx.B;
      S = tx.S; 
      cout = tx.cout; 
    endfunction
    
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      sqnc_item tx;
      bit status = 1;
      $cast(tx, rhs);
      status &= (cin  == tx.cin);
      status &= (A == tx.A);
      status &= (B == tx.B);
      status &= (S == tx.S);
      status &= (cout == tx.cout);
      return status;
    endfunction

  endclass: sqnc_item

class P4_sequence extends uvm_sequence #(sqnc_item); 

  `uvm_object_utils(P4_sequence)

function new (string name = ""); 
super.new (name); 
endfunction

task body; 
`uvm_info ("SEQUENCE", $sformatf("TASK BODY: STARTING..."), UVM_HIGH)
if (starting_phase != null)
starting_phase.raise_objection(this); 

repeat(num_cycles)
// create the object, start it, randomize it, end it. 
      begin
        req = sqnc_item::type_id::create("req");
        start_item(req);
        if( !req.randomize() )
          `uvm_error("", "Randomize failed")
        finish_item(req);
        `uvm_info ("SEQUENCE", $sformatf("SEQUENCE ITEM GENERATED! | %S", req.convert2string()), UVM_HIGH)
      end

if (starting_phase != null)
starting_phase.drop_objection(this);
endtask 
endclass: P4_sequence


class P4_driver extends uvm_driver #(sqnc_item); 
 `uvm_component_utils(P4_driver)

    virtual P4_if dut_vi ; 

    function new (string name, uvm_component parent); 
        super.new (name, parent); 
    endfunction

function void build_phase (uvm_phase phase); 
      // Get interface reference from config database
      if( !uvm_config_db #(virtual P4_if)::get(this, "", "P4_if", dut_vi) )
        `uvm_error("", "uvm_config_db::get failed")
endfunction

task run_phase (uvm_phase phase); 
//get sqnc_item, drive it to IF, close it
forever
      begin
        seq_item_port.get_next_item(req);
        @(posedge dut_vi.clock);
        `uvm_info ("DRIVER", $sformatf("DRIVING THE GENERATED PACKET"), UVM_HIGH)
        dut_vi.cin  = req.cin;
        dut_vi.A = req.A;
        dut_vi.B = req.B; 
        seq_item_port.item_done();
      end
endtask 
endclass: P4_driver


class P4_sequencer extends uvm_sequencer #(sqnc_item); 
  `uvm_component_utils(P4_sequencer)

function new (string name, uvm_component parent); 
super.new (name, parent); 
endfunction

endclass: P4_sequencer


class P4_monitor extends uvm_monitor; 
  
  `uvm_component_utils(P4_monitor)
  virtual P4_if dut_vi; 
  semaphore sema4; 

  function new (string name, uvm_component parent); 
    super.new(name,parent);
  endfunction
  
  uvm_analysis_port #(sqnc_item) mon_analysis_port; 

  function void build_phase (uvm_phase phase); 
      `uvm_info (get_type_name(), "START BUILDING PHASE", UVM_HIGH)

    //get if
    if( !uvm_config_db #(virtual P4_if)::get(this, "", "P4_if", dut_vi) )
    `uvm_error("", "uvm_config_db::get failed")
    sema4 = new(1);
    //call analysys_port constructor
    mon_analysis_port = new ("mon_analaysis_port", this); 
  endfunction

  task run_phase (uvm_phase phase);
    //create an transaction object, assign the if value to it, write it on the port.
    sqnc_item data; 
    data = sqnc_item::type_id::create("data"); 
    forever begin 
      @(negedge dut_vi.clock);
      data.A = dut_vi.A; 
      data.B = dut_vi.B; 
      data.cin = dut_vi.cin; 
      data.cout = dut_vi.cout; 
      data.S = dut_vi.S;
      `uvm_info("Monitor", $sformatf("found packet: %s", data.convert2string()), UVM_MEDIUM)
    mon_analysis_port.write(data);
    end     
  endtask
endclass


class P4_agent extends uvm_agent; 

  `uvm_component_utils(P4_agent)
  function new (string name, uvm_component parent); 
    super.new (name, parent); 
  endfunction

  P4_driver driver; 
  P4_sequencer sequencer; 
  P4_monitor monitor; 

  function void build_phase (uvm_phase phase); 
      `uvm_info (get_type_name(), "START BUILDING PHASE", UVM_HIGH)

    driver = P4_driver::type_id::create("driver", this);
    sequencer = P4_sequencer::type_id::create ("sequencer", this);
    monitor = P4_monitor::type_id::create("monitor", this); 
  endfunction

  virtual function void connect_phase (uvm_phase phase);
      `uvm_info (get_type_name(), "START CONNECT PHASE", UVM_HIGH)

    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass


class P4_scoreboard extends uvm_scoreboard; 

  `uvm_component_utils(P4_scoreboard)

  function new (string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent); 
  endfunction
  //get data from analysis_port, compute expected results, compare real results with expected. 
  uvm_analysis_imp #(sqnc_item, P4_scoreboard) ap_imp; 

  virtual function void build_phase (uvm_phase phase); 
      `uvm_info (get_type_name(), "START BUILDING PHASE", UVM_HIGH)

    super.build_phase(phase);
    ap_imp = new("ap_imp", this); 
  endfunction
  
  //compute the expected output for a given item
  function sqnc_item ref_model (sqnc_item item);
  sqnc_item expected_item = sqnc_item::type_id::create("expected_item");  
  logic [NBIT:0] tmp = item.A + item.B + item.cin; 
  expected_item.S = tmp [NBIT-1:0]; 
  expected_item.cout = tmp[NBIT];
  //`uvm_info ("SCOREBOARD", $sformatf("REF_MODEL: EXPECTED_ITEM: %0d", expected_item.S), UVM_HIGH)

  return expected_item; 
  endfunction

  //check wether expected output matches the actual one.
  virtual function void write (sqnc_item actual);

   sqnc_item expected_out = new; 
    expected_out = ref_model(actual); 

    if (expected_out.S != actual.S) begin
      `uvm_error("Scoreboard:", $sformatf("Time: %0t | Expected sum: %0d, Actual: %0d", $time, expected_out.S, actual.S))
    if (expected_out.cout != actual.cout)
      `uvm_error("Scoreboard:", $sformatf("Time: %0t | Expected Cout: %b, Actual: %b", $time, expected_out.cout, actual.cout))
    end
        `uvm_info ("SCOREBOARD", $sformatf("WRITE FUNCTION: Expected sum: %0d, Actual: %0d", expected_out.S, actual.S), UVM_HIGH)
  endfunction 

  task run_phase (uvm_phase phase); 

  endtask
  
  //to be completed
  virtual function void check_phase (uvm_phase phase); 

  endfunction
endclass: P4_scoreboard



class P4_cov extends uvm_subscriber#(sqnc_item);

    `uvm_component_utils(P4_cov)

    sqnc_item item; 
    covergroup P4_cg;
        a_cp: coverpoint item.A {
            bins corner[]   = {0, (1<<NBIT)-1, (1<<(NBIT-1))-1};
            bins others     = default;
        }
        b_cp: coverpoint item.B {
            bins corner[]   = {0, (1<<NBIT)-1, (1<<(NBIT-1))-1};
            bins others     = default;
        }
    endgroup: P4_cg

    function new (string name = "", uvm_component parent); 
      super.new(name, parent);
      P4_cg = new;
    endfunction

    function void build_phase (uvm_phase phase);
    `uvm_info ("COV", $sformatf("WRITE FUNCTION: start coverage"), UVM_HIGH)
    P4_cg.start(); 
    endfunction 

    function void extract_phase (uvm_phase phase); 
    `uvm_info ("COV", $sformatf("WRITE FUNCTION: stop coverage"), UVM_HIGH)
    P4_cg.stop(); 
    endfunction

  virtual function void write (sqnc_item t);
    `uvm_info ("COV", $sformatf("WRITE FUNCTION: sampling for coverage: A = %0d", t.A), UVM_HIGH)
      item = t; 
      //t.do_copy(ite); 
      P4_cg.sample(); 
    endfunction
endclass: P4_cov


class P4_env extends uvm_env; 

`uvm_component_utils(P4_env)

P4_scoreboard scoreboard; 
P4_agent agent; 
P4_cov cov; 

function new (string name, uvm_component parent); 
super.new (name, parent);
endfunction

function void build_phase (uvm_phase phase); 
    `uvm_info (get_type_name(), "START BUILDING PHASE", UVM_HIGH)
scoreboard = P4_scoreboard::type_id::create("scoreboard",this);
agent = P4_agent::type_id::create("agent",this);
cov = P4_cov::type_id::create("cov",this);
endfunction

function void connect_phase (uvm_phase phase); 
agent.monitor.mon_analysis_port.connect(scoreboard.ap_imp);
agent.monitor.mon_analysis_port.connect(cov.analysis_export); 
endfunction
endclass: P4_env


class P4_test extends uvm_test;

  `uvm_component_utils(P4_test)
  //create an instance of env class
  P4_env env; 

  function new (string name, uvm_component parent); 
    super.new (name, parent);
  endfunction

  function void build_phase (uvm_phase phase); 
    `uvm_info (get_type_name(), "START BUILDING PHASE", UVM_MEDIUM)
    env = P4_env::type_id::create("P4_env",this);
  endfunction

    task run_phase(uvm_phase phase);
      P4_sequence seq;
      seq = P4_sequence::type_id::create("seq");
      if( !seq.randomize() ) 
        `uvm_error("", "Randomize failed")
      seq.starting_phase = phase;
      seq.start(env.agent.sequencer );
    endtask
    
endclass: P4_test

endpackage: P4_pkg



module top; 
  import uvm_pkg::*;
  import P4_pkg::*;
  //instance interface and wrap
  P4_if dut_if (); 
  P4_wrap dut_wrap(dut_if); 
  //clock process
  initial
  begin
    dut_if.clock = 0;
    forever #5 dut_if.clock = ~dut_if.clock;
  end
  
  initial
  begin
    uvm_config_db #(virtual P4_if)::set(null, "*", "P4_if", dut_if);
    uvm_top.finish_on_completion = 1;

    //set verbosity level for uvm_info messages
    uvm_top.set_report_verbosity_level(UVM_HIGH);
    `uvm_info ("TOP", $sformatf("TEST STARTIG..."), UVM_MEDIUM)
    //run the test
    run_test("P4_test");
    `uvm_info ("TOP", $sformatf("TEST FINISHED"), UVM_MEDIUM)
  end

endmodule: top