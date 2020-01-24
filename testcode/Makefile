#

ARMCC=arm-none-eabi-gcc
CCFLAGS=-O1 -march=armv2
ARMLD=arm-none-eabi-ld
SSFLAGS=-march=armv2
LDFLAGS=--script ld.script

TEST_S=start.s
TEST_C=test.c

.c.o:
	$(ARMCC) $(CCFLAGS) -c $*.c

.s.o:
	$(ARMCC) $(SSFLAGS) -c $*.s

test.arm: $(TEST_S:.s=.o) $(TEST_C:.c=.o)
	$(ARMLD) $(LDFLAGS) -o test.arm $(TEST_S:.s=.o) $(TEST_C:.c=.o)

