module axi4_lite_master #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS = 32
) (
    //Global Signals
    input logic ACLK,
    input logic ARESETn,

    input logic START_READ,
    input logic START_WRITE,

    input logic [DATA_WIDTH-1:0] w_data,
    input logic [   ADDRESS-1:0] address,
    output logic [DATA_WIDTH-1:0] r_data,

    //arread channel 
    input  logic               M_ARREADY,
    output logic [ADDRESS-1:0] M_ARADDR,
    output logic               M_ARVALID,
    //output logic [2:0] ARPROT

    //read channel
    input  logic [DATA_WIDTH-1:0] M_RDATA,
    input  logic [           1:0] M_RRESP,
    input  logic                  M_RVALID,
    output logic                  M_RREADY,

    //aw channel
    output logic [ADDRESS-1:0] M_AWADDR,
    output logic               M_AWVALID,
    input  logic               M_AWREADY,

    //write channel
    output logic [DATA_WIDTH-1:0] M_WDATA,
    output logic                  M_WSTRB,
    output logic                  M_WVALID,
    input  logic                  M_WREADY,
    input  logic [           1:0] M_BRESP,
    input  logic                  M_BVALID,
    output logic                  M_BREADY

);

  logic read_start;
  logic write_addr;
  logic write_data;
  logic write_start;

  typedef enum logic [2:0] {
    IDLE,
    AR_CHANNEL,
    RDATA_CHANNEL,
    WRITE_CHANNEL,
    WRESP_CHANNEL
  } state_type;

  state_type state, n_state;

  //ar
  assign M_ARADDR = (state == AR_CHANNEL) ? address : 0;
  assign M_ARVALID = (state == AR_CHANNEL) ? 1 : 0;
  //read
  assign M_RREADY = (state == RDATA_CHANNEL) ? 1 : 0;
  //assign r_data = (state == RDATA_CHANNEL) ? M_RDATA : 32'h0; //to slave register
  //awrite
  assign M_AWVALID = (state == WRITE_CHANNEL) ? address : 0;
  assign M_AWADDR = (state == WRITE_CHANNEL) ? 1 : 0;
  assign write_addr = (M_AWVALID && M_AWREADY);
  assign write_data = (M_WVALID && M_WREADY);

  //write
  assign M_WVALID = (state == WRITE_CHANNEL) ? 1 : 0;
  assign M_WDATA = (state == WRITE_CHANNEL) ? w_data : 32'h0;
  assign M_WSTRB = (state == WRITE_CHANNEL) ? 4'b1111 : 0;  //fixed

  //wresp
  assign M_BREADY = ((state == WRESP_CHANNEL) || (state == WRESP_CHANNEL)) ? 1 : 0;

  always_ff @(posedge ACLK) begin
    if (!ARESETn) begin
      state <= IDLE;
      read_start <= 0;

    end else begin
      state <= n_state;
      read_start <= START_READ;
    end
  end

  always_comb begin
    case (state)
      IDLE: begin
        if (read_start) begin
          n_state = AR_CHANNEL;
        end else if (write_start) begin
          n_state = WRITE_CHANNEL;
        end else begin
          n_state = IDLE;
        end
      end
      AR_CHANNEL: begin
        if (M_ARVALID && M_ARREADY) n_state = RDATA_CHANNEL;
      end
      RDATA_CHANNEL: begin
        if (M_RVALID && M_RREADY) n_state = IDLE;
      end
      WRITE_CHANNEL: begin
        if (write_addr && w_data) n_state = WRESP_CHANNEL;
      end
      WRESP_CHANNEL: begin
        if (M_BVALID && M_BREADY) n_state = IDLE;
      end
      default: n_state = IDLE;
    endcase
  end



endmodule
