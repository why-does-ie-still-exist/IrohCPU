module IrohCPU(input clk, input memclk, input rst);
    reg [7:0] ab;
    reg [7:0] bb;
    reg [7:0] cb;
    reg [7:0] db;
    reg [7:0] pc;
    reg [7:0] sp;
    reg zf;
    reg cf;
    reg of;
    reg sf;

    reg [7:0] firstArg;
    reg [7:0] secondArg;
    reg isAdding;
    wire overflow, unsignedOverflow, isZero, sign;
    wire [7:0] result;

    alu internalALU( .firstArg(firstArg), .secondArg(secondArg), .isAdding(isAdding),
    .overflow(overflow), .unsignedOverflow(unsignedOverflow), .isZero(isZero),
    .sign(sign), .result(result) );

    reg [7:0] addr;
    reg enable;
    reg wEnable;
    reg [15:0] newWord;
    wire [15:0] wordOut;

    internal_mem aMemory(.clk(memclk), .addr(addr), .enable(enable),
    .wEnable(wEnable), .newWord(newWord), .wordOut(wordOut));

    parameter FETCH = 2'b00, DECODE = 2'b01, EX1 = 2'b10, EX2 = 2'b11;

    reg [1:0] state;
    reg [1:0] nextstate;
    reg [15:0] instruction;

    always @ * begin
        case(state)
            FETCH : nextstate = DECODE;
            DECODE : nextstate = EX1;
            EX1 : nextstate = EX2;
            EX2 : nextstate = FETCH;
        endcase
    end

    reg [7:0] destreg;
    reg [7:0] srcreg;
    always @ * begin
        case(instruction[15:14])
            2'b00 : begin
                case(instruction[13:12])
                    2'b00 : destreg = ab;
                    2'b01 : destreg = bb;
                    2'b10 : destreg = cb;
                    2'b11 : destreg = db;
                endcase
                case(instruction[1:0])
                    2'b00 : srcreg = ab;
                    2'b01 : srcreg = bb;
                    2'b10 : srcreg = cb;
                    2'b11 : srcreg = db;
                endcase
            end
            2'b01, 2'b11 : begin
                case(instruction[13:12])
                    2'b00 : destreg = ab;
                    2'b01 : destreg = bb;
                    2'b10 : destreg = cb;
                    2'b11 : destreg = db;
                endcase
                srcreg = 'x;
            end
            2'b10 : begin
                case(instruction[13:12])
                    2'b00 : srcreg = ab;
                    2'b01 : srcreg = bb;
                    2'b10 : srcreg = cb;
                    2'b11 : srcreg = db;
                endcase
                destreg = 'x;
            end
        endcase    
    end

    always @(posedge clk) begin
        if(rst) begin
            ab <= '0;
            bb <= '0;
            cb <= '0;
            db <= '0;
            pc <= '0;
            sp <= '0;
            zf <= '0;
            cf <= '0;
            of <= '0;
            sf <= '0;
            wEnable <= '0;
            enable <= 1'b1;
            firstArg <= '0;
            secondArg <= '0; //this makes sure the pc is set to 0 during the first fetch.
            isAdding <= 1'b1;
            addr <= '0;
            pc <= '0;
            state <= FETCH;
        end else begin
            case(state)
                FETCH : begin
                    pc <= result;
                    addr <= result;
                end
                DECODE : begin
                    instruction <= wordOut;
                    if(wordOut[15:14] == 2'b01  | wordOut[15:14] == 2'b10) begin //if instruction has mem as source operand, fetch it.
                        addr <= wordOut[7:0];
                    end
                end
                EX1 : begin
                    $display("instruction %b",instruction[11:8]);
                    case(instruction[11:8])
                        4'b1000, 4'b1001 : begin //ADD/SUB
                            $display("adding or subbing");
                            isAdding <= ~instruction[8];
                            case (instruction[15:14])
                                2'b00 : begin
                                    $display("%b %b %b",instruction[15:14],destreg,srcreg);
                                    firstArg <= destreg;
                                    secondArg <= srcreg;
                                end
                                2'b01 : begin
                                    $display("%b %b %b",instruction[15:14],destreg,srcreg);
                                    firstArg <= destreg;
                                    secondArg <= wordOut[7:0]; //from mem in decode
                                end
                                2'b10 : begin
                                    $display("%b %b %b",instruction[15:14],destreg,srcreg);
                                    firstArg <= wordOut[7:0]; //from mem in decode
                                    secondArg <= srcreg;
                                end
                                2'b11 : begin
                                    $display("%b %b %b",instruction[15:14],destreg,instruction[7:0]);
                                    firstArg <= destreg;
                                    secondArg <= instruction[7:0];
                                end
                            endcase
                        end
                        4'b0000 : begin //MOV
                            case (instruction[15:14])
                                2'b00 : begin
                                    case (instruction[13:12])
                                        2'b00 : ab <= srcreg;
                                        2'b01 : bb <= srcreg;
                                        2'b10 : cb <= srcreg;
                                        2'b11 : db <= srcreg;
                                    endcase
                                end
                                2'b01 : begin
                                    case (instruction[13:12])
                                        2'b00 : ab <= wordOut[7:0]; //from mem in decode
                                        2'b01 : bb <= wordOut[7:0];
                                        2'b10 : cb <= wordOut[7:0];
                                        2'b11 : db <= wordOut[7:0];
                                    endcase
                                end
                                2'b10 : begin
                                    wEnable <= 1'b1;
                                    newWord <= {8'b0, srcreg};
                                end
                                2'b11 : begin
                                    case (instruction[13:12])
                                        2'b00 : ab <= instruction[7:0];
                                        2'b01 : bb <= instruction[7:0];
                                        2'b10 : cb <= instruction[7:0];
                                        2'b11 : db <= instruction[7:0];
                                    endcase
                                end
                            endcase
                        end
                        4'b0011 : begin

                        end
                        4'b0001 : begin //JMP
                            //Don't need to do anything in this phase
                        end
                        4'b0010 : begin //JEZ
                            //Don't need to do anything in this phase
                        end
                        4'b0011 : begin //GET
                            case (instruction[15:14])
                                2'b00 : begin
                                    case (instruction[1:0])
                                        2'b00 : addr <= ab;
                                        2'b01 : addr <= bb;
                                        2'b10 : addr <= cb;
                                        2'b11 : addr <= db;
                                    endcase
                                end
                                2'b01 : begin
                                    addr <= wordOut[7:0];
                                end
                            endcase
                        end
                        4'b0100 : begin //WRITE
                            case (instruction[15:14])
                                2'b00 : begin
                                    case (instruction[13:12])
                                        2'b00 : addr <= ab;
                                        2'b01 : addr <= bb;
                                        2'b10 : addr <= cb;
                                        2'b11 : addr <= db;
                                    endcase
                                end
                                2'b10 : begin
                                    addr <= wordOut[7:0];
                                end
                            endcase 
                            case (instruction[1:0])
                                        2'b00 : newWord <= {8'b0, ab};
                                        2'b01 : newWord <= {8'b0, bb};
                                        2'b10 : newWord <= {8'b0, cb};
                                        2'b11 : newWord <= {8'b0, db};
                            endcase
                            wEnable = 1'b1;
                        end
                    endcase
                end
                EX2 : begin
                    if(instruction[11:8] != 4'b0001 && instruction[11:8] != 4'b0010) begin // if not jump
                        case(instruction[11:8])
                            4'b1000, 4'b1001 : begin //ADD, SUB
                                $display("Result: %b", result);
                                case (instruction[13:12])
                                        2'b00 : ab <= result;
                                        2'b01 : bb <= result;
                                        2'b10 : cb <= result;
                                        2'b11 : db <= result;
                                endcase
                                zf = isZero;
                                cf = unsignedOverflow;
                                of = overflow;
                                sf <= sign;
                            end
                            4'b0000 : begin //MOV
                                wEnable = 1'b0;
                            end
                            4'b0011 : begin //GET
                                case (instruction[13:12])
                                        2'b00 : ab <= wordOut[7:0];
                                        2'b01 : bb <= wordOut[7:0];
                                        2'b10 : cb <= wordOut[7:0];
                                        2'b11 : db <= wordOut[7:0];
                                endcase
                            end
                            4'b0100 : begin //WRITE
                                wEnable = 1'b0;
                            end
                        endcase

                        firstArg <= pc;
                        secondArg <= 8'b1;
                        isAdding <= 1'b1;
                    end else begin // if is jump
                        case(instruction[11:8])
                            4'b0001 : begin
                                case(instruction[15:14])
                                    2'b00 : begin
                                        firstArg <= destreg;
                                        secondArg <= 0;
                                        isAdding <= 1'b1;
                                    end
                                    2'b01, 2'b10 : begin
                                        firstArg <= wordOut[7:0];
                                        secondArg <= 0;
                                        isAdding <= 1'b1;
                                    end
                                    2'b11 : begin
                                        firstArg <= instruction[7:0];
                                        secondArg <= 0;
                                        isAdding <= 1'b1;
                                    end
                                endcase
                            end
                            4'b0010 : begin
                                if(zf) begin
                                    case(instruction[15:14])
                                        2'b00 : begin
                                            firstArg <= destreg;
                                            secondArg <= 0;
                                            isAdding <= 1'b1;
                                        end
                                        2'b01, 2'b10 : begin
                                            firstArg <= wordOut[7:0];
                                            secondArg <= 0;
                                            isAdding <= 1'b1;
                                        end
                                        2'b11 : begin
                                            firstArg <= instruction[7:0];
                                            secondArg <= 0;
                                            isAdding <= 1'b1;
                                        end
                                    endcase
                                end else begin
                                    firstArg <= pc;
                                    secondArg <= 8'b1;
                                    isAdding <= 1'b1;
                                end
                            end
                        endcase
                    end
                end
            endcase
            state <= nextstate;
        end
    end

endmodule