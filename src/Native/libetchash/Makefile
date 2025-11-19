CFLAGS += -g -Wall -c -fPIC -O2 -MMD -MP -Wno-pointer-sign -Wno-char-subscripts -Wno-unused-variable -Wno-unused-function -Wno-strict-aliasing -Wno-discarded-qualifiers -Wno-unused-const-variable $(CPU_FLAGS) $(HAVE_FEATURE)
CXXFLAGS += -g -Wall -fPIC -fpermissive -O2 -MMD -MP -Wno-char-subscripts -Wno-unused-variable -Wno-unused-function -Wno-strict-aliasing -Wno-sign-compare -std=c++11 $(CPU_FLAGS) $(HAVE_FEATURE)
LDFLAGS += -shared
TARGET = libetchash.so

OBJECTS = internal.o io.o io_posix.o sha3.o exports.o

DEPS = $(OBJECTS:.o=.d)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(LDFLAGS) -o $@ $^ $(LDLIBS)

-include $(DEPS)

.PHONY: clean

clean:
	$(RM) $(TARGET) $(OBJECTS) $(DEPS)
