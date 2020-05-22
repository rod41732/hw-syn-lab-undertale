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

    localparam NUM_OF_ENEMY = 5;


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
    reg isHit = 0;
    reg [5:0] hitCD = 0;
    reg [7:0] hp = 50, maxHp = 50, enemyHp = 100, maxEnemyHp = 100; // HPs
    wire [7:0] attackDamage; 

    reg [3:0] gameState = 7;
    reg [15:0] tickCount = 0; // for countdown purpose or something
    reg hasPlayed = 0;
    // ========= wirings
    // RGB data from module
    wire [BUS_WIDTH-1:0] playerRGB, borderRGB, hpbarRGB, attackIndRGB, mapRGB, gameoverRGB;
    
    wire [BUS_WIDTH-1:0] enemyRGB[NUM_OF_ENEMY-1:0], mergeRGB[NUM_OF_ENEMY-1:0];
    reg [NUM_OF_ENEMY-1:0] hitEnemy;

    assign mergeRGB[0] = enemyRGB[0];
    genvar x;
    generate
        for (x = 1; x < NUM_OF_ENEMY; x = x+1) begin
            assign mergeRGB[x] = |mergeRGB[x-1] ? mergeRGB[x-1] : enemyRGB[x];
        end
    endgenerate

    // buffer    
    reg [BUS_WIDTH-1:0] dataInReg;
    
    // debug stuff
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
        nextWe = (gameState != 7 || hasPlayed) && (state == 0 || state == 1);

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
        
    end


    
    // hit detection
        generate
            for (x=0; x<NUM_OF_ENEMY; x = x+1) begin
                always @(*) begin
                    if (|playerRGB && |enemyRGB[x]) begin
                        hitEnemy[x] = 1;
                        // hp <= hp - 5;
                    end
                    else hitEnemy[x] = 0;
                end
            end
        endgenerate

    wire [2:0] hitCount;
    count_one #(.IN_BITS(5)) countHit(hitEnemy, hitCount);

    // state assignment
    always @(posedge clk) begin
        state <= nextState;
        i <= ni;
        j <= nj;
        we <= nextWe;
        writeAddr <= nextWriteAddr;

        if (state == 0) begin
            dataInReg <= 0;
            // isHit <= 0;
            i <= 0;
            j <= 0;
            // hp <= isHit ? (hp <= 3 ? 0 : hp - 3) : hp;
            // hitCD = hitCD == 0 ? 0 : hitCD - 1;
        end
        else if (state == 1) begin

            if (gameState == 0) begin // dodge
                if (|playerRGB) dataInReg <= playerRGB;
                else if (|mergeRGB[NUM_OF_ENEMY-1]) dataInReg <= mergeRGB[NUM_OF_ENEMY-1];
                else if (|borderRGB) dataInReg <= borderRGB;
                else if (|hpbarRGB) dataInReg <= hpbarRGB;
                // else if (|attackIndRGB) dataInReg <= attackIndRGB;
                else dataInReg <= 0;
            end
            else if(gameState == 1) begin // attack

                if (|borderRGB) dataInReg <= borderRGB;
                else if (|hpbarRGB) dataInReg <= hpbarRGB;
                else if (|attackIndRGB) dataInReg <= attackIndRGB;
                else dataInReg <= 0; // some how ?
                // else dataInReg <= 0;
            end
            else if (gameState == 7 && hasPlayed) begin // death menu
                if (|gameoverRGB) dataInReg <= gameoverRGB;
                else dataInReg <= 0;
            end
            else if (gameState == 2) begin // map
                if (|mapRGB) dataInReg <= mapRGB;
                else dataInReg <= 0;
            end
        end


        hp <= hp >= hitCount * 5 ? hp - hitCount*5 : 0;

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
        end

        // key press logic
        if (!pTransmit && transmit) begin
            if (tx_buf == 8'h20)
                if (gameState == 1) begin
                    enemyHp <= enemyHp <= attackDamage ? 0 : enemyHp - attackDamage;
                    gameState <= 0;
                    tickCount <= 0;
                end
                else if (gameState == 7) begin
                    hasPlayed <= 1;
                    gameState <= 1;
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

    // ============================== model section
    player #(.BUS_WIDTH(BUS_WIDTH)) playerModel(
        clk,
        transmit,
        tx_buf,
        gameState,
        j,
        i,
        playerRGB
    );

    // enemy #(.COLOR_WIDTH(BUS_WIDTH)) enemy1(
    reg [15:0] salts[3:0];
    initial begin
        salts[0] = 1353;
        salts[1] = 5012;
        salts[2] = 4272;
        salts[3] = 7622;
        salts[4] = 3222;
    end
    
    

    generate
        for (x = 0; x < NUM_OF_ENEMY; x = x+1) begin
            enemy #(.COLOR_WIDTH(BUS_WIDTH), .seed(3441)) enemyX(clk, gameClk, gameState, salts[x], hitEnemy[x], j, i, enemyRGB[x]);
        end
    endgenerate
    
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

    gameover #(.BUS_WIDTH(BUS_WIDTH)) gameoverDialog(j, i, gameoverRGB);
    // ================================= end model section 

    assign dataIn = dataInReg;

endmodule
