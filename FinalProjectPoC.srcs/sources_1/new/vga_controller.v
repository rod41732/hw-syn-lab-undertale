`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2020 05:06:05 PM
// Design Name: 
// Module Name: vga_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// renderer + logic check
module vga_controller(
    clk,
    gameClk, // game clock, only run X time per sec
    // player part
    tx_buf,
    transmit,
    // RAM part, naming is respect to RAM
    writeAddr,
    dataIn,
    we,

    debugOutput
    // readAddr,
    // dataOut
);
    parameter WIDTH = 640;
    parameter HEIGHT = 480;
    parameter BUS_WIDTH = 12; // set equal to size of color

    localparam NUM_OF_ENTITY = 2;

    // declaration
    // clocks
    input wire clk;
    input wire gameClk;
    // keyboards
    input wire [7:0] tx_buf;
    input wire transmit;
    // to-from RAM
    output reg [18:0] writeAddr;
    // output wire [18:0] readAddr;
    output reg we;
    output wire [BUS_WIDTH-1:0] dataIn;
    output reg [15:0] debugOutput;
    // input wire [BUS_WIDTH-1:0] dataOut;

    // local state
    reg [1:0] state = 0, nextState; // 0=CLEAR, 1=DRAW_PLAYER, 2=IDLE (wait for next tick)
    reg pGameClk = 0, nextWe;
    reg [18:0] nextWriteAddr;
    
    // scan position
    reg [9:0] i = 0, j = 0, ni, nj; // row, col
	
    // game data
    reg [9:0] cx = 10'd320, cy = 10'd240;
    reg isHit = 0;
    reg [5:0] hitCD = 0;
    reg [7:0] hp = 100, maxHp = 100, enemyHp = 100, maxEnemyHp = 100; // playerHP

    reg [3:0] gameState = 0; //
    reg [15:0] tickCount = 0; // for countdown purpose or something

    // ========= wirings
    // RGB data from module
    wire [BUS_WIDTH-1:0] playerRGB, enemy1RGB, enemy2RGB, borderRGB, hpbarRGB;
    
    // buffer    
    reg [BUS_WIDTH-1:0] dataInReg;
    

    // next states (state, i, j) calculation
    always @(*) begin
        if (state == 1) // advance when idle only
            if (j == WIDTH-1) begin // end_row
                nj = 0;

                if (i == HEIGHT-1)
                    ni = 0;
                else
                    ni = i + 1;
            end // normally
            else begin
                ni = i;
                nj = j + 1;
            end


        // calculate state 
        if (state == 0)
            nextState = 1;
        else if (state == 1)
            nextState = (j == WIDTH-1 && i == HEIGHT-1) ? 2 : 1;
        if (state == 2)
            nextState = (!gameClk && pGameClk) ? 0 : 2; // negedge ?


        nextWriteAddr = (state == 2'b00 || state == 2'b01) ? 11'd640*{9'b0, i} + j : 0;
        nextWe = state == 2'b00 || state == 2'b01;
    end

    // state assignment
    always @(posedge clk) begin
        state <= nextState;
        i <= ni;
        j <= nj;
        we <= nextWe;
        writeAddr <= nextWriteAddr;

        if (state == 0) begin
            dataInReg <= 0;
            isHit <= 0;
            hp <= isHit ? (hp <= 3 ? 0 : hp - 3) : hp;
            hitCD = hitCD == 0 ? 0 : hitCD - 1;
        end
        else if (state == 1) begin

            if (gameState == 0) begin // VS monster
                if (|playerRGB) dataInReg <= playerRGB;
                else if (|enemy1RGB) dataInReg <= enemy1RGB;
                else if (|enemy2RGB) dataInReg <= enemy2RGB;
                else if (|borderRGB) dataInReg <= borderRGB;
                else if (|hpbarRGB) dataInReg <= hpbarRGB;
                else dataInReg = 0;
                
                if (|playerRGB && (|enemy1RGB || |enemy2RGB) && ~isHit && ~|hitCD) begin
                    isHit <= 1;
                    hitCD <= 6'd60;
                end
            end
            else begin
                dataInReg <= 5'd1; // dummy data
            end
        end
        pGameClk = gameClk;
    end

    // // TODO: control gameState and tickcount
    always @(posedge gameClk) begin
        if (gameState == 0) begin
            if (tickCount == 300) begin
                gameState = 1;
                tickCount = 0;
            end
            else 
                tickCount = tickCount + 1;
        end 
        else if (gameState == 1) begin
            if (tickCount == 40) begin
                gameState = 0; 
                tickCount = 0;
            end
            else 
                tickCount = tickCount + 1;
        end
    end

    // keyboard logic stuff
	always @(negedge transmit) begin
		if (tx_buf == 8'h57) cy = cy - 10; // w 
		else if (tx_buf == 8'h53) cy = cy + 10; // s
		else if (tx_buf ==  8'h41) cx = cx - 10; // a
		else if (tx_buf ==  8'h44) cx = cx + 10; // d
	end


    // ============================== model section
    player #(.BUS_WIDTH(BUS_WIDTH)) playerModel(
        cx,
        cy,
        j,
        i,
        playerRGB
    );

    // enemy #(.COLOR_WIDTH(BUS_WIDTH)) enemy1(
    enemy #(.COLOR_WIDTH(BUS_WIDTH), .initY(320)) enemy1(
        gameClk,
        1,
        0,
        j,
        i,
        enemy1RGB
    );

    enemy #(.COLOR_WIDTH(BUS_WIDTH), .initX(320)) enemy2(
        gameClk,
        0,
        1,
        j,
        i,
        enemy2RGB
    );

    border #(.BUS_WIDTH(BUS_WIDTH)) gameBorder(
        j, i, borderRGB
    );

    hpbar hpbar1(j, i, hp, maxHp, enemyHp, maxEnemyHp, hpbarRGB);

    // ================================= end model section 

    assign dataIn = dataInReg;

endmodule
