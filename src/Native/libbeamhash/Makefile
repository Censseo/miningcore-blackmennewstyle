CFLAGS += -g -Wall -c -fPIC -O2 -MMD -MP -Wno-pointer-sign -Wno-char-subscripts -Wno-unused-variable -Wno-unused-function -Wno-strict-aliasing -Wno-discarded-qualifiers -Wno-unused-const-variable $(CPU_FLAGS) $(HAVE_FEATURE)
CXXFLAGS += -g -Wall -fPIC -fpermissive -O2 -funroll-loops -fomit-frame-pointer -Wno-char-subscripts -Wno-unused-variable -Wno-unused-function -Wno-strict-aliasing -Wno-sign-compare -std=c++11 $(CPU_FLAGS) $(HAVE_FEATURE)
LDFLAGS += -shared
TARGET = libbeamhash.so

OBJECTS = blake/blake2b.o beamHashIII_imp.o beamhashverify.o equihashR_imp.o exports.o 

DEPS = $(OBJECTS:.o=.d)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(LDFLAGS) -o $@ $^ $(LDLIBS)

-include $(DEPS)

.PHONY: clean

clean:
	$(RM) $(TARGET) $(OBJECTS) $(DEPS)
