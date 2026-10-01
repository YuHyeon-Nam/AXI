module axi4_lite_top (
    input ACLK,
    input ARESETn
);
    //waddr ch
    logic AWVALID;
    logic AWREADY;
    logic AWADDR;
    logic AWPROT;
    
    //wdata ch
    logic WVALID;
    logic WREADY;
    logic WDATA;
    logic WSTRB;

    //wresp ch
    logic BVALID;
    logic BREADY;
    logic BRESP;

    //raddr ch
    logic ARVALID;
    logic ARREADY;
    logic ARADDR;
    logic ARPROT;

    //rdata ch
    logic RVALID;
    logic RREADY;
    logic RDATA;
    logic RRESP;
    
endmodule