module axi4_lite_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS = 32
) (
    input  logic                  ACLK,
    input  logic                  ARESETn,
    input  logic                  read_s,
    input  logic                  write_s,
    input  logic [   ADDRESS-1:0] address,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data
);
  //waddr ch
  logic                  AWVALID;
  logic                  AWREADY;
  logic [   ADDRESS-1:0] AWADDR;

  //wdata ch
  logic                  WVALID;
  logic                  WREADY;
  logic [DATA_WIDTH-1:0] WDATA;
  logic                  WSTRB;

  //wresp ch
  logic                  BVALID;
  logic                  BREADY;
  logic [           1:0] BRESP;

  //raddr ch
  logic                  ARVALID;
  logic                  ARREADY;
  logic [   ADDRESS-1:0] ARADDR;

  //rdata ch
  logic                  RVALID;
  logic                  RREADY;
  logic [DATA_WIDTH-1:0] RDATA;
  logic [           1:0] RRESP;

  axi4_lite_master #(
      .DATA_WIDTH(32),
      .ADDRESS(32)
  ) u_axi_lite_master (
      .ACLK(ACLK),
      .ARESETn(ARESETn),
      .START_READ(read_s),
      .START_WRITE(write_s),
      .w_data(w_data),
      .address(address),
      .r_data(r_data),
      .M_ARREADY(ARREADY),
      .M_ARADDR(ARADDR),
      .M_ARVALID(ARVALID),
      .M_RDATA(RDATA),
      .M_RRESP(RRESP),
      .M_RVALID(RVALID),
      .M_RREADY(RREADY),
      .M_AWADDR(AWADDR),
      .M_AWVALID(AWVALID),
      .M_AWREADY(AWREADY),
      .M_WDATA(WDATA),
      .M_WSTRB(WSTRB),
      .M_WVALID(WVALID),
      .M_WREADY(WREADY),
      .M_BRESP(BRESP),
      .M_BVALID(BVALID),
      .M_BREADY(BREADY)
  );

  axi4_lite_slave #(
      .DATA_WIDTH(32),
      .ADDRESS(32)
  ) u_axi4_lite_slave (
      .ACLK(ACLK),
      .ARESETn(ARESETn),
      .S_ARADDR(ARADDR),
      .S_ARVALID(ARVALID),
      .S_ARREADY(ARREADY),
      .S_RREADY(RREADY),
      .S_RDATA(RDATA),
      .S_RRESP(RRESP),
      .S_RVALID(RVALID),
      .S_AWADDR(AWADDR),
      .S_AWVALID(AWVALID),
      .S_AWREADY(AWREADY),
      .S_WDATA(WDATA),
      .S_WSTRB(WSTRB),
      .S_WVALID(WVALID),
      .S_WREADY(WREADY),
      .S_BRESP(BRESP),
      .S_BVALID(BVALID),
      .S_BREADY(BREADY)
  );
endmodule
