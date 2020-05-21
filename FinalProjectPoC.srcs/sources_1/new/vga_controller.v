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
    reg nextWe;
    reg [18:0] nextWriteAddr;

    // polling
    reg pGameClk = 0, pTransmit = 0, pEncounter = 0;
    // --> Interrupt-ish ?
    wire onGameClk = !pGameClk && gameClk;
    wire onTransmit = !pTransmit && transmit;

    // scan position
    reg [9:0] i = 0, j = 0, ni, nj; // row, col
	
    // game data
    reg [9:0] cx = 10'd320, cy = 10'd240;
    reg isHit = 0;
    reg [5:0] hitCD = 0;
    reg [7:0] hp = 100, maxHp = 100, enemyHp = 1, maxEnemyHp = 100; // HPs
    wire [7:0] attackDamage; 

    reg [3:0] gameState = 7, nextGameState = 0; //
    reg [15:0] tickCount = 0, nextTickCount = 0; // for countdown purpose or something

    // ========= wirings
    // RGB data from module
    wire [BUS_WIDTH-1:0] playerRGB, enemy1RGB, enemy2RGB, borderRGB, hpbarRGB, attackIndRGB, mapRGB;
    
    // buffer    
    reg [BUS_WIDTH-1:0] dataInReg;
    
    always @(posedge clk)
        if (gameState == 0 || gameState == 2)
            debugOutput = tickCount;
        else if (gameState == 1)
            debugOutput = attackDamage;
        else 
            debugOutput = 16'hffff;

    // next states (state, i, j) calculation
    always @(*) begin
        // render + game loop state
        if (state == 0) 
            nextState = 1;
        else if (state == 1)
            nextState = (j == WIDTH-1 && i == HEIGHT-1) ? 2 : 1;
        else if (state == 2)
            nextState = onGameClk ? 0 : 2;

        nextWriteAddr = (state == 2'b00 || state == 2'b01) ? 11'd640*{9'b0, i} + j : 0;
        nextWe = gameState != 7 && (state == 2'b00 || state == 2'b01);

        // render scan state
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
        // -- use in clk instead
        // if (!pGameClk && gameClk) begin
            // if (gameState == 0) begin
            //     if (tickCount == 300) begin
            //         nextGameState = 1;
            //         nextTickCount = 0;
            //     end
            //     else 
            //         nextTickCount = tickCount + 1;
            // end 
        // end
        // if (!pTransmit && transmit) begin
        //     nextGameState = 0;
        // end
    end

    // state assignment
    always @(posedge clk) begin
        state <= nextState;
        i <= ni;
        j <= nj;
        we <= nextWe;
        writeAddr <= nextWriteAddr;

        // tickCount <= nextTickCount;
        // gameState <= nextGameState;

        if (state == 0) begin
            dataInReg <= 0;
            isHit <= 0;
            i <= 0;
            j <= 0;
            hp <= isHit ? (hp <= 3 ? 0 : hp - 3) : hp;
            hitCD = hitCD == 0 ? 0 : hitCD - 1;
        end
        else if (state == 1) begin

            if (gameState == 0) begin // dodge


                if (|playerRGB) dataInReg <= playerRGB;
                else if (|enemy1RGB) dataInReg <= enemy1RGB;
                else if (|enemy2RGB) dataInReg <= enemy2RGB;
                else if (|borderRGB) dataInReg <= borderRGB;
                else if (|hpbarRGB) dataInReg <= hpbarRGB;
                // else if (|attackIndRGB) dataInReg <= attackIndRGB;
                else dataInReg <= 0;
                
                if (|playerRGB && (|enemy1RGB || |enemy2RGB) && ~isHit && ~|hitCD) begin
                    isHit <= 1;
                    hitCD <= 6'd60;
                end



            end
            else if(gameState == 1) begin // attack

                if (|playerRGB) dataInReg <= playerRGB;
                // else if (|enemy1RGB) dataInReg <= enemy1RGB;
                // else if (|enemy2RGB) dataInReg <= enemy2RGB;
                else if (|borderRGB) dataInReg <= borderRGB;
                else if (|hpbarRGB) dataInReg <= hpbarRGB;
                else if (|attackIndRGB) dataInReg <= attackIndRGB;
                else dataInReg <= 0; // some how ?
                // else dataInReg <= 0;
                
                // else 
            end
            else if (gameState == 7) begin // menu
                dataInReg <= (i/4+j/4)%2 == 0 ? 5'd1 : 5'd2;
            end
            else if (gameState == 2) begin // map
                if (|mapRGB) dataInReg <= mapRGB;
                else dataInReg <= 0;
            end
        end

        // game state
        if (gameClk && !pGameClk) begin
            if (enemyHp == 0 ) begin // enemy dead --> go to map
                // reset game and go to map
                enemyHp <= 100;
                gameState <= 2;
            end
            else if (hp == 0) begin // dead --> go to main
                hp <= 100;
                enemyHp <= 100;
                gameState <= 7;
            end
            else if (gameState == 0) begin
                if (tickCount == 300) begin
                    gameState <= 1; // attack phase
                    tickCount <= 0;
                end
                else 
                    tickCount <= tickCount + 1;
            end
            // else if (gameState == 2) begin 
            //     if (tickCount == 400) begin
            //         gameState <= 0; // dodge phase
            //         tickCount <= 0;
            //     end
            //     else 
            //         tickCount <= tickCount + 1;
            // end
        end
        // cheat logic




        // attack logic
        if (!pTransmit && transmit) begin
            if (tx_buf == 8'h20)
                if (gameState == 1) begin
                    enemyHp <= enemyHp <= attackDamage ? 0 : enemyHp - attackDamage;
                    gameState <= 0;
                    tickCount <= 0;
                end
                else if (gameState == 7) begin
                    gameState <= 0;
                end
            else if (tx_buf == 8'h58) // X
                enemyHp <= 0; 
        end
        // encounter enemy
        if (!pEncounter && encounter) begin
            gameState <= 0;
        end

        pEncounter <= encounter;
        pGameClk <= gameClk;
        pTransmit <= transmit;
    end

    // keyboard logic stuff
    wire gameTransmit = (transmit && gameState == 0);
	always @(negedge gameTransmit) begin
		if (tx_buf == 8'h57) cy = cy - 10; // w 
		else if (tx_buf == 8'h53) cy = cy + 10; // s
		else if (tx_buf ==  8'h41) cx = cx - 10; // a
		else if (tx_buf ==  8'h44) cx = cx + 10; // d

        if (cx <= 240) cx = 240;
        if (cx >= 400) cx = 400;
        if (cy <= 240) cx = 240;
        if (cy >= 420) cx = 420;
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

    attack_ind #(.BUS_WIDTH(BUS_WIDTH)) attackInd1(
        clk,
        gameClk,
        j,
        i,
        attackIndRGB,
        attackDamage
    );

    // only trigger when gameState = 2
    wire transmitMap = transmit && gameState == 2;
    map #(.BUS_WIDTH(BUS_WIDTH)) mapModule(
        clk,
        transmitMap,
        tx_buf,
        j,
        i,
        mapRGB,
        encounter
    );


    hpbar hpbar1(j, i, hp, maxHp, enemyHp, maxEnemyHp, hpbarRGB);

    // ================================= end model section 

    assign dataIn = dataInReg;

endmodule
