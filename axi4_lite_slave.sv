module axi4_lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS = 32
) (
    //Global Signals
    input logic ACLK,
    input logic ARESETn,

    //arread channel 
    input  logic [ADDRESS-1:0] S_ARADDR,
    input  logic               S_ARVALID,
    output logic               S_ARREADY,
    //output logic [2:0] ARPROT

    //read channel
    input  logic                  S_RREADY,
    output logic [DATA_WIDTH-1:0] S_RDATA,
    output logic [           1:0] S_RRESP,
    output logic                  S_RVALID,

    //aw channel
    input  logic [ADDRESS-1:0] S_AWADDR,
    input  logic               S_AWVALID,
    output logic               S_AWREADY,

    //write channel
    input  logic [DATA_WIDTH-1:0] S_WDATA,
    input  logic                  S_WSTRB,
    input  logic                  S_WVALID,
    output logic                  S_WREADY,
    output logic [           1:0] S_BRESP,
    output logic                  S_BVALID,

    input logic S_BREADY
);
  localparam no_of_registers = 32;
  logic [DATA_WIDTH-1:0] register[no_of_registers-1:0];
  logic [ADDRESS-1:0] addr;
  logic write_addr;
  logic write_data;

  integer i;

  typedef enum {
    IDLE,
    AR_CHANNEL,
    RDATA_CHANNEL,
    WRITE_CHANNEL,
    WRESP_CHANNEL
  } state_type;
  state_type state, n_state;

  //ar
  assign S_ARREADY = (state == AR_CHANNEL) ? 1 : 0;
  //read
  assign S_RDATA = (state == RDATA_CHANNEL) ? register[addr] : 0;
  assign S_RRESP = (state == RDATA_CHANNEL) ? 2'b00 : 0;

  //write
  assign S_WREADY = (state == WRITE_CHANNEL) ? 1 : 0;
  assign write_data = (S_WREADY && S_WVALID) ? 1 : 0;
  assign write_addr = (S_WREADY && S_WVALID) ? 1 : 0;

  always_ff @(posedge ACLK) begin
    if (!ARESETn) begin
      for (i = 0; i < 32; i++) begin
        register[i] <= 32'b0;
      end
    end else begin
      if (state == WRITE_CHANNEL) begin
        register[S_AWADDR] <= S_WDATA;
      end else if (state == AR_CHANNEL) begin
        addr <= S_ARADDR;
      end
    end
  end

  always_ff @(posedge ACLK) begin
    if (!ARESETn) begin
      state <= IDLE;
    end else begin
      state <= n_state;
    end
  end

  always_comb begin
    case (state)
      IDLE: begin
        if (S_AWVALID) begin
          n_state = WRITE_CHANNEL;
        end else if (S_ARVALID) begin
          n_state = RDATA_CHANNEL;
        end else begin
          n_state = IDLE;
        end
      end
      AR_CHANNEL: begin
        if (S_ARVALID && S_ARREADY) n_state = RDATA_CHANNEL;
      end
      RDATA_CHANNEL: begin
        if (S_RVALID && S_RREADY) n_state = IDLE;
      end
      WRITE_CHANNEL: begin
        if (write_addr && write_data) n_state = WRESP_CHANNEL;
      end
      WRESP_CHANNEL: begin
        if (S_BVALID && S_BREADY) n_state = IDLE;
      end
      default: n_state = IDLE;
    endcase

  end


endmodule
