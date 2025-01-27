RM:=rm -rf

NAME:=HigherLower

CC:=gcc
CC_FLAGS:=-c -g

LD:=gcc
LD_FLAGS:=#-lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 

INC_DIR:=include
SRC_DIR:=src
OBJ_DIR:=objs

INC_EXT:=inc
SRC_EXT:=asm
OBJ_EXT:=obj

INC_FILES:=$(wildcard $(INC_DIR)/*.$(INC_EXT))
SRC_FILES:=$(wildcard $(SRC_DIR)/*.$(SRC_EXT))
OBJ_FILES:=$(SRC_FILES:$(SRC_DIR)/%.$(SRC_EXT)=$(OBJ_DIR)/%.$(OBJ_EXT))

build: $(NAME)

$(NAME): $(OBJ_FILES)
	@echo Linking $@
	@$(LD) -o $@ $^ $(LD_FLAGS) 

$(OBJ_DIR)/%.$(OBJ_EXT):$(SRC_DIR)/%.$(SRC_EXT)
	@echo Assembling $(notdir $^) into $(notdir $@)
	@mkdir -p $(dir $@)
	@$(CC) -o $@ $^ $(CC_FLAGS)

start: build
	./$(NAME)

clean:
	@$(RM) $(OBJ_DIR)

wipe: clean
	@$(RM) $(NAME)

.PHONY: build start clean wipe
