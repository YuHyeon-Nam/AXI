module axi4_lite_master (
    input logic ACLK,
    input logic ARESETn,
    input logic start_rd, // upstream pulse signal
    input logic [31:0] raddr,
    output logic [31:0] ARADDR,
    output logic ARVALID,
    input logic ARREADY
    //output logic [2:0] ARPROT
);

  reg [31:0] r_raddr;
  reg r_rvalid;

 //1번시도
  always_ff @(posedge ACLK) begin
    if (!ARESETn) begin
      ARADDR   <= 31'b0;
      ARVALID  <= 1'b0;
      r_raddr  <= '0;
      ARVALID <= '0;
    end else if (start_rd) begin
      r_raddr  <= raddr;
      ARVALID <= 1'b1;
    end else if (ARVALID && ARREADY) begin
      ARADDR  <= r_raddr;
      ARVALID <= 1'b0;
    end else begin
    end
  end

  // 2번시도 FSM

  logic [1:0] state, n_state;
  localparam IDLE = 2'b00, ONE = 2'b01, TWO = 2'b10, THREE = 2'b11;

  always_ff @(posedge ACLK) begin
    if (!ARESETn) begin
      state  <= IDLE;
      ARADDR   <= 31'b0;
      ARVALID  <= 1'b0;
      r_raddr  <= '0;
      r_rvalid <= '0;
    end else begin
        state <= n_state;
    end
  end

    // master/processor read에 대해 1cycle이 더 걸림 ONE에서?
  always_comb begin
    ARADDR = 1'b0;
    ARVALID = 1'b0;
    n_state = state;
    case (state)
        IDLE: begin
            if(start_rd) begin
                r_raddr = raddr;
                r_rvalid = 1'b1;
                n_state = ONE;
            end
        end
        ONE : begin
            if(ARREADY)begin
                ARADDR = r_raddr;  
                ARVALID = r_rvalid;
                n_state = TWO;
            end
        end
    endcase
  end

endmodule
