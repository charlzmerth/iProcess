int array[100] = { 4, 5, 6 };

char *foo = "Hi!";

int x = 0x12;
volatile unsigned char *debug_port;

int main() {
    int register i;
    debug_port = (unsigned char *) 0xffff0010; // LED
    (*debug_port) = 1;
    debug_port = (unsigned char *) 0xffff0000; // serial console
    int result = 0;
    for (i =0; i < 10; i++) {
        (*debug_port) = (unsigned char) i;
        array[i] = array[i] + i;
        result += array[i];
    }
    (*debug_port) = result;
    debug_port = (unsigned char *) 0xffff0010;
    (*debug_port) = 0;

    return result;
}
