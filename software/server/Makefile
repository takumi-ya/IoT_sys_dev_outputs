#
TARGET = sample_server

#
CROSS_COMPILE = arm-linux-gnueabihf-
CFLAGS = -Dsoc_cv_av -g -Wall -I ${SOCEDS_DEST_ROOT}/ip/altera/hps/altera_hps/hwlib/include -I ${SOCEDS_DEST_ROOT}/ip/altera/hps/altera_hps/hwlib/include/soc_cv_av -I/home/iot22/include
LDFLAGS = -g -Wall -L/home/iot22/lib -lmicrohttpd
CC = $(CROSS_COMPILE)gcc-5
ARCH= arm

build: $(TARGET)
$(TARGET): main.o
	$(CC) $(LDFLAGS) $^ -o $@

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~