package HelloALU;

typedef enum{Mul, Div, Add, Sub, And, Or, Pow} AluOps deriving (Eq, Bits);

interface Power;
  method Action setOperands(Int#(32) a, Int#(32) b);
  method Int#(32) getPower();
endinterface

module mkPower(Power);
  Reg#(Bool) resultValid <- mkReg(False);
  Reg#(Int#(32)) regA <- mkReg(0);
  Reg#(Int#(32)) regB <- mkReg(0);
  Reg#(Int#(32)) result <- mkReg(1);

  rule calcPower (regB > 0);
    regB <= regB - 1;
    result <= result * regA;
  endrule

  rule calcDone (regB == 0 && !resultValid);
    resultValid <= True;
  endrule

  method Action setOperands(Int#(32) a, Int#(32) b);
    regA <= a;
    regB <= b;
    result <= 1;
    resultValid <= False;
  endmethod

  method Int#(32) getPower() if(resultValid);
    return result;
  endmethod

endmodule

interface HelloALU;
  method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
  method ActionValue#(Int#(32)) getResult();
endinterface

module mkSimpleALU (HelloALU);
  Reg#(Int#(32)) regA <- mkReg(0);
  Reg#(Int#(32)) regB <- mkReg(0);
  Reg#(Int#(32)) result <- mkReg(0);
  Reg#(AluOps) currentOp <- mkReg(Mul);
  Reg#(Bool) gotOperands <- mkReg(False);
  Reg#(Bool) gotResult <- mkReg(False);

  Power pow <- mkPower();

  rule calculate (gotOperands);
    Int#(32) imm = 0;
    case(currentOp)
      Mul: imm = regA * regB;
      Div: imm = regA / regB;
      Add: imm = regA + regB;
      Sub: imm = regA - regB;
      And: imm = regA & regB;
      Or: imm = regA | regB;
      Pow: imm = pow.getPower();
    endcase
    result <= imm;
    gotOperands <= False;
    gotResult <= True;
  endrule

  method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b) if(!gotOperands); 
    regA <= a;
    regB <= b;
    currentOp <= op;
    gotOperands <= True;
    gotResult <= False;
    if (op == Pow) pow.setOperands(a, b);
  endmethod

  method ActionValue#(Int#(32)) getResult() if(gotResult);
    return result;
  endmethod

endmodule

module mkALUTestbench(Empty);
HelloALU uut <- mkSimpleALU();
Reg#(UInt#(8)) testState <- mkReg(0);

rule checkMul (testState == 0);
  uut.setupCalculation(Mul, 4,5);
  testState <= testState + 1; endrule
  
rule checkDiv (testState == 2); 
  uut.setupCalculation(Div, 12,4); 
  testState <= testState + 1; 
endrule 

rule checkAdd (testState == 4); 
  uut.setupCalculation(Add, 12,4); 
  testState <= testState + 1; 
endrule

 rule checkSub (testState == 6);
  uut.setupCalculation(Sub, 12,4);
  testState <= testState + 1;
 endrule

 rule checkAnd (testState == 8);
  uut.setupCalculation(And, 32'hA,32'hA);
  testState <= testState + 1;
 endrule

 rule checkOr (testState == 10);
  uut.setupCalculation(Or, 32'hA,32'hA);
  testState <= testState + 1;
 endrule

 rule checkPow (testState == 12);
  uut.setupCalculation(Pow, 2, 12);
  testState <= testState + 1;
 endrule

 rule printResults (unpack(pack(testState)[0]));
  $display("Result: %d", uut.getResult());
  testState <= testState + 1;
 endrule

 rule endSim (testState == 14);
  $finish();
 endrule

  endmodule

endpackage

