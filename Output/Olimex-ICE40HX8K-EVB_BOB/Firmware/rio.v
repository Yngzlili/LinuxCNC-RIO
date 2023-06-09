/*
    ######### Olimex-ICE40HX8K-EVB_BOB #########
*/


module rio (
        input DIN0,
        input DIN1,
        input DIN2,
        input DIN3,
        input DIN4,
        output DOUT0,
        output DOUT1,
        output DOUT2,
        output DOUT3,
        output ENA,
        output ERROR_OUT,
        input INTERFACE_SPI_MOSI,
        output INTERFACE_SPI_MISO,
        input INTERFACE_SPI_SCK,
        input INTERFACE_SPI_SSEL,
        output JOINT0_STEPPER_STP,
        output JOINT0_STEPPER_DIR,
        output JOINT1_STEPPER_STP,
        output JOINT1_STEPPER_DIR,
        output JOINT2_STEPPER_STP,
        output JOINT2_STEPPER_DIR,
        output JOINT3_STEPPER_STP,
        output JOINT3_STEPPER_DIR,
        output JOINT4_STEPPER_STP,
        output JOINT4_STEPPER_DIR,
        input sysclk,
        input VIN0_ENCODER_A,
        input VIN0_ENCODER_B,
        output VOUT0_PWM_DIR,
        output VOUT0_PWM_PWM,
        output VOUT1_PWM_DIR,
        output VOUT1_PWM_PWM
    );


    reg ESTOP = 0;
    wire ERROR;
    wire INTERFACE_TIMEOUT;
    assign ERROR = (INTERFACE_TIMEOUT | ESTOP);
    assign ERROR_OUT = ERROR;

    parameter BUFFER_SIZE = 272;

    wire[271:0] rx_data;
    wire[271:0] tx_data;

    reg signed [31:0] header_tx;
    always @(posedge sysclk) begin
        if (ESTOP) begin
            header_tx <= 32'h65737470;
        end else begin
            header_tx <= 32'h64617461;
        end
    end

    wire jointEnable0;
    wire jointEnable1;
    wire jointEnable2;
    wire jointEnable3;
    wire jointEnable4;

    assign ENA = (jointEnable0 || jointEnable1 || jointEnable2 || jointEnable3 || jointEnable4) && ~ERROR;

    // fake din's to fit byte
    reg DIN5 = 0;
    reg DIN6 = 0;
    reg DIN7 = 0;

    // vouts 2
    wire signed [31:0] setPoint0;
    wire signed [31:0] setPoint1;

    // vins 1
    wire signed [31:0] processVariable0;

    // joints 5
    wire signed [31:0] jointFreqCmd0;
    wire signed [31:0] jointFreqCmd1;
    wire signed [31:0] jointFreqCmd2;
    wire signed [31:0] jointFreqCmd3;
    wire signed [31:0] jointFreqCmd4;
    wire signed [31:0] jointFeedback0;
    wire signed [31:0] jointFeedback1;
    wire signed [31:0] jointFeedback2;
    wire signed [31:0] jointFeedback3;
    wire signed [31:0] jointFeedback4;

    // rx_data 272
    wire [31:0] header_rx;
    assign header_rx = {rx_data[247:240], rx_data[255:248], rx_data[263:256], rx_data[271:264]};
    assign jointFreqCmd0 = {rx_data[215:208], rx_data[223:216], rx_data[231:224], rx_data[239:232]};
    assign jointFreqCmd1 = {rx_data[183:176], rx_data[191:184], rx_data[199:192], rx_data[207:200]};
    assign jointFreqCmd2 = {rx_data[151:144], rx_data[159:152], rx_data[167:160], rx_data[175:168]};
    assign jointFreqCmd3 = {rx_data[119:112], rx_data[127:120], rx_data[135:128], rx_data[143:136]};
    assign jointFreqCmd4 = {rx_data[87:80], rx_data[95:88], rx_data[103:96], rx_data[111:104]};
    assign setPoint0 = {rx_data[55:48], rx_data[63:56], rx_data[71:64], rx_data[79:72]};
    assign setPoint1 = {rx_data[23:16], rx_data[31:24], rx_data[39:32], rx_data[47:40]};
    // assign jointEnable7 = rx_data[15];
    // assign jointEnable6 = rx_data[14];
    // assign jointEnable5 = rx_data[13];
    assign jointEnable4 = rx_data[12];
    assign jointEnable3 = rx_data[11];
    assign jointEnable2 = rx_data[10];
    assign jointEnable1 = rx_data[9];
    assign jointEnable0 = rx_data[8];
    // assign DOUT7 = rx_data[7];
    // assign DOUT6 = rx_data[6];
    // assign DOUT5 = rx_data[5];
    // assign DOUT4 = rx_data[4];
    assign DOUT3 = rx_data[3];
    assign DOUT2 = rx_data[2];
    assign DOUT1 = rx_data[1];
    assign DOUT0 = rx_data[0];

    // tx_data 232
    assign tx_data = {
        header_tx[7:0], header_tx[15:8], header_tx[23:16], header_tx[31:24],
        jointFeedback0[7:0], jointFeedback0[15:8], jointFeedback0[23:16], jointFeedback0[31:24],
        jointFeedback1[7:0], jointFeedback1[15:8], jointFeedback1[23:16], jointFeedback1[31:24],
        jointFeedback2[7:0], jointFeedback2[15:8], jointFeedback2[23:16], jointFeedback2[31:24],
        jointFeedback3[7:0], jointFeedback3[15:8], jointFeedback3[23:16], jointFeedback3[31:24],
        jointFeedback4[7:0], jointFeedback4[15:8], jointFeedback4[23:16], jointFeedback4[31:24],
        processVariable0[7:0], processVariable0[15:8], processVariable0[23:16], processVariable0[31:24],
        DIN7, DIN6, DIN5, DIN4, DIN3, DIN2, DIN1, DIN0,
        40'd0
    };

    // expansion I/O's

    // vin_quadencoder's
    vin_quadencoder #(32) vin_quadencoder0 (
        .clk (sysclk),
        .quadA (VIN0_ENCODER_A),
        .quadB (VIN0_ENCODER_B),
        .pos (processVariable0)
    );

    // interface_spislave
    interface_spislave #(BUFFER_SIZE, 32'h74697277, 100000000) spi1 (
        .clk (sysclk),
        .SPI_SCK (INTERFACE_SPI_SCK),
        .SPI_SSEL (INTERFACE_SPI_SSEL),
        .SPI_MOSI (INTERFACE_SPI_MOSI),
        .SPI_MISO (INTERFACE_SPI_MISO),
        .rx_data (rx_data),
        .tx_data (tx_data),
        .pkg_timeout (INTERFACE_TIMEOUT)
    );

    // vout_spipoti's

    // expansion_shiftreg's

    // vout_pwm's
    vout_pwm #(10000) vout_pwm0 (
        .clk (sysclk),
        .dty (setPoint0),
        .disabled (ERROR),
        .dir (VOUT0_PWM_DIR),
        .pwm (VOUT0_PWM_PWM)
    );
    vout_pwm #(10000) vout_pwm1 (
        .clk (sysclk),
        .dty (setPoint1),
        .disabled (ERROR),
        .dir (VOUT1_PWM_DIR),
        .pwm (VOUT1_PWM_PWM)
    );

    // vin_pulsecounter's

    // vin_mpgencoder's

    // vout_frequency's

    // joint_pwmdir's

    // vin_pwmcounter's

    // joint_stepper's
    joint_stepper joint_stepper0 (
        .clk (sysclk),
        .jointEnable (jointEnable0 && !ERROR),
        .jointFreqCmd (jointFreqCmd0),
        .jointFeedback (jointFeedback0),
        .DIR (JOINT0_STEPPER_DIR),
        .STP (JOINT0_STEPPER_STP)
    );
    joint_stepper joint_stepper1 (
        .clk (sysclk),
        .jointEnable (jointEnable1 && !ERROR),
        .jointFreqCmd (jointFreqCmd1),
        .jointFeedback (jointFeedback1),
        .DIR (JOINT1_STEPPER_DIR),
        .STP (JOINT1_STEPPER_STP)
    );
    joint_stepper joint_stepper2 (
        .clk (sysclk),
        .jointEnable (jointEnable2 && !ERROR),
        .jointFreqCmd (jointFreqCmd2),
        .jointFeedback (jointFeedback2),
        .DIR (JOINT2_STEPPER_DIR),
        .STP (JOINT2_STEPPER_STP)
    );
    joint_stepper joint_stepper3 (
        .clk (sysclk),
        .jointEnable (jointEnable3 && !ERROR),
        .jointFreqCmd (jointFreqCmd3),
        .jointFeedback (jointFeedback3),
        .DIR (JOINT3_STEPPER_DIR),
        .STP (JOINT3_STEPPER_STP)
    );
    joint_stepper joint_stepper4 (
        .clk (sysclk),
        .jointEnable (jointEnable4 && !ERROR),
        .jointFreqCmd (jointFreqCmd4),
        .jointFeedback (jointFeedback4),
        .DIR (JOINT4_STEPPER_DIR),
        .STP (JOINT4_STEPPER_STP)
    );

    // vin_sonar's

    // vout_udpoti's

    // vin_frequency's

    // joint_rcservo's

    // vout_sinepwm's

endmodule
