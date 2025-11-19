CFLAGS += -g -Wall -c -fPIC -O3 -Wno-format -fomit-frame-pointer $(CPU_FLAGS) -march=native 
CXXFLAGS += -g -Wall -fPIC -fpermissive -O3 -Wno-format -fomit-frame-pointer -std=c++11 $(CPU_FLAGS) -march=native 
LDFLAGS += -shared
LDLIBS = -lpthread
TARGET = libcortexcuckoocycle.so

OBJECTS = crypto/blake2b-ref.o cortexcuckoocycle.o exports.o

DEPS = $(OBJECTS:.o=.d)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(LDFLAGS) -o $@ $^ $(LDLIBS)

-include $(DEPS)

.PHONY: clean

clean:
	$(RM) $(TARGET) $(OBJECTS) $(DEPS)
