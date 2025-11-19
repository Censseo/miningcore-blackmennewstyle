CFLAGS += -g -Wall -c -fPIC -O2 -MMD -MP -Wno-pointer-sign -Wno-char-subscripts -Wno-unused-variable -Wno-unused-function -Wno-strict-aliasing -Wno-discarded-qualifiers -Wno-unused-const-variable $(CPU_FLAGS) 
CXXFLAGS += -g -Wall -fPIC -fpermissive -O2 -MMD -MP -Wno-char-subscripts -Wno-unused-variable -Wno-unused-function -Wno-strict-aliasing -Wno-sign-compare -std=c++11 $(CPU_FLAGS)
LDFLAGS += -shared
TARGET = libkawpow.so

OBJECTS = ethash/ethash.o keccak/keccak.o keccak/keccakf800.o keccak/keccakf1600.o ethash/managed.o ethash/primes.o ethash/progpow.o exports.o

DEPS = $(OBJECTS:.o=.d)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(LDFLAGS) -o $@ $^ $(LDLIBS)

-include $(DEPS)

.PHONY: clean

clean:
	$(RM) $(TARGET) $(OBJECTS) $(DEPS)
