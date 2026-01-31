# Makefile for Lambda Calculus Evaluator

# Directories
SRC_DIR = src
BIN_DIR = bin
TEST_DIR = tests

# Compiler settings
GNATMAKE = gnatmake
GNATFLAGS = -aI$(SRC_DIR) -aO$(BIN_DIR)
GNATBIND_FLAGS = 
GNATLINK_FLAGS = -o $(BIN_DIR)/lambda

# Source files
MAIN_SOURCE = $(SRC_DIR)/main.adb
SOURCES = $(wildcard $(SRC_DIR)/*.adb) $(wildcard $(SRC_DIR)/*.ads)

# Test files
TEST_FILES = $(wildcard $(TEST_DIR)/*.l)

# Target executable
TARGET = $(BIN_DIR)/lambda

# Default target
all: $(TARGET)

# Build target
$(TARGET): $(SOURCES) | $(BIN_DIR)
	$(GNATMAKE) -D $(BIN_DIR) $(SRC_DIR)/main.adb -o $(TARGET)

# Create bin directory if it doesn't exist
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Clean build artifacts
clean:
	rm -rf $(BIN_DIR)
	rm -f $(SRC_DIR)/*.ali $(SRC_DIR)/*.o
	rm -f *.ali *.o

# Run the REPL
run: $(TARGET)
	$(TARGET)

# Test with all test files
test: $(TARGET)
	@echo "Running tests..."
	@for test_file in $(TEST_FILES); do \
		echo ""; \
		echo "=== Testing: $$test_file ==="; \
		$(TARGET) < $$test_file; \
	done

# Test a specific file
test-file: $(TARGET)
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make test-file FILE=tests/identity.l"; \
	else \
		echo "Testing: $(FILE)"; \
		$(TARGET) < $(FILE); \
	fi

# Help
help:
	@echo "Lambda Calculus Evaluator - Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all        - Build the project (default)"
	@echo "  clean      - Remove build artifacts"
	@echo "  run        - Run the interactive REPL"
	@echo "  test       - Run all test files in $(TEST_DIR)/"
	@echo "  test-file  - Run a specific test file (usage: make test-file FILE=tests/identity.l)"
	@echo "  help       - Show this help message"

.PHONY: all clean run test test-file help
