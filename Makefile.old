
# DIRS

RTL_DIR = rtl
TB_DIR  = tb
OUT_DIR = /tmp/$(USER)/vcs
SYN_DIR = $(OUT_DIR)/synth


# TOOLS

VCS = vcs
DC  = dc_shell
DV  = design_vision


# FILES

SRCS = $(wildcard $(RTL_DIR)/*.sv)
TBS  = $(wildcard $(TB_DIR)/*_tb.sv)

TEST_NAMES = $(patsubst $(TB_DIR)/%_tb.sv,%,$(TBS))
SIMVS = $(patsubst %,$(OUT_DIR)/%/simv,$(TEST_NAMES))


# DEFAULT TOP (override via make TOP=...)

TOP ?= ALU


# VCS FLAGS

VCS_FLAGS = -sverilog -timescale=1ns/1ps -debug_access+all -kdb -lca


# ALL

all: $(SIMVS)


# BUILD SIM

$(OUT_DIR)/%:
	mkdir -p $@

$(OUT_DIR)/%/simv: $(TB_DIR)/%_tb.sv $(SRCS)
	@mkdir -p $(OUT_DIR)/$*
	$(VCS) $(VCS_FLAGS) $^ -o $@


# RUN

run: all
	@for t in $(TEST_NAMES); do \
		echo "Running $$t..."; \
		$(OUT_DIR)/$$t/simv > $(OUT_DIR)/$$t/run.log; \
	done

run-%: $(OUT_DIR)/%/simv
	@echo "Running $*..."
	@cd $(OUT_DIR)/$* && ./simv > run.log


# SYNTHESIS (Design Compiler)

define DC_SCRIPT
read_verilog $(SRCS)
current_design $(TOP)
link

# clock simples (ajuste conforme seu design)
create_clock -period 10 clk

compile

# outputs
write -format verilog -hierarchy -output $(SYN_DIR)/$(TOP)/$(TOP).v
write -format ddc -output $(SYN_DIR)/$(TOP)/$(TOP).ddc

report_area  > $(SYN_DIR)/$(TOP)/area.rpt
report_timing > $(SYN_DIR)/$(TOP)/timing.rpt

exit
endef

synth:
	@mkdir -p $(SYN_DIR)/$(TOP)
	@echo "$$DC_SCRIPT" > $(SYN_DIR)/$(TOP)/run.tcl
	$(DC) -f $(SYN_DIR)/$(TOP)/run.tcl | tee $(SYN_DIR)/$(TOP)/synth.log


# VIEW (Design Vision)

view-all: synth
	@echo "Opening full schematic for $(TOP)..."
	$(DV) -f $(SYN_DIR)/$(TOP)/run.tcl &

view-module: synth
	@echo "Opening module view for $(TOP)..."
	$(DV) -f $(SYN_DIR)/$(TOP)/run.tcl &


# CLEAN
clean:
	rm -rf $(OUT_DIR)
	rm -rf csrc simv simv.daidir simv.vdb ucli.key
	rm -rf *.vpd *.vcd *.log *.fsdb *.key
	rm -rf DVEfiles verdiLog novas.* urgReport
	rm -rf AN.DB

.PHONY: all run clean run-% synth view-all view-module
