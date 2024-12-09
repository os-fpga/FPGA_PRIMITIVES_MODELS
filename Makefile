# Makefile for running simulations of designs using Iverilog

# Design name input (change this to your desired design name)
DESIGN_NAME ?= DSP38

# Directories
FLIST ?= ./sim_models/verilog/$(DESIGN_NAME)
SRC_DIR ?= ./sim_models/verilog
TB_DIR ?= ./tb/$(DESIGN_NAME)
SIM_DIR = sim
SIM_RESULTS_DIR = sim_results

# Source and testbench files
SRC_FILES = $(wildcard $(SRC_DIR)/$(DESIGN_NAME).v)
TB_FILES = $(wildcard $(TB_DIR)/*.v $(TB_DIR)/*.sv)
COMPILE_ARGS_FILE = $(TB_DIR)/compile_args.txt


# Check if COMPILE_ARGS_FILE exists, and set COMPILE_ARGS accordingly
ifeq ($(wildcard $(COMPILE_ARGS_FILE)),)
    COMPILE_ARGS :=
else
    COMPILE_ARGS := -D$(shell cat $(COMPILE_ARGS_FILE))
endif

# Simulation executable
SIM_EXECUTABLE = $(SIM_DIR)/$(DESIGN_NAME)_sim

# Simulation command
#SIM_COMMAND = iverilog -g2012 -o $(SIM_EXECUTABLE) $(COMPILE_ARGS) $(SRC_FILES) $(TB_FILES) 

SIM_COMMAND = iverilog -g2012 -o $(SIM_EXECUTABLE) -DTIMED_SIM $(COMPILE_ARGS) $(TB_FILES)  $(FLIST) 

.PHONY: all clean

all: $(SIM_EXECUTABLE)
	@echo "Simulation executable created: $(SIM_EXECUTABLE)"
	@echo "Running simulation..."
	@mkdir -p $(SIM_RESULTS_DIR)
	@cd $(SIM_DIR) && ./$(DESIGN_NAME)_sim > ../$(SIM_RESULTS_DIR)/$(DESIGN_NAME)_sim_out.log

$(SIM_EXECUTABLE): $(SRC_FILES) $(TB_FILES)
	@mkdir -p $(SIM_DIR)
	$(SIM_COMMAND)

clean:
	@echo "Cleaning up..."
	@rm -rf $(SIM_DIR) $(SIM_RESULTS_DIR)


