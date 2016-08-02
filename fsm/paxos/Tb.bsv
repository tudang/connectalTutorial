package Tb;

typedef enum { IDLE, PHASE1A, PHASE1B, PHASE2A, PHASE2B, FINISH } State deriving (Bits, Eq);

(* synthesize *)
module mkTb (Empty);

	Reg#(State) state <- mkReg(IDLE);
	Reg#(Bool) init <- mkReg(False);
	Reg#(Bool) recv1b <- mkReg(False);
	Reg#(Bool) recv2b <- mkReg(False);
	Reg#(int) count1b <- mkReg(0);
	Reg#(int) count2b <- mkReg(0);
	Reg#(int) quorum <- mkReg(2);

	rule stateIdle ( state == IDLE );
		if (!init) begin
			$display("Start phase 1");
			init <= True;
			state <= PHASE1A;
		end
		else if (recv1b) begin
			state <= PHASE1B;
		end
		else if (recv2b) begin
			state <= PHASE2B;
		end
	endrule

	rule statePhase1A (state == PHASE1A);
		$display("Sent Phase1A messages");
		state <= IDLE;
		recv1b <= True;
		recv2b <= False;
	endrule

	rule statePhase1B (state == PHASE1B);
		$display("Received Phase1B messages");
		if (count1b == quorum)
			state <= PHASE2A;
		else begin
			state <= IDLE;
			count1b <= count1b + 1;
		end
	endrule

	rule  statePhase2A (state == PHASE2A);
		$display("Sent Phase2A messages");
		state <= IDLE;
		recv1b <= False;
		recv2b <= True;
	endrule

	rule statePhase2B (state == PHASE2B);
		$display("Received Phase2B messages");
		if (count2b == quorum)
			state <= FINISH;
		else begin
			state <= IDLE;
			count2b <= count2b + 1;
		end
	endrule

	rule stateFinish (state == FINISH);
		$display("Paxos has finished");
		$finish;
	endrule
endmodule
endpackage