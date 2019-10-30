package HelloBluespec;

	interface HelloBluespec;
		(* always_enabled, always_ready *) method Bool led();
	endinterface

	module mkHelloBluespec(HelloBluespec);

		Reg #(UInt #(25)) counter <- mkReg(0);
		Reg #(Bool) status <- mkReg(False);

		rule helloDisplay (counter == 25'h1ffffff);
			$display("(%0d) Hello World!", $time);
			status <= !status;
		endrule

		rule countUp;
			if(counter == 25'h1ffffff) counter <= 0;
			else counter <= counter + 1;
		endrule

		method Bool led();
			return status;
		endmethod

	endmodule

	module mkHelloTestbench(Empty);
		Reg #(UInt#(32)) counter <- mkReg(0);
		Reg #(Bool) lastCycleStatus <- mkReg(False);

		HelloBluespec hello <- mkHelloBluespec();

		rule finishSim (counter == 200000000);
			$finish();
		endrule

		rule countUp;
			counter <= counter + 1;
		endrule

		rule checkLedStatus;
			lastCycleStatus <= hello.led();
			if (lastCycleStatus == True && hello.led() == False) $display("Led aus.");
			else if (lastCycleStatus == False && hello.led() == True) $display("Led an.");
		endrule

	endmodule
endpackage
